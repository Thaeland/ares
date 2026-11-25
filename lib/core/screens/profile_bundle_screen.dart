import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/portable_profile_bundle.dart';
import '../services/remote_workspace.dart';
import 'profile_admin_panel.dart' show profileError;

class ProfileBundleScreen extends StatefulWidget {
  const ProfileBundleScreen({
    super.key,
    required this.admin,
    required this.gateway,
  });
  final RemoteProfileAdmin admin;
  final String gateway;
  @override
  State<ProfileBundleScreen> createState() => _BundleState();
}

class _BundleState extends State<ProfileBundleScreen> {
  PortableProfileBundle? bundle;
  final checked = <String>{};
  final dest = TextEditingController();
  String message = '';
  bool importing = false, busy = false;
  @override
  void initState() {
    super.initState();
    ConnectionMutationBarrier.addListener(_changed);
  }

  void _changed() {
    try {
      widget.admin.check();
    } catch (_) {
      if (mounted) {
        setState(() {
          bundle = null;
          checked.clear();
          message = 'Connection changed. Reopen Profiles.';
        });
      }
    }
  }

  @override
  void dispose() {
    ConnectionMutationBarrier.removeListener(_changed);
    dest.dispose();
    super.dispose();
  }

  void check() {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      throw const WorkspaceException(WorkspaceFailure.stale);
    }
    widget.admin.check();
  }

  Future<void> run(Future<void> Function() task) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = '';
    });
    try {
      check();
      await task();
    } catch (e) {
      message = e is FormatException
          ? 'Unsupported or oversized profile archive.'
          : profileError(e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> selectLocal() async {
    final pick = await FilePicker.platform.pickFiles(
      withReadStream: true,
      withData: false,
    );
    check();
    if (pick == null) return;
    final file = pick.files.single;
    if (file.size > PortableProfileBundle.compressedLimit) {
      throw const FormatException();
    }
    final stream =
        file.readStream ??
        (file.path == null ? null : File(file.path!).openRead());
    if (stream == null) throw const FormatException();
    final bytes = await PortableProfileBundle.bounded(
      stream,
      PortableProfileBundle.compressedLimit,
    );
    check();
    final b = await PortableProfileBundle.inspect(bytes);
    check();
    bundle = b;
    importing = true;
    checked.clear();
  }

  @override
  Widget build(BuildContext context) {
    final b = bundle;
    return Scaffold(
      appBar: AppBar(title: const Text('Portable profile bundle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${widget.gateway} / ${widget.admin.name}'),
          if (busy) const LinearProgressIndicator(),
          if (message.isNotEmpty) Text(message),
          if (b == null) ...[
            const Text(
              'Export prepares a .tar.gz on the gateway. Review its portable files before saving a copy here. Import opens a local archive for review; opening alone uploads nothing.',
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      final data = await widget.admin.portableExport(check);
                      check();
                      bundle = data;
                      importing = false;
                      checked.clear();
                    }),
              child: const Text('Prepare profile export'),
            ),
            TextButton(
              onPressed: busy ? null : () => run(selectLocal),
              child: const Text('Open .tar.gz from this device'),
            ),
          ] else ...[
            Text(
              'Bundle: ${b.profile} · ${b.files.length} reviewable files · ${b.omitted} omitted',
            ),
            const Text(
              'Only selected text files travel. Review for secrets and private information. Config, skills and schedules can change what the new profile does.',
            ),
            for (final entry in b.files.entries)
              ExpansionTile(
                title: Text(entry.key),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(entry.value),
                  ),
                  CheckboxListTile(
                    title: const Text('Include this reviewed file'),
                    value: checked.contains(entry.key),
                    onChanged: busy
                        ? null
                        : (v) => setState(() {
                            if (v == true) {
                              checked.add(entry.key);
                            } else {
                              checked.remove(entry.key);
                            }
                          }),
                  ),
                ],
              ),
            if (importing) ...[
              const Text(
                'The gateway retains a private staged copy. Import creates a new profile; it will not replace an existing one.',
              ),
              TextField(
                controller: dest,
                decoration: const InputDecoration(labelText: 'New profile ID'),
              ),
            ],
            FilledButton(
              onPressed: busy || checked.isEmpty
                  ? null
                  : () => run(() async {
                      if (importing) {
                        final name = dest.text;
                        await widget.admin.importPortable(
                          b,
                          Set.of(checked),
                          name,
                          check,
                        );
                        check();
                        message = 'Imported $name on ${widget.gateway}.';
                      } else {
                        final bytes = b.encode(checked);
                        check();
                        final path = await FilePicker.platform.saveFile(
                          dialogTitle: 'Save reviewed profile bundle',
                          fileName: '${b.profile}.tar.gz',
                          bytes: bytes,
                        );
                        check();
                        message = path == null
                            ? 'Save cancelled.'
                            : 'Profile bundle saved.';
                      }
                      checked.clear();
                      bundle = null;
                    }),
              child: Text(
                importing
                    ? 'Import selected files'
                    : 'Save selected files to device',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
