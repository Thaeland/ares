# Settings redesign

Worktree: `settings-reorganisation`, branch `v5/settings-reorganisation`, baseline `4a73b53e`. Inventory was committed first (`f5de82b2`); the implementation checkpoint is `fac598d9`, followed by the validation/fixes checkpoint recorded in the branch history. No dependency or preference schema changes.

## Navigation and ownership

`SettingsBrowser` takes an explicit `SettingsMode`; it never derives the experience from, or writes, `nextgen_enabled`. `SettingsScreen` supplies the shared and Classic catalog, and `NgSettingsPage` supplies its NextGen controls and owner-bound gateway actions. Scope filtering applies to both browsing and search. The one explicit interface switch retains its existing preference/service behavior.

Nine categories contain real controls: General & language; Appearance; Chat & sessions; Voice; Notifications; Device & shortcuts; Connections & models; Privacy & backup; About & help. Summaries show constituent controls and current interface, language, theme mode, or connection where applicable. Category selection stays within the settings route; Back returns to the catalog/search, then to the caller. Search retains its query, includes category and mode paths, and jumps to mounted control anchors. Shared presentation search/tour IDs are retained. Gateway/model/provider selectors continue to provide their existing nested controls and authority checks.

The existing desktop shortcut, palette `settings`, sidebar/More and drawer entrypoints remain intact. Both deep-link consumers now honor category paths; legacy `gateway`, `connection` and `shortcuts` aliases map to Connections or Device. Settings links never switch the active layout. Existing connection/profile ownership validation runs before consuming a deep link.

Shared controls continue to use the same stores: appearance/reading, text size, reply voice, auto-read, barge-in, notifications, native desktop integration, shortcuts, language and encrypted backup. Classic density, verbosity and source filters remain Classic-only. NextGen theme/accent/glow/black and return-to-gateway restoration remain NextGen-only. Model and provider administration are identified as gateway tools; existing More/tool entrypoints remain available. No updater was reintroduced.

`nextgen_reopen_last_chat` already existed. Its new label describes the actual behavior: it restores a chat when returning to a gateway, not on an ordinary cold launch. The existing landing behavior and explicit notification/link precedence are preserved.

## Presentation and safety

The category body is constrained to 840 logical pixels on desktop. Rows wrap, have at least 64dp height, and use 8/16px spacing. Classic inherits Hermes/Material; NextGen uses Ng typography, colors and surfaces. The NextGen Material bridge is rebuilt from the resolved NextGen/imported scheme so shared selectors, radio sheets, sliders, disabled ink and HermesTokens readers do not inherit Classic palette colors. Existing theme source and contrast guards remain intact.

NextGen theme selection is keyboard accessible with 48dp targets; accent buttons have localized tooltips and selected semantics. Shared dialogs and sheets inherit the enclosing theme. Large-text RTL tests exercise all nine categories at 320px. Backup headings and NextGen connection metadata now wrap correctly. Identity keys retain the selected category during theme rebuilds and reset connection-owned children when the owner endpoint/profile changes.

Gateway sign-out has its own danger group and existing confirmation. Backup import retains the existing passphrase, merge/replace choice and confirmation. Auth identity, connection-check progress/results and sign-out confirmation are generation guarded against owner changes. Native capability checks remain in their existing components. Android battery/background and embedded push controls now use the existing positive capability flags, including exclusion from Linux. Parked builds exclude voice and notification surfaces and skip the NextGen voice refresh.

## Inventory and localization

[settings-inventory.md](settings-inventory.md) records 147 stable IDs, original locations, intended groups, experience scope, persisted services/keys, owner/platform gating, migration status and live target group. The original 139 IDs are preserved; eight additional nested pet/radio controls were added during exercise. A checked-in baseline fixture verifies uniqueness, no lost IDs, scope, and mapping to the rendered per-mode catalog.

All eleven new strings are present in English plus all thirteen translated ARB variants in identical source order. `flutter gen-l10n` regenerated the localization sources. Existing Russian/Ukrainian plural warnings are unchanged.

## Verification

Private temp directory: `/Volumes/Storage/Hermes/scratch/settings-reorganisation-tmp`.

- `flutter analyze --fatal-infos`: clean.
- Focused settings/appearance/notifications/desktop/backup/deep-link/palette/models/session suites: **444 passed** (`focused-final.log`). Includes offline persistence, licenses, model/profile authority, actual palette/shortcut routes, Classic and NextGen category deep links, nested search/tour, keyboard theme activation, shared key round trips, stale identity, all categories at 320px/1.6x/Arabic RTL, and existing theme source/contrast checks.
- Platform regression batch after using positive Android capability flags: **34 passed** (`platform-tests.log`), covering Android/iOS/Linux/macOS/Windows plus existing background and desktop integration tests.
- `flutter test --no-pub --dart-define=ARES_PARKED_AUTOMOTIVE=true test/settings_platform_gating_test.dart`: **10 passed** (`parked-tests.log`).
- Screenshot harness: **8 scenarios passed**, producing **32 PNGs** (four real screens per scenario). See the capture directory below. Tests fail on layout exceptions and assert actual control identities; desktop native capabilities are synthetic method-channel fixtures.

The single self-review found and fixed theme-change category reset, narrow backup/connection overflow, non-keyboard theme selection, inherited Classic selector/disabled colors in NextGen, and Android-only controls on Linux. Older tests were adapted to tap categories before their existing behavior assertions; the obsolete Classic-only chip test was replaced with live separation/persistence coverage. No assertions were removed from model authority, notification, backup or native capability tests.

## Screenshots and limits

Captures: `/Volumes/Storage/Hermes/scratch/settings-reorganisation-previews`.

Reproduction:

```sh
HERMES_WORKSPACE_PREVIEW_DIR=/Volumes/Storage/Hermes/scratch/settings-reorganisation-previews \
TMPDIR=/Volumes/Storage/Hermes/scratch/settings-reorganisation-tmp \
flutter test --no-pub test/settings_screenshots_test.dart
```

The harness reuses the existing `theme_app_integration_test.dart` RepaintBoundary capture convention with real fonts and demo-only data. Matrix: Classic/NextGen × light/dark × Android phone 390×844/Linux desktop 1280×900. Each captures categories, appearance, notifications and device settings. `manifest.json` in the capture directory records dimensions and SHA-256 hashes. Representative images were visually inspected, including the corrected NextGen shared controls and desktop integration.

No blocking implementation issue remains. Full-suite and performance gates are left to the parent as requested. These are deterministic widget captures and mocked native capabilities, not installer/device acceptance. Root search indexes category hosts and explicit local leaf targets; dynamic gateway model/provider choices remain in their existing nested selectors. No main/other-worktree changes, pushes, tags, publishing, installers, live gateways or live credentials were used.
