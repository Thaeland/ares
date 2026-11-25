/// The primary window's native desktop integration: one owner for the tray,
/// quick entry, the global hotkey and power events, created by the app root
/// on Windows, macOS and Linux only.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/hermes_deeplink.dart';
import '../services/locale_preference.dart';
import '../services/notification_prefs.dart';
import '../services/turn_notification_service.dart' show notificationStrings;
import '../widgets/desktop_shortcuts.dart';
import 'desktop_os.dart';
import 'quick_entry.dart';
import 'tray_controller.dart';

class DesktopIntegration {
  DesktopIntegration({
    required SharedPreferences preferences,
    DesktopShell shell = const DesktopShell(),
    VoidCallback? onNewChat,
    Future<void> Function(bool enabled)? setNotificationsEnabled,
    ValueListenable<NotificationPrefs>? notifications,
    this._deepLinks,
    List<QuickEntryChat> Function()? quickEntryChats,
    QuickEntrySpawn? quickEntrySpawn,
    this._strings,
  }) : prefs = DesktopOsPrefs(preferences),
       _shell = shell,
       _onNewChat = onNewChat ?? _fireNewChat,
       _setNotificationsEnabled =
           setNotificationsEnabled ?? NotificationPrefsStore.setEnabled,
       _notifications = notifications ?? notificationPrefs {
    quickEntry = QuickEntryLauncher(
      chats: quickEntryChats ?? QuickEntryTargets.current,
      locale: () => strings().localeName,
      onPrefill: _routePrefill,
      spawn: quickEntrySpawn,
    );
    tray = TrayController(
      prefs: prefs,
      labels: _trayLabels,
      onAction: handleTrayAction,
      notificationsPaused: () => !_notifications.value.enabled,
      quickEntryAvailable: () => true,
      refreshOn: _notifications,
      channel: shell.channel,
    );
  }

  /// The running integration, for settings screens and the command
  /// palette. Null on phones, in tests that do not create one, and in child
  /// windows.
  static DesktopIntegration? current;

  final DesktopOsPrefs prefs;
  final DesktopShell _shell;
  final VoidCallback _onNewChat;
  final Future<void> Function(bool enabled) _setNotificationsEnabled;
  final ValueListenable<NotificationPrefs> _notifications;
  final HermesDeepLinkService? _deepLinks;
  final AppLocalizations Function()? _strings;

  late final TrayController tray;
  late final QuickEntryLauncher quickEntry;

  bool _disposed = false;

  static void _fireNewChat() => fireDesktopShortcut(DesktopShortcut.newChat);

  void start() {
    if (_disposed) return;
    current = this;
    tray.start();
  }

  AppLocalizations strings() {
    final custom = _strings;
    if (custom != null) return custom();
    final chosen = LocalePreference.read(prefs.preferences);
    if (chosen != null && AppLocalizations.delegate.isSupported(chosen)) {
      return lookupAppLocalizations(chosen);
    }
    return notificationStrings();
  }

  TrayLabels _trayLabels() {
    final l = strings();
    return TrayLabels(
      tooltip: 'Ares',
      open: l.desktop_tray_open,
      newChat: l.desktop_tray_new_chat,
      quickEntry: l.desktop_tray_quick_entry,
      pauseNotifications: l.desktop_tray_pause_notifications,
      quit: l.desktop_tray_quit,
    );
  }

  /// Opens quick entry (command palette); false when it could not open.
  Future<bool> openQuickEntry() =>
      _disposed ? Future.value(false) : quickEntry.show();

  /// The hand-back from the quick-entry window: show the main window and
  /// route a prefill-only link through the validated deep-link router.
  void _routePrefill(QuickEntryPrefill prefill) {
    if (_disposed) return;
    unawaited(_shell.showWindow());
    (_deepLinks ?? HermesDeepLinkService.shared).handleRawLink(
      prefill.toDeepLink(),
    );
  }

  @visibleForTesting
  void handleTrayAction(TrayAction action) {
    if (_disposed) return;
    switch (action) {
      case TrayAction.open:
        unawaited(_shell.showWindow());
      case TrayAction.newChat:
        unawaited(_shell.showWindow());
        _onNewChat();
      case TrayAction.quickEntry:
        unawaited(quickEntry.toggle());
      case TrayAction.pauseNotifications:
        unawaited(_setNotificationsEnabled(!_notifications.value.enabled));
      case TrayAction.quit:
        unawaited(quit());
    }
  }

  /// Tears the integration down (tray icon, hotkey, quick entry), then asks
  /// the runner to close the primary window.
  Future<void> quit() async {
    await dispose();
    await _shell.quit();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (identical(current, this)) current = null;
    quickEntry.dispose();
    await tray.dispose();
  }
}
