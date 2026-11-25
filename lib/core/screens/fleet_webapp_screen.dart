import 'package:flutter/material.dart';

import '../services/connection_mutation_barrier.dart';
import '../services/gateway_fleet.dart';
import '../services/remote_workspace.dart';
import 'fleet_screen.dart' show enrollFleetAddress, fleetError;

class FleetWebappScreen extends StatefulWidget {
  const FleetWebappScreen({
    super.key,
    required this.owner,
    required this.label,
    required this.fleet,
  });
  final RemoteWorkspaceOwner owner;
  final String label;
  final GatewayFleet fleet;
  @override
  State<FleetWebappScreen> createState() => _FleetWebappScreenState();
}

class _FleetWebappScreenState extends State<FleetWebappScreen> {
  late final pane = widget.owner.pane();
  late final epoch = ConnectionMutationBarrier.capture(
    widget.owner.connectionId,
  );
  WorkspaceTarget? target;
  String? message;
  CloudInventory? cloud;
  WebappRegistry? registry;
  WebappDirection? direction;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    ConnectionMutationBarrier.addListener(changed);
  }

  void changed() {
    if (!ConnectionMutationBarrier.isCurrent(
      widget.owner.connectionId,
      epoch,
    )) {
      pane.invalidate();
      if (mounted) {
        setState(() {
          cloud = null;
          target = null;
          registry = null;
          direction = null;
          message = 'Account changed. Reopen this page.';
        });
      }
    }
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(changed);
    pane.close();
    super.dispose();
  }

  Future<void> run(
    Future<void> Function(WorkspaceTarget) job, {
    bool fresh = false,
  }) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
      if (fresh) {
        cloud = null;
        registry = null;
        direction = null;
        target = null;
      }
    });
    try {
      final t = target ?? await pane.bind(widget.owner.route());
      t.checkCurrent();
      target = t;
      await job(t);
      t.checkCurrent();
    } catch (e) {
      if (mounted) {
        setState(() {
          message = fleetError(e);
          if (target?.isCurrent != true) {
            cloud = null;
            registry = null;
            direction = null;
            target = null;
          }
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> confirmPrimary(WorkspaceTarget t, WebappGateway row) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set the Webapp’s primary gateway?'),
        content: Text(
          '${widget.label} → ${row.label} (${row.id})\nThis changes the shared registry, not the last-used gateway.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Set primary'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    t.checkCurrent();
    registry = await t.setWebappPrimary(row);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cloud and Desktop Webapp')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: Text(widget.label),
          subtitle: Text(widget.owner.profile ?? 'Serving profile'),
        ),
        const Text('Hermes Cloud'),
        TextButton(
          onPressed: busy
              ? null
              : () => run((t) async {
                  cloud = await t.discoverCloud();
                }, fresh: true),
          child: const Text('Discover signed-in agents'),
        ),
        if (cloud case final c?) ...[
          if (c.org case final org?)
            ListTile(title: Text('Organisation: ${org.name}')),
          for (final o in c.choices)
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: Text(o.name),
              subtitle: Text(o.id),
              onTap: busy
                  ? null
                  : () => run((t) async {
                      cloud = null;
                      cloud = await t.discoverCloud(orgId: o.id);
                    }),
            ),
          for (final a in c.agents)
            ListTile(
              title: Text(a.name),
              subtitle: Text(
                '${a.status} · ${a.address?.toString() ?? 'No gateway address yet'}',
              ),
              onTap: a.address == null || busy
                  ? null
                  : () => run((t) async {
                      final latest = await t.discoverCloud(orgId: c.org?.id);
                      t.checkCurrent();
                      if (latest.org?.id != c.org?.id ||
                          !latest.agents.contains(a)) {
                        throw const WorkspaceException(
                          WorkspaceFailure.mismatch,
                        );
                      }
                      if (context.mounted) {
                        await enrollFleetAddress(
                          context,
                          widget.fleet,
                          address: a.address,
                          label: a.name,
                        );
                      }
                    }),
            ),
          if (c.agents.isEmpty && c.choices.isEmpty)
            const Text('No agents available.'),
        ],
        const Divider(),
        const Text('Existing Desktop Webapp'),
        TextButton(
          onPressed: busy
              ? null
              : () => run((t) async {
                  final d = await t.fleetDiagnostics();
                  t.checkCurrent();
                  message = 'Gateway ${d.version} · ${d.access}';
                }, fresh: true),
          child: const Text('Check gateway and Web Access status'),
        ),
        const Text(
          'These settings belong to the machine serving this Webapp. Publishing and restarts are not remote actions.',
        ),
        TextButton(
          onPressed: busy
              ? null
              : () => run((t) async {
                  registry = await t.webappRegistry();
                }, fresh: true),
          child: const Text('Read Webapp gateway registry'),
        ),
        if (registry case final r?)
          for (final entry in r.entries)
            ListTile(
              title: Text(entry.label),
              subtitle: Text(
                [
                  entry.kind,
                  entry.id,
                  if (r.lastUsed == entry.id) 'Last used',
                  if (r.primary == entry.id) 'Primary',
                ].join(' · '),
              ),
              trailing: IconButton(
                tooltip: 'Set primary: ${entry.label}',
                icon: Icon(
                  r.primary == entry.id ? Icons.star : Icons.star_border,
                ),
                onPressed: busy || r.primary == entry.id
                    ? null
                    : () => run((t) => confirmPrimary(t, entry)),
              ),
            ),
        TextButton(
          onPressed: busy
              ? null
              : () => run((t) async {
                  direction = await t.webappDirection();
                }, fresh: true),
          child: const Text('Read shared display preferences'),
        ),
        if (direction case final value?)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chat text direction on this Webapp and Desktop'),
              Wrap(
                children: [
                  for (final d in WebappDirection.values)
                    ChoiceChip(
                      label: Text(d.name.toUpperCase()),
                      selected: value == d,
                      onSelected: busy || d == value
                          ? null
                          : (_) => run((t) async {
                              direction = await t.setWebappDirection(d);
                            }),
                    ),
                ],
              ),
            ],
          ),
        if (busy) const LinearProgressIndicator(),
        if (message case final msg?) Text(msg),
      ],
    ),
  );
}
