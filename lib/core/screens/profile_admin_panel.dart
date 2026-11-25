import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr/qr.dart';
import '../services/remote_workspace.dart';
import 'profile_transfer_screen.dart';
import 'profile_bundle_screen.dart';

String profileError(Object e) => switch (e) {
  WorkspaceException(reason: WorkspaceFailure.unsupported) =>
    'This operation is unavailable on this gateway.',
  WorkspaceException(reason: WorkspaceFailure.denied) =>
    'Access denied by the gateway.',
  WorkspaceException(reason: WorkspaceFailure.stale) =>
    'Connection changed. Reopen Profiles.',
  WorkspaceException(reason: WorkspaceFailure.invalid) =>
    'Invalid input or gateway response. Check the target before retrying.',
  _ => 'Could not verify the result. Refresh the target before trying again.',
};
Future<String?> profileInput(
  BuildContext context,
  String title,
  String field,
  String scope,
) {
  String value = '';
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(scope),
          TextField(
            autofocus: true,
            decoration: InputDecoration(labelText: field),
            onChanged: (v) => value = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, value),
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

class ProfileAdminPanel extends StatefulWidget {
  const ProfileAdminPanel({
    super.key,
    required this.admin,
    required this.label,
    required this.onRosterChanged,
  });
  final RemoteProfileAdmin admin;
  final String label;
  final VoidCallback onRosterChanged;
  @override
  State<ProfileAdminPanel> createState() => _ProfileAdminPanelState();
}

class _Field {
  const _Field(
    this.label, {
    this.value = '',
    this.secret = false,
    this.lines = 1,
    this.choices,
  });
  final String label, value;
  final bool secret;
  final int lines;
  final List<String>? choices;
}

class _Editor {
  _Editor(this.title, this.warning, this.fields, this.submit);
  final String title, warning;
  final List<_Field> fields;
  final Future<void> Function(List<String>) submit;
}

class _ProfileAdminPanelState extends State<ProfileAdminPanel> {
  RemoteProfileAdmin get a => widget.admin;
  String get scope => '${widget.label} / ${a.name}';
  bool busy = false;
  String message = '';
  _Editor? editor;
  List<String> values = [];
  List<ProfileChannel>? channels;
  List<ProfilePair>? pairs;
  ({bool enabled, List<ProfileHook> entries})? hooks;
  TelegramSetup? setup;
  QrImage? qr;
  ProfileBackup? backup;
  ProfileBackup? completedBackup;
  String? revealedSecret;
  bool showSecret = false;
  List<String> csv(String s) => s
      .split(',')
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();
  void edit(
    String title,
    String warning,
    List<_Field> fields,
    Future<void> Function(List<String>) submit,
  ) {
    if (!mounted) return;
    a.check();
    setState(() {
      editor = _Editor(title, warning, fields, submit);
      values = fields.map((f) => f.value).toList();
      message = '';
      revealedSecret = null;
    });
  }

  Future<void> run(Future<void> Function() work) async {
    if (busy) return;
    setState(() {
      busy = true;
      message = '';
      revealedSecret = null;
      showSecret = false;
    });
    try {
      a.check();
      await work();
    } catch (e) {
      if (mounted) message = profileError(e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget action(String text, Future<void> Function() work, {String? detail}) =>
      ListTile(
        title: Text(text),
        subtitle: detail == null ? null : Text(detail),
        onTap: busy ? null : () => run(work),
      );
  void changeRoster(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    widget.onRosterChanged();
  }

  Future<void> persona() async {
    final before = await a.soul();
    edit(
      'Edit SOUL.md',
      'Save the persona for $scope.',
      [_Field('Persona', value: before.content, lines: 7)],
      (v) async {
        await a.saveSoul(before, v[0]);
        message = 'Persona saved.';
      },
    );
  }

  void channelEditor(ProfileChannel c) {
    final inputs = [
      for (final f in c.fields)
        _Field(
          '${f.key} (${f.isSet ? 'configured' : 'not set'})',
          value: f.listValue ?? '',
          secret: f.listValue == null,
        ),
    ];
    edit(
      'Configure ${c.name}',
      'Applies to $scope. Blank keeps an existing value. To remove a value, list its key below.',
      [
        _Field(
          'Enabled',
          value: c.enabled ? 'yes' : 'no',
          choices: const ['yes', 'no'],
        ),
        ...inputs,
        const _Field('Keys to remove (comma-separated)'),
      ],
      (v) async {
        if (!{'yes', 'no'}.contains(v.first)) {
          throw const WorkspaceException(WorkspaceFailure.invalid);
        }
        final clear = csv(v.last);
        final env = <String, String>{};
        for (var i = 0; i < c.fields.length; i++) {
          final f = c.fields[i];
          final val = v[i + 1].trim();
          if (val.isNotEmpty && val != f.listValue && !clear.contains(f.key)) {
            env[f.key] = val;
          }
        }
        final hot = await a.updateChannel(c, v.first == 'yes', env, clear);
        channels = await a.channels();
        message = hot
            ? 'Saved and applied by the gateway.'
            : 'Saved. A gateway restart may be required.';
      },
    );
  }

  void newHook() {
    edit(
      'Create signed route',
      'Applies to $scope. Use a unique name. The gateway creates a signing secret. If another operator creates the name simultaneously the host may replace that route.',
      [
        const _Field('Route ID'),
        const _Field(
          'Signature',
          value: 'generic',
          choices: ['generic', 'github', 'gitlab', 'linear'],
        ),
        const _Field('Events (comma-separated)'),
        const _Field(
          'Delivery target',
          value: 'log',
          choices: [
            'log',
            'telegram',
            'discord',
            'slack',
            'email',
            'github_comment',
          ],
        ),
        const _Field('Prompt', lines: 3),
        const _Field('Skills (comma-separated)'),
        const _Field(
          'Delivery mode',
          value: 'Agent processes event',
          choices: ['Agent processes event', 'Direct delivery'],
        ),
        const _Field('Delivery chat ID (optional)'),
      ],
      (v) async {
        final r = await a.createHook(
          route: v[0],
          signature: v[1],
          events: csv(v[2]),
          delivery: v[3],
          prompt: v[4],
          skills: csv(v[5]),
          direct: v[6] == 'Direct delivery',
          chatId: v[7],
        );
        hooks = await a.hooks();
        revealedSecret = r.secret;
        message = 'Created ${r.url}. Store the signing secret before leaving.';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = editor;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (message.isNotEmpty) SelectableText(message),
        if (revealedSecret != null) ...[
          TextButton(
            onPressed: () => setState(() => showSecret = !showSecret),
            child: Text(
              showSecret ? 'Hide signing secret' : 'Reveal signing secret',
            ),
          ),
          if (showSecret) SelectableText(revealedSecret!),
        ],
        if (form != null) ...[
          Text(form.title, style: Theme.of(context).textTheme.titleLarge),
          Text(form.warning),
          for (var i = 0; i < form.fields.length; i++)
            if (form.fields[i].choices case final options?)
              DropdownButtonFormField<String>(
                key: ValueKey((form, i)),
                initialValue: values[i],
                decoration: InputDecoration(labelText: form.fields[i].label),
                items: [
                  for (final option in options)
                    DropdownMenuItem(value: option, child: Text(option)),
                ],
                onChanged: busy
                    ? null
                    : (v) {
                        if (v != null) values[i] = v;
                      },
              )
            else
              TextFormField(
                key: ValueKey((form, i)),
                initialValue: values[i],
                enabled: !busy,
                obscureText: form.fields[i].secret,
                autocorrect: false,
                enableSuggestions: false,
                minLines: form.fields[i].lines,
                maxLines: form.fields[i].lines,
                maxLength: form.fields[i].lines > 1 ? 131072 : 8192,
                decoration: InputDecoration(
                  labelText: form.fields[i].label,
                  counterText: '',
                ),
                onChanged: (v) => values[i] = v,
              ),
          Wrap(
            children: [
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        editor = null;
                        values = [];
                      }),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () => run(() async {
                        final args = [...values];
                        await form.submit(args);
                        if (mounted) {
                          editor = null;
                          values = [];
                        }
                      }),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ] else ...[
          action('Edit persona', persona, detail: 'SOUL.md'),
          action('Portable profile bundle', () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ProfileBundleScreen(admin: a, gateway: widget.label),
              ),
            );
          }),
          action(
            'Clone profile',
            () async => edit(
              'Clone profile',
              'Copy settings, skills, persona and potentially provider credentials from $scope. Messaging tokens are not requested.',
              [const _Field('New profile ID')],
              (v) async {
                await a.roster.create(v[0], clone: a.name);
                changeRoster('Cloned ${a.name} to ${v[0]}.');
              },
            ),
          ),
          action(
            a.name == 'default' ? 'Rename display label' : 'Rename profile',
            () async => edit(
              'Rename ${a.name}',
              a.name == 'default'
                  ? 'Change the presentation label for $scope. Its ID stays default.'
                  : 'Rename $scope on the server. A running gateway may stop.',
              [const _Field('New name')],
              (v) async {
                await a.rename(v[0]);
                changeRoster('Rename verified.');
              },
            ),
          ),
          if (a.name != 'default')
            action(
              'Delete profile',
              () async => edit(
                'Delete ${a.name}',
                'Permanently delete $scope, including sessions and credentials. Type the exact profile ID.',
                [const _Field('Profile ID to delete')],
                (v) async {
                  if (v[0] != a.name) {
                    throw const WorkspaceException(WorkspaceFailure.mismatch);
                  }
                  final settled = await a.remove();
                  changeRoster(
                    settled
                        ? 'Profile deleted.'
                        : 'Profile deleted. Server identity cleanup is still pending.',
                  );
                },
              ),
            ),
          action(
            'Export profile archive',
            () async => edit(
              'Export ${a.name}',
              'Create a .tar.gz on $scope. Known credential stores are excluded, but private data can remain. Review before sharing.',
              [],
              (v) async {
                message =
                    'Archive on ${widget.label}: ${await a.exportProfile()}';
              },
            ),
          ),
          action(
            'Import profile archive',
            () async => edit(
              'Import a trusted profile',
              'Use a reviewed .tar.gz already on ${widget.label}. It can contain plugins, scripts and schedules. A new profile ID is required.',
              [
                const _Field('Absolute archive path on gateway'),
                const _Field('New profile ID'),
              ],
              (v) async {
                await a.importProfile(v[0], v[1]);
                changeRoster('Imported ${v[1]}.');
              },
            ),
          ),
          const Divider(),
          action('Messaging channels', () async {
            channels = await a.channels();
          }),
          for (final c in channels ?? <ProfileChannel>[])
            action(
              c.name,
              () async => channelEditor(c),
              detail: '${c.id} · ${c.state}',
            ),
          action('DM pairing requests', () async {
            pairs = await a.pairs();
            if (pairs!.isEmpty) message = 'No pending or approved users.';
          }),
          for (final p in pairs ?? <ProfilePair>[])
            if (p.pending &&
                !RegExp(r'^[a-f0-9]{16}$').hasMatch(p.request ?? ''))
              ListTile(
                title: Text(p.user),
                subtitle: const Text(
                  'Legacy pairing: no verifiable request ID. Ask the user to pair again.',
                ),
              )
            else
              action(
                '${p.pending ? 'Approve' : 'Revoke'} ${p.user}',
                () async => edit(
                  '${p.pending ? 'Approve' : 'Revoke'} ${p.user}',
                  '${p.platform} on $scope: ${p.pending ? 'allow' : 'remove'} this user’s messaging access.',
                  [],
                  (v) async {
                    await a.changePair(p);
                    pairs = await a.pairs();
                    message = 'Pairing change verified.';
                  },
                ),
                detail: p.platform,
              ),
          if (setup == null)
            action(
              'Create Telegram bot by QR',
              () async => edit(
                'Create Telegram bot',
                'Start a Telegram pairing on $scope using the gateway’s setup service.',
                [const _Field('Bot name', value: 'Hermes Agent')],
                (v) async {
                  final result = await a.startTelegram(v[0]);
                  qr = QrImage(
                    QrCode.fromData(
                      data: result.payload,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                  );
                  setup = result;
                },
              ),
            ),
          if (setup case final s?) ...[
            Center(
              child: Semantics(
                label: 'Telegram bot creation QR code',
                child: CustomPaint(
                  size: const Size.square(216),
                  painter: _QR(qr!),
                ),
              ),
            ),
            SelectableText(s.payload),
            Text('Expires: ${s.expires.toLocal()}'),
            action('Check Telegram pairing', () async {
              final status = await a.telegramStatus(s);
              if (!status.ready) {
                message = 'Waiting for Telegram.';
                return;
              }
              edit(
                'Apply Telegram bot',
                'Enable @${status.bot} on $scope and attempt a gateway restart. Only the listed users may message it.',
                [_Field('Allowed numeric user IDs', value: status.user)],
                (v) async {
                  final needs = await a.applyTelegram(s, csv(v[0]));
                  setup = null;
                  qr = null;
                  message = needs
                      ? 'Saved. Restart still required.'
                      : 'Saved; gateway restart requested.';
                },
              );
            }),
            action('Cancel Telegram setup', () async {
              await a.cancelTelegram(s);
              setup = null;
              qr = null;
            }),
          ],
          const Divider(),
          action('Inbound webhooks', () async {
            hooks = await a.hooks();
          }),
          if (hooks case final h?) ...[
            if (!h.enabled)
              action(
                'Enable webhook service',
                () async => edit(
                  'Enable webhooks',
                  'Enable inbound webhooks on $scope and attempt a gateway restart.',
                  [],
                  (v) async {
                    final needs = await a.enableHooks();
                    hooks = await a.hooks();
                    message = needs
                        ? 'Enabled. Restart still required.'
                        : 'Enabled; restart requested.';
                  },
                ),
              )
            else
              action('Create signed route', () async => newHook()),
            for (final route in h.entries) ...[
              ListTile(
                title: Text(route.name),
                subtitle: SelectableText('${route.signature} · ${route.url}'),
              ),
              Wrap(
                children: [
                  for (final del in [false, true])
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => run(
                              () async => edit(
                                '${del
                                    ? 'Delete'
                                    : route.enabled
                                    ? 'Disable'
                                    : 'Enable'} ${route.name}',
                                'Change exactly ${route.name} on $scope.',
                                [],
                                (v) async {
                                  await a.changeHook(route, delete: del);
                                  hooks = await a.hooks();
                                  message = 'Route change verified.';
                                },
                              ),
                            ),
                      child: Text(
                        del
                            ? 'Delete route'
                            : route.enabled
                            ? 'Disable route'
                            : 'Enable route',
                      ),
                    ),
                ],
              ),
            ],
          ],
          const Divider(),
          action(
            'Back up entire agent home',
            () async => edit(
              'Back up entire agent home',
              'This is not an Ares settings backup. Save all profiles, sessions and credentials on ${widget.label}. The archive is sensitive.',
              [],
              (v) async {
                completedBackup = null;
                backup = await a.startBackup();
                message = 'Backup started on ${widget.label}.';
              },
            ),
          ),
          action('Transfer to a Cloud agent', () async {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ProfileTransferScreen(source: a, label: widget.label),
              ),
            );
          }),
          if (backup case final b?)
            action('Check backup progress', () async {
              if (await a.backupDone(b)) {
                message = 'Backup verified on ${widget.label}: ${b.archive}';
                completedBackup = b;
                backup = null;
              } else {
                message = 'Backup still running on ${widget.label}.';
              }
            }),
          if (completedBackup case final done?)
            action(
              'Save backup to this device',
              () async {
                final bytes = await a.backupBytes(done);
                if (!mounted) return;
                a.check();
                final path = await FilePicker.platform.saveFile(
                  dialogTitle: 'Save sensitive full-home archive',
                  fileName: 'hermes-backup.zip',
                  bytes: bytes,
                );
                message = path == null ? 'Save cancelled.' : 'Backup saved.';
              },
              detail: 'Up to 32 MiB. Larger archives remain on the gateway.',
            ),
        ],
      ],
    );
  }
}

class _QR extends CustomPainter {
  _QR(this.image);
  final QrImage image;
  @override
  void paint(Canvas canvas, Size size) {
    final side = image.moduleCount + 8;
    final unit = size.shortestSide / side;
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final pen = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var y = 0; y < image.moduleCount; y++) {
      for (var x = 0; x < image.moduleCount; x++) {
        if (image.isDark(y, x)) {
          canvas.drawRect(
            Rect.fromLTWH((x + 4) * unit, (y + 4) * unit, unit, unit),
            pen,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QR oldDelegate) => image != oldDelegate.image;
}
