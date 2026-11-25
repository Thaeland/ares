import 'package:flutter/material.dart';

import '../services/gateway_fleet.dart';

/// The check and confirmation name exact owners. No fan-out over a list that
/// is re-resolved after the dialog closes. Each target settles independently.
class FleetUpdatesScreen extends StatefulWidget {
  const FleetUpdatesScreen({super.key, required this.fleet});
  final GatewayFleet fleet;
  @override
  State<FleetUpdatesScreen> createState() => _FleetUpdatesScreenState();
}

class _FleetUpdatesScreenState extends State<FleetUpdatesScreen> {
  List<FleetUpdateRow> rows = [];
  bool busy = false;
  Future<void> check() async {
    setState(() => busy = true);
    final result = await widget.fleet.checkUpdates();
    if (mounted) {
      setState(() {
        rows = result;
        busy = false;
      });
    }
  }

  Future<void> apply() async {
    final selected = rows.where((r) => r.canStart).toList();
    if (selected.isEmpty) return;
    setState(() => busy = true);
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Update these remote gateways?'),
        content: SingleChildScrollView(
          child: Text(
            'This can restart the backend and interrupt other users. It will not update Ares.\n\n${selected.map((r) => r.description).join('\n')}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Update listed gateways'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (yes == true) await Future.wait(selected.map((r) => r.start()));
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fleet updates')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Checks connected gateways. Cloud is platform-managed; entries without enrollment provenance are excluded.',
        ),
        TextButton(
          onPressed: busy ? null : check,
          child: const Text('Check connected gateways'),
        ),
        for (final row in rows)
          ListTile(
            title: Text(row.description),
            subtitle: Text(row.state),
            trailing: row.hasReceipt
                ? IconButton(
                    tooltip: 'Read update receipt',
                    icon: const Icon(Icons.receipt_long),
                    onPressed: busy
                        ? null
                        : () async {
                            setState(() => busy = true);
                            await row.refreshReceipt();
                            if (mounted) setState(() => busy = false);
                          },
                  )
                : null,
          ),
        if (rows.any((r) => r.canStart))
          FilledButton(
            onPressed: busy ? null : apply,
            child: const Text('Review eligible updates'),
          ),
        if (busy) const LinearProgressIndicator(),
      ],
    ),
  );
}
