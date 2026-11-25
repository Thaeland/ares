part of 'remote_workspace.dart';

/// Review scopes mirrored from the gateway's `/api/git/review` routes.
/// Branch and last-turn are read-only; only uncommitted changes can be shipped.
enum GitReviewScope {
  uncommitted('uncommitted'),
  branch('branch'),
  lastTurn('lastTurn');

  const GitReviewScope(this.wire);
  final String wire;
}

final class GitReviewFile {
  const GitReviewFile({
    required this.path,
    required this.added,
    required this.removed,
    required this.status,
    required this.staged,
  });

  final String path;
  final int added;
  final int removed;
  final String status;
  final bool staged;
}

final class GitReviewList {
  const GitReviewList({required this.files, required this.base});
  final List<GitReviewFile> files;
  final String? base;
}

final class GitWorktreeInfo {
  const GitWorktreeInfo({
    required this.path,
    required this.branch,
    required this.isMain,
    required this.detached,
    required this.locked,
  });

  final String path;
  final String? branch;
  final bool isMain;
  final bool detached;
  final bool locked;
}

final class GitBranchInfo {
  const GitBranchInfo({
    required this.name,
    required this.checkedOut,
    required this.isDefault,
    required this.isRemote,
    required this.worktreePath,
  });

  final String name;
  final bool checkedOut;
  final bool isDefault;
  final bool isRemote;
  final String? worktreePath;
}

final class GitBaseBranch {
  const GitBaseBranch({
    required this.name,
    required this.isRemote,
    required this.isDefault,
  });

  final String name;
  final bool isRemote;
  final bool isDefault;
}

final class GitShipInfo {
  const GitShipInfo({required this.ghReady, required this.prUrl});
  final bool ghReady;
  final String? prUrl;
}

final class GitWorktreeCreated {
  const GitWorktreeCreated({
    required this.path,
    required this.branch,
    required this.repoRoot,
  });

  final String path;
  final String branch;
  final String repoRoot;
}

/// HEAD captured before a turn, keyed by the bound directory.
final class GitTurnMemory {
  String? cwd;
  String? head;

  void remember(String directory, String sha) {
    cwd = directory;
    head = sha;
  }

  String? baselineFor(String directory) => cwd == directory ? head : null;
}

const _gitStatuses = {'M', 'A', 'D', 'R', 'C', 'U', '?'};
final _gitSha = RegExp(r'^[0-9a-f]{7,64}$');
final _gitBranchName = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{0,199}$');

bool _gitRelative(String file) {
  if (file.isEmpty ||
      file.length > 1024 ||
      !RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]*$').hasMatch(file) ||
      file.contains('..') ||
      file.contains('//') ||
      file.endsWith('/')) {
    return false;
  }
  return file
      .split('/')
      .every((part) => part.isNotEmpty && part != '.' && part != '..');
}

bool _gitBranch(String name) {
  if (!_gitBranchName.hasMatch(name)) return false;
  if (name.endsWith('/') ||
      name.endsWith('.') ||
      name.endsWith('.lock') ||
      name.contains('..') ||
      name.contains('@{') ||
      name.contains('//')) {
    return false;
  }
  return true;
}

bool _commitMessage(String message) {
  final trimmed = message.trim();
  if (trimmed.isEmpty || trimmed.length > 2000) return false;
  return !RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]').hasMatch(trimmed);
}

/// A commit subject drafted from the files the gateway would commit.
/// This does not call a model: the diff is only scanned for paths.
String draftGitCommitMessage(String diff, {String avoid = ''}) {
  final files = <String>[];
  for (final line in diff.split('\n')) {
    String? path;
    if (line.startsWith('diff --git ')) {
      final mark = line.lastIndexOf(' b/');
      if (mark >= 0) path = line.substring(mark + 3).trim();
    } else if (line.startsWith('#   ') && !line.startsWith('#   ...')) {
      path = line.substring(4).trim();
    }
    if (path != null && _gitRelative(path) && !files.contains(path)) {
      files.add(path);
    }
  }
  if (files.isEmpty) return '';
  final summary = files.length == 1
      ? 'Update ${files.single}'
      : 'Update ${files.length} files\n\n${files.take(12).join('\n')}';
  return summary == avoid.trim() ? '$summary\n' : summary;
}

