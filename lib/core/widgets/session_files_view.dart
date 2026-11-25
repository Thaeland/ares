import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/connection_mutation_barrier.dart';
import '../services/remote_workspace.dart';
import 'git_review_pane.dart';
import 'markdown_file_preview.dart';

/// Same tree beside either chat; on a phone it takes the body while the live
/// transcript stays mounted. No second session or local filesystem is opened.
class SessionFilesLayout extends StatelessWidget {
  const SessionFilesLayout({super.key, required this.child, this.files});
  final Widget child;
  final SessionFilesView? files;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= 850;
      return Stack(
        children: [
          Positioned.fill(
            right: files != null && wide ? 360 : 0,
            child: Offstage(offstage: files != null && !wide, child: child),
          ),
          if (files != null)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: wide ? 360 : box.maxWidth,
              child: files!,
            ),
        ],
      );
    },
  );
}

void appendWorkspaceReference(TextEditingController input, String reference) {
  final text = input.text.isEmpty
      ? '$reference '
      : '${input.text}\n$reference ';
  input.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

class SessionFilesView extends StatefulWidget {
  const SessionFilesView({
    super.key,
    required this.owner,
    required this.route,
    required this.onReference,
    required this.onClose,
    this.onHandOff,
    this.onGitClosed,
    this.startOnGit = false,
    this.focusGitFile,
    this.turnBaseline,
  });
  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final ValueChanged<String> onReference;
  final VoidCallback onClose;
  final ValueChanged<String>? onHandOff;
  final VoidCallback? onGitClosed;
  final bool startOnGit;
  final String? focusGitFile;
  final String? turnBaseline;
  @override
  State<SessionFilesView> createState() => _FilesState();
}

class _FilesState extends State<SessionFilesView> {
  late WorkspacePane _pane;
  Object? _account;
  WorkspaceTarget? _target;
  final _rows = <String, List<WorkspaceEntry>>{};
  final _expanded = <String>{};
  Set<String> _changed = {};
  WorkspaceDocument? _file;
  final _source = TextEditingController();
  int _epoch = 0;
  bool _busy = false;
  bool _showIgnored = false;
  bool _editing = false;
  bool _showSource = false;
  bool _review = false;
  bool _git = false;
  String? _message;
  bool get _dirty => _editing && _file != null && _source.text != _file!.text;
  bool _owns(int e) => mounted && e == _epoch;

  @override
  void initState() {
    super.initState();
    ConnectionMutationBarrier.addListener(_revoked);
    _git = widget.startOnGit;
    _bind();
  }

  @override
  void didUpdateWidget(SessionFilesView old) {
    super.didUpdateWidget(old);
    if (old.route != widget.route || old.owner != widget.owner) {
      _pane.close();
      _bind();
    }
    if (widget.startOnGit && !old.startOnGit) _git = true;
  }

  void _bind() {
    _pane = widget.owner.pane();
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    _clear();
    _reload();
  }

  void _clear() {
    _epoch++;
    _rows.clear();
    _expanded.clear();
    _changed = {};
    _file = null;
    _source.clear();
    _editing = false;
    _review = false;
    _target = null;
    _busy = false;
  }

  void _revoked() {
    if (!ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      _pane.invalidate();
      setState(() {
        _clear();
        _message = 'Connection changed. Reopen files on the new connection.';
      });
    }
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_revoked);
    _pane.close();
    _epoch++;
    _source.dispose();
    super.dispose();
  }

  String _failure(Object e) => e is WorkspaceException
      ? switch (e.reason) {
          WorkspaceFailure.stale =>
            'The connection or session changed. Reopen this pane.',
          WorkspaceFailure.unbound =>
            'No verified host working directory for this session.',
          WorkspaceFailure.denied => 'The gateway denied this operation.',
          WorkspaceFailure.unsupported =>
            'This gateway does not support this operation.',
          WorkspaceFailure.mismatch =>
            'The file, owner or working directory changed. Reload and review.',
          WorkspaceFailure.invalid =>
            'The gateway returned an unsafe path or invalid file response.',
          WorkspaceFailure.insecure =>
            'Workspace access requires a secure gateway connection.',
          WorkspaceFailure.unavailable =>
            'Gateway unavailable. Refresh to check the current state.',
        }
      : 'Gateway operation could not be confirmed.';

  Future<void> _reload() async {
    final previous = {..._expanded};
    final e = ++_epoch;
    setState(() {
      _target = null;
      _rows.clear();
      _expanded.clear();
      _changed = {};
      _message = null;
      _busy = true;
    });
    try {
      final t = await _pane.bind(widget.route);
      final root = t.fileRoot;
      final listing = await t.listSessionFiles();
      final fresh = {root: listing};
      final expanded = <String>{};
      // Re-expand only folders freshly re-issued beneath the new root.
      final queue = [...listing];
      for (var i = 0; i < queue.length; i++) {
        if (!_owns(e)) return;
        final n = queue[i];
        if (n.directory && previous.contains(n.path)) {
          final kids = await t.listSessionFiles(n);
          fresh[n.path] = kids;
          expanded.add(n.path);
          queue.addAll(kids);
        }
      }
      Set<String> changed = {};
      String? statusMessage;
      try {
        changed = await t.changedPaths();
      } on WorkspaceException catch (err) {
        if (err.reason == WorkspaceFailure.stale ||
            err.reason == WorkspaceFailure.mismatch) {
          rethrow;
        }
        statusMessage = 'Git status unavailable.';
      }
      if (!_owns(e)) return;
      t.checkCurrent();
      setState(() {
        _target = t;
        _rows.addAll(fresh);
        _expanded.addAll(expanded);
        _changed = changed;
        _message = statusMessage;
      });
    } catch (err) {
      if (_owns(e)) setState(() => _message = _failure(err));
    } finally {
      if (_owns(e)) setState(() => _busy = false);
    }
  }

  Future<void> _act(Future<void> Function(WorkspaceTarget t, int e) f) async {
    final t = _target;
    if (t == null || _busy) return;
    final e = ++_epoch;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      t.checkCurrent();
      await f(t, e);
    } catch (err) {
      if (_owns(e)) setState(() => _message = _failure(err));
    } finally {
      if (_owns(e)) setState(() => _busy = false);
    }
  }

  Future<void> _open(WorkspaceEntry node) => _act((t, e) async {
    if (node.directory) {
      if (_expanded.contains(node.path)) {
        setState(() => _expanded.remove(node.path));
        return;
      }
      final list = await t.listSessionFiles(node);
      if (!_owns(e)) return;
      t.checkCurrent();
      setState(() {
        _rows[node.path] = list;
        _expanded.add(node.path);
      });
      return;
    }
    final file = await t.readDocument(node);
    if (!_owns(e)) return;
    t.checkCurrent();
    setState(() => _display(file));
  });
  void _display(WorkspaceDocument file) {
    _file = file;
    _source.text = file.text;
    _editing = false;
    _review = false;
    _showSource = !isMarkdownFilename(file.entry.name);
  }

  Future<void> _reference(
    WorkspaceEntry n, {
    bool lines = false,
    bool relative = false,
    bool copy = false,
  }) => _act((t, e) async {
    final selection = _source.selection;
    await t.verifySession();
    if (!_owns(e)) return;
    t.checkCurrent();
    var suffix = '';
    if (lines) {
      if (!selection.isValid ||
          selection.isCollapsed ||
          _editing ||
          _file?.entry != n) {
        return;
      }
      int lineAt(int offset) =>
          '\n'.allMatches(_source.text.substring(0, offset)).length + 1;
      final first = lineAt(selection.start), last = lineAt(selection.end - 1);
      suffix = first == last ? ':$first' : ':$first-$last';
    }
    final path = '${relative ? n.relative : n.path}$suffix';
    if (copy) {
      await Clipboard.setData(ClipboardData(text: path));
    } else {
      widget.onReference('@${n.directory ? 'folder' : 'file'} $path');
    }
  });

  Future<void> _move() => _act((t, e) async {
    final fences = await t.cwdFences();
    if (!mounted || !_owns(e)) return;
    var draft = t.fileRoot;
    final path = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change this chat’s working directory?'),
        content: TextFormField(
          initialValue: draft,
          onChanged: (v) => draft = v,
          decoration: const InputDecoration(
            labelText: 'Absolute gateway directory',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, draft),
            child: const Text('Change directory'),
          ),
        ],
      ),
    );
    if (path == null || !_owns(e)) return;
    await t.changeCwd(path, fences);
    if (!_owns(e)) return;
    _expanded.clear();
    await _reload();
  });

  Future<void> _save() => _act((t, e) async {
    final file = _file!, draft = _source.text;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace gateway file?'),
        content: Text(
          '${file.entry.path}\n\nOnly if the file still matches the version you reviewed. A compatible host retains the displaced file for recovery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    if (ok != true || !_owns(e)) return;
    try {
      final saved = await t.replaceDocument(file, draft);
      if (!_owns(e)) return;
      t.checkCurrent();
      setState(() {
        _display(saved);
        _message = 'Saved and verified on the gateway.';
      });
    } on WorkspaceException catch (err) {
      if (!_owns(e)) return;
      setState(() {
        _review = true;
        _message = err.reason == WorkspaceFailure.unsupported
            ? 'Guarded saving is unavailable on this gateway. Your draft is still here.'
            : '${_failure(err)} Save was not confirmed. Your draft is still here.';
      });
    }
  });

  Future<void> _reviewLatest() => _act((t, e) async {
    final original = _file!;
    final current = await t.readDocument(original.entry);
    if (!mounted || !_owns(e)) return;
    final choice = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review current gateway version'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(child: SelectableText(current.text)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Discard draft and reload'),
          ),
          if (current.editable)
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keep draft against this version'),
            ),
        ],
      ),
    );
    if (choice == null || !_owns(e)) return;
    t.checkCurrent();
    setState(() {
      if (choice) {
        _file = current;
        _review = false;
      } else {
        _display(current);
      }
    });
  });

  Future<void> _back() async {
    if (_busy) return;
    final e = _epoch;
    if (_dirty &&
        await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Discard unsaved edits?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Keep editing'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Discard edits'),
                  ),
                ],
              ),
            ) !=
            true) {
      return;
    }
    if (!_owns(e)) return;
    if (_file == null) {
      widget.onClose();
      return;
    }
    setState(() {
      _file = null;
      _source.clear();
      _editing = false;
      _review = false;
      _message = null;
    });
  }

  Iterable<({WorkspaceEntry node, int depth})> _visible(
    String path, [
    int depth = 0,
  ]) sync* {
    for (final n in _rows[path] ?? const <WorkspaceEntry>[]) {
      if (!_showIgnored && n.ignored == true) continue;
      yield (node: n, depth: depth);
      if (n.directory && _expanded.contains(n.path)) {
        yield* _visible(n.path, depth + 1);
      }
    }
  }

  Widget _tree(WorkspaceTarget t) {
    final visible = _visible(t.fileRoot).toList();
    final flags = (_rows.values.expand((v) => v)).any((n) => n.ignored != null);
    return Column(
      children: [
        ListTile(
          title: const Text('Remote working directory'),
          subtitle: SelectableText(t.fileRoot),
          trailing: IconButton(
            tooltip: 'Change working directory',
            icon: const Icon(Icons.drive_file_move_outline),
            onPressed: _busy ? null : _move,
          ),
        ),
        if (flags)
          CheckboxListTile(
            dense: true,
            title: const Text('Show ignored files'),
            value: _showIgnored,
            onChanged: (v) => setState(() => _showIgnored = v ?? false),
          ),
        if (!flags && visible.isNotEmpty)
          const Text('Gateway does not report ignored status.'),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No visible entries'))
              : ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (ctx, i) {
                    final n = visible[i].node;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: (visible[i].depth.clamp(0, 6) * 10).toDouble(),
                      ),
                      child: ListTile(
                        dense: true,
                        enabled: !_busy,
                        leading: Icon(
                          n.directory
                              ? (_expanded.contains(n.path)
                                    ? Icons.folder_open
                                    : Icons.folder_outlined)
                              : Icons.description_outlined,
                        ),
                        title: Text(n.name),
                        subtitle: _changed.contains(n.path)
                            ? const Text('Changed')
                            : n.ignored == true
                            ? const Text('Ignored')
                            : null,
                        onTap: () => _open(n),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Actions for ${n.name}',
                          enabled: !_busy,
                          onSelected: (v) {
                            if (n.owner == _target) {
                              _reference(
                                n,
                                relative: v == 'relative',
                                copy: v != 'attach',
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'relative',
                              child: Text('Copy relative path'),
                            ),
                            const PopupMenuItem(
                              value: 'absolute',
                              child: Text('Copy gateway path'),
                            ),
                            PopupMenuItem(
                              value: 'attach',
                              child: Text(
                                n.directory
                                    ? 'Attach folder reference'
                                    : 'Attach file reference',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _document(WorkspaceDocument file) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SelectableText(file.entry.relative),
      if (file.truncated) const Text('Preview truncated — editing disabled.'),
      Wrap(
        children: [
          if (!_editing && !file.binary)
            TextButton(
              onPressed: () => setState(() => _showSource = true),
              child: const Text('Select lines'),
            ),
          if (!_editing && file.editable)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _editing = true;
                      _showSource = true;
                    }),
              child: const Text('Edit'),
            ),
          if (_editing)
            TextButton(
              onPressed: _busy || _review || !_dirty ? null : _save,
              child: const Text('Save'),
            ),
          if (_review)
            TextButton(
              onPressed: _busy ? null : _reviewLatest,
              child: const Text('Review gateway version'),
            ),
          if (!_editing && _showSource && !file.binary)
            ValueListenableBuilder(
              valueListenable: _source,
              builder: (ctx, v, _) => TextButton(
                onPressed:
                    _busy || !v.selection.isValid || v.selection.isCollapsed
                    ? null
                    : () => _reference(file.entry, lines: true),
                child: const Text('Attach selected lines'),
              ),
            ),
        ],
      ),
      Expanded(
        child: file.binary
            ? const Center(child: Text('Binary file — no text preview.'))
            : !_showSource
            ? MarkdownFilePreview(
                key: ValueKey(file.entry.path),
                text: file.text,
              )
            : TextField(
                controller: _source,
                readOnly: !_editing || _busy,
                expands: true,
                minLines: null,
                maxLines: null,
                style: const TextStyle(fontFamily: 'monospace'),
                onChanged: (_) => setState(() {}),
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'File source',
                  alignLabelWithHint: true,
                ),
              ),
      ),
    ],
  );

  String? _recordedTurnBaseline() {
    final session = widget.route.storedSessionId;
    final cwd = _target?.canonicalCwd;
    if (session == null || cwd == null) return null;
    return gitTurnMemory.baselineFor(
      ownerId: widget.owner.connectionId,
      profile: widget.owner.profile,
      sessionId: session,
      cwd: cwd,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_git) {
      return GitReviewPane(
        owner: widget.owner,
        route: widget.route,
        turnBaseline: _recordedTurnBaseline() ?? widget.turnBaseline,
        initialFile: widget.focusGitFile,
        onHandOff: widget.onHandOff,
        onClose: () {
          setState(() => _git = false);
          widget.onGitClosed?.call();
        },
      );
    }
    final t = _target;
    final file = _file;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Material(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: file == null
                          ? 'Close session files'
                          : 'Back to tree',
                      icon: Icon(file == null ? Icons.close : Icons.arrow_back),
                      onPressed: _busy ? null : _back,
                    ),
                    const Expanded(child: Text('Session files')),
                    if (file == null)
                      IconButton(
                        key: const Key('open-git-review'),
                        tooltip: 'Git review',
                        icon: const Icon(Icons.difference_outlined),
                        onPressed: _busy
                            ? null
                            : () => setState(() => _git = true),
                      ),
                    if (file == null)
                      IconButton(
                        tooltip: 'Refresh tree',
                        icon: const Icon(Icons.refresh),
                        onPressed: _busy ? null : _reload,
                      ),
                  ],
                ),
                if (_busy) const LinearProgressIndicator(),
                if (_message != null) Text(_message!),
                if (t != null)
                  Expanded(child: file == null ? _tree(t) : _document(file)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
