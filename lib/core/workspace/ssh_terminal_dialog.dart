import 'package:flutter/material.dart';

typedef SshLogin = ({
  String host,
  int port,
  String user,
  String pin,
  String password,
});

/// Credentials entered here are never saved or borrowed from a gateway.
class SshTerminalDialog extends StatefulWidget {
  const SshTerminalDialog({super.key});
  @override
  State<SshTerminalDialog> createState() => _SshState();
}

class _SshState extends State<SshTerminalDialog> {
  final values = List.generate(
    5,
    (i) => TextEditingController(text: i == 1 ? '22' : ''),
  );
  @override
  void dispose() {
    for (final c in values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Open a verified SSH terminal'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Use a fingerprint obtained independently from the host administrator. This opens a new remote login, not the gateway or a local shell.',
          ),
          for (final (i, label) in [
            'SSH host',
            'Port',
            'User',
            'Host key fingerprint (SHA256:…)',
            'SSH password (not saved)',
          ].indexed)
            TextField(
              controller: values[i],
              obscureText: i == 4,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(labelText: label),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, (
          host: values[0].text,
          port: int.tryParse(values[1].text) ?? 0,
          user: values[2].text,
          pin: values[3].text,
          password: values[4].text,
        )),
        child: const Text('Connect'),
      ),
    ],
  );
}