String _boundGitCwd(WorkspaceTarget target) {
  final cwd = target.canonicalCwd;
  if (cwd == null || !isSafeWorkspacePath(cwd)) {
    _fail(WorkspaceFailure.unbound);
  }
  return cwd;
}

Future<void> _requireHostGit(WorkspaceTarget target) async {
  final backend = await target.read(WorkspaceRead.terminalBackends);
  if (backend is! Map ||
      backend['active'] != 'local' ||
      (target._binding?.backend != null &&
          target._binding!.backend != 'local')) {
    _fail(WorkspaceFailure.unbound);
  }
  await target.verifySession();
}

GitReviewFile _reviewFile(Object? raw) {
  if (raw is! Map) _fail(WorkspaceFailure.invalid);
  final path = raw['path'];
  final added = raw['added'];
  final removed = raw['removed'];
  final status = raw['status'];
  final staged = raw['staged'];
  if (path is! String ||
      !_gitRelative(path) ||
      added is! int ||
      added < 0 ||
      removed is! int ||
      removed < 0 ||
      status is! String ||
      !_gitStatuses.contains(status) ||
      staged is! bool) {
    _fail(WorkspaceFailure.invalid);
  }
  return GitReviewFile(
    path: path,
    added: added,
    removed: removed,
    status: status,
    staged: staged,
  );
}

