import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/connection_mutation_barrier.dart';
import '../services/remote_workspace.dart';

/// A read/modify/write is shared across panes addressing the same physical
/// preference. An old pane must not overwrite a sibling's hidden roots.
class DiscoveryFilterPreferences {
  DiscoveryFilterPreferences(this.target);
  final WorkspaceTarget target;
  static final _pending = <String, Future<void>>{};

  Future<WorkspaceRepoFilters> read() => _access();

  Future<WorkspaceRepoFilters> setHidden(String path, bool hide) =>
      _access((current) {
        final hidden = {...current.hidden};
        hide ? hidden.add(path) : hidden.remove(path);
        return WorkspaceRepoFilters(
          roots: current.roots,
          exclusions: current.exclusions,
          hidden: hidden,
        );
      });

  Future<WorkspaceRepoFilters> setSubtrees(
    WorkspaceRepoFilters displayed,
    Iterable<String> roots,
    Iterable<String> exclusions,
  ) => _access((current) {
    if (!setEquals(current.roots, displayed.roots) ||
        !setEquals(current.exclusions, displayed.exclusions)) {
      throw const WorkspaceException(WorkspaceFailure.mismatch);
    }
    return WorkspaceRepoFilters(
      roots: roots,
      exclusions: exclusions,
      hidden: current.hidden,
    );
  });

  Future<WorkspaceRepoFilters> _access([
    WorkspaceRepoFilters Function(WorkspaceRepoFilters)? change,
  ]) async {
    final scope = target.discoveryPreferenceScope;
    final key = 'repo_discovery.v1.${sha256.convert(utf8.encode(scope))}';
    final before = _pending[key];
    final operation = () async {
      if (before != null) await before;
      target.checkCurrent();
      final storage = SharedPreferencesAsync();
      final raw = await storage.getString(key);
      target.checkCurrent();
      final current = raw == null ? WorkspaceRepoFilters() : _decode(raw);
      if (change == null) return current;
      final next = change(current);
      final encoded = jsonEncode({
        'roots': next.roots.toList(),
        'exclusions': next.exclusions.toList(),
        'hidden': next.hidden.toList(),
      });
      target.checkCurrent();
      await storage.setString(key, encoded);
      target.checkCurrent();
      final confirmed = await storage.getString(key);
      target.checkCurrent();
      if (confirmed != encoded) {
        throw const WorkspaceException(WorkspaceFailure.mismatch);
      }
      return _decode(confirmed!);
    }();
    final tail = _pending[key] = operation.then<void>(
      (_) {},
      onError: (_, _) {},
    );
    try {
      return await operation;
    } on WorkspaceException {
      rethrow;
    } catch (_) {
      target.checkCurrent();
      throw const WorkspaceException(WorkspaceFailure.unavailable);
    } finally {
      if (identical(_pending[key], tail)) _pending.remove(key);
    }
  }

  static WorkspaceRepoFilters _decode(String encoded) {
    final data = jsonDecode(encoded);
    return WorkspaceRepoFilters(
      roots: (data['roots'] as List).cast<String>(),
      exclusions: (data['exclusions'] as List).cast<String>(),
      hidden: (data['hidden'] as List).cast<String>(),
    );
  }
}

/// Both Projects layouts use the gateway that supplied their route.
class WorkspaceDiscoveryView extends StatelessWidget {
  const WorkspaceDiscoveryView({
    super.key,
    required this.owner,
    required this.route,
  });
  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;

  @override
  Widget build(BuildContext context) =>
      _DiscoveryPane(key: ValueKey((owner, route)), owner: owner, route: route);
}

class _DiscoveryPane extends StatefulWidget {
  const _DiscoveryPane({
    required super.key,
    required this.owner,
    required this.route,
  });
  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  @override
  State<_DiscoveryPane> createState() => _DiscoveryPaneState();
}

