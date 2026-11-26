import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../services/connection_manager.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/bot_desktop_session.dart';
import '../services/remote_workspace.dart';
import '../theme/hermes_theme.dart';
import '../widgets/bot_desktop_viewer.dart';
import '../../nextgen/data/chat_controller.dart';
import '../../nextgen/data/nextgen_gateway.dart';
import '../../nextgen/ui/chat_view.dart';
import '../../nextgen/ui/nextgen_scope.dart';
import 'chat_screen.dart';

/// Native Bot Mode workspace (`F11`): the bot roster, canonical bot chats,
/// per-bot routines, multi-bot rooms and the Bot Desktop (status, start/stop,
/// thumbnail, takeover lease and sandbox-image switch), scoped to [owner] and
/// [route]. All gateway calls go through the owner's fenced target so late
/// replies never land on a different account or profile.
class BotsScreen extends StatefulWidget {
  const BotsScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.connection,
    this.displayConnector,
    this.openBotChat,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;

  /// Opens the live screen for a `display.observe` ticket. Production dials
  /// the gateway's `/api/display/ws`; tests supply an in-memory screen.
  @visibleForTesting
  final BotDisplayConnector? displayConnector;

  /// Shows a bot's chat page. Production pushes it; tests inspect it.
  @visibleForTesting
  final Future<void> Function(BuildContext context, BotChatPage page)?
  openBotChat;

  @override
  State<BotsScreen> createState() => _BotsScreenState();
}

enum _BotsTab { roster, rooms, screen, routines }

class _BotsScreenState extends State<BotsScreen> with WidgetsBindingObserver {
  WorkspacePane? _pane;
  WorkspaceTarget? _target;
  Object? _account;
  Object _token = Object();

  // One counter per kind of read: only the newest request may land.
  int _roomsRequest = 0;
  int _routinesRequest = 0;
  int _screenRequest = 0;
  int _thumbnailRequest = 0;

  _BotsTab _tab = _BotsTab.roster;
  bool _loading = true;
  WorkspaceFailure? _failure;
  String? _errorDetail;

  // Roster
  List<BotRosterProfile> _roster = const [];
  bool _botModeProtocol = false;
  String? _installId;
  String _search = '';
  final _searchController = TextEditingController();

  // Rooms
  RoomCapabilities? _roomsCaps;
  List<RoomSummary> _rooms = const [];
  bool _roomsLoading = false;

  // Screen
  String? _screenProfile; // null = current row in roster
  DisplayStatus? _display;

  /// The take-over in progress: the live viewer and the lease it holds.
  BotDesktopSession? _session;

  /// The package install this screen started, with its output so far.
  _BotInstall? _install;
  void Function()? _installUnwatch;
  DisplayThumbnail? _thumbnail;
  ImageProvider? _thumbnailImage;
  bool _thumbnailSuppressed = false;
  Timer? _thumbnailTimer;
  bool _screenBusy = false;

  // Routines
  String? _routinesProfile; // null = _screenProfile or current
  List<RoutineJob> _routines = const [];
  String? _routinesScope;
  bool _routinesLoading = false;