extension SessionGit on WorkspaceTarget {
  Future<String?> gitRevParseHead() => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(
      ['git', 'review', 'rev-parse'],
      {'path': cwd, 'ref': 'HEAD'},
    );
    if (raw is! Map || !raw.containsKey('sha')) _fail(WorkspaceFailure.invalid);
    final sha = raw['sha'];
    if (sha == null) return null;
    if (sha is! String || !_gitSha.hasMatch(sha)) {
      _fail(WorkspaceFailure.invalid);
    }
    return sha;
  }, session: true);

  Future<GitReviewList> gitReviewList({
    required GitReviewScope scope,
    String? base,
  }) => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    if (scope == GitReviewScope.lastTurn) {
      if (base == null || !_gitSha.hasMatch(base)) {
        _fail(WorkspaceFailure.invalid);
      }
    } else if (base != null) {
      _fail(WorkspaceFailure.invalid);
    }
    await _requireHostGit(this);
    final raw = await _get(
      ['git', 'review', 'list'],
      {'path': cwd, 'scope': scope.wire, 'base': ?base},
    );
    if (raw is! Map || raw['files'] is! List) _fail(WorkspaceFailure.invalid);
    final reported = raw['base'];
    if (reported != null &&
        (reported is! String || !_gitSha.hasMatch(reported))) {
      _fail(WorkspaceFailure.invalid);
    }
    final files = [for (final row in raw['files'] as List) _reviewFile(row)];
    return GitReviewList(files: List.unmodifiable(files), base: reported);
  }, session: true);

  Future<String> gitReviewDiff({
    required String file,
    required GitReviewScope scope,
    String? base,
    bool staged = false,
  }) => _withOwner(() async {
    if (!_gitRelative(file)) _fail(WorkspaceFailure.invalid);
    if (scope == GitReviewScope.lastTurn) {
      if (base == null || !_gitSha.hasMatch(base)) {
        _fail(WorkspaceFailure.invalid);
      }
    } else if (base != null) {
      _fail(WorkspaceFailure.invalid);
    }
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(
      ['git', 'review', 'diff'],
      {
        'path': cwd,
        'file': file,
        'scope': scope.wire,
        'staged': staged ? 'true' : 'false',
        'base': ?base,
      },
    );
    if (raw is! Map || raw['diff'] is! String) _fail(WorkspaceFailure.invalid);
    return raw['diff'] as String;
  }, session: true);

  Future<({String diff, String recent})> gitCommitContext() =>
      _withOwner(() async {
        final cwd = _boundGitCwd(this);
        await _requireHostGit(this);
        final raw = await _get(
          ['git', 'review', 'commit-context'],
          {'path': cwd},
        );
        if (raw is! Map || raw['diff'] is! String || raw['recent'] is! String) {
          _fail(WorkspaceFailure.invalid);
        }
        return (diff: raw['diff'] as String, recent: raw['recent'] as String);
      }, session: true);

  Future<GitShipInfo> gitShipInfo() => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(['git', 'review', 'ship-info'], {'path': cwd});
    if (raw is! Map || raw['ghReady'] is! bool) _fail(WorkspaceFailure.invalid);
    final pr = raw['pr'];
    if (pr == null) {
      return GitShipInfo(ghReady: raw['ghReady'] as bool, prUrl: null);
    }
    if (pr is! Map || pr['url'] is! String || (pr['url'] as String).isEmpty) {
      _fail(WorkspaceFailure.invalid);
    }
    return GitShipInfo(
      ghReady: raw['ghReady'] as bool,
      prUrl: pr['url'] as String,
    );
  }, session: true);

  Future<List<GitWorktreeInfo>> gitWorktrees() => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(['git', 'worktrees'], {'path': cwd});
    if (raw is! Map || raw['worktrees'] is! List) {
      _fail(WorkspaceFailure.invalid);
    }
    return List.unmodifiable([
      for (final row in raw['worktrees'] as List) _worktree(row),
    ]);
  }, session: true);

  Future<List<GitBranchInfo>> gitBranches() => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(['git', 'branches'], {'path': cwd});
    if (raw is! Map || raw['branches'] is! List) {
      _fail(WorkspaceFailure.invalid);
    }
    return List.unmodifiable([
      for (final row in raw['branches'] as List) _branch(row),
    ]);
  }, session: true);

  Future<List<GitBaseBranch>> gitBaseBranches() => _withOwner(() async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _get(['git', 'base-branches'], {'path': cwd});
    if (raw is! Map || raw['branches'] is! List) {
      _fail(WorkspaceFailure.invalid);
    }
    return List.unmodifiable([
      for (final row in raw['branches'] as List) _baseBranch(row),
    ]);
  }, session: true);

  Future<void> gitStage({String? file}) => _mutate('review/stage', file: file);

  Future<void> gitUnstage({String? file}) =>
      _mutate('review/unstage', file: file);

  Future<void> gitRevert({String? file}) =>
      _mutate('review/revert', file: file);

  Future<void> gitCommit({required String message, bool push = false}) =>
      _mutate('review/commit', message: message, push: push);

  Future<void> gitPush() => _mutate('review/push');

  Future<String> gitCreatePullRequest() => _withOwner(() async {
    final raw = await _post('review/create-pr', const {});
    if (raw is! Map ||
        raw['url'] is! String ||
        (raw['url'] as String).isEmpty) {
      _fail(WorkspaceFailure.invalid);
    }
    return raw['url'] as String;
  }, session: true);

  Future<GitWorktreeCreated> gitWorktreeAdd({
    String? name,
    String? branch,
    String? base,
    String? existingBranch,
  }) => _withOwner(() async {
    if (existingBranch != null) {
      if (name != null || branch != null || base != null) {
        _fail(WorkspaceFailure.invalid);
      }
      if (!_gitBranch(existingBranch)) _fail(WorkspaceFailure.invalid);
    } else {
      if (name != null && !_gitBranch(name)) {
        _fail(WorkspaceFailure.invalid);
      }
      if (branch != null && !_gitBranch(branch)) {
        _fail(WorkspaceFailure.invalid);
      }
      if (base != null && !_gitBranch(base)) {
        _fail(WorkspaceFailure.invalid);
      }
    }
    final raw = await _post('worktree/add', {
      'name': ?name,
      'branch': ?branch,
      'base': ?base,
      'existingBranch': ?existingBranch,
    });
    if (raw is! Map) _fail(WorkspaceFailure.invalid);
    final path = raw['path'];
    final created = raw['branch'];
    final root = raw['repoRoot'];
    if (path is! String ||
        !isSafeWorkspacePath(path) ||
        created is! String ||
        !_gitBranch(created) ||
        root is! String ||
        !isSafeWorkspacePath(root)) {
      _fail(WorkspaceFailure.invalid);
    }
    return GitWorktreeCreated(path: path, branch: created, repoRoot: root);
  }, session: true);

  Future<void> gitWorktreeRemove({
    required String worktreePath,
    bool force = false,
  }) => _withOwner(() async {
    if (!isSafeWorkspacePath(worktreePath) || worktreePath == canonicalCwd) {
      _fail(WorkspaceFailure.invalid);
    }
    final known = await gitWorktrees();
    if (!known.any((tree) => tree.path == worktreePath && !tree.isMain)) {
      _fail(WorkspaceFailure.mismatch);
    }
    await _post('worktree/remove', {
      'worktreePath': worktreePath,
      'force': force,
    });
  }, session: true);

  Future<void> gitSwitchBranch(String branch) => _withOwner(() async {
    if (!_gitBranch(branch)) _fail(WorkspaceFailure.invalid);
    final raw = await _post('branch/switch', {'branch': branch});
    if (raw is! Map || raw['branch'] != branch) _fail(WorkspaceFailure.invalid);
  }, session: true);

  Future<void> _mutate(
    String operation, {
    String? file,
    String? message,
    bool push = false,
  }) => _withOwner(() async {
    if (file != null && !_gitRelative(file)) _fail(WorkspaceFailure.invalid);
    if (message != null && !_commitMessage(message)) {
      _fail(WorkspaceFailure.invalid);
    }
    final fields = <String, Object?>{};
    if (operation == 'review/stage' ||
        operation == 'review/unstage' ||
        operation == 'review/revert') {
      if (file != null) fields['file'] = file;
    } else if (operation == 'review/commit') {
      fields['message'] = message!.trim();
      fields['push'] = push;
    } else if (operation != 'review/push') {
      _fail(WorkspaceFailure.invalid);
    }
    await _post(operation, fields);
  }, session: true);

  Future<Object?> _post(String operation, Map<String, Object?> fields) async {
    final cwd = _boundGitCwd(this);
    await _requireHostGit(this);
    final raw = await _owner._dashboard.workspaceGitPost(
      operation: operation,
      profile: effectiveProfile,
      check: checkCurrent,
      body: {'path': cwd, ...fields},
    );
    if (operation == 'review/create-pr' ||
        operation == 'worktree/add' ||
        operation == 'branch/switch') {
      return raw;
    }
    if (raw is! Map || raw['ok'] != true) _fail(WorkspaceFailure.invalid);
    return raw;
  }
}

