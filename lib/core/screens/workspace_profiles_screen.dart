import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/remote_workspace.dart';

/// Read-only roster of the selected gateway. This is not a profile switcher:
/// browsing another profile never changes the active chat or issues a write.
class WorkspaceProfilesScreen extends StatefulWidget {
  const WorkspaceProfilesScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.label,
  });
  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final String label;

  @override
  State<WorkspaceProfilesScreen> createState() =>
      _WorkspaceProfilesScreenState();
}

class _WorkspaceProfilesScreenState extends State<WorkspaceProfilesScreen> {
  late WorkspacePane _pane;
  late Future<List<String>> _snapshot;
  Object? _account;

  void _bind() {
    _pane = widget.owner.pane();
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    _startRead();
  }

  void _startRead() {
    _snapshot = _load();
    // A synchronous owner refusal can settle before FutureBuilder subscribes.
    // Its builder still receives the failure on the original future.
    _snapshot.ignore();
  }

  @override
  void initState() {
    super.initState();
    _bind();
    ConnectionMutationBarrier.addListener(_accountChanged);
  }

  void _accountChanged() {
    if (ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      return;
    }
    _pane.invalidate();
    if (mounted) setState(_startRead);
  }

  @override
  void didUpdateWidget(WorkspaceProfilesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.owner != oldWidget.owner || widget.route != oldWidget.route) {
      _pane.close();
      _bind();
    }
  }

  Future<List<String>> _load() async {
    final target = await _pane.bind(widget.route);
    final response = await target.read(WorkspaceRead.profiles) as Map;
    return [
      for (final row in response['profiles'] as List)
        (row as Map)['name'] as String,
    ];
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_accountChanged);
    _pane.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.ng_profiles),
        actions: [
          IconButton(
            tooltip: l.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_startRead),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(widget.label),
            subtitle: widget.route.profile == null
                ? null
                : Text(widget.route.profile!),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _snapshot,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  final why = error is WorkspaceException
                      ? error.reason
                      : WorkspaceFailure.unavailable;
                  return Center(
                    child: Text(switch (why) {
                      WorkspaceFailure.denied => l.ng_notify_permission_denied,
                      WorkspaceFailure.unsupported => l.ng_unsupported,
                      WorkspaceFailure.stale || WorkspaceFailure.mismatch =>
                        l.ng_the_gateway_connection_dropped_try_again,
                      WorkspaceFailure.insecure =>
                        'HTTPS · ${l.check_the_connection_and_try_again}',
                      _ => l.check_the_connection_and_try_again,
                    }),
                  );
                }
                final names = snapshot.requireData;
                if (names.isEmpty) return Center(child: Text(l.no_matches));
                return ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(names[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
