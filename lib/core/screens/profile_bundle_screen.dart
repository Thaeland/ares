import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/connection.dart';
import '../workspace/profile_presentation.dart';
import '../workspace/profile_presentation_store.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/portable_profile_bundle.dart';
import '../services/profile_file_save.dart';
import '../services/remote_workspace.dart';
import 'profile_admin_panel.dart' show profileError;

class ProfileBundleScreen extends StatefulWidget {
  const ProfileBundleScreen({
    super.key,
    required this.admin,
    required this.gateway,
    required this.connection,
    required this.nextGen,
  });
  final RemoteProfileAdmin admin;
  final String gateway;
  final SavedConnection connection;
  final bool nextGen;
  @override
  State<ProfileBundleScreen> createState() => _BundleState();
}

class _BundleState extends State<ProfileBundleScreen> {
  PortableProfileBundle? bundle;
  final checked = <String>{};
  final dest = TextEditingController();
  String message = '';
  bool importing = false, busy = false;
  bool adopt = false;
  ProfilePresentation? preview;
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
          preview = null;
          adopt = false;
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
    bundle = b.withDesktop(
      ProfilePresentation.parseText(b.files['desktop.json'])?.encode(),
    );
    importing = true;
    preview = null;
    adopt = false;
    checked.clear();
  }

  String _layoutLabel(ProfilePresentation style) => switch (style.geometry) {
    null => 'Current layout',
    (paired: false, stacked: _, percent: _) => 'One pane',
    final g =>
      '${g.stacked ? 'Stacked' : 'Side by side'} · ${g.percent}% first pane',
  };

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
            TextButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      final style = ProfilePresentation.parse(
                        await widget.admin.bundledPresentation(),
                      );
                      check();
                      preview = style;
                      if (preview == null) {
                        message = 'No supported appearance in this profile.';
                      }
                    }),
              child: const Text('Review appearance saved with this profile'),
            ),
            if (preview case final style?) ...[
              Text(
                'Skin: ${style.skin ?? 'unchanged'} · Mode: ${style.mode?.name ?? 'unchanged'} · ${_layoutLabel(style)}',
              ),
              const Text(
                'Applies only to this named profile on this device. An imported arrangement starts with empty panes; choose its chats yourself.',
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () => run(() async {
                        final store = ProfilePresentationStore(
                          await SharedPreferences.getInstance(),
                        );
                        await store.apply(widget.connection, style, check);
                        preview = null;
                        message =
                            'Appearance applied to ${widget.gateway} / ${widget.admin.name}.';
                      }),
                child: const Text('Apply to this profile on this device'),
              ),
            ],
            const Text(
              'Export prepares a .tar.gz on the gateway. Review its portable files before saving a copy here. Import opens a local archive for review; opening alone uploads nothing.',
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () => run(() async {
                      final data = await widget.admin.portableExport(check);
                      check();
                      final store = ProfilePresentationStore(
                        await SharedPreferences.getInstance(),
                      );
                      check();
                      bundle = data.withDesktop(
                        store
                            .snapshot(widget.connection, widget.nextGen)
                            .encode(),
                      );
                      preview = null;
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
              if (checked.contains('desktop.json'))
                CheckboxListTile(
                  value: adopt,
                  onChanged: busy
                      ? null
                      : (v) => setState(() => adopt = v == true),
                  title: const Text(
                    'Apply appearance to the new profile on this device',
                  ),
                  subtitle: const Text(
                    'Imports colours and pane sizes, never chats, tools or session IDs.',
                  ),
                ),
              const Text(
                'The gateway retains a private staged copy. Import creates a new profile; it will not replace an existing one.',
              ),
              TextField(
                controller: dest,
                enabled: !busy,
                decoration: const InputDecoration(labelText: 'New profile ID'),
              ),
            ],
            FilledButton(
              onPressed: busy || checked.isEmpty
                  ? null
                  : () => run(() async {
                      if (importing) {
                        final name = dest.text;
                        final receipt = await widget.admin.importPortable(
                          b,
                          Set.of(checked),
                          name,
                          check,
                        );
                        check();
                        message = 'Imported $name on ${widget.gateway}.';
                        if (adopt && checked.contains('desktop.json')) {
                          final actual = ProfilePresentation.parse(receipt);
                          if (actual == null ||
                              actual.encode() != b.files['desktop.json']) {
                            message +=
                                ' Appearance not applied: the gateway did not confirm the reviewed overlay.';
                          } else {
                            try {
                              final store = ProfilePresentationStore(
                                await SharedPreferences.getInstance(),
                              );
                              await store.apply(
                                widget.connection.copyWith(
                                  gatewayProfile: name,
                                ),
                                actual,
                                check,
                              );
                              message += ' Appearance applied on this device.';
                            } catch (_) {
                              check();
                              message +=
                                  ' Appearance was not saved on this device.';
                            }
                          }
                        }
                      } else {
                        final bytes = b.encode(checked);
                        check();
                        final path = await saveProfileFile(
                          title: 'Save reviewed profile bundle',
                          filename: '${b.profile}.tar.gz',
                          check: check,
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
