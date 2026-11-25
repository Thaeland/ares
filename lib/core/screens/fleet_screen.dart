import 'dart:async';

import 'package:flutter/material.dart';

import '../../nextgen/data/chat_controller.dart';
import '../../nextgen/ui/connect_screen.dart';
import '../services/gateway_fleet.dart';
import '../services/remote_workspace.dart';
import 'fleet_webapp_screen.dart';
import 'fleet_ssh_screen.dart';
import 'fleet_updates_screen.dart';

/// Owned above navigation: switching visible gateways doesn't reroute or close
/// an attached conversation. Only explicit disconnect/account edits end it.
class FleetScope extends InheritedWidget {
  const FleetScope({super.key, required this.fleet, required super.child});
  final GatewayFleet fleet;
  static GatewayFleet of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FleetScope>()!.fleet;
  @override
  bool updateShouldNotify(FleetScope oldWidget) => fleet != oldWidget.fleet;
}

String fleetError(Object e) => switch (e) {
  WorkspaceException(reason: WorkspaceFailure.unsupported) =>
    'This gateway does not offer this service.',
  WorkspaceException(reason: WorkspaceFailure.denied) =>
    'Sign-in or permission required on this gateway.',
  WorkspaceException(reason: WorkspaceFailure.insecure) =>
    'A secure gateway address is required.',
  WorkspaceException(
    reason: WorkspaceFailure.stale || WorkspaceFailure.mismatch,
  ) =>
    'The owner changed. Refresh before continuing.',
  _ => 'Could not verify the operation. Check the gateway and refresh.',
};
void _notice(BuildContext context, Object e) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(fleetError(e))));

Future<void> enrollFleetAddress(
  BuildContext context,
  GatewayFleet fleet, {
  Uri? address,
  String? label,
}) async {
  // A discovered URL only pre-fills the ordinary new-account flow. Never pass
  // the discovery gateway's SavedConnection, certificate or Portal session.
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (ctx) => NgConnectScreen(
        connManager: fleet.manager,
        firstRun: false,
        fleetEnrollment: true,
        initialAddress: address,
        initialLabel: label,
        onCancel: () => Navigator.pop(ctx),
        onConnected: (_) => Navigator.pop(ctx),
      ),
    ),
  );
}

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key, required this.serving, required this.label});
  final RemoteWorkspaceOwner? serving;
  final String label;
  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  @override
  Widget build(BuildContext context) {
    final fleet = FleetScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gateway fleet')),
      body: ListenableBuilder(
        listenable: fleet,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: const Text('Verified SSH'),
              subtitle: const Text(
                'Confirm a host key, inspect a remote service or open its shell',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const FleetSshScreen()),
              ),
            ),
            if (widget.serving case final owner?)
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: const Text('Cloud and Desktop Webapp'),
                subtitle: Text(widget.label),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => FleetWebappScreen(
                      owner: owner,
                      label: widget.label,
                      fleet: fleet,
                    ),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.add_link),
              title: const Text('Register an existing gateway or Webapp'),
              subtitle: const Text(
                'Sign in to its address. Nothing is hosted on this device.',
              ),
              onTap: () async {
                await enrollFleetAddress(context, fleet);
                if (mounted) setState(() {});
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Fleet updates'),
              leading: const Icon(Icons.system_update_alt),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => FleetUpdatesScreen(fleet: fleet),
                ),
              ),
            ),
            for (final c in fleet.manager.getConnections())
              if (fleet.host(c.id) case final h?)
                _GatewayGroup(key: ObjectKey(h), host: h, fleet: fleet)
              else
                ListTile(
                  title: Text(c.label),
                  subtitle: Text(c.gatewayProfile ?? c.host),
                  trailing: TextButton(
                    onPressed: c.hasDashboardAuth
                        ? () async {
                            try {
                              await fleet.attach(c.id);
                            } catch (e) {
                              if (context.mounted) _notice(context, e);
                            }
                          }
                        : null,
                    child: const Text('Connect'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _GatewayGroup extends StatelessWidget {
  const _GatewayGroup({
    super.key,
    required this.host,
    required this.fleet,
    this.childProfile = false,
  });
  final bool childProfile;
  final FleetHost host;
  final GatewayFleet fleet;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: host,
    builder: (context, _) {
      final target = host.target;
      final c = host.gateway.connection;
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(c.label),
              subtitle: Text(
                '${c.gatewayProfile ?? 'Serving profile'} · ${host.gateway.state.label}',
              ),
              trailing: Wrap(
                children: [
                  IconButton(
                    tooltip: 'Refresh roster',
                    onPressed: host.loading ? null : host.refresh,
                    icon: const Icon(Icons.refresh),
                  ),
                  if (!childProfile)
                    IconButton(
                      tooltip: 'Disconnect ${c.label}',
                      onPressed: () => fleet.detach(c.id),
                      icon: const Icon(Icons.link_off),
                    ),
                ],
              ),
            ),
            if (host.loading)
              const LinearProgressIndicator()
            else if (!childProfile)
              CheckboxListTile(
                title: const Text('Open this gateway on launch'),
                subtitle: const Text(
                  'Primary for Ares; does not change the last-used gateway.',
                ),
                value: GatewayFleet.primaryId(fleet.manager, [c]) == c.id,
                onChanged: (_) async {
                  try {
                    await fleet.togglePrimary(host);
                  } catch (e) {
                    if (context.mounted) _notice(context, e);
                  }
                },
              ),
            if (!childProfile)
              SwitchListTile(
                title: const Text('Reconnect in fleet on launch'),
                value: fleet.remembered(c.id),
                onChanged: (v) async {
                  try {
                    await fleet.remember(host, v);
                  } catch (e) {
                    if (context.mounted) _notice(context, e);
                  }
                },
              ),
            if (host.loading)
              const SizedBox.shrink()
            else if (host.failure case final why?)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(fleetError(WorkspaceException(why))),
              )
            else if (target != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: childProfile
                    ? Text(c.gatewayProfile!)
                    : Wrap(
                        children: [
                          for (final name in host.profiles)
                            ActionChip(
                              label: Text(name),
                              onPressed: name == c.gatewayProfile
                                  ? null
                                  : () {
                                      try {
                                        host.attachProfile(name, target);
                                      } catch (e) {
                                        _notice(context, e);
                                      }
                                    },
                            ),
                        ],
                      ),
              ),
              for (final r in host.sessions)
                ListTile(
                  leading: const Icon(Icons.chat_outlined),
                  title: Text(r.title),
                  subtitle: Text(r.profile),
                  onTap: () async {
                    try {
                      // The default profile can change on the server. Attach a
                      // named owner before opening any conversation on it.
                      if (c.gatewayProfile == null) {
                        host.attachProfile(r.profile, target);
                        return;
                      }
                      final chat = await host.openSession(r, target);
                      if (context.mounted && host.current) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => _FleetChat(
                              fleet: fleet,
                              host: host,
                              row: r,
                              chat: chat,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) _notice(context, e);
                    }
                  },
                ),
              if (host.sessions.isEmpty)
                const ListTile(title: Text('No sessions for this profile.')),
              if (host.hasMore)
                TextButton(
                  onPressed: () => host.refresh(more: true),
                  child: const Text('More sessions'),
                ),
            ],
            if (!childProfile)
              for (final p in host.attachedProfiles)
                _GatewayGroup(
                  key: ObjectKey(p),
                  host: p,
                  fleet: fleet,
                  childProfile: true,
                ),
          ],
        ),
      );
    },
  );
}

