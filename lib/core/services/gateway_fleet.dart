import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../nextgen/data/chat_controller.dart';
import '../../nextgen/data/nextgen_gateway.dart';
import 'connection_manager.dart';
import 'connection_mutation_barrier.dart';
import 'remote_workspace.dart';

/// A user's explicit attachment to a saved account. The gateway, all of its
/// chats and their listeners outlive the currently visible route, but never
/// an edit to the saved account. Neither labels nor profile names are keys.
final class FleetHost extends ChangeNotifier {
  FleetHost._(SavedConnection c, this._epoch) : gateway = NextGenGateway(c) {
    _pane = gateway.workspace.pane();
    _reconnect = gateway.reconnected.listen((_) {
      if (_target != null && !_target!.isCurrent) unawaited(refresh());
    });
    gateway.addListener(_stateChanged);
  }
  final NextGenGateway gateway;
  final Object? _epoch;
  late final WorkspacePane _pane;
  late final StreamSubscription<void> _reconnect;
  final _chats = <String, NgChatController>{};
  WorkspaceTarget? _target;
  WorkspaceTarget? get target =>
      current && _target?.isCurrent == true ? _target : null;
  bool _closed = false;
  bool get current =>
      !_closed &&
      ConnectionMutationBarrier.isCurrent(gateway.connection.id, _epoch);
  List<String> profiles = const [];
  List<FleetSession> sessions = const [];
  int total = 0;
  WorkspaceFailure? failure;
  Object _flight = Object();
  bool loading = false;
  void _stateChanged() {
    if (current) notifyListeners();
  }

  void _check() {
    if (!current) throw const WorkspaceException(WorkspaceFailure.stale);
  }

  Future<void> refresh({bool more = false}) async {
    _check();
    final flight = _flight = Object();
    final previous = more ? sessions : const <FleetSession>[];
    loading = true;
    failure = null;
    // A new bind supersedes the old page. Keep it out of the view while
    // disconnected, but retain the target identity for reconnect detection.
    notifyListeners();
    try {
      final host = await _pane.bind(gateway.workspace.route());
      final roster = await host.read(WorkspaceRead.profiles) as Map;
      final page = await host.fleetSessions(offset: previous.length);
      host.checkCurrent();
      if (!identical(flight, _flight) || !current) return;
      _target = host;
      profiles = List.unmodifiable([
        for (final r in roster['profiles'] as List) r['name'] as String,
      ]);
      sessions = List.unmodifiable(
        {
          ...{for (final r in previous) r.id: r},
          ...{for (final r in page.rows) r.id: r},
        }.values,
      );
      total = page.total;
    } catch (e) {
      if (!identical(flight, _flight) || !current) return;
      failure = e is WorkspaceException
          ? e.reason
          : WorkspaceFailure.unavailable;
      profiles = const [];
      sessions = const [];
      total = 0;
    } finally {
      if (identical(flight, _flight) && current) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<NgChatController> openSession(
    FleetSession row,
    WorkspaceTarget source,
  ) async {
    _check();
    source.checkCurrent();
    if (!identical(source, _target) || !sessions.contains(row)) {
      throw const WorkspaceException(WorkspaceFailure.stale);
    }
    final pane = gateway.workspace.pane();
    try {
      final route = gateway.workspace.route(storedSessionId: row.id);
      final selected = await pane.bind(route);
      source.checkCurrent();
      selected.checkCurrent();
      if (selected.effectiveProfile != row.profile) {
        throw const WorkspaceException(WorkspaceFailure.mismatch);
      }
      final chat = _chats.putIfAbsent(row.id, () {
        final chat = NgChatController(
          gateway,
          sessionId: row.id,
          title: row.title,
        );
        unawaited(chat.open());
        return chat;
      });
      return chat;
    } finally {
      pane.close();
    }
  }

  /// A chat controller's cached runtime id alone is not evidence after a
  /// reconnect. Only submit to a revalidated stored row and the current
  /// socket's explicit stored→runtime receipt; never create on a missing id.
  Future<bool> send(
    FleetSession row,
    NgChatController chat,
    String text,
  ) async {
    _check();
    final pane = gateway.workspace.pane();
    try {
      final selected = await pane.bind(
        gateway.workspace.route(storedSessionId: row.id),
      );
      if (!identical(_chats[row.id], chat) ||
          selected.effectiveProfile != row.profile ||
          selected.runtimeSessionId == null ||
          selected.runtimeSessionId != chat.runtimeId ||
          chat.running) {
        throw const WorkspaceException(WorkspaceFailure.unbound);
      }
      return await chat.send(text, fleetTarget: selected);
    } finally {
      pane.close();
    }
  }

  @override
  void dispose() {
    _closed = true;
    _pane.close();
    _reconnect.cancel();
    gateway.removeListener(_stateChanged);
    for (final c in _chats.values) {
      c.dispose();
    }
    _chats.clear();
    gateway.dispose();
    super.dispose();
  }
}

final class GatewayFleet extends ChangeNotifier {
  GatewayFleet(this.manager) {
    ConnectionMutationBarrier.addListener(_prune);
  }
  final ConnectionManager manager;
  final _hosts = <String, FleetHost>{};
  FleetHost? host(String id) => _hosts[id];
  bool _closed = false;
  void _prune() {
    for (final id in _hosts.keys.toList()) {
      if (!_hosts[id]!.current) detach(id);
    }
  }

  Future<FleetHost> attach(String id) async {
    final epoch = ConnectionMutationBarrier.capture(id);
    final saved = await manager.loadConnectionsWithSecrets();
    if (_closed || !ConnectionMutationBarrier.isCurrent(id, epoch)) {
      throw const WorkspaceException(WorkspaceFailure.stale);
    }
    final c = saved.where((s) => s.id == id).singleOrNull;
    if (c == null || !c.hasDashboardAuth) {
      throw const WorkspaceException(WorkspaceFailure.unbound);
    }
    final existing = _hosts[id];
    if (existing != null) return existing;
    final host = _hosts[id] = FleetHost._(c, epoch);
    notifyListeners();
    unawaited(host.refresh());
    return host;
  }

  void detach(String id) {
    final removed = _hosts.remove(id);
    if (removed == null) return;
    removed.dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    ConnectionMutationBarrier.removeListener(_prune);
    for (final h in _hosts.values) {
      h.dispose();
    }
    _hosts.clear();
    super.dispose();
  }
}
