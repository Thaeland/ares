import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/connection.dart';
import '../models/session.dart';
import '../services/connection_mutation_barrier.dart';
import 'workspace_layout.dart';
import 'profile_presentation_store.dart';
import 'terminal_chat_link.dart';
import 'workspace_pane.dart';
import 'workspace_picker.dart';
import 'workspace_popout.dart';
import 'workspace_registry.dart';

class ParallelWorkspace extends StatefulWidget {
  ParallelWorkspace({
    required this.connection,
    required this.nextGen,
    required this.loadSessions,
    required this.buildChat,
    this.registry,
  }) : super(key: ValueKey((connection, nextGen)));
  final SavedConnection connection;
  final bool nextGen;
  final Future<List<Session>> Function() loadSessions;
  final Widget Function(BuildContext, Session, VoidCallback) buildChat;
  final WorkspaceRegistry? registry;

  @override
  State<ParallelWorkspace> createState() => _WorkspaceState();
}

enum _Command {
  split,
  swap,
  undock,
  stack,
  ratio,
  focus,
  hide,
  reload,
  close,
  others,
  right,
  all,
  reopen,
  previous,
  next,
  moveLeft,
  moveRight,
  save,
  restore,
  refresh,
  popout,
}

class _WorkspaceState extends State<ParallelWorkspace> {
  final _chatLinks = <String, TerminalChatLink>{};
  TerminalChatLink _link(String id) =>
      _chatLinks.putIfAbsent(id, () => TerminalChatLink(widget.connection, id));
  final _versions = <PaneRef, Object>{};
  Object _version(PaneRef pane) => _versions.putIfAbsent(pane, Object.new);
  WorkspaceLayout _layout = WorkspaceLayout();
  SharedPreferences? _prefs;
  Map<String, Session> _roster = {};
  late final _epoch = ConnectionMutationBarrier.capture(widget.connection.id);
  late String _key;
  bool _loading = true, _failed = false, _focus = false;
  PaneRef? _lastTouched;
  bool get _current =>
      mounted &&
      ConnectionMutationBarrier.isCurrent(widget.connection.id, _epoch);
  WorkspaceRegistry get _registry => widget.registry ?? aresWorkspaceRegistry;
  PaneRef? get _primary => _layout.primary;

  void _readLayout(SharedPreferences prefs) {
    final installed = ProfilePresentationStore(prefs).read(widget.connection);
    _key = workspaceLayoutKey(widget.connection, widget.nextGen, installed);
    final raw = prefs.get(_key), g = installed?.style.geometry;
    _layout = raw is String
        ? WorkspaceLayout.decode(raw)
        : g == null
        ? WorkspaceLayout()
        : WorkspaceLayout.unbound(
            paired: g.paired,
            stacked: g.stacked,
            percent: g.percent,
          );
  }

  void _presentationChanged() {
    final prefs = _prefs;
    if (!_current || prefs == null) return;
    final installed = ProfilePresentationStore(prefs).read(widget.connection);
    if (workspaceLayoutKey(widget.connection, widget.nextGen, installed) ==
        _key) {
      return;
    }
    setState(() {
      _versions.clear();
      _focus = false;
      _lastTouched = null;
      _readLayout(prefs);
    });
  }

  @override
  void dispose() {
    ProfilePresentationStore.revision.removeListener(_presentationChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ProfilePresentationStore.revision.addListener(_presentationChanged);
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      // An unavailable roster must not disable connection-level tools or
      // discard the user's layout. Restored chats wait for exact live rows.
      if (_prefs == null) {
        final prefs = await SharedPreferences.getInstance();
        if (!_current) return;
        setState(() {
          _prefs = prefs;
          _readLayout(prefs);
        });
      }
      final rows = await widget.loadSessions();
      if (!_current) return;
      setState(() {
        _roster = {
          for (final row in rows)
            if (!row.isLocalDraft && !row.archived && row.id.isNotEmpty)
              row.id: row,
        };
        _failed = false;
        _loading = false;
      });
    } catch (_) {
      if (_current) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  void _refresh() {
    if (_loading) return;
    setState(() => _loading = true);
    unawaited(_load());
  }

  void _message(String text) => ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text(text)));
  void _edit(VoidCallback apply) {
    if (!_current || _prefs == null) return;
    setState(() {
      apply();
      _versions.removeWhere((pane, _) => !_layout.tabs.contains(pane));
      _chatLinks.removeWhere(
        (id, _) => !_layout.tabs.any((pane) => pane.sessionId == id),
      );
      if (_primary == null) _focus = false;
    });
    // SharedPreferences updates its in-process cache synchronously and sends
    // writes on the ordered preferences channel. Do not retain account objects.
    unawaited(_persist(_prefs!, _key, _layout.encode()));
  }