  @override
  void initState() {
    super.initState();
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    ConnectionMutationBarrier.addListener(_onAccountChanged);
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next != _search && mounted) setState(() => _search = next);
    });
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant BotsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner || oldWidget.route != widget.route) {
      _closePaneAfterHandBack();
      _pane = null;
      _target = null;
      _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
      _cancelThumbnail();
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_onAccountChanged);
    _cancelThumbnail();
    _thumbnailImage?.evict();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _stopInstallWatch();
    _closePaneAfterHandBack();
    super.dispose();
  }

  /// Leaving never keeps the bot locked out: the lease is released on the
  /// pane it was taken on, and only then is that pane closed.
  void _closePaneAfterHandBack() {
    final pane = _pane;
    final session = _session;
    _session = null;
    if (session == null) {
      pane?.close();
      return;
    }
    session.removeListener(_onSessionChanged);
    unawaited(session.close().whenComplete(() => pane?.close()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // In the background the user can neither see nor drive the screen.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_endSession(BotDesktopClose.background));
    }
  }

  void _onSessionChanged() {
    // The viewer dropped or was evicted: the session has released the lease.
    if (_session?.isClosed == true) {
      unawaited(_endSession(_session!.closedBecause!));
    }
  }

  /// Ends the take-over (if any) and repaints the lease the gateway reports.
  Future<void> _endSession(BotDesktopClose because) async {
    final session = _session;
    if (session == null) return;
    _session = null;
    session.removeListener(_onSessionChanged);
    await session.close(because: because);
    if (!_ownsScreen(session.target, session.profile)) return;
    setState(() => _display = _display?.copyWith(lease: session.lease));
    unawaited(_loadScreen(session.target));
  }

  void _onAccountChanged() {
    if (ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      return;
    }
    _pane?.invalidate();
    _target = null;
    _cancelThumbnail();
    if (mounted) {
      setState(() {
        _loading = false;
        _failure = WorkspaceFailure.stale;
      });
    }
  }

  /// Swaps the decoded frame. The frame it replaces is dropped from the
  /// image cache once the new one has painted, so a 4 s poll keeps one frame
  /// in memory; nothing is written to disk.
  void _showThumbnail(Uint8List? bytes) {
    final previous = _thumbnailImage;
    _thumbnailImage = bytes == null
        ? null
        : ResizeImage.resizeIfNeeded(
            _thumbnailDecodeWidth,
            null,
            MemoryImage(bytes),
          );
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.evict());
    }
  }

  static const _thumbnailDecodeWidth = 1280;

  void _cancelThumbnail() {
    _thumbnailTimer?.cancel();
    _thumbnailTimer = null;
  }

  Future<WorkspaceTarget> _bound() async {
    final existing = _target;
    if (existing != null && existing.isCurrent) return existing;
    _pane?.close();
    final pane = _pane = widget.owner.pane();
    final bound = await pane.bind(widget.route);
    _target = bound;
    return bound;
  }

  Future<void> _load() async {
    final token = _token = Object();
    setState(() {
      _loading = true;
      _failure = null;
      _errorDetail = null;
    });
    try {
      final target = await _bound();
      if (!mounted || !identical(token, _token)) return;
      final roster = await target.botRoster(includeSessions: true);
      if (!mounted || !identical(token, _token)) return;
      setState(() {
        _roster = roster.profiles;
        _botModeProtocol = roster.botModeProtocol;
        _installId = roster.installId;
        _loading = false;
        _screenProfile ??= _roster.firstOrNull?.name;
        _routinesProfile ??= _screenProfile;
      });
      if (_tab == _BotsTab.rooms) unawaited(_loadRooms(target));
      if (_tab == _BotsTab.routines) unawaited(_loadRoutines(target));
      if (_tab == _BotsTab.screen) unawaited(_loadScreen(target));
    } on WorkspaceException catch (e) {
      if (!mounted || !identical(token, _token)) return;
      setState(() {
        _loading = false;
        _failure = e.reason;
      });
    } catch (_) {
      if (!mounted || !identical(token, _token)) return;
      setState(() {
        _loading = false;
        _failure = WorkspaceFailure.unavailable;
      });
    }
  }

  /// True while [target] is still this screen's gateway: the same
  /// connection, account and profile it was bound for. Every request captures
  /// its target (and its bot) before the first await and checks again after
  /// each one, so a late reply is dropped instead of landing on whatever is
  /// selected now.
  bool _owns(WorkspaceTarget target) =>
      mounted && identical(target, _target) && target.isCurrent;

  bool _ownsScreen(WorkspaceTarget target, String bot) =>
      _owns(target) && _screenProfile == bot;

  bool _ownsRoutines(WorkspaceTarget target, String bot) =>
      _owns(target) && _routinesProfile == bot;

  Future<void> _loadRooms(WorkspaceTarget target) async {
    final request = ++_roomsRequest;
    bool current() => request == _roomsRequest && _owns(target);
    setState(() => _roomsLoading = true);
    try {
      final caps = await target.roomCapabilities();
      if (!current()) return;
      final rooms = await target.roomList(limit: 50);
      if (!current()) return;
      setState(() {
        _roomsCaps = caps;
        _rooms = rooms;
        _roomsLoading = false;
      });
    } catch (e) {
      if (!current()) return;
      setState(() {
        _roomsLoading = false;
        _roomsCaps = null;
        _rooms = const [];
        _errorDetail = 'Could not load rooms: $e';
      });
    }
  }

  Future<void> _loadRoutines(WorkspaceTarget target) async {
    final bot = _routinesProfile;
    if (bot == null) return;
    final request = ++_routinesRequest;
    bool current() => request == _routinesRequest && _ownsRoutines(target, bot);
    setState(() => _routinesLoading = true);
    try {
      final result = await target.botRoutinesWithLegacyPause(bot);
      if (!current()) return;
      setState(() {
        _routines = result.jobs;
        _routinesScope = result.scoped;
        _routinesLoading = false;
      });
    } on WorkspaceException catch (e) {
      if (!current()) return;
      setState(() {
        _routinesLoading = false;
        _routines = const [];
        _errorDetail = 'Could not load routines: ${e.reason.name}';
      });
    } catch (_) {
      if (!current()) return;
      setState(() => _routinesLoading = false);
    }
  }

  Future<void> _loadScreen(WorkspaceTarget target) async {
    final bot = _screenProfile;
    if (bot == null) return;
    final request = ++_screenRequest;
    bool current() => request == _screenRequest && _ownsScreen(target, bot);
    try {
      final status = await target.displayStatus(bot);
      if (!current()) return;
      setState(() {
        _display = status;
        _thumbnailSuppressed = false;
      });
      if (status.running) {
        await _refreshThumbnail(target, bot);
        if (!current()) return;
        _scheduleThumbnail(target, bot);
      } else {
        _cancelThumbnail();
      }
    } on WorkspaceException catch (e) {
      if (!current()) return;
      setState(() {
        _display = null;
        _errorDetail = 'Bot Desktop: ${e.reason.name}';
      });
    } catch (_) {
      if (!current()) return;
      setState(() => _display = null);
    }
  }

  Future<void> _refreshThumbnail(WorkspaceTarget target, String bot) async {
    final request = ++_thumbnailRequest;
    try {
      final thumb = await target.displayThumbnail(bot);
      if (request != _thumbnailRequest || !_ownsScreen(target, bot)) return;
      setState(() {
        _thumbnail = thumb;
        _thumbnailSuppressed = thumb.suppressed != null;
        _showThumbnail(thumb.bytes);
      });
    } catch (_) {
      // Thumbnail poll must not spam errors; leave the last frame.
    }
  }

  void _scheduleThumbnail(WorkspaceTarget target, String bot) {
    _cancelThumbnail();
    _thumbnailTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_ownsScreen(target, bot)) {
        timer.cancel();
        return;
      }
      if (_tab == _BotsTab.screen) unawaited(_refreshThumbnail(target, bot));
    });
  }

  /// Runs one Bot Desktop action for the bot selected when it was tapped.
  /// [apply] only runs if that bot (and this gateway) is still the one shown
  /// when the reply arrives.
  Future<void> _screenAction<T>({
    required Future<T> Function(WorkspaceTarget target, String bot) send,
    required void Function(WorkspaceTarget target, String bot, T value) apply,
    required String failure,
  }) async {
    final target = _target;
    final bot = _screenProfile;
    if (target == null || bot == null) return;
    setState(() => _screenBusy = true);
    try {
      final value = await send(target, bot);
      if (!_ownsScreen(target, bot)) return;
      apply(target, bot, value);
    } catch (e) {
      if (_ownsScreen(target, bot)) _toast('$failure: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  void _stopInstallWatch() {
    _installUnwatch?.call();
    _installUnwatch = null;
  }

  /// `display.install` only starts the package manager on the gateway host.
  /// Its output arrives as `display.install.log` events, its end as
  /// `display.install.done`, and its sudo prompt as a request this screen
  /// answers; all three are followed from before the call is sent.
  Future<void> _startInstalling() async {
    final target = _target;
    final bot = _screenProfile;
    if (target == null || bot == null || _install?.running == true) return;
    final profileKey = _display?.profileKey;
    final install = _BotInstall(bot);
    _stopInstallWatch();
    final unwatchLog = target.watchDisplayInstall(
      profileKey: profileKey,
      onLog: (line) {
        if (!mounted) return;
        setState(() {
          install.lines.add(line);
          if (install.lines.length > _BotInstall.keep) {
            install.lines.removeAt(0);
          }
        });
      },
      onDone: (code, status) => _installDone(target, install, code, status),
    );
    final unwatchSudo = target.answerDisplayInstallSudo(
      profileKey: profileKey,
      onAsked: (request) => unawaited(_askSudo(install, request)),
    );
    _installUnwatch = () {
      unwatchLog();
      unwatchSudo();
    };
    setState(() {
      _install = install;
      _screenBusy = true;
    });
    try {
      final result = await target.displayInstall(bot);
      if (!mounted) return;
      if (!result.started) {
        _installFailed(install, 'The gateway did not start the install.');
      } else if (result.command case final command?) {
        setState(() => install.lines.insert(0, '\$ $command'));
      }
    } catch (e) {
      _installFailed(install, 'Install failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  void _installFailed(_BotInstall install, String message) {
    if (identical(_install, install)) _stopInstallWatch();
    if (!mounted) return;
    setState(() {
      install.running = false;
      install.error = message;
    });
  }

  void _installDone(
    WorkspaceTarget target,
    _BotInstall install,
    int code,
    DisplayStatus? status,
  ) {
    if (code != 0 || status?.installed != true) {
      _installFailed(install, switch (code) {
        -1 => 'The install was cancelled.',
        -2 =>
          'sudo is not available on the gateway host. Run the command '
              'above there, then refresh.',
        _ => 'The install failed (exit code $code).',
      });
      return;
    }
    if (identical(_install, install)) _stopInstallWatch();
    if (!mounted) return;
    setState(() {
      install.running = false;
      if (identical(_install, install)) _install = null;
      if (_ownsScreen(target, install.bot)) _display = status;
    });
    _toast('Bot Desktop installed for ${install.bot}');
  }

  /// The gateway's sudo prompt for the install this screen started. The
  /// password is read from an obscured field and goes straight into the
  /// response to that one request: it is never stored, logged or put in any
  /// call's params. Cancelling answers empty, which the gateway reads as
  /// "skipped".
  Future<void> _askSudo(
    _BotInstall install,
    DisplayInstallSudoRequest request,
  ) async {
    if (!mounted) {
      request.skip();
      return;
    }
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SudoPasswordDialog(bot: install.bot),
    );
    if (password == null || password.isEmpty) {
      request.skip();
    } else {
      request.answer(password);
    }
  }

  Future<void> _startScreen() => _screenAction(
    send: (target, bot) => target.displayStart(bot),
    apply: (target, bot, status) {
      setState(() => _display = status);
      if (status.running) {
        unawaited(_refreshThumbnail(target, bot));
        _scheduleThumbnail(target, bot);
      }
    },
    failure: 'Start failed',
  );

  Future<void> _stopScreen() async {
    final profile = _screenProfile;
    if (_target == null || profile == null) return;
    // The gateway refuses to stop a screen a person is driving unless told
    // to (methods_display.py); say so before asking.
    final humanHeld = _display?.lease.isAgent == false;
    final confirmed = await _confirm(
      title: 'Stop Bot Desktop for $profile?',
      message: humanHeld
          ? 'Someone is controlling this screen. Stopping it ends their '
                'session and closes everything open on it.'
          : 'Everything open on the bot’s screen is closed.',
      confirmLabel: 'Stop',
    );
    if (!confirmed || !mounted || _screenProfile != profile) return;
    await _screenAction(
      send: (target, bot) => target.displayStop(bot, force: humanHeld),
      apply: (target, bot, status) {
        _cancelThumbnail();
        setState(() => _display = status);
      },
      failure: 'Stop refused',
    );
  }

  /// Take over = open the live viewer, then take the lease. Without a live
  /// viewer nothing is acquired; when the viewer closes, for any reason, the
  /// lease goes back.
  Future<void> _takeOverScreen() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null || _session != null) return;
    setState(() => _screenBusy = true);
    BotDesktopSession? session;
    try {
      session = await BotDesktopSession.open(
        target,
        profile,
        connect: widget.displayConnector,
        reason: 'Take over from Ares',
      );
      final foreground =
          WidgetsBinding.instance.lifecycleState == null ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
      if (!mounted || !_ownsScreen(target, profile) || !foreground) {
        await session.close();
        return;
      }
      _session = session;
      session.addListener(_onSessionChanged);
      setState(() {
        _screenBusy = false;
        _display = _display?.copyWith(lease: session!.lease);
      });
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              BotDesktopViewerPage(session: session!, botName: profile),
        ),
      );
      // The viewer was closed: hand back.
      await _endSession(BotDesktopClose.handedBack);
    } catch (e) {
      await session?.close();
      if (_ownsScreen(target, profile)) {
        _toast('Take over failed: $e');
        unawaited(_loadScreen(target));
      }
    } finally {
      if (mounted && _screenBusy) setState(() => _screenBusy = false);
    }
  }

  /// The way out when a lease outlived its viewer (a crash, a dropped link,
  /// another device): give the screen back to the bot.
  Future<void> _forceHandBack() async {
    final profile = _screenProfile;
    if (_target == null || profile == null) return;
    final confirmed = await _confirm(
      title: 'Give $profile’s screen back to the bot?',
      message:
          'A person is holding this screen. If they are still using it, '
          'they lose control.',
      confirmLabel: 'Hand back',
    );
    if (!confirmed || !mounted || _screenProfile != profile) return;
    await _screenAction(
      send: (target, bot) => target.displayLeaseRelease(bot, force: true),
      apply: (target, bot, lease) =>
          setState(() => _display = _display?.copyWith(lease: lease)),
      failure: 'Hand back failed',
    );
  }

  Future<void> _switchSandboxImage() async {
    final profile = _screenProfile;
    if (_target == null || profile == null) return;
    final pending = _display?.imageSwitch;
    final confirmed = await _confirm(
      title: 'Adopt the new sandbox image?',
      message:
          '$profile moves from ${pending?['current_image'] ?? '?'} to '
          '${pending?['target_image'] ?? '?'}. Its container is recreated '
          'on the next terminal call; anything kept only in the current '
          'container is lost.',
      confirmLabel: 'Adopt image',
    );
    if (!confirmed || !mounted || _screenProfile != profile) return;
    await _screenAction(
      send: (target, bot) =>
          target.displaySwitchSandboxImage(bot, approve: true),
      apply: (target, bot, status) => setState(() => _display = status),
      failure: 'Image switch failed',
    );
  }

  Future<void> _keepCurrentImage() => _screenAction(
    send: (target, bot) =>
        target.displaySwitchSandboxImage(bot, approve: false),
    apply: (target, bot, status) => setState(() => _display = status),
    failure: 'Keep refused',
  );

  /// Asks before stopping, replacing or removing something a bot is using.
  /// False on Cancel or dismissal: the caller then sends nothing.
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        key: const Key('bots-confirm-dialog'),
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            key: const Key('bots-confirm-cancel'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.sharedL10n.cancel),
          ),
          FilledButton(
            key: const Key('bots-confirm-ok'),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openCanonicalChat(BotRosterProfile bot) {
    unawaited(() async {
      try {
        final target = await _bound();
        final chat = await target.resolveCanonicalChat(bot.name);
        // The connection or account changed while the chat was resolved.
        if (!mounted || !_owns(target)) return;
        final page = BotChatPage(
          connection: widget.connection,
          storedId: chat.sessionId,
          title: botCanonicalChatTitle,
          profile: chat.profile,
        );
        final open = widget.openBotChat;
        if (open != null) {
          await open(context, page);
        } else {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => page));
        }
        if (mounted) setState(() {});
      } on WorkspaceException catch (e) {
        if (mounted) _toast('Could not open Bot Chat: ${e.reason.name}');
      } catch (e) {
        if (mounted) _toast('Could not open Bot Chat: $e');
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 480;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bots · ${widget.connection.label}'),
        actions: [
          if (_botModeProtocol)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Tooltip(
                message:
                    'Gateway injects the teammate-messaging protocol itself — no extra SOUL.md protocol is sent.',
                child: Icon(Icons.auto_awesome_outlined, size: 18),
              ),
            ),
          IconButton(
            tooltip: context.sharedL10n.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => unawaited(_load()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: SegmentedButton<_BotsTab>(
              segments: const [
                ButtonSegment(
                  value: _BotsTab.roster,
                  label: Text('Roster'),
                  icon: Icon(Icons.people_outline),
                ),
                ButtonSegment(
                  value: _BotsTab.rooms,
                  label: Text('Rooms'),
                  icon: Icon(Icons.groups_outlined),
                ),
                ButtonSegment(
                  value: _BotsTab.screen,
                  label: Text('Screen'),
                  icon: Icon(Icons.desktop_windows_outlined),
                ),
                ButtonSegment(
                  value: _BotsTab.routines,
                  label: Text('Routines'),
                  icon: Icon(Icons.schedule_outlined),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => _onTabChanged(s.single),
            ),
          ),
          Expanded(child: _loadBody(isNarrow)),
        ],
      ),
    );
  }

  void _onTabChanged(_BotsTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    final target = _target;
    if (target == null) return;
    switch (tab) {
      case _BotsTab.rooms:
        unawaited(_loadRooms(target));
      case _BotsTab.routines:
        _routinesProfile ??= _screenProfile;
        unawaited(_loadRoutines(target));
      case _BotsTab.screen:
        _screenProfile ??= _roster.firstOrNull?.name;
        unawaited(_loadScreen(target));
      case _BotsTab.roster:
        break;
    }
  }

  Widget _loadBody(bool isNarrow) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failure != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bots unavailable (${_failure!.name})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _failure == WorkspaceFailure.stale
                    ? 'The account changed. Reconnect or refresh.'
                    : 'Try refreshing. If it persists, the gateway may not support bots.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => unawaited(_load()),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }
    final banner = _errorDetail;
    return Column(
      children: [
        if (banner != null)
          Material(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      banner,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dismiss',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _errorDetail = null),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: switch (_tab) {
            _BotsTab.roster => _rosterView(isNarrow),
            _BotsTab.rooms => _roomsView(),
            _BotsTab.screen => _screenView(isNarrow),
            _BotsTab.routines => _routinesView(isNarrow),
          },
        ),
      ],
    );
  }

  // ── Roster ────────────────────────────────────────────────────────────

  List<BotRosterProfile> get _visibleRoster {
    final needle = _search.toLowerCase();
    return _roster.where((p) {
      if (needle.isEmpty) return true;
      return [
        p.name,
        p.displayName,
        p.description,
        p.model,
        p.provider,
      ].where((s) => s.isNotEmpty).any((s) => s.toLowerCase().contains(needle));
    }).toList();
  }

  Widget _rosterView(bool isNarrow) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search bots',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        if (_visibleRoster.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(child: Text('No bots found.')),
          ),
        for (final bot in _visibleRoster)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  bot.hasAvatar ? Icons.smart_toy : Icons.person_outline,
                ),
              ),
              title: Text(
                bot.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                [
                  bot.model.isNotEmpty ? bot.model : 'no model',
                  if (bot.provider.isNotEmpty) bot.provider,
                  '${bot.skillCount} skill${bot.skillCount == 1 ? '' : 's'}',
                  if (bot.canonicalSessionId != null) 'Bot Chat',
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openRosterDetail(bot),
            ),
          ),
        const SizedBox(height: 16),
        const SizedBox(height: 4),
        Text(
          _installId != null
              ? 'Gateway reports install id $_installId · bot_mode_protocol: $_botModeProtocol'
              : 'The gateway injects the teammate-messaging protocol when bot_mode_protocol is set. Handle: default→hermes, otherwise the profile name.',
          style: TextStyle(fontSize: 12, color: HermesTokens.of(context).muted),
        ),
      ],
    );
  }

  void _openRosterDetail(BotRosterProfile bot) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _RosterDetailSheet(
        bot: bot,
        onOpenChat: () {
          Navigator.of(sheetContext).pop();
          _openCanonicalChat(bot);
        },
        onOpenRoutines: () {
          Navigator.of(sheetContext).pop();
          setState(() {
            _routinesProfile = bot.name;
            _tab = _BotsTab.routines;
          });
          final target = _target;
          if (target != null) unawaited(_loadRoutines(target));
        },
        onOpenScreen: () {
          Navigator.of(sheetContext).pop();
          setState(() {
            _screenProfile = bot.name;
            _tab = _BotsTab.screen;
          });
          final target = _target;
          if (target != null) unawaited(_loadScreen(target));
        },
      ),
    );
  }

  // ── Rooms ─────────────────────────────────────────────────────────────

  Widget _roomsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_roomsCaps != null) _roomsStatusCard(_roomsCaps!),
        _roomsCreateRow(),
        const SizedBox(height: 12),
        if (_roomsLoading)
          const Center(child: CircularProgressIndicator())
        else if (_rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(
              child: Text('No rooms yet. Create one from your roster.'),
            ),
          ),
        for (final room in _rooms)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                room.disbanded ? Icons.block : Icons.groups_outlined,
              ),
              title: Text(room.name),
              subtitle: Text(
                '${room.members.length} member${room.members.length == 1 ? '' : 's'}'
                '${room.disbanded ? ' · disbanded' : ''}'
                '${room.adopted ? ' · adopted' : ''}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openRoom(room),
            ),
          ),
      ],
    );
  }

  Widget _roomsStatusCard(RoomCapabilities caps) {
    final driver = caps.driver;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(driver ? Icons.hub : Icons.desktop_windows_outlined),
        title: Text(driver ? 'Gateway rooms' : 'Desktop-driven rooms'),
        subtitle: Text(
          driver
              ? 'Rooms are owned by the gateway. Methods: ${caps.methods.join(', ')}.'
              : (caps.persistentProcess
                    ? 'Rooms may not be seated by this gateway (persistent process required).'
                    : 'Classic fallback: the Desktop drives the group rounds (not newly created here).'),
        ),
        trailing: Text(
          'v${caps.protocolVersion}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _roomsCreateRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _roster.isEmpty ? null : () => _openCreateRoomSheet(),
            child: Text('${context.sharedL10n.create} room'),
          ),
        ),
        IconButton(
          tooltip: 'Refresh rooms',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final target = _target;
            if (target != null) unawaited(_loadRooms(target));
          },
        ),
      ],
    );
  }

  void _openCreateRoomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CreateRoomSheet(
        roster: _roster,
        onCreate: (name, roomId, members) async {
          Navigator.of(sheetContext).pop();
          final target = _target;
          if (target == null) return;
          setState(() {
            _roomsLoading = true;
          });
          try {
            await target.roomCreate(
              roomId: roomId,
              name: name,
              members: members,
            );
            if (!_owns(target)) return;
            _toast('Room created');
            await _loadRooms(target);
          } on WorkspaceException catch (e) {
            if (!_owns(target)) return;
            setState(() => _roomsLoading = false);
            _toast('Room creation refused (${e.reason.name})');
          } catch (e) {
            if (!_owns(target)) return;
            setState(() => _roomsLoading = false);
            _toast('Room creation failed: $e');
          }
        },
      ),
    );
  }

  void _openRoom(RoomSummary room) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BotRoomScreen(
          owner: widget.owner,
          route: widget.route,
          connection: widget.connection,
          room: room,
        ),
      ),
    );
  }

  // ── Screen (Bot Desktop) ────────────────────────────────────────────────

  Widget _screenView(bool isNarrow) {
    final profiles = _roster.map((p) => p.name).toList();
    final selected = _screenProfile;
    final status = _display;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: profiles.contains(selected) ? selected : null,
          items: [
            for (final n in profiles)
              DropdownMenuItem(value: n, child: Text(n)),
          ],
          decoration: const InputDecoration(
            labelText: 'Bot',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (n) {
            if (n == null || n == _screenProfile) return;
            _cancelThumbnail();
            setState(() {
              _screenProfile = n;
              _display = null;
              _thumbnail = null;
              _showThumbnail(null);
              _thumbnailSuppressed = false;
            });
            final target = _target;
            if (target != null) unawaited(_loadScreen(target));
          },
        ),
        const SizedBox(height: 12),
        if (status == null && !_screenBusy)
          Card(
            child: const ListTile(
              title: Text('Screen status unavailable'),
              subtitle: Text(
                'Start the bot’s screen to watch its thumbnail, or take over to use it yourself.',
              ),
            ),
          ),
        if (status != null) _displayCard(status),
        if (_install case final install? when install.bot == selected)
          _installCard(install),
        if (status != null) _screenControls(status),
        if (status?.running == true) _thumbnailCard(),
        const SizedBox(height: 12),
        Text(
          'Take over opens the live screen and gives you control of it. '
          'Control goes back to the bot when you close the live screen, '
          'leave this page or put the app in the background.',
          style: TextStyle(fontSize: 12, color: HermesTokens.of(context).muted),
        ),
      ],
    );
  }

  Widget _displayCard(DisplayStatus status) {
    final unsupported = !status.supported;
    final installed = status.installed;
    final blocked = status.blocker;
    final imageSwitch = status.imageSwitch;
    return Card(
      child: ListTile(
        leading: Icon(
          unsupported
              ? Icons.block_outlined
              : installed
              ? (status.running
                    ? Icons.desktop_windows
                    : Icons.desktop_windows_outlined)
              : Icons.download_outlined,
        ),
        title: Text(
          !unsupported
              ? installed
                    ? status.running
                          ? 'Running'
                          : 'Stopped'
                    : 'Not installed'
              : 'Unsupported host',
        ),
        subtitle: Text(
          [
            if (installed) '${status.geometry} · ${status.placement}',
            if (status.pid != null) 'pid ${status.pid}',
            if (status.missing.isNotEmpty)
              'missing: ${status.missing.join(', ')}',
            if (blocked != null) 'blocked: $blocked',
            if (!unsupported && !installed && status.missing.isEmpty)
              'No sandbox image switch is pending.',
            if (imageSwitch != null)
              'switch image: ${imageSwitch['current_image'] ?? '?'} → ${imageSwitch['target_image'] ?? '?'}',
          ].join(' · '),
        ),
        trailing: status.running
            ? Text(
                status.lease.isAgent
                    ? 'agent holds'
                    : '${status.lease.holder} holds',
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
      ),
    );
  }

  Widget _installCard(_BotInstall install) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: const Key('bots-install-card'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              install.running
                  ? 'Installing Bot Desktop on the gateway host…'
                  : 'The install did not finish',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (install.running)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
            if (install.lines.isNotEmpty)
              Container(
                key: const Key('bots-install-log'),
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  reverse: true,
                  child: SelectableText(
                    install.lines.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'GeistMono',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (install.error case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error,
                  key: const Key('bots-install-error'),
                  style: TextStyle(color: scheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _screenControls(DisplayStatus status) {
    final unsupported = !status.supported;
    final installed = status.installed;
    final running = status.running;
    final humanHeld = !status.lease.isAgent;
    final installing = _install?.running == true;
    final imageSwitchPending = status.imageSwitch != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!unsupported && !installed)
              OutlinedButton.icon(
                onPressed: _screenBusy || installing ? null : _startInstalling,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Install'),
              ),
            if (!unsupported && installed && !running)
              FilledButton.icon(
                onPressed: _screenBusy ? null : _startScreen,
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('Start'),
              ),
            if (!unsupported && installed && running)
              FilledButton.icon(
                onPressed: _screenBusy ? null : () => _stopScreen(),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Stop'),
              ),
            if (!unsupported && installed && running)
              OutlinedButton.icon(
                key: const Key('bots-take-over'),
                onPressed: _screenBusy || _session != null
                    ? null
                    : _takeOverScreen,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Take over'),
              ),
            if (!unsupported && running && humanHeld && _session == null)
              OutlinedButton.icon(
                key: const Key('bots-force-hand-back'),
                onPressed: _screenBusy ? null : _forceHandBack,
                icon: const Icon(Icons.visibility_off_outlined),
                label: const Text('Hand back'),
              ),
            if (imageSwitchPending && !_screenBusy) ...[
              FilledButton.icon(
                onPressed: _screenBusy ? null : _switchSandboxImage,
                icon: const Icon(Icons.sync_alt_outlined),
                label: const Text('Adopt image'),
              ),
              OutlinedButton.icon(
                onPressed: _screenBusy ? null : _keepCurrentImage,
                icon: const Icon(Icons.close),
                label: const Text('Keep current image'),
              ),
            ],
            if (status.missing.isNotEmpty && !unsupported)
              Tooltip(
                message:
                    'The gateway reported missing pieces: ${status.missing.join(', ')}',
                child: TextButton(
                  onPressed: _screenBusy || installing
                      ? null
                      : _startInstalling,
                  child: const Text('Install missing pieces'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailCard() {
    final thumbnail = _thumbnail;
    final scheme = Theme.of(context).colorScheme;
    final unavailable = Container(
      height: 96,
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(
        'Thumbnail unavailable',
        style: TextStyle(color: scheme.onSurfaceVariant),
      ),
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Screen thumbnail (live)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_thumbnailImage case final image?)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  // The last frame stays up while the next one decodes.
                  child: Image(
                    key: const Key('bots-thumbnail-image'),
                    image: image,
                    gaplessPlayback: true,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => unavailable,
                  ),
                ),
              )
            else if (thumbnail?.dataUrl != null)
              unavailable
            else if (_thumbnailSuppressed)
              const Text('Thumbnail suppressed while the screen is human-held.')
            else
              const Text('Thumbnail not available yet.'),
          ],
        ),
      ),
    );
  }

  // ── Routines ───────────────────────────────────────────────────────────

  Widget _routinesView(bool isNarrow) {
    final profiles = _roster.map((p) => p.name).toList();
    final selected = _routinesProfile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: profiles.contains(selected) ? selected : null,
          items: [
            for (final n in profiles)
              DropdownMenuItem(value: n, child: Text(n)),
          ],
          decoration: const InputDecoration(
            labelText: 'Bot',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (n) {
            if (n == null || n == _routinesProfile) return;
            setState(() {
              _routinesProfile = n;
              _routines = const [];
              _routinesScope = null;
              _routinesLoading = false;
            });
            final target = _target;
            if (target != null) unawaited(_loadRoutines(target));
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              _routinesScope ?? '${selected ?? '—'} · routines',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final target = _target;
                if (target != null) unawaited(_loadRoutines(target));
              },
            ),
            IconButton(
              tooltip: 'Add routine',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _routinesLoading ? null : () => _openRoutineDialog(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_routinesLoading)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_routines.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('No routines for this bot.')),
          ),
        for (final job in _routines) _routineTile(job),
        const SizedBox(height: 16),
        Text(
          'Routines are [bot:<name>]-tagged jobs owned by the bot’s profile store. Legacy delegated routines are force-paused on load.',
          style: TextStyle(fontSize: 12, color: HermesTokens.of(context).muted),
        ),
      ],
    );
  }

  Widget _routineTile(RoutineJob job) {
    final tagged = RoutineJob.splitTags(job.name);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          job.enabled ? Icons.schedule : Icons.pause_circle_outline,
        ),
        title: Text(
          tagged.title.isNotEmpty ? tagged.title : job.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            job.schedule,
            if (job.enabled) 'enabled' else 'paused',
            ?job.repeat,
            if (job.state.isNotEmpty) job.state,
            if (job.lastStatus.isNotEmpty) 'last: ${job.lastStatus}',
            if (job.nextRunAt != null) 'next: ${job.nextRunAt}',
            if (job.lastError != null && job.lastError!.isNotEmpty)
              'error: ${job.lastError}',
          ].where((s) => s.isNotEmpty).join(' · '),
        ),
        trailing: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            if (!job.enabled)
              IconButton(
                tooltip: 'Resume',
                icon: const Icon(Icons.play_arrow_outlined),
                onPressed: () => _routineAction('resume', job),
              )
            else
              IconButton(
                tooltip: 'Pause',
                icon: const Icon(Icons.pause_outlined),
                onPressed: () => _routineAction('pause', job),
              ),
            IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _routineAction('remove', job),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _routineAction(String action, RoutineJob job) async {
    final target = _target;
    final profile = _routinesProfile;
    if (target == null || profile == null) return;
    if (action == 'remove') {
      final title = RoutineJob.splitTags(job.name).title;
      final confirmed = await _confirm(
        title: 'Remove routine ${title.isEmpty ? job.name : title}?',
        message:
            'The routine is deleted from $profile’s schedule. '
            'This cannot be undone.',
        confirmLabel: 'Remove',
      );
      if (!confirmed || !_ownsRoutines(target, profile)) return;
    }
    setState(() => _routinesLoading = true);
    try {
      switch (action) {
        case 'pause':
          await target.botRoutinePause(profile, job.jobId);
        case 'resume':
          await target.botRoutineResume(profile, job.jobId);
        case 'remove':
          await target.botRoutineRemove(profile, job.jobId);
      }
      if (!_ownsRoutines(target, profile)) return;
      await _loadRoutines(target);
    } catch (e) {
      if (_ownsRoutines(target, profile)) {
        setState(() => _routinesLoading = false);
        _toast('$action failed: $e');
      }
    }
  }

  void _openRoutineDialog() {
    final profile = _routinesProfile;
    if (profile == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => _RoutineDialog(
        onAdd: (draft) async {
          final target = _target;
          if (target == null) return 'Not connected.';
          try {
            await target.botRoutineAdd(
              profile: profile,
              title: draft.title,
              schedule: draft.schedule,
              instruction: draft.instruction,
              repeat: draft.repeat,
              continuity: draft.continuity,
              deliverToBotChat: draft.deliverToBotChat,
            );
          } on WorkspaceException catch (e) {
            return 'Add failed: ${e.reason.name}';
          } catch (e) {
            return 'Add failed: $e';
          }
          if (!_ownsRoutines(target, profile)) return null;
          _toast('Routine added');
          unawaited(_loadRoutines(target));
          return null;
        },
      ),
    );
  }
}

