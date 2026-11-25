/// Authenticated, per-pane access to a remote Hermes workspace. See
/// docs/remote-workspace-contract.md before adding an operation.
library;

import 'connection_manager.dart';
import 'connection_mutation_barrier.dart';
import 'ws_client.dart';

/// Each entry is a particular operation, not permission for a whole family.
enum WorkspaceRead {
  profiles,
  defaultDirectory,
  gitStatus,
  pendingApprovals,
  processes,
  dashboardPlugins,
  terminalBackends,
  hostTerminalTicket,
}

enum WorkspaceFailure {
  stale,
  mismatch,
  unbound,
  unsupported,
  denied,
  unavailable,
  invalid,
  insecure,
}

final class WorkspaceException implements Exception {
  const WorkspaceException(this.reason);
  final WorkspaceFailure reason;
  @override
  String toString() => 'Remote workspace: ${reason.name}';
}

Never _fail(WorkspaceFailure why) => throw WorkspaceException(why);

/// Display/cache identity only. Never reconstruct a live target from this.
typedef WorkspaceRoute = ({
  String connectionId,
  String? profile,
  String? storedSessionId,
});

typedef _StoredWorkspace = ({String profile, String? cwd, int? generation});

/// One per *constructed* gateway, not per globally selected saved ID.
final class RemoteWorkspaceOwner {
  RemoteWorkspaceOwner({
    required this.connectionId,
    required String? profile,
    required this._dashboard,
    required this._connect,
    required this._ownsSocket,
  }) : profile = profile?.trim().isEmpty == true ? null : profile?.trim(),
       _account = ConnectionMutationBarrier.capture(connectionId),
       _closed = ConnectionMutationBarrier.isPending(connectionId);

  final String connectionId;
  final String? profile;
  final DashboardClient _dashboard;
  final Future<WsClient> Function() _connect;
  final bool Function(WsClient) _ownsSocket;

  final Object? _account;
  bool _closed;

  WorkspacePane pane() => WorkspacePane._(this);
  void close() => _closed = true;

  void _check() {
    if (_closed ||
        !ConnectionMutationBarrier.isCurrent(connectionId, _account)) {
      _fail(WorkspaceFailure.stale);
    }
  }
}

/// The route owns this handle. Call [invalidate] synchronously when leaving
/// the route; [bind] also invalidates its previous result before the first await.
final class WorkspacePane {
  WorkspacePane._(this._owner);
  final RemoteWorkspaceOwner _owner;
  Object _selection = Object();
  bool _closed = false;
  void invalidate() => _selection = Object();
  void close() {
    _closed = true;
    invalidate();
  }

  Future<WorkspaceTarget> bind(
    WorkspaceRoute route, {
    String? expectedCwd,
  }) async {
    final selected = _selection = Object();
    WsClient? pinned;
    void check() {
      _owner._check();
      if (_closed ||
          !identical(selected, _selection) ||
          (pinned != null && !_owner._ownsSocket(pinned!))) {
        _fail(WorkspaceFailure.stale);
      }
    }

    return _guard(check, () async {
      if (route.connectionId != _owner.connectionId ||
          route.profile != _owner.profile ||
          route.profile != _owner._dashboard.gatewayProfile) {
        _fail(WorkspaceFailure.mismatch);
      }
      final base = Uri.parse(_owner._dashboard.baseUrl);
      final loopback = const {
        '127.0.0.1',
        '::1',
        'localhost',
      }.contains(base.host);
      if (base.userInfo.isNotEmpty ||
          base.hasQuery ||
          base.hasFragment ||
          !(base.scheme == 'https' || (base.scheme == 'http' && loopback))) {
        _fail(WorkspaceFailure.insecure);
      }
      final id = route.storedSessionId;
      if (id != null &&
          (id.isEmpty ||
              id == '.' ||
              id == '..' ||
              id.trim() != id ||
              RegExp(r'[/\\%?#\x00-\x1f\x7f]').hasMatch(id))) {
        _fail(WorkspaceFailure.invalid);
      }
      if (id == null && expectedCwd != null) _fail(WorkspaceFailure.unbound);
      final ws = pinned = await _owner._connect();
      check();
      if (ws.baseUrl != _owner._dashboard.baseUrl) {
        _fail(WorkspaceFailure.mismatch);
      }
      final ready = await ws.waitForGatewayReady();
      check();
      Future<_StoredWorkspace> readRow() async {
        final raw = await _owner._dashboard.workspaceJson(
          ['sessions', id!],
          query: {'profile': ?route.profile},
          check: check,
        );
        if (raw is! Map ||
            raw['id'] != id ||
            raw['profile'] is! String ||
            (raw['profile'] as String).isEmpty ||
            (route.profile != null && raw['profile'] != route.profile)) {
          _fail(WorkspaceFailure.mismatch);
        }
        final cwd = raw['cwd'];
        if (cwd != null && (cwd is! String || !_canonicalPath(cwd))) {
          _fail(WorkspaceFailure.invalid);
        }
        return (
          profile: raw['profile'] as String,
          cwd: cwd as String?,
          generation: raw['git_metadata_generation'] as int?,
        );
      }

      final row = id == null ? null : await readRow();
      if (expectedCwd != null && expectedCwd != row?.cwd) {
        _fail(WorkspaceFailure.mismatch);
      }
      return WorkspaceTarget._(
        _owner,
        route,
        ws,
        check,
        row,
        id == null ? null : ws.workspaceBinding(id),
        readRow,
        WsClient.readyFrameHasSessionAuthority(ready),
      );
    });
  }
}

