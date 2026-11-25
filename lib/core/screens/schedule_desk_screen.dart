import 'package:flutter/material.dart';

import '../services/connection_manager.dart';
import '../services/remote_workspace.dart';
import '../services/scoped_profile_owner.dart';

/// All-profile schedules. Mutations are sent to the job's own profile, never
/// to whichever profile happens to be open in chat.
class ScheduleDeskScreen extends StatefulWidget {
  const ScheduleDeskScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.connection,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;

  @override
  State<ScheduleDeskScreen> createState() => _ScheduleDeskScreenState();
}

class _ScheduleDeskScreenState extends State<ScheduleDeskScreen> {
  WorkspacePane? _pane;
  WorkspaceTarget? _catalog;
  var _busy = false;
  String? _error;
  String _output = '';
  List<RemoteCronJob> _jobs = const [];
  List<RemoteBlueprint> _blueprints = const [];
  String? _blueprintProfile;
  final _slots = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    for (final controller in _slots.values) {
      controller.dispose();
    }
    _pane?.close();
    super.dispose();
  }

  Future<WorkspaceTarget> _boundCatalog() async {
    final current = _catalog;
    if (current != null && current.isCurrent) return current;
    _pane?.close();
    final pane = _pane = widget.owner.pane();
    final target = await pane.bind(widget.route);
    _catalog = target;
    return target;
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    String? profile;
    try {
      final catalog = await _boundCatalog();
      final jobs = await catalog.allSchedules();
      profile = _blueprintProfile ?? widget.route.profile;
      if (!mounted) return;
      setState(() => _jobs = jobs);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (profile != null && mounted) {
      try {
        await _loadBlueprints(profile);
      } on WorkspaceException catch (error) {
        if (mounted) setState(() => _error = '$error');
      }
    }
  }

  Future<void> _loadBlueprints(String profile) async {
    final blueprints = await withProfileOwner(
      widget.connection,
      profile,
      (target) => target.blueprints(),
    );
    if (!mounted) return;
    setState(() {
      _blueprintProfile = profile;
      _blueprints = blueprints;
    });
  }

  Future<void> _onOwner(
    RemoteCronJob job,
    Future<void> Function(WorkspaceTarget target) action,
  ) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await withProfileOwner(widget.connection, job.profile, action);
      final catalog = await _boundCatalog();
      final jobs = await catalog.allSchedules();
      if (!mounted) return;
      setState(() => _jobs = jobs);
    } on WorkspaceException catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create(RemoteBlueprint blueprint) async {
    final profile = _blueprintProfile;
    if (profile == null) return;
    final values = {
      for (final field in blueprint.fields)
        field.name: (_slots[field.name]?.text ?? field.defaultValue ?? '')
            .trim(),
    };
    setState(() => _busy = true);
    try {
      final job = await withProfileOwner(
        widget.connection,
        profile,
        (target) => target.instantiateBlueprint(blueprint.key, values),
      );
      if (!mounted) return;
      setState(() => _output = 'Created ${job.name} on ${job.profile}.');
      await _open();
    } on WorkspaceException catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = {
      if (widget.route.profile != null) widget.route.profile!,
      for (final job in _jobs) job.profile,
    }.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _open,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'The list covers every profile on this gateway. Stop, pause, catch-up, delivery and blueprints are sent to the job\'s owning profile.',
          ),
          if (_error != null) Text(_error!, key: const Key('schedule-error')),
          Text(_output, key: const Key('schedule-output')),
          for (final job in _jobs)
            Card(
              key: ValueKey('${job.profile}/${job.id}'),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.profile} · ${job.name}',
                      key: Key('schedule-job-${job.profile}-${job.id}'),
                    ),
                    Text(
                      job.runInFlight
                          ? 'A run is in progress'
                          : 'No current run',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (job.runInFlight)
                          FilledButton(
                            key: Key('schedule-stop-${job.profile}-${job.id}'),
                            onPressed: _busy
                                ? null
                                : () => _onOwner(job, (target) async {
                                    final cancelled = await target
                                        .stopCurrentRun(job);
                                    _output = cancelled
                                        ? 'Stop requested for ${job.name}.'
                                        : 'No run was in flight for ${job.name}.';
                                  }),
                            child: const Text('Stop current run'),
                          ),
                        OutlinedButton(
                          key: Key('schedule-pause-${job.profile}-${job.id}'),
                          onPressed: _busy
                              ? null
                              : () => _onOwner(
                                  job,
                                  (target) => target.setFutureRuns(
                                    job,
                                    resume: !job.enabled,
                                  ),
                                ),
                          child: Text(
                            job.enabled
                                ? 'Pause future runs'
                                : 'Resume future runs',
                          ),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      key: Key('schedule-catchup-${job.id}'),
                      value: switch (job.catchUp) {
                        true => 'run',
                        false => 'skip',
                        null => 'default',
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'default',
                          child: Text('Catch-up default'),
                        ),
                        DropdownMenuItem(
                          value: 'run',
                          child: Text('Run one missed'),
                        ),
                        DropdownMenuItem(
                          value: 'skip',
                          child: Text('Skip missed'),
                        ),
                      ],
                      onChanged: _busy
                          ? null
                          : (value) {
                              final catchUp = switch (value) {
                                'run' => true,
                                'skip' => false,
                                _ => null,
                              };
                              _onOwner(
                                job,
                                (target) => target.setCatchUp(job, catchUp),
                              );
                            },
                    ),
                    _DeliveryEditor(
                      key: ValueKey('delivery-${job.profile}-${job.id}'),
                      connection: widget.connection,
                      job: job,
                      busy: _busy,
                      onChanged: (deliver) => _onOwner(
                        job,
                        (target) => target.setDelivery(job, deliver),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Text('Blueprint recipes'),
          DropdownButton<String>(
            key: const Key('schedule-blueprint-profile'),
            value: profiles.contains(_blueprintProfile)
                ? _blueprintProfile
                : null,
            hint: const Text('Profile for the new job'),
            items: [
              for (final profile in profiles)
                DropdownMenuItem(value: profile, child: Text(profile)),
            ],
            onChanged: _busy || profiles.isEmpty
                ? null
                : (profile) {
                    if (profile != null) _loadBlueprints(profile);
                  },
          ),
          for (final blueprint in _blueprints) ...[
            Text('${blueprint.title} (${blueprint.source ?? 'builtin'})'),
            Text(blueprint.description),
            for (final field in blueprint.fields)
              TextField(
                key: Key('blueprint-${blueprint.key}-${field.name}'),
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: field.help,
                ),
                controller: _slots.putIfAbsent(
                  field.name,
                  () => TextEditingController(text: field.defaultValue ?? ''),
                ),
              ),
            FilledButton(
              key: Key('blueprint-create-${blueprint.key}'),
              onPressed: _busy ? null : () => _create(blueprint),
              child: Text('Create ${blueprint.title}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryEditor extends StatefulWidget {
  const _DeliveryEditor({
    super.key,
    required this.connection,
    required this.job,
    required this.busy,
    required this.onChanged,
  });

  final SavedConnection connection;
  final RemoteCronJob job;
  final bool busy;
  final ValueChanged<String> onChanged;

  @override
  State<_DeliveryEditor> createState() => _DeliveryEditorState();
}

class _DeliveryEditorState extends State<_DeliveryEditor> {
  List<RemoteDeliveryTarget>? _targets;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _DeliveryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.job.profile != widget.job.profile ||
        oldWidget.job.id != widget.job.id) {
      _targets = null;
      _error = null;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final targets = await withProfileOwner(
        widget.connection,
        widget.job.profile,
        (target) => target.deliveryTargets(),
      );
      if (mounted) setState(() => _targets = targets);
    } on WorkspaceException catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = _targets;
    if (_error != null) return Text(_error!);
    if (targets == null) return const Text('Loading delivery targets');
    final selected = widget.job.deliver.split(',').toSet();
    return Wrap(
      children: [
        for (final target in targets)
          FilterChip(
            label: Text(
              target.homeTargetSet
                  ? target.name
                  : '${target.name} (no home channel)',
            ),
            selected: selected.contains(target.id),
            onSelected: widget.busy
                ? null
                : (_) {
                    try {
                      widget.onChanged(
                        toggleDeliveryTarget(widget.job.deliver, target.id),
                      );
                    } on FormatException catch (error) {
                      setState(() => _error = error.message);
                    }
                  },
          ),
      ],
    );
  }
}
