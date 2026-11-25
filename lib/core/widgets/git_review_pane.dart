import 'dart:async';

import 'package:flutter/material.dart';

import '../models/turn_changed_files.dart';
import '../services/remote_workspace.dart';
import 'markdown_link_handler.dart';

/// Test hook for the pull-request button. Production uses the shared web-link
/// handler, which allows only http and https.
@visibleForTesting
Future<void> Function(String url)? debugOpenGitPullRequest;

class TurnChangedFilesCard extends StatelessWidget {
  const TurnChangedFilesCard({
    super.key,
    required this.files,
    required this.onOpen,
  });

  final List<TurnChangedFile> files;
  final ValueChanged<TurnChangedFile> onOpen;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Card(
      key: const Key('turn-changed-files'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              files.length == 1
                  ? '1 file changed this turn'
                  : '${files.length} files changed this turn',
              style: theme.textTheme.titleSmall,
            ),
            for (final file in files)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(file.name),
                subtitle: Text('+${file.added} -${file.removed}'),
                onTap: () => onOpen(file),
              ),
          ],
        ),
      ),
    );
  }
}

/// Owner-scoped Git review for the session directory. Mutations are the named
/// gateway operations; this pane never assembles a shell command.
class GitReviewPane extends StatefulWidget {
  const GitReviewPane({
    super.key,
    required this.owner,
    required this.route,
    this.expectedCwd,
    this.turnBaseline,
    this.initialFile,
    this.onHandOff,
    this.onClose,
    this.onFollowed,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final String? expectedCwd;
  final String? turnBaseline;
  final String? initialFile;
  final ValueChanged<String>? onHandOff;
  final VoidCallback? onClose;
  final ValueChanged<String>? onFollowed;

  @override
  State<GitReviewPane> createState() => _GitReviewPaneState();
}

class _GitReviewPaneState extends State<GitReviewPane> {
  late WorkspacePane _pane;
  WorkspaceTarget? _target;
  var _epoch = 0;
  var _busy = false;
  var _pinned = false;
  String? _expected;
  var _scope = GitReviewScope.uncommitted;
  String? _baseline;
  String? _baselineCwd;
  var _omitted = 0;
  String? _message;
  String? _diff;
  String? _selected;
  String? _prUrl;
  var _ghReady = false;
  List<GitReviewFile> _files = const [];
  List<GitWorktreeInfo> _trees = const [];
  List<GitBranchInfo> _branches = const [];
  List<GitBaseBranch> _bases = const [];
  final _commit = TextEditingController();
  final _workName = TextEditingController();
  final _workBranch = TextEditingController();
  String? _base;
  String? _convert;
  String? _switchTo;

  bool _owns(int epoch) => mounted && epoch == _epoch;

  @override
  void initState() {
    super.initState();
    _baseline = widget.turnBaseline;
    _expected = widget.expectedCwd;
    _pane = widget.owner.pane();
    _load();
  }

  @override
  void didUpdateWidget(GitReviewPane old) {
    super.didUpdateWidget(old);
    final switched =
        !identical(old.owner, widget.owner) || old.route != widget.route;
    if (switched) {
      _pane.close();
      _pane = widget.owner.pane();
      _target = null;
      _expected = widget.expectedCwd;
      _baseline = widget.turnBaseline;
      _baselineCwd = null;
      _files = const [];
      _diff = null;
      _message = null;
      _load();
      return;
    }
    if (old.turnBaseline != widget.turnBaseline) {
      _baseline = widget.turnBaseline;
      _baselineCwd = null;
      if (_scope == GitReviewScope.lastTurn) _load();
    }
  }

  @override
  void dispose() {
    _epoch++;
    _pane.close();
    _commit.dispose();
    _workName.dispose();
    _workBranch.dispose();
    super.dispose();
  }

  Future<void> _load({String? expected}) async {
    final epoch = ++_epoch;
    // A Follow confirms one directory. Keeping that path would make every
    // later move look like the session changed.
    final pinned = expected ?? _expected;
    if (expected != null) _expected = null;
    setState(() {
      _busy = true;
      _message = null;
    });
    WorkspaceTarget? bound;
    try {
      final target = await _pane.bind(widget.route, expectedCwd: pinned);
      if (!_owns(epoch)) return;
      bound = target;
      final cwd = target.canonicalCwd;
      final baseline = _baselineFor(cwd);
      final results = await Future.wait<Object?>([
        target.gitReviewList(
          scope: _scope,
          base: _scope == GitReviewScope.lastTurn ? baseline : null,
        ),
        target.gitWorktreeRows(),
        target.gitBranchRows(),
        target.gitBaseBranchRows(),
        target.gitShipInfo(),
      ]);
      if (!_owns(epoch)) return;
      final list = results[0] as GitReviewList;
      final trees = results[1] as GitRows<GitWorktreeInfo>;
      final branches = results[2] as GitRows<GitBranchInfo>;
      final bases = results[3] as GitRows<GitBaseBranch>;
      final ship = results[4] as GitShipInfo;
      setState(() {
        _target = target;
        _baseline = baseline;
        _baselineCwd = cwd;
        _files = list.files;
        _trees = trees.rows;
        _branches = branches.rows;
        _bases = bases.rows;
        _omitted =
            list.omitted + trees.omitted + branches.omitted + bases.omitted;
        _ghReady = ship.ghReady;
        _prUrl = ship.prUrl ?? _prUrl;
        _base ??= _bases
            .where((row) => row.isDefault)
            .map((row) => row.name)
            .firstOrNull;
        _selected = _match(widget.initialFile) ?? _selected;
        _busy = false;
      });
      if (_selected != null) await _showDiff(epoch);
    } on WorkspaceException catch (error) {
      if (!_owns(epoch)) return;
      setState(() {
        _busy = false;
        _message = _why(error);
        if (bound != null) _target = bound;
      });
    } catch (_) {
      if (!_owns(epoch)) return;
      setState(() {
        _busy = false;
        _message = 'The Git operation did not complete.';
        if (bound != null) _target = bound;
      });
    }
  }

  String? _baselineFor(String? cwd) {
    final session = widget.route.storedSessionId;
    if (cwd != null && session != null) {
      final recorded = gitTurnMemory.baselineFor(
        ownerId: widget.owner.connectionId,
        profile: widget.owner.profile,
        sessionId: session,
        cwd: cwd,
      );
      if (recorded != null) return recorded;
    }
    if (cwd != null && cwd == _baselineCwd) return _baseline;
    if (widget.turnBaseline != null &&
        (widget.expectedCwd == null || widget.expectedCwd == cwd)) {
      return widget.turnBaseline;
    }
    return null;
  }

  String? get _scopeBase =>
      _scope == GitReviewScope.lastTurn ? _baseline : null;

  String? _match(String? requested) {
    if (requested == null) return null;
    for (final file in _files) {
      if (file.path == requested ||
          requested.endsWith('/${file.path}') ||
          requested.endsWith('\\${file.path}')) {
        return file.path;
      }
    }
    return null;
  }

  Future<void> _showDiff(int epoch) async {
    final target = _target;
    final path = _selected;
    if (target == null || path == null) return;
    final file = _files.where((row) => row.path == path).firstOrNull;
    try {
      final diff = await target.gitReviewDiff(
        file: path,
        scope: _scope,
        base: _scopeBase,
        staged: _scope == GitReviewScope.uncommitted && (file?.staged ?? false),
      );
      if (!_owns(epoch)) return;
      setState(() => _diff = diff);
    } on WorkspaceException catch (error) {
      if (_owns(epoch)) setState(() => _message = _why(error));
    }
  }

  Future<void> _act(Future<void> Function(WorkspaceTarget target) run) async {
    final target = _target;
    if (target == null || _busy) return;
    final epoch = _epoch;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await run(target);
      if (!_owns(epoch)) return;
      await _load();
    } on WorkspaceException catch (error) {
      if (!_owns(epoch)) return;
      setState(() {
        _busy = false;
        _message = _why(error);
      });
    } catch (_) {
      if (!_owns(epoch)) return;
      setState(() {
        _busy = false;
        _message = 'The Git operation did not complete.';
      });
    }
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('git-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return answer == true;
  }

  @override
  Widget build(BuildContext context) {
    final shipping = _scope == GitReviewScope.uncommitted && _files.isNotEmpty;
    return Material(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close Git review',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
                const Expanded(child: Text('Git review')),
                const Text('Pin lane'),
                Switch(
                  key: const Key('git-follow-pin'),
                  value: _pinned,
                  onChanged: (value) => setState(() => _pinned = value),
                ),
                IconButton(
                  key: const Key('git-refresh'),
                  tooltip: 'Refresh Git review',
                  onPressed: _busy ? null : () => _load(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (_busy) const LinearProgressIndicator(),
            if (_message != null) Text(_message!, key: const Key('git-error')),
            if (_omitted > 0)
              Text(
                _omitted == 1
                    ? '1 Git entry was left out because it was not safe to show.'
                    : '$_omitted Git entries were left out because they were not safe to show.',
                key: const Key('git-omitted'),
              ),
            if (_target?.canonicalCwd case final cwd?)
              Text(cwd, key: const Key('git-cwd')),
            const SizedBox(height: 8),
            SegmentedButton<GitReviewScope>(
              segments: const [
                ButtonSegment(
                  value: GitReviewScope.uncommitted,
                  label: Text('Uncommitted'),
                ),
                ButtonSegment(
                  value: GitReviewScope.branch,
                  label: Text('Branch'),
                ),
                ButtonSegment(
                  value: GitReviewScope.lastTurn,
                  label: Text('Last turn'),
                ),
              ],
              selected: {_scope},
              onSelectionChanged: _busy
                  ? null
                  : (next) async {
                      setState(() {
                        _scope = next.single;
                        _diff = null;
                      });
                      await _load();
                    },
            ),
            if (_scope != GitReviewScope.uncommitted)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Branch and last-turn views are read-only.',
                  key: Key('git-readonly'),
                ),
              ),
            if (_scope == GitReviewScope.lastTurn && _baseline == null)
              OutlinedButton(
                key: const Key('git-mark-head'),
                onPressed: _busy
                    ? null
                    : () => _act((target) async {
                        final sha = await target.gitRevParseHead();
                        final cwd = target.canonicalCwd;
                        final session = widget.route.storedSessionId;
                        if (sha == null || cwd == null || session == null) {
                          throw WorkspaceException(WorkspaceFailure.invalid);
                        }
                        gitTurnMemory.remember(
                          ownerId: widget.owner.connectionId,
                          profile: widget.owner.profile,
                          sessionId: session,
                          cwd: cwd,
                          sha: sha,
                        );
                        _baseline = sha;
                        _baselineCwd = cwd;
                      }),
                child: const Text('Mark HEAD as the turn baseline'),
              ),
            if (shipping) ...[
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    key: const Key('git-stage-all'),
                    onPressed: _busy
                        ? null
                        : () => _act((target) => target.gitStage()),
                    child: const Text('Stage all'),
                  ),
                  TextButton(
                    key: const Key('git-revert-all'),
                    onPressed: _busy
                        ? null
                        : () async {
                            final yes = await _confirm(
                              'Discard every uncommitted change?',
                              'Tracked files return to HEAD and untracked files in this session directory are removed.',
                              'Discard',
                            );
                            if (yes) await _act((target) => target.gitRevert());
                          },
                    child: const Text('Discard all'),
                  ),
                ],
              ),
            ],
            for (final file in _files)
              ListTile(
                key: Key('git-file-${file.path}'),
                selected: file.path == _selected,
                title: Text(file.path),
                subtitle: Text(
                  '${file.status} +${file.added} -${file.removed}${file.staged ? ' staged' : ''}',
                ),
                onTap: () async {
                  setState(() => _selected = file.path);
                  await _showDiff(_epoch);
                },
                trailing: shipping
                    ? Wrap(
                        children: [
                          IconButton(
                            key: Key(
                              file.staged
                                  ? 'git-unstage-${file.path}'
                                  : 'git-stage-${file.path}',
                            ),
                            tooltip: file.staged ? 'Unstage' : 'Stage',
                            onPressed: _busy
                                ? null
                                : () => _act(
                                    (target) => file.staged
                                        ? target.gitUnstage(file: file.path)
                                        : target.gitStage(file: file.path),
                                  ),
                            icon: Icon(file.staged ? Icons.remove : Icons.add),
                          ),
                          IconButton(
                            key: Key('git-revert-${file.path}'),
                            tooltip: 'Discard file',
                            onPressed: _busy
                                ? null
                                : () async {
                                    final yes = await _confirm(
                                      'Discard ${file.path}?',
                                      'This restores the committed copy or removes the untracked file.',
                                      'Discard',
                                    );
                                    if (yes) {
                                      await _act(
                                        (target) =>
                                            target.gitRevert(file: file.path),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.undo),
                          ),
                        ],
                      )
                    : null,
              ),
            if (_diff != null)
              SelectableText(
                _diff!.length > 20000
                    ? '${_diff!.substring(0, 20000)}\n\u2026 truncated'
                    : _diff!,
                key: const Key('git-diff'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            if (shipping) ...[
              TextField(
                key: const Key('git-message'),
                controller: _commit,
                minLines: 2,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Commit message'),
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    key: const Key('git-generate'),
                    onPressed: _busy
                        ? null
                        : () => _act((target) async {
                            final context = await target.gitCommitContext();
                            final draft = draftGitCommitMessage(
                              context.diff,
                              avoid: _commit.text,
                            );
                            if (draft.isEmpty) {
                              _message = 'Nothing in the diff to summarise.';
                              return;
                            }
                            _commit.text = draft;
                          }),
                    child: const Text('Generate message'),
                  ),
                  FilledButton(
                    key: const Key('git-commit'),
                    onPressed: _busy
                        ? null
                        : () => _act(
                            (target) => target.gitCommit(message: _commit.text),
                          ),
                    child: const Text('Commit'),
                  ),
                  FilledButton(
                    key: const Key('git-commit-push'),
                    onPressed: _busy
                        ? null
                        : () => _act(
                            (target) => target.gitCommit(
                              message: _commit.text,
                              push: true,
                            ),
                          ),
                    child: const Text('Commit and push'),
                  ),
                  OutlinedButton(
                    key: const Key('git-push'),
                    onPressed: _busy
                        ? null
                        : () => _act((target) => target.gitPush()),
                    child: const Text('Push'),
                  ),
                  OutlinedButton(
                    key: const Key('git-pr'),
                    onPressed: _busy
                        ? null
                        : _prUrl != null
                        ? () => unawaited(_openPullRequest(_prUrl!))
                        : _ghReady
                        ? () => _act((target) async {
                            final url = await target.gitCreatePullRequest();
                            _prUrl = url;
                          })
                        : null,
                    child: Text(
                      _prUrl == null
                          ? 'Create pull request'
                          : 'Pull request ready',
                    ),
                  ),
                  if (widget.onHandOff != null)
                    TextButton(
                      key: const Key('git-hand-off'),
                      onPressed: () {
                        widget.onHandOff!(
                          'Ship this session workspace: review the uncommitted diff, commit, push to its private remote, and open a pull request if gh is available. Stay in this repository.',
                        );
                      },
                      child: const Text('Ask Hermes to ship'),
                    ),
                ],
              ),
              Text(
                _ghReady
                    ? 'gh is authenticated on this gateway.'
                    : 'Install the GitHub CLI (gh) and sign in to open PRs',
                key: const Key('git-gh'),
              ),
              if (_prUrl case final url?)
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(url, key: const Key('git-pr-url')),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_openPullRequest(url)),
                      child: const Text('Open'),
                    ),
                  ],
                ),
            ],
            const Divider(),
            Text('Worktrees', style: Theme.of(context).textTheme.titleSmall),
            for (final tree in _trees)
              ListTile(
                title: Text(tree.branch ?? tree.path),
                subtitle: Text(tree.path),
                trailing: tree.isMain
                    ? const Text('Main')
                    : Wrap(
                        children: [
                          TextButton(
                            key: Key('git-follow-${tree.branch}'),
                            onPressed: _busy || _pinned
                                ? null
                                : () async {
                                    final yes = await _confirm(
                                      'Follow ${tree.branch}?',
                                      'The session working directory becomes this worktree unless the lane is pinned.',
                                      'Follow',
                                    );
                                    if (!yes || _pinned) return;
                                    await _act((target) async {
                                      final fences = await target.cwdFences();
                                      await target.changeCwd(tree.path, fences);
                                      await _pane.adoptMovedWorkspace(
                                        widget.route,
                                      );
                                      widget.onFollowed?.call(tree.path);
                                      await _load(expected: tree.path);
                                    });
                                  },
                            child: const Text('Follow'),
                          ),
                          TextButton(
                            key: Key('git-remove-${tree.branch}'),
                            onPressed: _busy
                                ? null
                                : () async {
                                    final yes = await _confirm(
                                      'Remove ${tree.branch}?',
                                      'The worktree directory is removed.',
                                      'Remove',
                                    );
                                    if (!yes) return;
                                    await _act(
                                      (target) => target.gitWorktreeRemove(
                                        worktreePath: tree.path,
                                      ),
                                    );
                                  },
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
              ),
            TextField(
              key: const Key('git-worktree-name'),
              controller: _workName,
              decoration: const InputDecoration(labelText: 'New worktree name'),
            ),
            TextField(
              key: const Key('git-worktree-branch'),
              controller: _workBranch,
              decoration: const InputDecoration(labelText: 'New branch'),
            ),
            if (_bases.isNotEmpty)
              DropdownButton<String>(
                key: const Key('git-worktree-base'),
                value: _bases.any((row) => row.name == _base) ? _base : null,
                hint: const Text('Base branch'),
                items: [
                  for (final row in _bases)
                    DropdownMenuItem(value: row.name, child: Text(row.name)),
                ],
                onChanged: (value) => setState(() => _base = value),
              ),
            FilledButton(
              key: const Key('git-worktree-create'),
              onPressed: _busy
                  ? null
                  : () => _act((target) async {
                      await target.gitWorktreeAdd(
                        name: _workName.text.trim().isEmpty
                            ? null
                            : _workName.text.trim(),
                        branch: _workBranch.text.trim().isEmpty
                            ? null
                            : _workBranch.text.trim(),
                        base: _base,
                      );
                    }),
              child: const Text('Create worktree'),
            ),
            if (_branches.isNotEmpty) ...[
              DropdownButton<String>(
                key: const Key('git-convert-branch'),
                value: _branches.any((row) => row.name == _convert)
                    ? _convert
                    : null,
                hint: const Text('Existing branch'),
                items: [
                  for (final row in _branches.where((row) => !row.isRemote))
                    DropdownMenuItem(value: row.name, child: Text(row.name)),
                ],
                onChanged: (value) => setState(() => _convert = value),
              ),
              OutlinedButton(
                key: const Key('git-worktree-convert'),
                onPressed: _busy || _convert == null
                    ? null
                    : () => _act(
                        (target) =>
                            target.gitWorktreeAdd(existingBranch: _convert),
                      ),
                child: const Text('Convert branch to worktree'),
              ),
              DropdownButton<String>(
                key: const Key('git-switch-branch'),
                value: _branches.any((row) => row.name == _switchTo)
                    ? _switchTo
                    : null,
                hint: const Text('Switch branch'),
                items: [
                  for (final row in _branches.where((row) => !row.isRemote))
                    DropdownMenuItem(value: row.name, child: Text(row.name)),
                ],
                onChanged: (value) => setState(() => _switchTo = value),
              ),
              OutlinedButton(
                key: const Key('git-switch'),
                onPressed: _busy || _switchTo == null
                    ? null
                    : () =>
                          _act((target) => target.gitSwitchBranch(_switchTo!)),
                child: const Text('Switch branch'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openPullRequest(String url) {
    final hook = debugOpenGitPullRequest;
    if (hook != null) return hook(url);
    return openMarkdownWebLink(context, url);
  }
}

String _why(WorkspaceException error) => switch (error.reason) {
  WorkspaceFailure.unsupported =>
    'This gateway does not support that Git operation.',
  WorkspaceFailure.unbound =>
    'Git needs the session directory on the local terminal backend.',
  WorkspaceFailure.denied => 'The gateway refused the Git operation.',
  WorkspaceFailure.mismatch => 'The session changed. Refresh and try again.',
  WorkspaceFailure.stale => 'This review is no longer the selected session.',
  WorkspaceFailure.invalid => 'The gateway returned an unexpected Git result.',
  WorkspaceFailure.insecure => 'Git review requires the gateway transport.',
  WorkspaceFailure.unavailable => 'The Git operation did not complete.',
};
