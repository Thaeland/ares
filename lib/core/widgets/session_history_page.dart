import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../services/remote_workspace.dart';

/// Branch, rewind, checkpoints, export and Claude/Codex import for one chat.
///
/// Classic and NextGen both open this page. It uses the owner that supplied
/// the session, not whichever gateway was opened last.
class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({
    super.key,
    required this.owner,
    required this.storedSessionId,
    this.onRewound,
  });

  final RemoteWorkspaceOwner owner;
  final String storedSessionId;
  final ValueChanged<String>? onRewound;

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  late final WorkspacePane _pane = widget.owner.pane();
  WorkspaceTarget? _target;
  var _loading = true;
  var _busy = false;
  String? _error;
  List<HistoryMessage> _messages = const [];
  ShownSessionLineage? _lineage;
  List<HistoryCheckpoint> _checkpoints = const [];
  int? _selectedRow;
  String? _selectedHash;
  String? _diff;
  String _format = 'md';
  var _redact = true;
  String? _foreignSource;
  ForeignSessionPage? _foreign;
  String? _selectedForeign;
  ForeignPreviewView? _foreignPreview;
  var _foreignUnsupported = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pane.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final target = await _pane.bind(
        widget.owner.route(storedSessionId: widget.storedSessionId),
      );
      final messages = await target.transcript();
      final lineage = await target.lineage();
      final checkpoints = await target.checkpoints();
      ForeignSessionPage? foreign;
      try {
        foreign = await target.foreignSessions();
      } on WorkspaceException catch (error) {
        if (error.reason != WorkspaceFailure.unsupported) rethrow;
        _foreignUnsupported = true;
      }
      if (!mounted || !target.isCurrent) return;
      setState(() {
        _target = target;
        _messages = messages;
        _lineage = lineage;
        _checkpoints = checkpoints;
        _foreign = foreign;
        _loading = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.reason.name;
        _loading = false;
      });
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const ValueKey('history-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return answer == true && mounted;
  }

  Future<void> _branch() async {
    final target = _target;
    final row = _selectedRow;
    if (target == null || row == null || _busy) return;
    final confirmed = await _confirm(
      'Branch from this message',
      'This creates a new chat containing history through the selected '
          'message. The current chat stays as it is.',
    );
    if (!confirmed || !target.isCurrent) return;
    setState(() => _busy = true);
    try {
      final fences = await target.historyFences();
      if (!target.isCurrent) return;
      final receipt = await target.branchAtMessage(
        throughMessageId: row,
        confirmed: true,
        fences: fences,
      );
      if (!mounted) return;
      setState(() {
        _notice = 'Branched as ${receipt.sessionId}';
        _busy = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.reason.name;
        _busy = false;
      });
    }
  }

  Future<void> _rewind() async {
    final target = _target;
    final row = _selectedRow;
    if (target == null || row == null || _busy) return;
    final confirmed = await _confirm(
      'Rewind to this message',
      'Messages from the selected one onward are removed from this chat. '
          'Files on the computer are not changed. Restoring those is a '
          'separate checkpoint action.',
    );
    if (!confirmed || !target.isCurrent) return;
    setState(() => _busy = true);
    try {
      final fences = await target.historyFences();
      if (!target.isCurrent) return;
      final receipt = await target.rewindAtMessage(
        targetMessageId: row,
        confirmed: true,
        fences: fences,
      );
      if (!mounted) return;
      widget.onRewound?.call(receipt.text);
      if (!mounted) return;
      Navigator.pop(context);
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.reason.name;
        _busy = false;
      });
    }
  }

  Future<void> _showDiff(String hash) async {
    final target = _target;
    if (target == null) return;
    setState(() {
      _selectedHash = hash;
      _diff = null;
    });
    try {
      final diff = await target.checkpointDiff(hash);
      if (!mounted || !target.isCurrent) return;
      setState(() => _diff = diff.text.isEmpty ? 'No differences.' : diff.text);
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.reason.name);
    }
  }

  Future<void> _restore() async {
    final target = _target;
    final hash = _selectedHash;
    if (target == null || hash == null || _busy) return;
    final confirmed = await _confirm(
      'Restore this checkpoint',
      'This replaces files in the session directory with the selected '
          'checkpoint. A full restore can also remove later chat messages. '
          'It does not branch the conversation.',
    );
    if (!confirmed || !target.isCurrent) return;
    setState(() => _busy = true);
    try {
      final receipt = await target.restoreCheckpoint(
        hash: hash,
        confirmed: true,
      );
      if (!mounted) return;
      final removed = receipt.historyRemoved;
      setState(() {
        _notice = removed == null
            ? 'Checkpoint restored'
            : 'Checkpoint restored. $removed chat messages were removed.';
        _busy = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.reason.name;
        _busy = false;
      });
    }
  }

  Future<void> _export() async {
    final target = _target;
    if (target == null || _busy) return;
    setState(() => _busy = true);
    try {
      final exported = await target.exportTranscript(
        format: _format,
        redact: _redact,
      );
      if (!mounted || !target.isCurrent) return;
      await SharePlus.instance.share(
        ShareParams(subject: exported.filename, text: exported.content),
      );
      if (!mounted) return;
      setState(() => _busy = false);
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.reason.name;
        _busy = false;
      });
    }
  }

  Future<void> _reloadForeign(String? source) async {
    final target = _target;
    if (target == null) return;
    setState(() {
      _foreignSource = source;
      _selectedForeign = null;
      _foreignPreview = null;
    });
    try {
      final page = await target.foreignSessions(source: source);
      if (!mounted || !target.isCurrent) return;
      setState(() {
        _foreignUnsupported = false;
        _foreign = page;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      if (error.reason == WorkspaceFailure.unsupported) {
        setState(() {
          _foreignUnsupported = true;
          _foreign = null;
        });
        return;
      }
      setState(() => _error = error.reason.name);
    }
  }

  Future<void> _previewForeign(String id) async {
    final target = _target;
    if (target == null) return;
    setState(() {
      _selectedForeign = id;
      _foreignPreview = null;
    });
    try {
      final preview = await target.previewForeign(id);
      if (!mounted || !target.isCurrent) return;
      setState(() => _foreignPreview = preview);
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      if (error.reason == WorkspaceFailure.unsupported) {
        setState(() {
          _foreignUnsupported = true;
          _foreignPreview = null;
        });
        return;
      }
      setState(() => _error = error.reason.name);
    }
  }

  Future<void> _importForeign() async {
    final target = _target;
    final id = _selectedForeign;
    final preview = _foreignPreview;
    if (target == null || id == null || preview == null || _busy) return;
    final confirmed = await _confirm(
      'Import this session',
      preview.alreadyImported == null
          ? 'Copy this Claude or Codex session into the current profile '
                'and open nothing until you choose the new chat.'
          : 'This session was already imported. Open the existing copy.',
    );
    if (!confirmed || !target.isCurrent) return;
    setState(() => _busy = true);
    try {
      final receipt = await target.importForeign(id);
      if (!mounted) return;
      setState(() {
        _notice = receipt.alreadyImported
            ? 'Already imported as ${receipt.sessionId}'
            : 'Imported as ${receipt.sessionId}';
        _busy = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      if (error.reason == WorkspaceFailure.unsupported) {
        setState(() {
          _foreignUnsupported = true;
          _foreignPreview = null;
          _busy = false;
        });
        return;
      }
      setState(() {
        _error = error.reason.name;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session history')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) Text('Could not finish: $_error'),
                if (_notice != null)
                  Text(_notice!, key: const ValueKey('history-notice')),
                const SizedBox(height: 12),
                Text('Lineage', style: Theme.of(context).textTheme.titleMedium),
                _lineageTiles(),
                const SizedBox(height: 16),
                Text(
                  'Messages',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text('Select a saved message to branch or rewind there.'),
                for (final message in _messages)
                  ListTile(
                    key: ValueKey('history-message-${message.rowId}'),
                    selected: _selectedRow == message.rowId,
                    title: Text(message.role),
                    subtitle: Text(
                      message.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => setState(() => _selectedRow = message.rowId),
                  ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      key: const ValueKey('history-branch'),
                      onPressed: _selectedRow == null || _busy ? null : _branch,
                      child: const Text('Branch from here'),
                    ),
                    OutlinedButton(
                      key: const ValueKey('history-rewind'),
                      onPressed: _selectedRow == null || _busy ? null : _rewind,
                      child: const Text('Rewind to here'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Checkpoints',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_checkpoints.isEmpty)
                  const Text('This session has no filesystem checkpoints.'),
                for (final checkpoint in _checkpoints)
                  ListTile(
                    key: ValueKey('history-checkpoint-${checkpoint.hash}'),
                    selected: _selectedHash == checkpoint.hash,
                    title: Text(
                      checkpoint.label.isEmpty
                          ? checkpoint.hash
                          : checkpoint.label,
                    ),
                    subtitle: Text(checkpoint.when),
                    onTap: () => _showDiff(checkpoint.hash),
                  ),
                if (_diff != null)
                  SelectableText(_diff!, key: const ValueKey('history-diff')),
                OutlinedButton(
                  key: const ValueKey('history-restore'),
                  onPressed: _selectedHash == null || _busy ? null : _restore,
                  child: const Text('Restore checkpoint'),
                ),
                const SizedBox(height: 16),
                Text('Export', style: Theme.of(context).textTheme.titleMedium),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'json', label: Text('JSON')),
                    ButtonSegment(value: 'md', label: Text('Markdown')),
                    ButtonSegment(value: 'html', label: Text('HTML')),
                  ],
                  selected: {_format},
                  onSelectionChanged: (value) =>
                      setState(() => _format = value.single),
                ),
                SwitchListTile(
                  key: const ValueKey('history-redact'),
                  value: _redact,
                  title: const Text('Redact tokens'),
                  onChanged: (value) => setState(() => _redact = value),
                ),
                FilledButton(
                  key: const ValueKey('history-export'),
                  onPressed: _busy ? null : _export,
                  child: const Text('Export transcript'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Import Claude or Codex',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_foreignUnsupported)
                  const Text(
                    'Claude and Codex import is not supported by this gateway.',
                  )
                else ...[
                  Text(
                    _foreign == null
                        ? ''
                        : 'Reading from ${_foreign!.host}. '
                              '${_foreign!.unreadable} logs could not be read.',
                  ),
                  SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('All')),
                      ButtonSegment(value: 'claude', label: Text('Claude')),
                      ButtonSegment(value: 'codex', label: Text('Codex')),
                    ],
                    selected: {_foreignSource},
                    onSelectionChanged: (value) => _reloadForeign(value.single),
                  ),
                  for (final row in _foreign?.sessions ?? const [])
                    ListTile(
                      key: ValueKey('history-foreign-${row.id}'),
                      selected: _selectedForeign == row.id,
                      title: Text(row.title),
                      subtitle: Text('${row.label} · ${row.turns}'),
                      onTap: () => _previewForeign(row.id),
                    ),
                  if (_foreignPreview != null) _previewList(_foreignPreview!),
                  FilledButton(
                    key: const ValueKey('history-import-host'),
                    onPressed: _foreignPreview == null || _busy
                        ? null
                        : _importForeign,
                    child: const Text('Import selected session'),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _lineageTiles() {
    final lineage = _lineage;
    if (lineage == null) return const SizedBox.shrink();
    final rows = <Widget>[
      if (lineage.parent != null)
        ListTile(
          title: Text(lineage.parent!.title),
          subtitle: const Text('Parent'),
        ),
      for (final sibling in lineage.siblings)
        ListTile(title: Text(sibling.title), subtitle: const Text('Sibling')),
      for (final child in lineage.children)
        ListTile(title: Text(child.title), subtitle: const Text('Fork')),
    ];
    if (rows.isEmpty) {
      return const Text('This chat has no forks or sibling branches.');
    }
    return Column(children: rows);
  }

  Widget _previewList(ForeignPreviewView preview) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preview.truncated)
          Text('Preview shows ${preview.messages.length} of ${preview.total}.'),
        for (final message in preview.messages)
          ListTile(
            title: Text(message.role),
            subtitle: Text(
              message.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
