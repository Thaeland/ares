import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/notification_prefs.dart';

/// Both settings surfaces already listen to NotificationPrefsStore.
class WindowsCompletionSoundTile extends StatelessWidget {
  const WindowsCompletionSoundTile({super.key, required this.prefs});
  final NotificationPrefs prefs;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListTile(
      title: Text(l.windows_completion_sound),
      trailing: DropdownButton<WindowsCompletionSound>(
        value: prefs.completionSound,
        items: [
          for (final s in WindowsCompletionSound.values)
            DropdownMenuItem(
              value: s,
              child: Text(switch (s) {
                WindowsCompletionSound.system => l.windows_sound_default,
                WindowsCompletionSound.mail => l.windows_sound_mail,
                WindowsCompletionSound.reminder => l.windows_sound_reminder,
                WindowsCompletionSound.silent => l.windows_sound_silent,
              }),
            ),
        ],
        onChanged: prefs.enabled
            ? (v) {
                if (v != null) NotificationPrefsStore.setWindowsSound(v);
              }
            : null,
      ),
    );
  }
}