/// No current-selection lookup, URL, arbitrary method, auth header or command
/// is accepted by the feature surface. Separate panes can hold separate targets.
final class WorkspaceTarget {
  WorkspaceTarget._(
    this._owner,
    this.route,
    this._socket,
    this._check,
    this._row,
    this._binding,
    this._readRow,
    this.sessionAuthority,
  );
  final RemoteWorkspaceOwner _owner;
  final WorkspaceRoute route;
  final WsClient _socket;
  final void Function() _check;
  final _StoredWorkspace? _row;
  final Future<_StoredWorkspace> Function() _readRow;
  final WorkspaceRuntime? _binding;
  String? get runtimeSessionId => _binding?.runtimeId;
  final bool sessionAuthority;
  String? get canonicalCwd => _row?.cwd;
  String? get effectiveProfile => _row?.profile ?? route.profile;
  bool get isCurrent {
    try {
      _check();
      return true;
    } on WorkspaceException {
      return false;
    }
  }

  /// Negotiate only the requested read (or terminal-ticket availability, by
  /// explicit user action). Null = validated success; a denial is not absence.
  Future<WorkspaceFailure?> probe(WorkspaceRead operation) async {
    try {
      await read(operation);
      return null;
    } on WorkspaceException catch (e) {
      return e.reason;
    }
  }