class _DiscoveryPaneState extends State<_DiscoveryPane> {
  late final _pane = widget.owner.pane();
  late final Object? _account;
  final _roots = TextEditingController();
  final _exclusions = TextEditingController();
  WorkspaceTarget? _target;
  WorkspaceRepoDiscovery? _snapshot;
  WorkspaceRepoFilters? _filters;
  WorkspaceFailure? _failure;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _account = ConnectionMutationBarrier.capture(widget.route.connectionId);
    ConnectionMutationBarrier.addListener(_accountChanged);
    _load();
  }

  void _accountChanged() {
    if (ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      return;
    }
    _pane.close();
    _roots.clear();
    _exclusions.clear();
    setState(() {
      _target = null;
      _snapshot = null;
      _filters = null;
      _failure = WorkspaceFailure.stale;
      _busy = false;
    });
  }

  @override
  void dispose() {
    _pane.close();
    ConnectionMutationBarrier.removeListener(_accountChanged);
    _roots.dispose();
    _exclusions.dispose();
    super.dispose();
  }

  /// A refresh may bind a fresh socket. A Scan gesture may only act upon
  /// the exact target whose policy was on screen when the user requested it.
  Future<void> _load({WorkspaceTarget? scanTarget}) async {
    if (!mounted || _busy || (scanTarget != null && scanTarget != _target)) {
      return;
    }
    setState(() {
      _busy = true;
      _failure = null;
      if (scanTarget == null) {
        _target = null;
        _snapshot = null;
        _filters = null;
      }
    });
    try {
      final target = scanTarget ?? await _pane.bind(widget.route);
      final snapshot = await target.discoverRepositories(
        scan: scanTarget != null,
      );
      final filters = await DiscoveryFilterPreferences(target).read();
      if (!mounted) return;
      target.checkCurrent();
      setState(() {
        _target = target;
        _snapshot = snapshot;
        _showFilters(filters);
      });
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = e.reason;
        _snapshot = null;
        _target = null;
        _filters = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showFilters(WorkspaceRepoFilters filters) {
    _filters = filters;
    _roots.text = filters.roots.join('\n');
    _exclusions.text = filters.exclusions.join('\n');
  }

  Future<void> _edit(
    WorkspaceTarget target,
    WorkspaceRepoFilters displayed,
    Future<WorkspaceRepoFilters> Function(DiscoveryFilterPreferences) change, {
    bool updateFields = false,
  }) async {
    if (!mounted || _busy || target != _target || displayed != _filters) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      final filters = await change(DiscoveryFilterPreferences(target));
      if (!mounted) return;
      target.checkCurrent();
      setState(() {
        if (updateFields ||
            !setEquals(displayed.roots, filters.roots) ||
            !setEquals(displayed.exclusions, filters.exclusions)) {
          _showFilters(filters);
        } else {
          _filters = filters;
        }
      });
    } on WorkspaceException catch (e) {
      if (!mounted) return;
      setState(() {
        _failure = e.reason;
        if (e.reason != WorkspaceFailure.invalid) {
          _snapshot = null;
          _filters = null;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    final stale = target != null && !target.isCurrent;
    final snapshot = stale ? null : _snapshot;
    final filters = _filters;
    final repos =
        snapshot?.repos.where((r) => filters!.shows(r.root)).toList() ?? [];
    final failure = stale ? WorkspaceFailure.stale : _failure;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository discovery'),
        actions: [
          IconButton(
            tooltip: 'Refresh results',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : () => _load(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 1 + repos.length,
          itemBuilder: (context, index) {
            if (index > 0) {
              final repo = repos[index - 1];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(repo.label.isEmpty ? repo.root : repo.label),
                subtitle: Text('${repo.root}\nSessions: ${repo.sessions}'),
                trailing: IconButton(
                  tooltip: 'Hide ${repo.root}',
                  icon: const Icon(Icons.visibility_off_outlined),
                  onPressed: _busy
                      ? null
                      : () => _edit(
                          target!,
                          filters!,
                          (store) => store.setHidden(repo.root, true),
                        ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (failure != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(switch (failure) {
                      WorkspaceFailure.invalid =>
                        'Invalid path or discovery data. Use absolute server paths without . or .. components.',
                      WorkspaceFailure.unsupported =>
                        'This gateway does not support repository discovery.',
                      WorkspaceFailure.denied =>
                        'The gateway denied access to repository discovery.',
                      WorkspaceFailure.stale =>
                        'The connection changed. Reopen discovery on the current gateway.',
                      WorkspaceFailure.mismatch =>
                        'The displayed settings have changed. Refresh before trying again.',
                      _ =>
                        'Could not load or verify discovery settings. Refresh to try again.',
                    }),
                  ),
                if (snapshot != null && target != null && filters != null) ...[
                  _hostPolicy(snapshot, target),
                  _localSettings(filters, target),
                  const Divider(),
                  Text(
                    'Repositories shown: ${repos.length} of ${snapshot.repos.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (snapshot.repos.isEmpty)
                    const Text('The gateway returned no repositories.')
                  else if (repos.isEmpty)
                    const Text('No repositories match your device filters.'),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _hostPolicy(WorkspaceRepoDiscovery snapshot, WorkspaceTarget target) {
    final policy = snapshot.policy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gateway scan policy',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          policy == null
              ? 'This gateway did not report a scan policy.'
              : 'Scanning: ${policy.enabled ? 'enabled' : 'disabled'}',
        ),
        if (policy != null) ...[
          Text(
            'Scan roots: ${policy.roots.isEmpty ? 'none' : policy.roots.join('\n')}',
          ),
          Text(
            'Excluded subtrees: ${policy.excludedSubtrees.isEmpty ? 'none' : policy.excludedSubtrees.join('\n')}',
          ),
          if (policy.roots.isEmpty || !policy.enabled)
            const Text(
              'To scan folders, configure repository scanning in the gateway profile’s Desktop settings.',
            ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Results can include cached repositories and repositories with sessions. A scan does not guarantee that every folder was reached.',
        ),
        OutlinedButton.icon(
          onPressed:
              _busy || policy == null || !policy.enabled || policy.roots.isEmpty
              ? null
              : () {
                  if (_snapshot == snapshot) _load(scanTarget: target);
                },
          icon: const Icon(Icons.search),
          label: const Text('Scan gateway roots'),
        ),
      ],
    );
  }

  Widget _localSettings(WorkspaceRepoFilters filters, WorkspaceTarget target) =>
      Column(
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Filter results on this device'),
            subtitle: const Text(
              'Only this discovery list changes, not the gateway scan.',
            ),
            children: [
              _pathField(_roots, 'Include subtrees (empty = all)'),
              _pathField(_exclusions, 'Exclude subtrees'),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _edit(
                        target,
                        filters,
                        (store) => store.setSubtrees(
                          filters,
                          _lines(_roots),
                          _lines(_exclusions),
                        ),
                        updateFields: true,
                      ),
                child: const Text('Apply filters'),
              ),
            ],
          ),
          if (filters.hidden.isNotEmpty)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text('Hidden repositories (${filters.hidden.length})'),
              children: [
                for (final path in filters.hidden)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(path),
                    trailing: TextButton(
                      onPressed: _busy
                          ? null
                          : () => _edit(
                              target,
                              filters,
                              (store) => store.setHidden(path, false),
                            ),
                      child: const Text('Undo hide'),
                    ),
                  ),
              ],
            ),
        ],
      );

  Widget _pathField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: controller,
      enabled: !_busy,
      minLines: 1,
      maxLines: 4,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: label,
        helperText: 'One absolute server path per line',
        border: const OutlineInputBorder(),
      ),
    ),
  );

  List<String> _lines(TextEditingController c) => const LineSplitter()
      .convert(c.text)
      .where((line) => line.isNotEmpty)
      .toList();
}