extension on DisplayStatus {
  DisplayStatus copyWith({DisplayLease? lease}) => DisplayStatus(
    profile: profile,
    supported: supported,
    installed: installed,
    missing: missing,
    running: running,
    pid: pid,
    geometry: geometry,
    placement: placement,
    blocker: blocker,
    memoryAvailableMb: memoryAvailableMb,
    memoryLimitMb: memoryLimitMb,
    imageSwitch: imageSwitch,
    lease: lease ?? this.lease,
    profileKey: profileKey,
  );
}

class _RosterDetailSheet extends StatelessWidget {
  const _RosterDetailSheet({
    required this.bot,
    required this.onOpenChat,
    required this.onOpenRoutines,
    required this.onOpenScreen,
  });

  final BotRosterProfile bot;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenRoutines;
  final VoidCallback onOpenScreen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  child: Icon(
                    bot.hasAvatar ? Icons.smart_toy : Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '@${bot.handle} · ${bot.model.isNotEmpty ? bot.model : 'no model'}'
                        '${bot.provider.isNotEmpty ? ' · ${bot.provider}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.sharedL10n.close,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bot.description.isNotEmpty)
              Text(
                bot.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (bot.description.isNotEmpty) const SizedBox(height: 8),
            Text(
              'Path: ${bot.path} · ${bot.skillCount} skills'
              '${bot.canonicalSessionId != null ? ' · Bot Chat present' : ' · Bot Chat missing'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (bot.lastSessionPreview != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last session: ${bot.lastSessionPreview}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Open Bot Chat'),
                    onPressed: onOpenChat,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule_outlined),
                    label: const Text('Routines'),
                    onPressed: onOpenRoutines,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.desktop_windows_outlined),
                    label: const Text('Bot Desktop'),
                    onPressed: onOpenScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRoomSheet extends StatefulWidget {
  const _CreateRoomSheet({required this.roster, required this.onCreate});

  final List<BotRosterProfile> roster;
  final Future<void> Function(
    String name,
    String roomId,
    List<RoomMember> members,
  )
  onCreate;

  @override
  State<_CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends State<_CreateRoomSheet> {
  final _nameInput = TextEditingController();
  final Set<String> _selected = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _nameInput.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameInput.removeListener(_onNameChanged);
    _nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final members = [
      for (final p in widget.roster)
        if (_selected.contains(p.name))
          RoomMember(
            memberId: p.name,
            profile: p.name,
            handle: p.handle,
            displayName: p.displayName.isNotEmpty ? p.displayName : '',
          ),
    ];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create room',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameInput,
                  decoration: const InputDecoration(
                    labelText: 'Room name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final bot in widget.roster)
                      FilterChip(
                        label: Text(bot.title),
                        selected: _selected.contains(bot.name),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selected.add(bot.name);
                            } else {
                              _selected.remove(bot.name);
                            }
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (members.isEmpty)
                  Text(
                    'Select at least one member.',
                    style: TextStyle(color: HermesTokens.of(context).muted),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed:
                      _busy || _nameInput.text.trim().isEmpty || members.isEmpty
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          final roomId =
                              'room-${_nameInput.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '-')}';
                          await widget.onCreate(
                            _nameInput.text.trim(),
                            roomId,
                            members,
                          );
                          if (mounted) setState(() => _busy = false);
                        },
                  child: _busy
                      ? const CircularProgressIndicator()
                      : const Text('Create room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One package install on a bot's gateway host, as far as this screen has
/// followed it.
class _BotInstall {
  _BotInstall(this.bot);

  /// Output lines kept on screen.
  static const keep = 200;

  final String bot;
  final lines = <String>[];
  bool running = true;
  String? error;
}

/// Asks for the sudo password of a Bot Desktop install. Pops with the text
/// (null on Cancel) and clears its own copy; nothing else keeps it.
class _SudoPasswordDialog extends StatefulWidget {
  const _SudoPasswordDialog({required this.bot});
  final String bot;

  @override
  State<_SudoPasswordDialog> createState() => _SudoPasswordDialogState();
}

class _SudoPasswordDialogState extends State<_SudoPasswordDialog> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password
      ..clear()
      ..dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_password.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const Key('bots-sudo-dialog'),
      scrollable: true,
      title: const Text('Administrator password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Installing Bot Desktop for ${widget.bot} needs sudo on the '
            'gateway host. The password is sent only to that gateway, for '
            'this install, and is not saved.',
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('bots-sudo-password'),
            controller: _password,
            autofocus: true,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'sudo password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('bots-sudo-cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.sharedL10n.cancel),
        ),
        FilledButton(
          key: const Key('bots-sudo-submit'),
          onPressed: _submit,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

/// What the New routine form sends: `cron.manage add` for one bot.
class _RoutineDraft {
  const _RoutineDraft({
    required this.title,
    required this.instruction,
    required this.schedule,
    required this.repeat,
    required this.continuity,
    required this.deliverToBotChat,
  });

  final String title;
  final String instruction;

  /// A Hermes schedule: a cron expression or `every <n><m|h|d>`.
  final String schedule;

  /// Run count after which the routine stops; null keeps it running.
  final int? repeat;
  final bool continuity;
  final bool deliverToBotChat;
}

enum _RoutineScheduleKind { cron, interval }

class _RoutineDialog extends StatefulWidget {
  const _RoutineDialog({required this.onAdd});

  /// Creates the routine; returns the error to show, or null on success.
  final Future<String?> Function(_RoutineDraft draft) onAdd;

  @override
  State<_RoutineDialog> createState() => _RoutineDialogState();
}

class _RoutineDialogState extends State<_RoutineDialog> {
  final _titleInput = TextEditingController();
  final _instructionInput = TextEditingController();
  final _cronInput = TextEditingController(text: '0 9 * * *');
  final _intervalInput = TextEditingController(text: '1');
  // Blank on purpose: 'Repeat' is a run COUNT on the gateway, so a default
  // of 1 would retire a daily routine after its first run.
  final _repeatInput = TextEditingController();
  _RoutineScheduleKind _kind = _RoutineScheduleKind.cron;
  String _intervalUnit = 'h';
  bool _continuity = false;
  bool _deliverToBotChat = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // The Add button follows what is typed.
    for (final input in _inputs) {
      input.addListener(_onInput);
    }
  }

  List<TextEditingController> get _inputs => [
    _titleInput,
    _instructionInput,
    _cronInput,
    _intervalInput,
    _repeatInput,
  ];

  void _onInput() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final input in _inputs) {
      input.dispose();
    }
    super.dispose();
  }

  String get _schedule {
    if (_kind == _RoutineScheduleKind.cron) return _cronInput.text.trim();
    final every = int.tryParse(_intervalInput.text.trim()) ?? 0;
    return every < 1 ? '' : 'every $every$_intervalUnit';
  }

  bool get _canAdd =>
      !_busy &&
      _titleInput.text.trim().isNotEmpty &&
      _instructionInput.text.trim().isNotEmpty &&
      _schedule.isNotEmpty;

  Future<void> _submit() async {
    if (!_canAdd) return;
    final limit = int.tryParse(_repeatInput.text.trim());
    final draft = _RoutineDraft(
      title: _titleInput.text.trim(),
      instruction: _instructionInput.text.trim(),
      schedule: _schedule,
      repeat: limit != null && limit > 0 ? limit : null,
      continuity: _continuity,
      deliverToBotChat: _deliverToBotChat,
    );
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onAdd(draft);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('New routine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('bots-routine-title'),
            controller: _titleInput,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          gap,
          TextField(
            key: const Key('bots-routine-instruction'),
            controller: _instructionInput,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Instruction',
              border: OutlineInputBorder(),
            ),
          ),
          gap,
          DropdownButtonFormField<_RoutineScheduleKind>(
            key: const Key('bots-routine-schedule-kind'),
            isExpanded: true,
            initialValue: _kind,
            decoration: const InputDecoration(
              labelText: 'Schedule',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: _RoutineScheduleKind.cron,
                child: Text('Cron expression', overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: _RoutineScheduleKind.interval,
                child: Text('Interval', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: _busy
                ? null
                : (kind) => setState(() => _kind = kind ?? _kind),
          ),
          gap,
          if (_kind == _RoutineScheduleKind.cron)
            TextField(
              key: const Key('bots-routine-cron'),
              controller: _cronInput,
              decoration: const InputDecoration(
                labelText: 'Cron expression',
                helperText: '0 9 * * * runs every day at 09:00',
                helperMaxLines: 3,
                border: OutlineInputBorder(),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('bots-routine-interval'),
                    controller: _intervalInput,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    decoration: const InputDecoration(
                      labelText: 'Every',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    key: const Key('bots-routine-interval-unit'),
                    isExpanded: true,
                    initialValue: _intervalUnit,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'm',
                        child: Text('minutes', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'h',
                        child: Text('hours', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'd',
                        child: Text('days', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: _busy
                        ? null
                        : (unit) => setState(() => _intervalUnit = unit ?? 'h'),
                  ),
                ),
              ],
            ),
          gap,
          TextField(
            key: const Key('bots-routine-repeat'),
            controller: _repeatInput,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(
              labelText: 'Stop after (runs)',
              hintText: '∞',
              helperText: 'Leave blank to keep running',
              helperMaxLines: 3,
              border: OutlineInputBorder(),
            ),
          ),
          gap,
          DropdownButtonFormField<bool>(
            key: const Key('bots-routine-deliver'),
            isExpanded: true,
            initialValue: _deliverToBotChat,
            decoration: const InputDecoration(
              labelText: 'Send results to',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: false,
                child: Text(
                  'Run history only',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Bot Chat', overflow: TextOverflow.ellipsis),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() => _deliverToBotChat = value ?? false),
          ),
          CheckboxListTile(
            key: const Key('bots-routine-continuity'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Continue from the previous run'),
            value: _continuity,
            onChanged: _busy
                ? null
                : (value) => setState(() => _continuity = value ?? false),
          ),
          if (_error case final error?)
            Text(
              error,
              key: const Key('bots-routine-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(context.sharedL10n.cancel),
        ),
        FilledButton(
          key: const Key('bots-routine-add'),
          onPressed: _canAdd ? _submit : null,
          child: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.sharedL10n.add),
        ),
      ],
    );
  }
}

/// Pushed page hosting a bot's canonical Bot Chat, on the bot's own profile.
///
/// Each layout shows it with its own chat: inside NextGen (an [NgScope] is
/// above) the NextGen chat view, on a gateway and scope of its own for the
/// bot's profile; in Classic the Classic chat screen on [chatConnection].
class BotChatPage extends StatefulWidget {
  const BotChatPage({
    super.key,
    required this.connection,
    required this.storedId,
    required this.title,
    required this.profile,
    this.gatewayFactory,
    this.classicChatBuilder,
  });

  /// The connection the roster was read on.
  final SavedConnection connection;
  final String storedId;
  final String title;

  /// The bot: the profile that owns [storedId].
  final String profile;

  /// Builds the NextGen chat's gateway. Tests record what it is given.
  @visibleForTesting
  final NextGenGateway Function(SavedConnection connection)? gatewayFactory;

  /// Builds the Classic chat. Tests record what it is given.
  @visibleForTesting
  final Widget Function(SavedConnection connection, Session session)?
  classicChatBuilder;

  /// The same gateway and account, on the bot's own profile. A bot's chat is
  /// a session in the bot's profile: read, resumed and sent to there, as
  /// Desktop opens it (`requestForBot`), not on whatever profile the saved
  /// connection selects. An unsaved copy; the saved connection is untouched.
  SavedConnection get chatConnection => profile.trim().isEmpty
      ? connection
      : connection.copyWith(gatewayProfile: profile.trim());

  @override
  State<BotChatPage> createState() => _BotChatPageState();
}

class _BotChatPageState extends State<BotChatPage> {
  NextGenGateway? _gateway;
  NgChatController? _chat;
  NgScope? _nextGen;
  bool _resolved = false;
  bool _loading = true;
  String? _failure;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolved) return;
    _resolved = true;
    // Read once: which layout this page was pushed from does not change.
    _nextGen = context.getInheritedWidgetOfExactType<NgScope>();
    if (_nextGen != null) unawaited(_start());
  }

  Future<void> _start() async {
    try {
      final gateway = (widget.gatewayFactory ?? NextGenGateway.new)(
        widget.chatConnection,
      );
      _gateway = gateway;
      final chat = NgChatController(
        gateway,
        sessionId: widget.storedId,
        title: widget.title,
      );
      _chat = chat;
      await chat.open();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failure = '$e';
      });
    }
  }

  @override
  void dispose() {
    _chat?.dispose();
    _gateway?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextGen = _nextGen;
    if (nextGen == null) {
      final session = Session(
        id: widget.storedId,
        title: widget.title,
        model: '',
        source: 'desktop',
        messageCount: 0,
        hasKnownMessageCount: false,
        isActive: false,
        preview: '',
        startedAt: 0,
      );
      final build = widget.classicChatBuilder;
      if (build != null) return build(widget.chatConnection, session);
      return ChatScreen(
        connection: widget.chatConnection,
        session: session,
        singleSession: true,
        onClose: () => Navigator.of(context).maybePop(),
      );
    }
    final chat = _chat;
    final gateway = _gateway;
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} · ${widget.profile}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failure != null || chat == null || gateway == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not open Bot Chat: $_failure',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          // The chat view reads its gateway from the scope: give it the
          // bot's, so nothing in it reaches the connection's own profile.
          : NgScope(
              connManager: nextGen.connManager,
              gateway: gateway,
              connections: nextGen.connections,
              switchTo: nextGen.switchTo,
              addGateway: nextGen.addGateway,
              signOut: nextGen.signOut,
              reload: nextGen.reload,
              signInAgain: nextGen.signInAgain,
              child: NgChatView(key: ObjectKey(chat), chat: chat),
            ),
    );
  }
}

/// Full-page room view: members, driver status, send form, history.
class BotRoomScreen extends StatefulWidget {
  const BotRoomScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.connection,
    required this.room,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;
  final RoomSummary room;

  @override
  State<BotRoomScreen> createState() => _BotRoomScreenState();
}

class _BotRoomScreenState extends State<BotRoomScreen> {
  WorkspacePane? _pane;
  WorkspaceTarget? _target;
  Object? _account;

  RoomSummary _room = RoomSummary(roomId: '', name: '');
  RoomDriverStatus? _driver;
  RoomContext? _context;
  List<RoomLogEvent> _log = const [];
  bool _loading = true;
  String? _error;

  final _messageInput = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    ConnectionMutationBarrier.addListener(_onAccountChanged);
    unawaited(_load());
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_onAccountChanged);
    _messageInput.dispose();
    _pane?.close();
    super.dispose();
  }

  void _onAccountChanged() {
    if (ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      return;
    }
    _pane?.invalidate();
    _target = null;
    if (mounted) {
      setState(() {
        _loading = false;
        _error = 'Account changed. Refresh before continuing.';
      });
    }
  }

  Future<WorkspaceTarget> _bound() async {
    final existing = _target;
    if (existing != null && existing.isCurrent) return existing;
    _pane?.close();
    final pane = _pane = widget.owner.pane();
    final bound = await pane.bind(widget.route);
    _target = bound;
    return bound;
  }

  Future<void> _load() async {
    try {
      final target = await _bound();
      if (!mounted) return;
      final state = await target.roomState(widget.room.roomId);
      final log = await target.roomLog(widget.room.roomId, limit: 60);
      if (!mounted) return;
      setState(() {
        _room = state.room;
        _driver = state.driverStatus;
        _context = state.context;
        _log = log.events;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load room: $e';
      });
    }
  }

  Future<void> _send() async {
    final text = _messageInput.text.trim();
    if (text.isEmpty) return;
    final target = _target;
    if (target == null) return;
    setState(() => _sending = true);
    try {
      await target.roomSend(widget.room.roomId, {'text': text});
      if (!mounted) return;
      _messageInput.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Send failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _stop() async {
    final target = _target;
    if (target == null) return;
    try {
      await target.roomStop(widget.room.roomId);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('Stop failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = _room;
    final driver = _driver;
    return Scaffold(
      appBar: AppBar(
        title: Text(room.name.isNotEmpty ? room.name : room.roomId),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => unawaited(_load()),
          ),
          IconButton(
            tooltip: 'Stop room',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: _stop,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _roomHeaderCard(room, driver),
                const SizedBox(height: 12),
                _membersCard(room),
                const SizedBox(height: 12),
                _contextCard(),
                const SizedBox(height: 16),
                const Text(
                  'Send a message',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageInput,
                  maxLines: 4,
                  maxLength: 65536,
                  decoration: const InputDecoration(
                    hintText: 'Message the room (mention members with @handle)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sending ? null : _send,
                        icon: const Icon(Icons.send),
                        label: Text(context.sharedL10n.send),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'History',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final ev in _log)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      ev.kind.startsWith('message')
                          ? Icons.chat_bubble_outline
                          : Icons.circle_outlined,
                      size: 18,
                    ),
                    title: Text(ev.kind),
                    subtitle: Text('#${ev.seq} · ${ev.actor}'),
                  ),
              ],
            ),
    );
  }

  Widget _roomHeaderCard(RoomSummary room, RoomDriverStatus? driver) {
    final status = driver == null
        ? 'unknown'
        : driver.running
        ? (driver.blocked
              ? 'blocked'
              : (driver.working ? 'working' : 'running'))
        : 'idle';
    return Card(
      child: ListTile(
        leading: Icon(
          driver?.running == true ? Icons.sync : Icons.pause_circle_outline,
        ),
        title: Text(
          '${room.name} — $status',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            '${room.revision} revision',
            if (driver != null && driver.counts.isNotEmpty)
              driver.counts.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', '),
            if (driver?.lastError != null) 'last error: ${driver!.lastError}',
            if (room.disbanded) 'disbanded',
          ].join(' · '),
        ),
      ),
    );
  }

  Widget _membersCard(RoomSummary room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Members', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in room.members)
                  Chip(
                    avatar: const Icon(Icons.person, size: 16),
                    label: Text(m.handle.isNotEmpty ? '@${m.handle}' : m.title),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _contextCard() {
    final roomContext = _context;
    if (roomContext == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room context', style: Theme.of(context).textTheme.titleSmall),
            if (roomContext.purpose.isNotEmpty)
              Text('Purpose: ${roomContext.purpose}'),
            if (roomContext.notes.isNotEmpty)
              Text('Notes: ${roomContext.notes}'),
            Text(
              'Routing: ${roomContext.routing}${roomContext.leadMemberId.isNotEmpty ? ' · lead ${roomContext.leadMemberId}' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
