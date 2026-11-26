import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/connection_manager.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/remote_workspace.dart';
import '../../nextgen/data/chat_controller.dart';
import '../../nextgen/data/nextgen_gateway.dart';
import '../../nextgen/ui/chat_view.dart';

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
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;

  @override
  State<BotsScreen> createState() => _BotsScreenState();
}

enum _BotsTab { roster, rooms, screen, routines, relay }

class _BotsScreenState extends State<BotsScreen> {
  WorkspacePane? _pane;
  WorkspaceTarget? _target;
  Object? _account;
  Object _token = Object();

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
  String? _watchViewerId;
  DisplayThumbnail? _thumbnail;
  bool _thumbnailSuppressed = false;
  Timer? _thumbnailTimer;
  bool _screenBusy = false;

  // Routines
  String? _routinesProfile; // null = _screenProfile or current
  List<RoutineJob> _routines = const [];
  String? _routinesScope;
  bool _routinesLoading = false;

  // Relay
  String? _relayProfile; // null = _screenProfile
  final _relayInput = TextEditingController();
  bool _relayBusy = false;
  RelayDelivery? _relayResult;

  @override
  void initState() {
    super.initState();
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    ConnectionMutationBarrier.addListener(_onAccountChanged);
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next != _search && mounted) setState(() => _search = next);
    });
    _relayInput.addListener(() {
      if (mounted) setState(() {});
    });
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant BotsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.owner != widget.owner || oldWidget.route != widget.route) {
      _pane?.close();
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
    _searchController.dispose();
    _relayInput.dispose();
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
    _cancelThumbnail();
    if (mounted) {
      setState(() {
        _loading = false;
        _failure = WorkspaceFailure.stale;
      });
    }
  }

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
        _relayProfile ??= _screenProfile;
      });
      if (_tab == _BotsTab.rooms) unawaited(_loadRooms(target));
      if (_tab == _BotsTab.routines) unawaited(_loadRoutines(target));
      if (_tab == _BotsTab.screen) unawaited(_loadScreen(target));
      if (_tab == _BotsTab.relay) {
        // Relay target defaults to the screen profile; nothing to load.
      }
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

  Future<void> _loadRooms(WorkspaceTarget target) async {
    setState(() => _roomsLoading = true);
    try {
      final caps = await target.roomCapabilities();
      final rooms = await target.roomList(limit: 50);
      if (!mounted) return;
      setState(() {
        _roomsCaps = caps;
        _rooms = rooms;
        _roomsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _roomsLoading = false;
        _roomsCaps = null;
        _rooms = const [];
        _errorDetail = 'Could not load rooms: $e';
      });
    }
  }

  Future<void> _loadRoutines(WorkspaceTarget target) async {
    final profile = _routinesProfile;
    if (profile == null) return;
    setState(() => _routinesLoading = true);
    try {
      final result = await target.botRoutinesWithLegacyPause(profile);
      if (!mounted) return;
      setState(() {
        _routines = result.jobs;
        _routinesScope = result.scoped;
        _routinesLoading = false;
      });
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _routinesLoading = false;
        _routines = const [];
        _errorDetail = 'Could not load routines: ${e.reason.name}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _routinesLoading = false);
    }
  }

  Future<void> _loadScreen(WorkspaceTarget target) async {
    final profile = _screenProfile;
    if (profile == null) return;
    try {
      final status = await target.displayStatus(profile);
      if (!mounted) return;
      setState(() {
        _display = status;
        _thumbnailSuppressed = false;
      });
      if (status.running) {
        await _refreshThumbnail(target);
        _scheduleThumbnail(target);
      } else {
        _cancelThumbnail();
      }
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _display = null;
        _errorDetail = 'Bot Desktop: ${e.reason.name}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _display = null);
    }
  }

  Future<void> _refreshThumbnail(WorkspaceTarget target) async {
    final profile = _screenProfile;
    if (profile == null) return;
    try {
      final thumb = await target.displayThumbnail(profile);
      if (!mounted) return;
      setState(() {
        _thumbnail = thumb;
        _thumbnailSuppressed = thumb.suppressed != null;
      });
    } catch (_) {
      // Thumbnail poll must not spam errors; leave the last frame.
    }
  }

  void _scheduleThumbnail(WorkspaceTarget target) {
    _cancelThumbnail();
    _thumbnailTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _tab == _BotsTab.screen) {
        unawaited(_refreshThumbnail(target));
      }
    });
  }

  Future<void> _startInstalling() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final result = await target.displayInstall(profile);
      if (!mounted) return;
      _toast(
        result.started
            ? 'Installing screen (${result.command ?? 'process launched'})'
            : 'Install declined: ${result.command ?? 'unknown reason'}',
      );
      await _loadScreen(target);
    } catch (e) {
      if (mounted) _toast('Install failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _startScreen() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final status = await target.displayStart(profile);
      if (!mounted) return;
      setState(() => _display = status);
      if (status.running) {
        await _refreshThumbnail(target);
        _scheduleThumbnail(target);
      }
    } catch (e) {
      if (mounted) _toast('Start failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _stopScreen() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final status = await target.displayStop(profile);
      if (!mounted) return;
      _cancelThumbnail();
      setState(() => _display = status);
    } catch (e) {
      if (mounted) _toast('Stop refused: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _takeOverScreen() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      String? viewerId = _watchViewerId;
      DisplayObserveResult? observe;
      if (viewerId == null) {
        try {
          observe = await target.displayObserve(profile);
          viewerId = observe.viewerId;
          _watchViewerId = viewerId;
        } catch (_) {
          // Not running yet or lease operation refused; fall back to a
          // lease-only acquire with an observe once started.
        }
      }
      if (viewerId == null) {
        if (!mounted) return;
        _toast('Screen is not up yet. Start it, then take over.');
        return;
      }
      final lease = await target.displayLeaseAcquire(
        profile,
        viewerId,
        reason: 'Take over from the bots workspace',
      );
      if (!mounted) return;
      setState(() {
        if (_display != null) {
          _display = _display!.copyWith(lease: lease);
        }
      });
    } catch (e) {
      if (mounted) _toast('Take over failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _handBackScreen() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final lease = await target.displayLeaseRelease(
        profile,
        viewerId: _watchViewerId,
        force: _watchViewerId == null,
      );
      if (!mounted) return;
      setState(() {
        if (_display != null) {
          _display = _display!.copyWith(lease: lease);
        }
        _watchViewerId = null;
      });
    } catch (e) {
      if (mounted) _toast('Hand back failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _switchSandboxImage() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final status = await target.displaySwitchSandboxImage(
        profile,
        approve: true,
      );
      if (!mounted) return;
      setState(() => _display = status);
    } catch (e) {
      if (mounted) _toast('Image switch failed: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  Future<void> _keepCurrentImage() async {
    final target = _target;
    final profile = _screenProfile;
    if (target == null || profile == null) return;
    setState(() => _screenBusy = true);
    try {
      final status = await target.displaySwitchSandboxImage(
        profile,
        approve: false,
      );
      if (!mounted) return;
      setState(() => _display = status);
    } catch (e) {
      if (mounted) _toast('Keep refused: $e');
    } finally {
      if (mounted) setState(() => _screenBusy = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<CanonicalChat> _openBotChat(BotRosterProfile bot) async {
    final target = await _bound();
    return target.resolveCanonicalChat(bot.name);
  }

  void _openCanonicalChat(BotRosterProfile bot) {
    unawaited(() async {
      try {
        final chat = await _openBotChat(bot);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BotChatPage(
              connection: widget.connection,
              storedId: chat.sessionId,
              title: botCanonicalChatTitle,
              profile: chat.profile,
            ),
          ),
        );
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
                ButtonSegment(
                  value: _BotsTab.relay,
                  label: Text('Relay'),
                  icon: Icon(Icons.send_outlined),
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
      case _BotsTab.relay:
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
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      banner,
                      style: TextStyle(
                        color: Colors.orange.shade900,
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
            _BotsTab.relay => _relayView(),
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
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
        onRelay: () {
          Navigator.of(sheetContext).pop();
          setState(() {
            _relayProfile = bot.name;
            _tab = _BotsTab.relay;
          });
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
            if (!mounted) return;
            _toast('Room created');
            await _loadRooms(target);
          } on WorkspaceException catch (e) {
            if (!mounted) return;
            setState(() => _roomsLoading = false);
            _toast('Room creation refused (${e.reason.name})');
          } catch (e) {
            if (!mounted) return;
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
            setState(() {
              _screenProfile = n;
              _display = null;
              _thumbnail = null;
              _watchViewerId = null;
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
                'Start the bot screen, then take over for input. Watch thumbnails while it runs.',
              ),
            ),
          ),
        if (status != null) _displayCard(status),
        if (status != null) _screenControls(status),
        if (status?.running == true) _thumbnailCard(),
        const SizedBox(height: 12),
        const Text(
          'No live RFB viewer is wired here: the Desktop uses the noVNC browser client for /api/display/ws, '
          'which is not available in this app. Use the real thumbnail, then Take over / Hand back to control the screen with the gateway’s lease. '
          'Status/install/switch-image are gateway-backed and are shown above.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _screenControls(DisplayStatus status) {
    final unsupported = !status.supported;
    final installed = status.installed;
    final running = status.running;
    final holdsLease = _watchViewerId != null;
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
                onPressed: _screenBusy ? null : _startInstalling,
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
                onPressed: _screenBusy || holdsLease ? null : _takeOverScreen,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Take over'),
              ),
            if (!unsupported && installed && running && holdsLease)
              OutlinedButton.icon(
                onPressed: _screenBusy ? null : _handBackScreen,
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
                  onPressed: _screenBusy ? null : _startInstalling,
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
            if (thumbnail != null && thumbnail.dataUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnail.dataUrl!,
                  errorBuilder: (_, _, _) => Container(
                    height: 96,
                    width: double.infinity,
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Thumbnail unavailable',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
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
        const Text(
          'Routines are [bot:<name>]-tagged jobs owned by the bot’s profile store. Legacy delegated routines are force-paused on load.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
      if (!mounted) return;
      await _loadRoutines(target);
    } catch (e) {
      if (mounted) {
        setState(() => _routinesLoading = false);
        _toast('$action failed: $e');
      }
    }
  }

  void _openRoutineDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _RoutineDialog(
        defaultProfile: _routinesProfile ?? _screenProfile ?? '',
        onAdd: (title, schedule, instruction, repeat) async {
          final target = _target;
          final profile = _routinesProfile;
          if (target == null || profile == null) return;
          setState(() => _routinesLoading = true);
          try {
            await target.botRoutineAdd(
              profile: profile,
              title: title,
              schedule: schedule,
              instruction: instruction,
              repeat: repeat,
            );
            if (!mounted) return;
            _toast('Routine added');
            await _loadRoutines(target);
          } catch (e) {
            if (!mounted) return;
            setState(() => _routinesLoading = false);
            _toast('Add failed: $e');
          }
        },
      ),
    );
  }

  // ── Relay ──────────────────────────────────────────────────────────────

  Widget _relayView() {
    final profiles = _roster.map((p) => p.name).toList();
    final selected = _relayProfile;
    final isCurrent = selected == _screenProfile;
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
            labelText: 'Target bot',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (n) {
            if (n == null) return;
            setState(() {
              _relayProfile = n;
              _relayResult = null;
            });
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Cross-connection delivery (relayed by this app). The message is sent to the target bot\'s '
          'profile through bot_relay.deliver.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _relayInput,
          maxLines: 5,
          maxLength: 65536,
          decoration: const InputDecoration(
            hintText: 'Message to the target bot',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _relayBusy || _relayInput.text.trim().isEmpty
              ? null
              : () => _sendRelay(),
          icon: const Icon(Icons.send),
          label: Text(
            isCurrent
                ? '${context.sharedL10n.send} to this bot'
                : '${context.sharedL10n.send} to @${botHandleFor(selected!)}',
          ),
        ),
        const SizedBox(height: 16),
        if (_relayResult != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery: ${_relayResult!.status.isEmpty ? 'unknown' : _relayResult!.status}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (_relayResult!.reply != null)
                    Text('Reply: ${_relayResult!.reply}'),
                  if (_relayResult!.error != null)
                    Text('Error: ${_relayResult!.error}'),
                  if (_relayResult!.reason != null)
                    Text('Reason: ${_relayResult!.reason}'),
                  if (_relayResult!.deliveryId != null)
                    Text(
                      'delivery_id: ${_relayResult!.deliveryId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _sendRelay() async {
    final target = _target;
    final profile = _relayProfile;
    final text = _relayInput.text.trim();
    if (target == null || profile == null || text.isEmpty) return;
    setState(() {
      _relayBusy = true;
      _relayResult = null;
    });
    try {
      final fromProfile = _effectiveProfile;
      final result = await target.botRelayDeliver(
        profile: profile,
        message: text,
        fromProfile: fromProfile,
        fromHandle: botHandleFor(fromProfile),
        fromConnection: widget.connection.id,
      );
      if (!mounted) return;
      setState(() => _relayResult = result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _relayResult = RelayDelivery(status: 'failed', error: '$e');
      });
    } finally {
      if (mounted) setState(() => _relayBusy = false);
    }
  }

  String get _effectiveProfile =>
      _target?.effectiveProfile?.trim().isNotEmpty == true
      ? _target!.effectiveProfile!
      : (_roster.firstOrNull?.name ?? 'default');
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
    required this.onRelay,
  });

  final BotRosterProfile bot;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenRoutines;
  final VoidCallback onOpenScreen;
  final VoidCallback onRelay;

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
                  OutlinedButton.icon(
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Send relay'),
                    onPressed: onRelay,
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
                  const Text(
                    'Select at least one member.',
                    style: TextStyle(color: Colors.grey),
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

class _RoutineDialog extends StatefulWidget {
  const _RoutineDialog({required this.defaultProfile, required this.onAdd});

  final String defaultProfile;
  final Future<void> Function(
    String title,
    String schedule,
    String instruction,
    int? repeat,
  )
  onAdd;

  @override
  State<_RoutineDialog> createState() => _RoutineDialogState();
}

class _RoutineDialogState extends State<_RoutineDialog> {
  final _titleInput = TextEditingController();
  final _scheduleInput = TextEditingController(text: '0 9 * * *');
  final _instructionInput = TextEditingController();
  final _repeatInput = TextEditingController(text: '1');
  bool _busy = false;

  @override
  void dispose() {
    _titleInput.dispose();
    _scheduleInput.dispose();
    _instructionInput.dispose();
    _repeatInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New routine'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Schedule is a raw cron string (e.g. 0 9 * * *).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleInput,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _scheduleInput,
              decoration: const InputDecoration(
                labelText: 'Schedule',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionInput,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Instruction',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _repeatInput,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Repeat (days)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.sharedL10n.cancel),
        ),
        FilledButton(
          onPressed:
              _busy ||
                  _titleInput.text.trim().isEmpty ||
                  _instructionInput.text.trim().isEmpty
              ? null
              : () async {
                  setState(() => _busy = true);
                  final repeat = int.tryParse(_repeatInput.text.trim());
                  await widget.onAdd(
                    _titleInput.text.trim(),
                    _scheduleInput.text.trim(),
                    _instructionInput.text.trim(),
                    repeat != null && repeat > 0 ? repeat : null,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
          child: _busy
              ? const CircularProgressIndicator()
              : Text(context.sharedL10n.add),
        ),
      ],
    );
  }
}

/// Pushed page hosting the canonical Bot Chat. The same page is used by
/// Classic and NextGen because it is a self-contained Material page.
class BotChatPage extends StatefulWidget {
  const BotChatPage({
    super.key,
    required this.connection,
    required this.storedId,
    required this.title,
    required this.profile,
  });

  final SavedConnection connection;
  final String storedId;
  final String title;
  final String profile;

  @override
  State<BotChatPage> createState() => _BotChatPageState();
}

class _BotChatPageState extends State<BotChatPage> {
  NextGenGateway? _gateway;
  NgChatController? _chat;
  bool _loading = true;
  String? _failure;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final gateway = NextGenGateway(widget.connection);
    _gateway = gateway;
    try {
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
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} · ${widget.profile}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failure != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not open Bot Chat: $_failure',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : NgChatView(key: ObjectKey(_chat), chat: _chat!),
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