  Future<Object?> read(WorkspaceRead operation) {
    final live =
        operation == WorkspaceRead.pendingApprovals ||
        operation == WorkspaceRead.processes;
    final scoped = live || operation == WorkspaceRead.gitStatus;
    void check() {
      _check();
      if (scoped && _row == null) _fail(WorkspaceFailure.unbound);
      if (live && runtimeSessionId == null) _fail(WorkspaceFailure.unbound);
      if (scoped &&
          !identical(
            _socket.workspaceBinding(route.storedSessionId!),
            _binding,
          )) {
        _fail(WorkspaceFailure.stale);
      }
      if (scoped &&
          _binding != null &&
          ((_binding.profile != null && _binding.profile != effectiveProfile) ||
              (_binding.cwd != null && _binding.cwd != canonicalCwd))) {
        _fail(WorkspaceFailure.mismatch);
      }
    }

    Future<void> verifyRow() async {
      if (scoped && await _readRow() != _row) _fail(WorkspaceFailure.mismatch);
      check();
    }

    Future<Object?> get(
      List<String> segments, [
      Map<String, String> params = const {},
    ]) => _owner._dashboard.workspaceJson(
      segments,
      check: check,
      query: {'profile': ?effectiveProfile, ...params},
    );
    Future<Map<String, dynamic>> rpc(
      String method,
      Map<String, dynamic> params,
    ) async {
      check();
      final response = await _socket.send(method, {
        'profile': ?effectiveProfile,
        ...params,
      }, includeProfile: false);
      check();
      final error = response['error'];
      if (error != null) {
        if (error is Map && error['code'] == -32601) {
          _fail(WorkspaceFailure.unsupported);
        }
        _fail(WorkspaceFailure.denied);
      }
      final result = response['result'];
      if (result is! Map<String, dynamic>) _fail(WorkspaceFailure.invalid);
      return result;
    }

    return _guard(check, () async {
      await verifyRow();
      Object? value;
      switch (operation) {
        case WorkspaceRead.profiles:
          final result = await rpc('profiles.list', {
            'include_sessions': false,
          });
          if (result['profiles'] is! List ||
              !(result['profiles'] as List).every(
                (r) => r is Map && r['name'] is String,
              )) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.pendingApprovals:
        case WorkspaceRead.processes:
          final approvals = operation == WorkspaceRead.pendingApprovals;
          final result = await rpc(
            approvals ? 'approval.pending' : 'process.list',
            {'session_id': runtimeSessionId},
          );
          if (result[approvals ? 'approvals' : 'processes'] is! List) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.defaultDirectory:
          final result = await get(['fs', 'default-cwd']);
          if (result is! Map ||
              result['cwd'] is! String ||
              !_canonicalPath(result['cwd'] as String)) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.dashboardPlugins:
          final result = await get(['dashboard', 'plugins']);
          if (result is! List ||
              !result.every((r) => r is Map && r['name'] is String)) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.terminalBackends:
          final result = await get(['tools', 'terminal', 'backends']);
          if (result is! Map ||
              result['active'] is! String ||
              result['backends'] is! List) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.gitStatus:
          final cwd = canonicalCwd;
          if (cwd == null) _fail(WorkspaceFailure.unbound);
          if (_binding?.backend != null && _binding!.backend != 'local') {
            _fail(WorkspaceFailure.unbound);
          }
          // /api/git is a host path, not the executor's SSH/container filesystem.
          final backend = await get(['tools', 'terminal', 'backends']);
          if (backend is! Map || backend['active'] != 'local') {
            _fail(WorkspaceFailure.unbound);
          }
          await verifyRow();
          final result = await get(['git', 'status'], {'path': cwd});
          if (result != null &&
              (result is! Map ||
                  result['files'] is! List ||
                  result['changed'] is! int)) {
            _fail(WorkspaceFailure.invalid);
          }
          value = result;
        case WorkspaceRead.hostTerminalTicket:
          // Do not open a shell to discover support, nor give a ticket to UI.
          value = await _owner._dashboard.workspaceJson(
            ['webapp', 'socket-ticket'],
            query: {'socket': 'host-terminal'},
            check: check,
            mintHostTerminalTicket: true,
          );
      }
      await verifyRow();
      return value;
    });
  }
}

/// An absolute server spelling, not a client-side realpath. Reject ambiguous
/// components (including the upstream second-decode fallback) instead of fixing them.
bool _canonicalPath(String path) {
  if (path.isEmpty ||
      path.trim() != path ||
      RegExp(r'[\x00-\x1f\x7f]|%[0-9a-fA-F]{2}').hasMatch(path)) {
    return false;
  }
  final drive = RegExp(r'^[A-Za-z]:[\\/]').hasMatch(path);
  final unc = path.startsWith(r'\\');
  if (!drive && !unc && !path.startsWith('/')) return false;
  if (path.startsWith('//') ||
      path.startsWith(r'\\?\') ||
      path.startsWith(r'\\.\')) {
    return false;
  }
  final components = drive || unc
      ? path.split(RegExp(r'[\\/]'))
      : path.split('/');
  if (unc &&
      (components.length < 4 ||
          components[2].isEmpty ||
          components[3].isEmpty)) {
    return false;
  }
  final rest = components.skip(unc ? 2 : 1).toList();
  if (rest.length == 1 && rest.single.isEmpty) return true;
  return rest.every((part) => part.isNotEmpty && part != '.' && part != '..');
}

Future<T> _guard<T>(void Function() check, Future<T> Function() run) async {
  check();
  try {
    final value = await run();
    check();
    return value;
  } catch (error) {
    check(); // Never surface an old owner's error on the replacement route.
    if (error is WorkspaceException) rethrow;
    if (error is DashboardHttpException) {
      if (const {401, 403}.contains(error.statusCode)) {
        _fail(WorkspaceFailure.denied);
      }
      if (const {404, 405, 501}.contains(error.statusCode)) {
        _fail(WorkspaceFailure.unsupported);
      }
    }
    if (error is FormatException || error is TypeError) {
      _fail(WorkspaceFailure.invalid);
    }
    _fail(WorkspaceFailure.unavailable);
  }
}