class _FleetChat extends StatefulWidget {
  const _FleetChat({
    required this.fleet,
    required this.host,
    required this.row,
    required this.chat,
  });
  final GatewayFleet fleet;
  final FleetHost host;
  final FleetSession row;
  final NgChatController chat;
  @override
  State<_FleetChat> createState() => _FleetChatState();
}

class _FleetChatState extends State<_FleetChat> {
  final input = TextEditingController();
  bool sending = false;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> send(WorkspaceTarget displayed) async {
    if (sending || input.text.trim().isEmpty) return;
    setState(() => sending = true);
    final text = input.text;
    try {
      if (!await widget.host.send(widget.row, widget.chat, text, displayed)) {
        throw const WorkspaceException(WorkspaceFailure.unavailable);
      }
      if (mounted && input.text == text) input.clear();
    } catch (e) {
      if (mounted) _notice(context, e);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        '${widget.host.gateway.connection.label} / ${widget.row.profile}',
      ),
    ),
    body: ListenableBuilder(
      listenable: widget.fleet,
      builder: (context, _) {
        if (!widget.host.current) {
          return const Center(child: Text('This gateway was disconnected.'));
        }
        final chat = widget.chat;
        return ListenableBuilder(
          listenable: Listenable.merge([chat, widget.host]),
          builder: (context, _) => SafeArea(
            child: Column(
              children: [
                ListTile(
                  title: Text(widget.row.title),
                  subtitle: Text(widget.row.id),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final item in chat.items)
                        if (item is NgUserItem || item is NgAssistantItem)
                          ListTile(
                            title: Text(
                              item is NgUserItem ? 'You' : 'Assistant',
                            ),
                            subtitle: SelectableText(
                              item is NgUserItem
                                  ? item.text
                                  : (item as NgAssistantItem).text,
                            ),
                          ),
                      if (chat.historyError != null || chat.error != null)
                        const Text(
                          'Some conversation data could not be loaded.',
                        ),
                    ],
                  ),
                ),
                if (chat.running) const LinearProgressIndicator(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: input,
                        decoration: const InputDecoration(
                          hintText: 'Message this session',
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Send to this session',
                      onPressed: switch (widget.host.target) {
                        final target?
                            when chat.runtimeId != null &&
                                !chat.running &&
                                !sending =>
                          () => send(target),
                        _ => null,
                      },
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
