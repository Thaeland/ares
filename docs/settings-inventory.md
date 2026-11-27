# Settings inventory

Baseline: `4a73b53e`, inspected before implementation. IDs below are stable inventory identifiers; existing widget keys, presentation tour IDs and command/deep-link IDs remain compatibility identifiers. Nested rows and actions are inventoried even when hosted by an existing shared component. No preference migration is required.

Categories: General (language/interface), Appearance (theme/reading/companion/radio), Chat & sessions, Voice, Notifications, Device & shortcuts (desktop/background), Connections & models (gateway administration), Privacy & backup (security/danger), About & help. Gateway operations remain distinguishable from device preferences and retain owner/capability checks. Advanced transport, chord editor and import choices remain progressively disclosed. There was no general security preference page or updater to migrate.

| Stable ID | Current location at baseline | Intended group | Experience | Persisted source | Scope | Gating | Migration status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| interface.mode | Classic top / NG Interface | general | shared | nextgen_enabled | global | all | pending |
| language | Classic top | general | shared | LocalePreference.key | global | all | pending |
| classic.theme.mode | Classic Appearance / ThemeAppearanceSettings | appearance | classic | theme_mode / theme_palette | mode | all | pending |
| classic.theme.palette | Classic Appearance / ThemeAppearanceSettings | appearance | classic | theme_mode / theme_palette | mode | all | pending |
| ng.theme.mode | NG Appearance | appearance | nextgen | nextgen_theme_mode / nextgen_accent / nextgen_pure_black / nextgen_glow | mode | all | pending |
| ng.theme.accent | NG Appearance | appearance | nextgen | nextgen_theme_mode / nextgen_accent / nextgen_pure_black / nextgen_glow | mode | all | pending |
| ng.theme.black | NG Appearance | appearance | nextgen | nextgen_theme_mode / nextgen_accent / nextgen_pure_black / nextgen_glow | mode | all | pending |
| ng.theme.glow | NG Appearance | appearance | nextgen | nextgen_theme_mode / nextgen_accent / nextgen_pure_black / nextgen_glow | mode | all | pending |
| presentation.theme.import | Both / PresentationSettingsPanel | appearance | shared | ImportedThemeStore | global | all | pending |
| presentation.theme.select | Both / PresentationSettingsPanel | appearance | shared | ImportedThemeStore | global | all | pending |
| presentation.theme.remove | Both / PresentationSettingsPanel | appearance | shared | ImportedThemeStore | global | all | pending |
| presentation.theme.limit-dialog | Both / PresentationSettingsPanel | appearance | shared | ImportedThemeStore | global | all | pending |
| presentation.font.chat | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.font.terminal | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.direction | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.bubble | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.embeds | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.embeds.reset | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.reactions | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.hearts | Both / PresentationSettingsPanel | appearance | shared | presentation.reading.v1 | global | all | pending |
| presentation.pet.enabled | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.pet.choose | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.pet.import | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.pet.remove | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.pet.roam | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.pet.popout | Both / PetdexSettings | appearance | shared | presentation.petdex.v1 | global | all | pending |
| presentation.radio.enabled | Both / AresRadioSettingsBody | appearance | shared | presentation.radio.* | global | all | pending |
| presentation.radio.station | Both / AresRadioSettingsBody | appearance | shared | presentation.radio.* | global | all | pending |
| presentation.radio.volume | Both / AresRadioSettingsBody | appearance | shared | presentation.radio.* | global | all | pending |
| presentation.radio.pin | Both / AresRadioSettingsBody | appearance | shared | presentation.radio.* | global | all | pending |
| presentation.radio.popout | Both / AresRadioSettingsBody | appearance | shared | presentation.radio.* | global | all | pending |
| presentation.search | Both / PresentationSettingsPanel | appearance | shared | presentation.tips.v1 / ephemeral | global | window translucency unavailable | pending |
| presentation.tour | Both / PresentationSettingsPanel | appearance | shared | presentation.tips.v1 / ephemeral | global | window translucency unavailable | pending |
| presentation.tips.dismiss | Both / PresentationSettingsPanel | appearance | shared | presentation.tips.v1 / ephemeral | global | window translucency unavailable | pending |
| presentation.tips.restore | Both / PresentationSettingsPanel | appearance | shared | presentation.tips.v1 / ephemeral | global | window translucency unavailable | pending |
| presentation.window.unavailable | Both / PresentationSettingsPanel | appearance | shared | presentation.tips.v1 / ephemeral | global | window translucency unavailable | pending |
| text-size | Classic Text size | appearance | shared | TextSizePreferenceStore | global | all | pending |
| text-size.picker | Classic Text size | appearance | shared | TextSizePreferenceStore | global | all | pending |
| classic.chat.density | Classic Appearance | chat | classic | chat_density / verbose_mode | mode | all | pending |
| classic.chat.verbose | Classic Appearance | chat | classic | chat_density / verbose_mode | mode | all | pending |
| classic.session.sources | Classic Session Sources | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.acp | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.api_server | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.cli | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.cron | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.desktop | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.discord | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.gateway | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.mobile | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.signal | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.slack | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.telegram | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.tool | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.tui | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| classic.session.source.whatsapp | Classic Session Sources checkbox | chat | classic | excluded_session_sources_<connectionId> | gateway | all | pending |
| voice.reply | Classic Voice / _VoicePicker; NG read_aloud consumes same keys | voice | shared | voice_name / voice_locale | global | not parked | pending |
| voice.reply.picker | Classic Voice / _VoicePicker; NG read_aloud consumes same keys | voice | shared | voice_name / voice_locale | global | not parked | pending |
| classic.voice.handsfree | Classic Voice | voice | classic | hermes_hands_free_enabled | mode | not parked | pending |
| voice.auto-read | Both Voice | voice | shared | AutoSpeakRepliesStore / BargeInPreferenceStore | global | not parked | pending |
| voice.barge-in | Both Voice | voice | shared | AutoSpeakRepliesStore / BargeInPreferenceStore | global | not parked | pending |
| voice.engine | Both Voice / gateway panels | voice | shared | VoiceLiveModeController / GatewayWakeWordController | gateway/profile | capability + not parked | pending |
| voice.wake.enabled | Both Voice / gateway panels | voice | shared | VoiceLiveModeController / GatewayWakeWordController | gateway/profile | capability + not parked | pending |
| voice.wake.capture | Both Voice / gateway panels | voice | shared | VoiceLiveModeController / GatewayWakeWordController | gateway/profile | capability + not parked | pending |
| voice.wake.device | Both Voice / gateway panels | voice | shared | VoiceLiveModeController / GatewayWakeWordController | gateway/profile | capability + not parked | pending |
| voice.wake.rearm | Both Voice / gateway panels | voice | shared | VoiceLiveModeController / GatewayWakeWordController | gateway/profile | capability + not parked | pending |
| notifications.enabled | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.approval | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.input | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.turnDone | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.turnError | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.backgroundDone | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.credits | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.plugin | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.activity | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.sound | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.sound.picker | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.mute | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.test | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.recent | Classic Notifications; NG notifications aggregated reply/request toggles | notifications | shared | hermes_notification_prefs / TurnNotificationService | platform | local notifications + not parked; Windows diagnostics retained | pending |
| notifications.ng-replies | NG NotificationSettings compatibility widget | notifications | shared | hermes_notification_prefs kinds (aggregate aliases) | global | not parked | pending |
| notifications.ng-requests | NG NotificationSettings compatibility widget | notifications | shared | hermes_notification_prefs kinds (aggregate aliases) | global | not parked | pending |
| notifications.push | Classic MobilePushSettings / advanced transport | notifications | shared | MobilePushSettings existing connection owner service | gateway/profile/platform | Android, not parked | pending |
| notifications.push.transport | Classic MobilePushSettings / advanced transport | notifications | shared | MobilePushSettings existing connection owner service | gateway/profile/platform | Android, not parked | pending |
| notifications.push.retry | Classic MobilePushSettings / advanced transport | notifications | shared | MobilePushSettings existing connection owner service | gateway/profile/platform | Android, not parked | pending |
| notifications.push.revoke | Classic MobilePushSettings / advanced transport | notifications | shared | MobilePushSettings existing connection owner service | gateway/profile/platform | Android, not parked | pending |
| background.enabled | Classic BackgroundWorkSettings / NG Keep running | device | shared | BackgroundWorkPrefsStore / OS battery settings | platform | Android-compatible runner | pending |
| background.battery | Classic BackgroundWorkSettings / NG Keep running | device | shared | BackgroundWorkPrefsStore / OS battery settings | platform | Android-compatible runner | pending |
| device.keep-awake | Both KeepAwakeSettingsCard | device | shared | keep_awake_mode | platform | runner capability | pending |
| device.keep-awake.picker | Both KeepAwakeSettingsCard | device | shared | keep_awake_mode | platform | runner capability | pending |
| desktop.tray | Both DesktopIntegrationCard | device | shared | desktop_tray_enabled_v1 / desktop_close_to_tray_v1 / desktop_quick_entry_hotkey_enabled_v1 / desktop_quick_entry_hotkey_v1 | platform | desktop + native capability | pending |
| desktop.close-to-tray | Both DesktopIntegrationCard | device | shared | desktop_tray_enabled_v1 / desktop_close_to_tray_v1 / desktop_quick_entry_hotkey_enabled_v1 / desktop_quick_entry_hotkey_v1 | platform | desktop + native capability | pending |
| desktop.hotkey | Both DesktopIntegrationCard | device | shared | desktop_tray_enabled_v1 / desktop_close_to_tray_v1 / desktop_quick_entry_hotkey_enabled_v1 / desktop_quick_entry_hotkey_v1 | platform | desktop + native capability | pending |
| desktop.hotkey.edit | Both DesktopIntegrationCard | device | shared | desktop_tray_enabled_v1 / desktop_close_to_tray_v1 / desktop_quick_entry_hotkey_enabled_v1 / desktop_quick_entry_hotkey_v1 | platform | desktop + native capability | pending |
| desktop.hotkey.reset | Both DesktopIntegrationCard | device | shared | desktop_tray_enabled_v1 / desktop_close_to_tray_v1 / desktop_quick_entry_hotkey_enabled_v1 / desktop_quick_entry_hotkey_v1 | platform | desktop + native capability | pending |
| shortcuts.rebind | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| shortcuts.reset | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| shortcuts.reset-all | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| shortcuts.editor.modifiers | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| shortcuts.editor.key | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| shortcuts.editor.save | Both KeyboardShortcutsSettingsCard / chord editor | device | shared | ShortcutsStore | platform | desktopShortcutsAvailable | pending |
| connection.info | Classic Connection | connections | shared | SavedConnection | gateway | all | pending |
| ng.connection.check | NG gateway and saved gateways | connections | nextgen | NgScope / runConnectionCheck / ConnectionManager | gateway/profile | all | pending |
| ng.connection.sign-in | NG gateway and saved gateways | connections | nextgen | NgScope / runConnectionCheck / ConnectionManager | gateway/profile | all | pending |
| ng.connection.saved | NG gateway and saved gateways | connections | nextgen | NgScope / runConnectionCheck / ConnectionManager | gateway/profile | all | pending |
| ng.connection.add | NG gateway and saved gateways | connections | nextgen | NgScope / runConnectionCheck / ConnectionManager | gateway/profile | all | pending |
| ng.connection.sign-out | NG gateway card | security | nextgen | NgScope.signOut / secure credential store | gateway/profile | all | pending |
| ng.connection.sign-out.confirm | NG gateway card | security | nextgen | NgScope.signOut / secure credential store | gateway/profile | all | pending |
| models.default | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.default.confirm | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.add | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.change | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.order | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.remove | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.save | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.fallback.discard | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.auxiliary | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.providers | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.refresh | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.provider-sign-in | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| models.nous-portal | NG NgModelsPage / Classic ModelManagementScreen via More | connections | shared | selected-profile gateway model APIs; existing route/owner guards | gateway/profile | gateway capability | pending |
| provider.oauth | Classic ProviderOAuthScreen / NG model subpage | connections | shared | ProviderOAuthScreen controller; gateway provider credentials | gateway/profile | provider capability | pending |
| provider.oauth.start | Classic ProviderOAuthScreen / NG model subpage | connections | shared | ProviderOAuthScreen controller; gateway provider credentials | gateway/profile | provider capability | pending |
| provider.oauth.finish | Classic ProviderOAuthScreen / NG model subpage | connections | shared | ProviderOAuthScreen controller; gateway provider credentials | gateway/profile | provider capability | pending |
| provider.oauth.cancel | Classic ProviderOAuthScreen / NG model subpage | connections | shared | ProviderOAuthScreen controller; gateway provider credentials | gateway/profile | provider capability | pending |
| provider.oauth.disconnect | Classic ProviderOAuthScreen / NG model subpage | connections | shared | ProviderOAuthScreen controller; gateway provider credentials | gateway/profile | provider capability | pending |
| backup.export | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.export.passphrase | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.export.confirm | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.export.deliver | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.import | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.import.passphrase | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.import.merge | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.import.replace | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| backup.import.confirm | Classic ConfigBackupCard / sheets | security | shared | ConfigBackupIo / encrypted ConfigBackupService | global + secure credentials | explicit user file selection; replace confirmation | pending |
| about.version | Classic About / NG Interface | about | shared | PackageInfo / legal_links / LicenseRegistry | global | all | pending |
| about.privacy | Classic About / NG Interface | about | shared | PackageInfo / legal_links / LicenseRegistry | global | all | pending |
| about.licenses | Classic About / NG Interface | about | shared | PackageInfo / legal_links / LicenseRegistry | global | all | pending |
| about.license-detail | Classic About / NG Interface | about | shared | PackageInfo / legal_links / LicenseRegistry | global | all | pending |
| ng.chat.reopen | NextGenPreferences.reopenKey (no existing UI) | chat | nextgen | nextgen_reopen_last_chat | mode/gateway | returning to gateway only; cold start lands on welcome | pending |

## Entrypoints and compatibility

- Classic workspace More, session-list drawer, desktop settings shortcut and palette `settings` open `SettingsScreen`.
- NextGen destination/sidebar, desktop shortcut and palette `settings` open `NgSettingsPage`.
- `hermes://settings/{appearance,gateway,notifications,shortcuts,connection}` and `/settings/...` previously ignored the validated category. Preserve those paths and route them to the corresponding category without changing `nextgen_enabled`.
- Presentation search (`presentation-search`) and tour (`theme`, `fonts`, `direction`, `pet`, `radio`) belong to the shared appearance panel. Preserve exact jump targets and tour back/next/finish/close.
- NG More settings previously opened the mixed Classic screen. Replace with direct shared categories in the NG experience.
- Model administration, providers, gateway queues, capabilities, fleet and project/workspace tools retain their existing routes outside Settings. They are gateway tools, not global user preferences. Project root stays in Projects (existing regression coverage).
- Cold NextGen launch deliberately shows the landing page. `nextgen_reopen_last_chat` defaults true and only restores `nextgen_last_session.<connection>` on a non-cold activation without an explicit link/share/notification/action. Explicit requested session wins. Fleet launch/reconnect preferences are separate gateway-management controls.
- Retired updater: absent and remains absent.
