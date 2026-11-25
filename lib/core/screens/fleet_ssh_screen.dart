import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../services/fleet_ssh.dart';

/// SSH is deliberately separate from HTTP saved accounts. No API key, bearer,
/// Portal identity, Webapp SSH auto-connect or local shell fallback is used.
class FleetSshScreen extends StatefulWidget {
  const FleetSshScreen({super.key});
  @override
  State<FleetSshScreen> createState() => _FleetSshScreenState();
}

class _FleetSshScreenState extends State<FleetSshScreen> {
  final host = TextEditingController(),
      user = TextEditingController(),
      port = TextEditingController(text: '22'),
      keyInput = TextEditingController(),
      identity = TextEditingController(),
      remotePort = TextEditingController(text: '9119'),
      command = TextEditingController();
  bool busy = false;
  String message = '', output = '';
  Process? shell;
  @override
  void dispose() {
    shell?.kill();
    for (final c in [
      host,
      user,
      port,
      keyInput,
      identity,
      remotePort,
      command,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<bool> confirm(String title, String detail) async =>
      await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(title),
          content: SelectableText(detail),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ==
      true;
  Future<void> action(String mode) async {
    if (busy || shell != null) return;
    setState(() {
      busy = true;
      message = '';
      output = '';
    });
    try {
      final dest = SshDestination(
        host.text.trim(),
        int.tryParse(port.text) ?? 0,
        user.text.trim(),
      );
      final id = identity.text.trim().isEmpty ? null : identity.text.trim();
      final servicePort = int.tryParse(remotePort.text) ?? 0;
      final home = await getApplicationSupportDirectory();
      if (!mounted) return;
      final client = FleetSsh(Directory.fromUri(home.uri.resolve('ares-ssh/')));
      if (mode == 'enroll') {
        final key = SshPublicKey.parse(keyInput.text);
        if (!await confirm(
              'Pin this SSH host key?',
              '${dest.label}\n${key.fingerprint}\nCompare this fingerprint with the host administrator over an independent channel. No connection will be made.',
            ) ||
            !mounted) {
          return;
        }
        await client.enroll(dest, key);
        if (mounted) setState(() => message = 'Host key pinned.');
        return;
      }
      final key = await client.enrolled(dest);
      if (!mounted) return;
      if (key == null) {
        throw const FleetSshException('Enroll the host’s public key first.');
      }
      final detail = mode == 'shell'
          ? 'Open an interactive login shell.'
          : 'Read ${mode == 'preview' ? '/' : '/api/health'} on remote 127.0.0.1:$servicePort through an SSH channel.';
      if (!await confirm(
            'Connect to ${dest.label}?',
            '$detail\n${key.fingerprint}\n${id == null ? 'Authenticate with your SSH agent.' : 'Use the selected identity file.'}',
          ) ||
          !mounted) {
        return;
      }
      if (mode != 'shell') {
        final s = await client.readLoopback(
          dest,
          preview: mode == 'preview',
          port: servicePort,
          identity: id,
        );
        if (mounted) setState(() => output = s);
        return;
      }
      final p = await client.shell(dest, identity: id);
      if (!mounted) {
        p.kill();
        return;
      }
      setState(() => shell = p);
      final drain = p.stderr.drain<void>();
      await for (final s in p.stdout.transform(
        const Utf8Decoder(allowMalformed: true),
      )) {
        if (!mounted || !identical(shell, p)) continue;
        final text = (output + s).replaceAll(
          RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'),
          '',
        );
        setState(
          () => output = text.length > 32768
              ? text.substring(text.length - 32768)
              : text,
        );
      }
      final rc = await p.exitCode;
      await drain;
      if (mounted) {
        setState(
          () => message = rc == 0
              ? 'SSH session closed.'
              : 'SSH session ended without a clean exit.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => message = e is FleetSshException
              ? e.message
              : 'SSH operation failed. Check the destination and identity.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          shell = null;
        });
      }
    }
  }

  Widget field(TextEditingController c, String label, {bool multi = false}) =>
      TextField(
        controller: c,
        enabled: !busy,
        maxLines: multi ? 2 : 1,
        autocorrect: false,
        decoration: InputDecoration(labelText: label),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verified SSH')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!FleetSsh.supported)
          const Text(
            'This device has no supported system OpenSSH transport. The pinned gateway relay automatically accepts new keys and cannot be used for verified enrollment.',
          )
        else ...[
          field(host, 'SSH host'),
          field(port, 'SSH port'),
          field(user, 'SSH user'),
          field(identity, 'Identity file (optional; otherwise use SSH agent)'),
          field(
            keyInput,
            'Public host key from administrator (ssh-ed25519)',
            multi: true,
          ),
          TextButton(
            onPressed: busy ? null : () => action('enroll'),
            child: const Text('Review host key'),
          ),
          const Divider(),
          field(remotePort, 'Remote loopback service port'),
          Wrap(
            children: [
              TextButton(
                onPressed: busy ? null : () => action('health'),
                child: const Text('Check gateway over SSH'),
              ),
              TextButton(
                onPressed: busy ? null : () => action('preview'),
                child: const Text('Preview source over SSH'),
              ),
              TextButton(
                onPressed: busy ? null : () => action('shell'),
                child: const Text('Open SSH shell'),
              ),
            ],
          ),
          if (shell case final p?) ...[
            TextField(
              controller: command,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Line to remote shell',
              ),
              onSubmitted: (s) {
                if (identical(shell, p)) {
                  p.stdin.writeln(s);
                  p.stdin.flush().catchError((Object _) {
                    p.kill();
                  });
                  command.clear();
                }
              },
            ),
            TextButton(
              onPressed: () => p.kill(),
              child: const Text('Disconnect shell'),
            ),
          ],
          if (busy && shell == null) const LinearProgressIndicator(),
          if (message.isNotEmpty) Text(message),
          if (output.isNotEmpty) SelectableText(output),
        ],
      ],
    ),
  );
}
