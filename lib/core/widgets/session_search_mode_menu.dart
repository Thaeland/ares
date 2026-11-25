import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/session_search_preferences.dart';

class SessionSearchModeMenu extends StatelessWidget {
  const SessionSearchModeMenu(this.access, {super.key});
  final SessionSearchAccess access;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final local = l?.on_device ?? 'On-device';
    final gateway = '${l?.full_text ?? 'Full-text'} (gateway)';
    return PopupMenuButton<bool>(
      tooltip:
          '${l?.search_mode ?? 'Search mode'}: ${access.value ? gateway : local}',
      icon: Icon(access.value ? Icons.manage_search : Icons.phone_android),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(
          value: false,
          checked: !access.value,
          child: Text(local),
        ),
        CheckedPopupMenuItem(
          value: true,
          checked: access.value,
          child: Text(gateway),
        ),
      ],
      onSelected: (enabled) async {
        try {
          await access.setServer(enabled);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not save search mode.')),
            );
          }
        }
      },
    );
  }
}