GitWorktreeInfo _worktree(Object? raw) {
  if (raw is! Map) _fail(WorkspaceFailure.invalid);
  final path = raw['path'];
  final branch = raw['branch'];
  if (path is! String ||
      !isSafeWorkspacePath(path) ||
      (branch != null && (branch is! String || !_gitBranch(branch))) ||
      raw['isMain'] is! bool ||
      raw['detached'] is! bool ||
      raw['locked'] is! bool) {
    _fail(WorkspaceFailure.invalid);
  }
  return GitWorktreeInfo(
    path: path,
    branch: branch as String?,
    isMain: raw['isMain'] as bool,
    detached: raw['detached'] as bool,
    locked: raw['locked'] as bool,
  );
}

GitBranchInfo _branch(Object? raw) {
  if (raw is! Map) _fail(WorkspaceFailure.invalid);
  final name = raw['name'];
  final worktree = raw['worktreePath'];
  if (name is! String ||
      !_gitBranch(name) ||
      raw['checkedOut'] is! bool ||
      raw['isDefault'] is! bool ||
      raw['isRemote'] is! bool ||
      (worktree != null &&
          (worktree is! String || !isSafeWorkspacePath(worktree)))) {
    _fail(WorkspaceFailure.invalid);
  }
  return GitBranchInfo(
    name: name,
    checkedOut: raw['checkedOut'] as bool,
    isDefault: raw['isDefault'] as bool,
    isRemote: raw['isRemote'] as bool,
    worktreePath: worktree as String?,
  );
}

GitBaseBranch _baseBranch(Object? raw) {
  if (raw is! Map) _fail(WorkspaceFailure.invalid);
  final name = raw['name'];
  if (name is! String ||
      !_gitBranch(name) ||
      raw['isRemote'] is! bool ||
      raw['isDefault'] is! bool) {
    _fail(WorkspaceFailure.invalid);
  }
  return GitBaseBranch(
    name: name,
    isRemote: raw['isRemote'] as bool,
    isDefault: raw['isDefault'] as bool,
  );
}