  Future<void> _persist(
    SharedPreferences prefs,
    String key,
    String value,
  ) async {
    try {
      if (await prefs.setString(key, value)) return;
    } catch (_) {
      /* Show a local-only failure. */
    }
    if (_current) {
      _message('Layout changed in this window but could not be saved.');
    }
  }

  String _title(PaneRef ref) {
    if (isWorkspaceSlot(ref)) {
      return ref == firstWorkspaceSlot ? 'First pane' : 'Second pane';
    }
    if (ref.page.isNotEmpty) {
      return _registry.page(ref.page)?.label ?? 'Unavailable page';
    }
    final title = _roster[ref.sessionId]?.title;
    return title == null || title.isEmpty ? ref.sessionId : title;
  }

  void _open(PaneRef ref, {bool split = false}) => _edit(() {
    if (!_layout.open(ref, split: split)) {
      _message('Close a tab first (maximum ${WorkspaceLayout.maxTabs}).');
    }
  });
  void _close(PaneRef pane) => _edit(() {
    _layout.close(pane);
    _versions.remove(pane);
  });

  Future<void> _pick({bool split = false}) async {
    final items = <PaneRef>{
      if (split) ..._layout.tabs,
      for (final id in _roster.keys) chatPane(id),
    }..removeWhere((r) => split && r == _primary);
    final ref = await pickWorkspaceItem(
      context,
      split ? 'Dock beside current pane' : 'Add chat',
      [
        for (final ref in items)
          (value: ref, label: _title(ref), detail: ref.sessionId),
      ],
    );
    if (_current && ref != null) _open(ref, split: split);
  }

  WorkspaceTarget _target(String id, {PaneRef? owner}) {
    final row = _roster[id];
    final version = owner == null ? null : _version(owner);
    return WorkspaceTarget(
      widget.connection,
      row,
      widget.nextGen,
      () =>
          _current &&
          (owner == null || identical(version, _versions[owner])) &&
          (id.isEmpty || (row != null && identical(_roster[id], row))),
      row == null ? null : _link(id),
    );
  }

  Future<void> _run(WorkspaceContribution item, WorkspaceTarget target) async {
    if (!_current) return;
    final reason = item.reason(target);
    if (reason != null) {
      _message(reason);
      return;
    }
    switch (item) {
      case WorkspacePage():
        _open((
          sessionId: item.requiresSession ? target.session!.id : '',
          page: item.id,
        ), split: _primary != null);
      case WorkspaceAction():
        try {
          await item.run(context, target);
        } catch (_) {
          if (_current) {
            _message('Action failed. Check the connection and try again.');
          }
        }
    }
  }

