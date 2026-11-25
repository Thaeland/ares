/// Shared "Desktop integration" settings card for Classic and NextGen.
///
/// Shown on Windows, macOS and Linux only. Every switch is device-local and
/// off by default; the card edits [DesktopOsPrefs] and the running
/// [DesktopIntegration] applies the change natively.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import 'desktop_integration.dart';
import 'desktop_os.dart';
import 'tray_controller.dart';

class DesktopIntegrationCard extends StatelessWidget {
  const DesktopIntegrationCard({
    required this.preferences,
    this.integration,
    super.key,
  });

  final SharedPreferences preferences;

  /// Defaults to [DesktopIntegration.current].
  final DesktopIntegration? integration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.sharedL10n;
    final prefs = DesktopOsPrefs(preferences);
    final running = integration ?? DesktopIntegration.current;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Card(
      key: const Key('desktop-integration-card'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ValueListenableBuilder<int>(
          valueListenable: desktopOsPrefsChanges,
          builder: (context, _, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.desktop_windows_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.desktop_integration_title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  key: const Key('desktop-tray-switch'),
                  title: Text(l.desktop_tray_setting),
                  subtitle: Text(l.desktop_tray_setting_help),
                  value: prefs.trayEnabled,
                  onChanged: (value) => prefs.setTrayEnabled(value),
                ),
                SwitchListTile(
                  key: const Key('desktop-close-to-tray-switch'),
                  title: Text(l.desktop_close_to_tray_setting),
                  value: prefs.closeToTray,
                  onChanged: prefs.trayEnabled
                      ? (value) => prefs.setCloseToTray(value)
                      : null,
                ),
                if (running != null)
                  ValueListenableBuilder<TrayStatus>(
                    valueListenable: running.tray.status,
                    builder: (context, status, _) =>
                        status == TrayStatus.unsupported
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              l.desktop_tray_unsupported,
                              key: const Key('desktop-tray-unsupported'),
                              style: muted,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
