import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/completion_cue.dart';
import '../services/notification_prefs.dart';

/// Both settings surfaces already listen to NotificationPrefsStore.
/// The same control is shown on every platform. Windows still plays the
/// choice through its toast sink; other platforms use [CompletionCue].
class WindowsCompletionSoundTile extends StatelessWidget {
  const WindowsCompletionSoundTile({super.key, required this.prefs});
  final NotificationPrefs prefs;
  @override
  Widget build(BuildContext context) {
    final l = context.sharedL10n;
    return Column(
      children: [
        SwitchListTile(
          title: Text(l.windows_window_activity),
          subtitle: Text(l.windows_window_activity_hint),
          value: prefs.shareWindowActivity,
          onChanged: NotificationPrefsStore.setShareWindowActivity,
        ),
        ListTile(
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
        ),
      ],
    );
  }
}
