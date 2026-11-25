import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../services/notification_prefs.dart';

/// Activity sharing and the completion sound, shared by the Classic and
/// NextGen notification settings (both already listen to
/// [NotificationPrefsStore]). The same control is shown on every platform.
///
/// The sound picker never sits in a [ListTile]'s `trailing` slot: on a narrow
/// phone with large text a trailing menu takes the whole tile width. The tile
/// shows the current choice as its subtitle and opens a sheet that wraps.
class CompletionSoundSettings extends StatelessWidget {
  const CompletionSoundSettings({super.key, required this.prefs});
  final NotificationPrefs prefs;

  static String soundLabel(AppLocalizations l, WindowsCompletionSound sound) =>
      switch (sound) {
        WindowsCompletionSound.system => l.windows_sound_default,
        WindowsCompletionSound.mail => l.windows_sound_mail,
        WindowsCompletionSound.reminder => l.windows_sound_reminder,
        WindowsCompletionSound.silent => l.windows_sound_silent,
      };

  Future<void> _pick(BuildContext context) {
    final l = context.sharedL10n;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.windows_completion_sound,
                  style: Theme.of(sheet).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                RadioGroup<WindowsCompletionSound>(
                  groupValue: prefs.completionSound,
                  onChanged: (value) {
                    if (value != null) {
                      NotificationPrefsStore.setWindowsSound(value);
                    }
                    Navigator.of(sheet).pop();
                  },
                  child: Column(
                    children: [
                      for (final sound in WindowsCompletionSound.values)
                        RadioListTile<WindowsCompletionSound>(
                          key: ValueKey('completion-sound-${sound.name}'),
                          value: sound,
                          title: Text(soundLabel(l, sound)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.sharedL10n;
    return Column(
      children: [
        SwitchListTile(
          key: const ValueKey('share-chat-activity'),
          title: Text(l.windows_window_activity),
          subtitle: Text(l.windows_window_activity_hint),
          value: prefs.shareWindowActivity,
          onChanged: NotificationPrefsStore.setShareWindowActivity,
        ),
        ListTile(
          key: const ValueKey('completion-sound'),
          enabled: prefs.enabled,
          title: Text(l.windows_completion_sound),
          subtitle: Text(soundLabel(l, prefs.completionSound)),
          trailing: const Icon(Icons.arrow_drop_down),
          onTap: () => _pick(context),
        ),
      ],
    );
  }
}
