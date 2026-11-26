import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../services/remote_workspace.dart';

/// Branch, rewind, checkpoints, export and Claude/Codex import for one chat
/// (or host-side Claude/Codex import for a bound owner/profile before a chat
/// is saved when [storedSessionId] is null).
///
/// Classic and NextGen both open this page. It uses the owner that supplied
/// the session, not whichever gateway was opened last.
class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({
    super.key,
    required this.owner,
    this.storedSessionId,
    this.onRewound,
    this.onOpenSession,
  });

  final RemoteWorkspaceOwner owner;
  final String? storedSessionId;
  final ValueChanged<String>? onRewound;
  final void Function(String sessionId, {String? title})? onOpenSession;

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  late final WorkspacePane _pane = widget.owner.pane();
  final TextEditingController _foreignSearchController =
      TextEditingController();
  WorkspaceTarget? _target;
  var _loading = true;
  var _busy = false;
  var _loadingMoreForeign = false;
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
  String _foreignSearch = '';
  ForeignSessionPage? _foreign;
  String? _foreignError;
  String? _selectedForeign;
  ForeignPreviewView? _foreignPreview;
  var _foreignPreviewLoading = false;
  String? _foreignPreviewError;
  var _foreignUnsupported = false;
  String? _notice;
  ({String sessionId, String? title})? _openableSession;

  bool get _hasStoredSession => widget.storedSessionId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _foreignSearchController.dispose();
    _pane.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _foreignError = null;
    });
    try {
      final target = await _pane.bind(
        widget.owner.route(storedSessionId: widget.storedSessionId),
      );
      var messages = const <HistoryMessage>[];
      ShownSessionLineage? lineage;
      var checkpoints = const <HistoryCheckpoint>[];
      if (_hasStoredSession) {
        messages = await target.transcript();
        lineage = await target.lineage();
        checkpoints = await target.checkpoints();
      }
      ForeignSessionPage? foreign;
      var unsupported = false;
      String? foreignErr;
      try {
        foreign = await target.foreignSessions(source: _foreignSource);
      } on WorkspaceException catch (error) {
        if (error.reason == WorkspaceFailure.unsupported) {
          unsupported = true;
        } else {
          foreignErr = error.reason.name;
        }
      }
      if (!mounted || !target.isCurrent) return;
      setState(() {
        _target = target;
        _messages = messages;
        _lineage = lineage;
        _checkpoints = checkpoints;
        _foreign = foreign;
        _foreignUnsupported = unsupported;
        _foreignError = foreignErr;
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
    final l10n = context.sharedL10n;
    final answer = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const ValueKey('history-confirm'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.continue_label),
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
        _openableSession = (
          sessionId: receipt.sessionId,
          title: receipt.title.isEmpty ? null : receipt.title,
        );
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
        _openableSession = null;
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
      _foreignError = null;
      _selectedForeign = null;
      _foreignPreview = null;
      _foreignPreviewError = null;
    });
    try {
      final page = await target.foreignSessions(source: source);
      if (!mounted || !target.isCurrent || _foreignSource != source) return;
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
      setState(() => _foreignError = error.reason.name);
    }
  }

  Future<void> _loadMoreForeign() async {
    final target = _target;
    final current = _foreign;
    final nextOffset = current?.nextOffset;
    if (target == null ||
        current == null ||
        nextOffset == null ||
        _loadingMoreForeign) {
      return;
    }
    final source = _foreignSource;
    setState(() {
      _loadingMoreForeign = true;
      _foreignError = null;
    });
    try {
      final page = await target.foreignSessions(
        source: source,
        offset: nextOffset,
      );
      if (!mounted || !target.isCurrent || _foreignSource != source) return;
      final merged = <String, ForeignSessionSummary>{
        for (final row in current.sessions) row.id: row,
        for (final row in page.sessions) row.id: row,
      };
      setState(() {
        _foreign = ForeignSessionPage(
          sessions: merged.values.toList(growable: false),
          host: page.host,
          unreadable: current.unreadable + page.unreadable,
          nextOffset: page.nextOffset,
        );
        _loadingMoreForeign = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMoreForeign = false;
        if (error.reason == WorkspaceFailure.unsupported) {
          _foreignUnsupported = true;
          _foreign = null;
        } else {
          _foreignError = error.reason.name;
        }
      });
    }
  }

  Future<void> _previewForeign(String id) async {
    final target = _target;
    if (target == null) return;
    setState(() {
      _selectedForeign = id;
      _foreignPreview = null;
      _foreignPreviewError = null;
      _foreignPreviewLoading = true;
    });
    try {
      final preview = await target.previewForeign(id);
      if (!mounted || !target.isCurrent || _selectedForeign != id) return;
      setState(() {
        _foreignPreview = preview;
        _foreignPreviewLoading = false;
      });
    } on WorkspaceException catch (error) {
      if (!mounted || _selectedForeign != id) return;
      if (error.reason == WorkspaceFailure.unsupported) {
        setState(() {
          _foreignUnsupported = true;
          _foreignPreview = null;
          _foreignPreviewLoading = false;
        });
        return;
      }
      setState(() {
        _foreignPreviewError = error.reason.name;
        _foreignPreviewLoading = false;
      });
    }
  }

  Future<void> _importForeign() async {
    final target = _target;
    final id = _selectedForeign;
    final preview = _foreignPreview;
    if (target == null || id == null || preview == null || _busy) return;
    final selectedRow = _foreign?.sessions
        .where((row) => row.id == id)
        .firstOrNull;
    final destination = target.effectiveProfile ?? 'default';
    final confirmed = await _confirm(
      'Import this session',
      preview.alreadyImported == null
          ? 'Copy this Claude or Codex session into profile "$destination" on '
                'this gateway.'
          : 'This session was already imported into "$destination". Continue '
                'with the existing copy.',
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
        _openableSession = (
          sessionId: receipt.sessionId,
          title: selectedRow?.title,
        );
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

  void _openSession(String sessionId, {String? title}) {
    final callback = widget.onOpenSession;
    if (callback == null || !mounted) return;
    Navigator.of(context).pop();
    callback(sessionId, title: title);
  }

  List<ForeignSessionSummary> _visibleForeignSessions() {
    final rows = _foreign?.sessions ?? const <ForeignSessionSummary>[];
    final query = _foreignSearch.trim().toLowerCase();
    if (query.isEmpty) return rows;
    return [
      for (final row in rows)
        if ('${row.title} ${row.cwd ?? ''} ${row.excerpt}'
            .toLowerCase()
            .contains(query))
          row,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.sharedL10n;
    final visibleForeign = _visibleForeignSessions();
    final destinationProfile =
        _target?.effectiveProfile ?? widget.owner.profile ?? 'default';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _hasStoredSession
              ? l10n.session_history
              : l10n.import_claude_or_codex,
        ),
        actions: [
          IconButton(
            key: const ValueKey('history-refresh'),
            tooltip: l10n.refresh,
            onPressed: _loading || _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const ValueKey('history-scroll'),
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) Text('Could not finish: $_error'),
                if (_notice != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(_notice!, key: const ValueKey('history-notice')),
                      if (widget.onOpenSession != null &&
                          _openableSession != null)
                        FilledButton.tonal(
                          key: const ValueKey('history-open-session'),
                          onPressed: _busy
                              ? null
                              : () => _openSession(
                                  _openableSession!.sessionId,
                                  title: _openableSession!.title,
                                ),
                          child: const Text('Open chat'),
                        ),
                    ],
                  ),
                if (_hasStoredSession) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Lineage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _lineageTiles(),
                  const SizedBox(height: 16),
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Text(
                    'Select a saved message to branch or rewind there.',
                  ),
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
                        onPressed: _selectedRow == null || _busy
                            ? null
                            : _branch,
                        child: const Text('Branch from here'),
                      ),
                      OutlinedButton(
                        key: const ValueKey('history-rewind'),
                        onPressed: _selectedRow == null || _busy
                            ? null
                            : _rewind,
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
                  Text(
                    'Export',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                ],
                Text(
                  l10n.import_claude_or_codex,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_foreignUnsupported)
                  const Text(
                    'Claude and Codex import is not supported by this gateway.',
                    key: ValueKey('history-foreign-unsupported'),
                  )
                else ...[
                  Text(
                    _foreign == null
                        ? 'Destination profile: $destinationProfile.'
                        : 'Reading from ${_foreign!.host} · '
                              'Destination profile: $destinationProfile. '
                              '${_foreign!.unreadable} logs could not be read.',
                    key: const ValueKey('history-foreign-meta'),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('All')),
                      ButtonSegment(
                        value: 'claude',
                        label: Text('Claude Code'),
                      ),
                      ButtonSegment(value: 'codex', label: Text('Codex')),
                    ],
                    selected: {_foreignSource},
                    onSelectionChanged: (value) => _reloadForeign(value.single),
                  ),
                  if ((_foreign?.sessions.isNotEmpty ?? false) ||
                      _foreignSearch.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextField(
                      key: const ValueKey('history-foreign-search'),
                      controller: _foreignSearchController,
                      decoration: InputDecoration(
                        labelText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) =>
                          setState(() => _foreignSearch = value),
                    ),
                  ],
                  if (_foreignError != null) ...[
                    const SizedBox(height: 8),
                    Text('Could not scan host sessions: $_foreignError'),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        key: const ValueKey('history-foreign-retry'),
                        onPressed: () => _reloadForeign(_foreignSource),
                        child: Text(l10n.retry),
                      ),
                    ),
                  ] else if (_foreign != null && visibleForeign.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _foreignSearch.trim().isEmpty
                          ? 'No Claude Code or Codex sessions found on this host.'
                          : 'No matching host sessions.',
                      key: const ValueKey('history-foreign-empty'),
                    ),
                  ],
                  for (final row in visibleForeign)
                    ListTile(
                      key: ValueKey('history-foreign-${row.id}'),
                      selected: _selectedForeign == row.id,
                      title: Text(row.title),
                      subtitle: Text(
                        [
                          '${row.label} · ${row.turns}',
                          if (row.cwd != null && row.cwd!.isNotEmpty)
                            row.cwd!
                          else if (row.excerpt.isNotEmpty)
                            row.excerpt,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _previewForeign(row.id),
                    ),
                  if (_foreign?.nextOffset != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const ValueKey('history-foreign-more'),
                        onPressed: _loadingMoreForeign
                            ? null
                            : _loadMoreForeign,
                        child: Text(
                          _loadingMoreForeign ? 'Loading…' : 'Load more',
                        ),
                      ),
                    ),
                  if (_foreignPreviewLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_foreignPreviewError != null) ...[
                    Text('Could not preview session: $_foreignPreviewError'),
                    if (_selectedForeign != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () => _previewForeign(_selectedForeign!),
                          child: Text(l10n.retry),
                        ),
                      ),
                  ],
                  if (_foreignPreview != null) _previewList(_foreignPreview!),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const ValueKey('history-import-host'),
                    onPressed: _foreignPreview == null || _busy
                        ? null
                        : _importForeign,
                    child: Text(
                      _foreignPreview?.alreadyImported != null
                          ? 'Open imported session'
                          : 'Import selected session',
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _lineageTiles() {
    final lineage = _lineage;
    if (lineage == null) return const SizedBox.shrink();
    final canOpen = widget.onOpenSession != null;
    final rows = <Widget>[
      if (lineage.parent != null)
        ListTile(
          key: ValueKey('history-lineage-parent-${lineage.parent!.id}'),
          title: Text(
            lineage.parent!.title.isEmpty
                ? lineage.parent!.id
                : lineage.parent!.title,
          ),
          subtitle: const Text('Parent'),
          onTap: canOpen
              ? () => _openSession(
                  lineage.parent!.id,
                  title: lineage.parent!.title,
                )
              : null,
        ),
      for (final sibling in lineage.siblings)
        ListTile(
          key: ValueKey('history-lineage-sibling-${sibling.id}'),
          title: Text(sibling.title.isEmpty ? sibling.id : sibling.title),
          subtitle: const Text('Sibling'),
          onTap: canOpen
              ? () => _openSession(sibling.id, title: sibling.title)
              : null,
        ),
      for (final child in lineage.children)
        ListTile(
          key: ValueKey('history-lineage-fork-${child.id}'),
          title: Text(child.title.isEmpty ? child.id : child.title),
          subtitle: const Text('Fork'),
          onTap: canOpen
              ? () => _openSession(child.id, title: child.title)
              : null,
        ),
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
        if (preview.cwd != null)
          Text(
            'Directory: ${preview.cwd}',
            key: const ValueKey('history-foreign-preview-cwd'),
          ),
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