  Future<void> _command(_Command command) async {
    final p = _primary;
    switch (command) {
      case _Command.split:
        await _pick(split: true);
      case _Command.swap:
        if (_layout.secondary case final s?) _open(s);
      case _Command.undock:
        _edit(() => _layout.secondary = null);
      case _Command.stack:
        _edit(() => _layout.stacked = !_layout.stacked);
      case _Command.ratio:
        _edit(
          () => _layout.percent = switch (_layout.percent) {
            50 => 60,
            60 => 40,
            _ => 50,
          },
        );
      case _Command.focus:
        setState(() => _focus = true);
      case _Command.hide:
        if (p != null) _edit(() => _layout.hide(p));
      case _Command.reload:
        if (p != null) _edit(() => _versions[p] = Object());
      case _Command.previous:
        _edit(() => _layout.cycle(-1));
      case _Command.next:
        _edit(() => _layout.cycle(1));
      case _Command.moveLeft:
        if (p != null) _edit(() => _layout.move(p, -1));
      case _Command.moveRight:
        if (p != null) _edit(() => _layout.move(p, 1));
      case _Command.close:
        if (p != null) _close(p);
      case _Command.others || _Command.right || _Command.all:
        final tabs = _layout.tabs.toList();
        final remove = switch (command) {
          _Command.others => tabs.where((r) => r != p),
          _Command.right => tabs.skip(tabs.indexOf(p!) + 1),
          _ => tabs,
        };
        _edit(() {
          for (final r in remove.toList().reversed) {
            _layout.close(r);
            _versions.remove(r);
          }
        });
      case _Command.reopen:
        _edit(() {
          if (!_layout.reopen()) {
            _message('Close a tab before reopening another.');
          }
        });
      case _Command.save:
        final name = await nameWorkspaceLayout(context);
        if (!mounted || !_current || name == null) return;
        if (_layout.saved.containsKey(name)) {
          final overwrite = await showDialog<bool>(
            context: context,
            useRootNavigator: false,
            builder: (context) => AlertDialog(
              title: Text('Replace layout “$name”?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Replace'),
                ),
              ],
            ),
          );
          if (overwrite != true || !_current) return;
        }
        _edit(() {
          if (!_layout.save(name)) {
            _message('Layout limit reached. Replace an existing layout.');
          }
        });
      case _Command.restore:
        final name = await pickWorkspaceItem(context, 'Restore layout', [
          for (final name in _layout.saved.keys)
            (value: name, label: name, detail: ''),
        ]);
        if (_current && name != null) _edit(() => _layout.restore(name));
      case _Command.refresh:
        _refresh();
      case _Command.popout:
        if (p != null && p.page.isEmpty && _roster.containsKey(p.sessionId)) {
          await openWorkspacePopout(
            context,
            sessionId: p.sessionId,
            connectionId: widget.connection.id,
            profile: widget.connection.gatewayProfile ?? '',
            nextGen: widget.nextGen,
          );
        }
    }
  }

  Widget _menu() {
    final p = _primary, pair = _layout.secondary != null, tabs = _layout.tabs;
    PopupMenuItem<_Command> item(
      _Command cmd,
      String label, [
      bool enabled = true,
    ]) => PopupMenuItem(value: cmd, enabled: enabled, child: Text(label));
    return PopupMenuButton<_Command>(
      tooltip: 'Workspace options',
      onSelected: _command,
      itemBuilder: (_) => [
        item(_Command.split, 'Dock another pane', p != null),
        item(_Command.swap, 'Swap panes', pair),
        item(_Command.undock, 'Undock second pane', pair),
        item(
          _Command.stack,
          _layout.stacked ? 'Arrange side by side' : 'Arrange top to bottom',
          pair,
        ),
        item(_Command.ratio, 'Change split size (${_layout.percent}%)', pair),
        item(_Command.focus, 'Focus pane full screen', p != null),
        if (supportsWorkspacePopout)
          item(
            _Command.popout,
            'Open chat in new window',
            p != null && p.page.isEmpty && _roster.containsKey(p.sessionId),
          ),
        item(_Command.hide, 'Hide pane (keep running)', p != null),
        item(_Command.previous, 'Previous tab', tabs.length > 1),
        item(_Command.next, 'Next tab', tabs.length > 1),
        item(
          _Command.moveLeft,
          'Move tab left',
          p != null && tabs.indexOf(p) > 0,
        ),
        item(
          _Command.moveRight,
          'Move tab right',
          p != null && tabs.indexOf(p) < tabs.length - 1,
        ),
        item(_Command.reload, 'Reload current tab', p != null),
        item(_Command.close, 'Close tab', p != null),
        item(_Command.others, 'Close other tabs', p != null && tabs.length > 1),
        item(
          _Command.right,
          'Close tabs to the right',
          p != null && tabs.indexOf(p) < tabs.length - 1,
        ),
        item(_Command.all, 'Close all tabs', tabs.isNotEmpty),
        item(_Command.reopen, 'Reopen closed tab', _layout.closed.isNotEmpty),
        item(_Command.save, 'Save named layout', _prefs != null),
        item(
          _Command.restore,
          'Restore named layout',
          _layout.saved.isNotEmpty,
        ),
        item(_Command.refresh, 'Refresh chat list', !_loading),
      ],
    );
  }

  Widget _tools() {
    final target = _target(_primary?.sessionId ?? '', owner: _primary);
    return PopupMenuButton<WorkspaceContribution>(
      tooltip: 'Workspace tools',
      icon: const Icon(Icons.extension_outlined),
      onSelected: (c) => _run(c, target),
      itemBuilder: (_) => [
        for (final c in _registry.entries)
          PopupMenuItem(
            value: c,
            enabled: c.reason(target) == null,
            child: ListTile(
              leading: Icon(c.icon),
              title: Text(c.label),
              subtitle: c.reason(target) == null
                  ? null
                  : Text(c.reason(target)!),
            ),
          ),
      ],
    );
  }

  Future<void> _chooseForSlot(PaneRef slot) async {
    final version = _version(slot);
    final rows = {
      for (final r in _roster.values)
        if (!_layout.tabs.contains(chatPane(r.id))) r.id: r,
    };
    final selected = await pickWorkspaceItem(
      context,
      'Choose a chat for this pane',
      [
        for (final r in rows.values)
          (value: r.id, label: r.title, detail: r.id),
      ],
    );
    if (!_current ||
        selected == null ||
        !identical(rows[selected], _roster[selected]) ||
        !identical(_versions[slot], version)) {
      return;
    }
    _edit(() => _layout.fillSlot(slot, selected));
  }

  Widget _content(BuildContext context, PaneRef ref) {
    if (isWorkspaceSlot(ref)) {
      return Center(
        child: TextButton.icon(
          onPressed: () => _chooseForSlot(ref),
          icon: const Icon(Icons.add_comment_outlined),
          label: Text('Choose chat for ${_title(ref).toLowerCase()}'),
        ),
      );
    }
    final row = _roster[ref.sessionId];
    if (ref.page.isEmpty && row != null) {
      return TerminalChatSlot(
        link: _link(row.id),
        child: widget.buildChat(context, row, () => _close(ref)),
      );
    }
    final page = _registry.page(ref.page);
    if (page != null) {
      final target = _target(ref.sessionId, owner: ref);
      final reason = page.reason(target);
      if (reason == null) {
        return Builder(builder: (ctx) => page.build(ctx, target));
      }
    }
    return Center(
      child: Text(
        'This ${ref.page.isEmpty ? 'chat' : 'page'} is not available for this connection.',
      ),
    );
  }

  Widget _panes(BoxConstraints box) {
    final p = _primary, s = _layout.secondary;
    final vertical = _layout.stacked;
    final minSide =
        (vertical ? box.maxHeight : box.maxWidth) *
        (_layout.percent <= 50 ? _layout.percent : 100 - _layout.percent) /
        100;
    final both =
        !_focus &&
        s != null &&
        (vertical ? minSide >= 340 && box.maxWidth >= 360 : minSide >= 440);
    final first =
        (vertical ? box.maxHeight : box.maxWidth) * _layout.percent / 100;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (p == null)
          Center(
            child: Text(
              _layout.tabs.isEmpty
                  ? 'Add a chat to start a workspace.'
                  : 'Select a tab to show its pane.',
            ),
          ),
        for (final ref in _layout.tabs)
          Positioned(
            key: ValueKey(ref),
            left: both && !vertical && ref == s ? first + 1 : 0,
            right: both && !vertical && ref == p ? box.maxWidth - first : 0,
            top: both && vertical && ref == s ? first + 1 : 0,
            bottom: both && vertical && ref == p ? box.maxHeight - first : 0,
            child: Offstage(
              offstage: ref != p && !(both && ref == s),
              child: ExcludeFocus(
                excluding: ref != p && !(both && ref == s),
                child: TickerMode(
                  enabled: ref == p || (both && ref == s),
                  child: LayoutBuilder(
                    builder: (ctx, local) => MediaQuery(
                      data: MediaQuery.of(ctx).copyWith(size: local.biggest),
                      child: Listener(
                        onPointerDown: (_) {
                          if (_lastTouched != ref) {
                            setState(() => _lastTouched = ref);
                          }
                        },
                        child: WorkspacePane(
                          key: ObjectKey(_version(ref)),
                          handleBack:
                              ref == (both && _lastTouched == s ? s : p),
                          child: Builder(builder: (ctx) => _content(ctx, ref)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _focus && p != null ? _title(p) : 'Parallel workspace',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: _focus
            ? IconButton(
                tooltip: 'Show workspace',
                icon: const Icon(Icons.fullscreen_exit),
                onPressed: () => setState(() => _focus = false),
              )
            : null,
        actions: _focus
            ? null
            : [
                IconButton(
                  tooltip: 'Add chat',
                  icon: const Icon(Icons.add_comment_outlined),
                  onPressed: _prefs == null ? null : () => _pick(),
                ),
                _tools(),
                _menu(),
              ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            if (_failed)
              TextButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Could not load chats. Retry'),
              ),
            if (!_focus && _layout.tabs.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final ref in _layout.tabs)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InputChip(
                          selected: p == ref,
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              _title(ref),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          avatar: ref == _layout.secondary
                              ? const Icon(Icons.splitscreen, size: 16)
                              : null,
                          onPressed: () => _open(ref),
                          onDeleted: () => _close(ref),
                          deleteButtonTooltipMessage: 'Close ${_title(ref)}',
                        ),
                      ),
                  ],
                ),
              ),
            if (_layout.secondary case final s? when !_focus)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: () => _open(s),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(
                    'Switch pane: ${_title(s)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            Expanded(child: LayoutBuilder(builder: (_, box) => _panes(box))),
          ],
        ),
      ),
    );
  }
}
