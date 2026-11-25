import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connection_manager.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/desktop_gateway_client.dart';
import '../services/remote_workspace.dart';
import 'profile_admin_panel.dart' show profileError;

class ProfileTransferScreen extends StatefulWidget {
  const ProfileTransferScreen({
    super.key,
    required this.source,
    required this.label,
  });
  final RemoteProfileAdmin source;
  final String label;
  @override
  State<ProfileTransferScreen> createState() => _ProfileTransferState();
}

class _ProfileTransferState extends State<ProfileTransferScreen> {
  CloudDirectory? directory;
  CloudAgent? agent;
  AgentTransfer? op;
  DesktopGatewayClient? dest;
  final typed = TextEditingController();
  String message = '';
  bool busy = false, revoked = false;
  Object? destEpoch;
  String? destId;
  SharedPreferences? prefs;
  Future<bool>? savingReceipt;
  bool priorReceipt = false;
  @override
  void initState() {
    super.initState();
    ConnectionMutationBarrier.addListener(_changed);
  }

  void _changed() {
    try {
      widget.source.check();
      if (destId != null &&
          !ConnectionMutationBarrier.isCurrent(destId!, destEpoch)) {
        throw StateError('changed');
      }
    } catch (_) {
      dest?.close();
      if (mounted) setState(() => revoked = true);
    }
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_changed);
    op?.cancel();
    dest?.close();
    typed.dispose();
    super.dispose();
  }

  void redraw() {
    final current = op;
    final proof = current?.undoFingerprint;
    if (current != null &&
        proof != null &&
        prefs != null &&
        savingReceipt == null) {
      savingReceipt = prefs!.setString(current.receiptKey, proof);
      savingReceipt!.ignore();
    }
    if (mounted) setState(() {});
  }

  Future<void> run(Future<void> Function() work) async {
    if (busy || revoked) return;
    setState(() {
      busy = true;
      message = '';
    });
    try {
      widget.source.check();
      await work();
    } catch (e) {
      message = profileError(e);
    } finally {
      busy = false;
      redraw();
    }
  }

  Future<void> discover([String? org]) async {
    directory = await widget.source.cloudAgents(org: org);
    if (directory!.teams.isEmpty && directory!.agents.isEmpty) {
      message = 'No available Cloud agents in this account.';
    }
  }

  Future<void> select(CloudAgent row) async {
    final manager = ConnectionManager(
      prefs = await SharedPreferences.getInstance(),
    );
    if (!mounted) return;
    widget.source.check();
    Iterable<SavedConnection> matches() => manager.getConnections().where(
      (c) =>
          cloudAgentOrigin(DesktopGatewayClient.normalizedGatewayBaseUrl(c)) ==
          row.origin,
    );
    final list = matches().toList();
    if (list.length != 1) {
      message =
          'Sign in to exactly one saved Ares connection for ${row.origin}, then return here.';
      return;
    }
    final id = list.single.id;
    final epoch = ConnectionMutationBarrier.capture(id);
    await manager.refreshConnectionCredentials(id);
    if (!mounted) return;
    widget.source.check();
    if (!ConnectionMutationBarrier.isCurrent(id, epoch)) {
      throw const WorkspaceException(WorkspaceFailure.stale);
    }
    final c = matches().single;
    if (c.id != id ||
        (!c.usesBrowserSignIn &&
            (c.dashboardPassword ?? '').isEmpty &&
            c.clientCertificate == null)) {
      throw const WorkspaceException(WorkspaceFailure.denied);
    }
    final d = DesktopGatewayClient.fromConnection(
      c.copyWith(gatewayProfile: 'default'),
    );
    dest?.close();
    dest = d;
    destId = id;
    destEpoch = epoch;
    final t = await d.workspace.pane().bind(d.workspace.route());
    final roster = await ProfileRoster.read(t);
    final target = await roster.settings(t, 'default');
    final transfer = await AgentTransfer.prepare(widget.source, target, row);
    final previous = prefs!.getString(transfer.receiptKey);
    if (!mounted) return;
    agent = row;
    op = transfer;
    priorReceipt = previous != null;
    if (previous != null) {
      try {
        await transfer.recoverUndo(previous);
      } on WorkspaceException {
        message =
            'The previous undo receipt could not be verified. No change was made.';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = op;
    final row = agent;
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer to Cloud')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Source: ${widget.label} / ${widget.source.name}'),
          if (revoked)
            const Text(
              'Connection changed. Leave this page. A restore already submitted may continue.',
            )
          else ...[
            if (busy)
              LinearProgressIndicator(
                value: current?.phase == AgentTransferPhase.upload
                    ? current?.fraction
                    : null,
              ),
            if (message.isNotEmpty) Text(message),
            if (current == null || row == null) ...[
              TextButton(
                onPressed: busy ? null : () => run(discover),
                child: const Text('Find my Cloud agents'),
              ),
              for (final t
                  in directory?.teams.entries ?? <MapEntry<String, String>>[])
                ListTile(
                  title: Text(t.value),
                  subtitle: Text(t.key),
                  onTap: busy ? null : () => run(() => discover(t.key)),
                ),
              for (final a in directory?.agents ?? <CloudAgent>[])
                ListTile(
                  title: Text(a.name),
                  subtitle: Text('${a.origin} · ${a.id}'),
                  onTap: busy ? null : () => run(() => select(a)),
                ),
            ] else ...[
              Text('Destination: ${row.name} · ${row.origin} / default'),
              Text('Agent ID: ${row.id}'),
              Text('Status: ${current.phase.name}'),
              if (current.phase == AgentTransferPhase.upload)
                Text('Copied ${((current.fraction ?? 0) * 100).floor()}%'),
              if (current.phase == AgentTransferPhase.prepared ||
                  current.canUndo) ...[
                Text(
                  current.canUndo
                      ? 'Undo replaces the destination with its pre-transfer backup.'
                      : 'Replace this Cloud agent with the entire source home, including credentials, conversations and files. The source is not deleted. Incoming messaging bots are switched off.',
                ),
                TextField(
                  controller: typed,
                  enabled: !busy,
                  decoration: const InputDecoration(
                    labelText: 'Type destination agent ID',
                  ),
                ),
                FilledButton(
                  onPressed: busy || (priorReceipt && !current.canUndo)
                      ? null
                      : () => run(() async {
                          final value = typed.text;
                          typed.clear();
                          if (current.canUndo) {
                            await current.undo(value, redraw);
                            await savingReceipt;
                            if (!await prefs!.remove(current.receiptKey)) {
                              throw StateError('Receipt not cleared');
                            }
                          } else {
                            try {
                              await current.replace(value, redraw);
                            } finally {
                              if (await savingReceipt == false) {
                                message =
                                    'Could not retain the local undo receipt. Keep this page open.';
                              }
                            }
                          }
                        }),
                  child: Text(
                    current.canUndo ? 'Undo transfer' : 'Replace Cloud agent',
                  ),
                ),
                if (priorReceipt)
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => run(() async {
                            if (typed.text != row.id) {
                              throw const WorkspaceException(
                                WorkspaceFailure.mismatch,
                              );
                            }
                            if (!await prefs!.remove(current.receiptKey)) {
                              throw StateError('Receipt not cleared');
                            }
                            typed.clear();
                            op = null;
                            agent = null;
                            priorReceipt = false;
                            savingReceipt = null;
                            dest?.close();
                            dest = null;
                            message =
                                'Local undo receipt forgotten. No remote backup was removed.';
                          }),
                    child: const Text('Forget local undo receipt only'),
                  ),
              ],
              if (busy &&
                  {
                    AgentTransferPhase.backup,
                    AgentTransferPhase.upload,
                  }.contains(current.phase))
                TextButton(
                  onPressed: current.cancel,
                  child: const Text('Stop before restore'),
                ),
              if (current.phase == AgentTransferPhase.restore ||
                  current.phase == AgentTransferPhase.undo)
                const Text(
                  'Do not close this page. Restore runs on the destination and cannot be cancelled.',
                ),
              if (current.undoArchive != null)
                SelectableText(
                  'Undo point on destination: ${current.undoArchive}',
                ),
              if (current.gatewayDown)
                const Text(
                  'Files restored; destination gateway needs attention.',
                ),
              if (current.messagingOff.isNotEmpty)
                Text('Messaging disabled: ${current.messagingOff.join(', ')}'),
            ],
          ],
        ],
      ),
    );
  }
}
