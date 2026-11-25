# Desktop OS integration (native runners)

Windows, macOS and Linux runners implement a small set of platform channels for the primary window. Dart owns every policy decision (whether a feature is on, menu text, what an action does); the runners draw native UI, register OS hooks and report events. Every feature is opt-in and off by default, and child window processes (pop-out chat, companion, quick entry) never construct any of it.

Dart: `lib/core/desktop/`. Settings: **Desktop integration** card in Classic Settings and NextGen Settings → Interface (desktop only).

## Shell: tray / menu-bar icon — `com.hermesagent.ares/shell`

| Direction | Method | Arguments | Result |
| --- | --- | --- | --- |
| Dart → runner | `setTray` | `{enabled, closeToTray, tooltip, items: [{id, label, checked?, separatorBefore?}]}` | `bool` icon shown |
| Dart → runner | `showWindow` | — | — (show, restore, focus the primary window) |
| Dart → runner | `quit` | — | — (runner closes the primary window after replying) |
| Dart → runner | `isTraySupported` | — | `bool` |
| runner → Dart | `onTrayAction` | item `id` | — |

- Item ids are `[a-z-]{1,32}`; labels are cleaned of control characters and bounded (64 characters, tooltip 127). At most 16 items. Unknown ids from the runner are ignored by Dart.
- Menu: Open Ares, New chat, Quick entry… (when available), Pause notifications (checked while the notification master switch is off), Quit Ares. A left click (Windows, Linux) shows the window; macOS opens the menu.
- **Close to tray** is a second opt-in. It only applies while the icon is actually shown: Windows hides on `WM_CLOSE` only with an installed icon; Linux only while the XEmbed icon is embedded; macOS keeps the app running after the last window closes and a Dock click or the menu brings it back.
- Windows: `Shell_NotifyIconW` (version 4), re-added after Explorer restarts (`TaskbarCreated`). The menu runs with `TrackPopupMenuEx`; no new activator, COM server or instance path. A second launch still focuses the hidden window through the existing mutex path.
- macOS: `NSStatusItem` with a template SF Symbol.
- Linux: `GtkStatusIcon` (XEmbed). It needs an X11 session with a tray host (KDE, Xfce, MATE, Cinnamon; GNOME needs a tray extension). On Wayland `setTray` returns `false` and Settings says the desktop has no usable tray. No new library is linked.

## Quick entry (HUD)

A small always-on-top window for typing a prompt into a chosen chat or a new one. Opened from the tray, the global hotkey, or **Quick entry** in the command palette (Classic and NextGen).

- It reuses the pop-out child machinery: the primary starts the same executable with `--ares-quick-entry-v1` (Windows launch role `quick_entry`, which requires a parent pipe on stdin and must be the only argument), sends one launch frame through `watchPopoutPipe` (≤ 2 KB: up to 12 recent chats `{id, title}` and the app locale), and the child exits when the pipe closes. The child owns no connection, credentials, tray, hotkey, toast routing or instance mutex.
- The child writes `ARES_QUICK_ENTRY_READY_V1`, then at most one line `{"prefill": text, "session": id|null}` and exits. The primary accepts only a chat id it offered and text up to 4,000 characters, then shows the main window and routes `hermes://session/<id>?prefill=…` or `hermes://open/chat?prefill=…` through the validated deep-link router. **Nothing is sent**: Enter in the window only puts the text in the composer; Shift+Enter adds a line; Escape closes.
- Showing it while it is open closes it (toggle). Windows activation stays primary-only: no second activator, COM server or `WM_COPYDATA` path; the primary calls `AllowSetForegroundWindow(ASFW_ANY)` before a tray or hotkey launch so the window can take focus.
- Placement: Windows centres it on the monitor under the pointer, a fifth of the way down, `HWND_TOPMOST`; macOS uses a floating window on all Spaces (also over full-screen apps); Linux keeps it above, centred, without a taskbar entry.

## Global hotkey — `com.hermesagent.ares/hotkey`

| Direction | Method | Arguments | Result |
| --- | --- | --- | --- |
| Dart → runner | `register` | `{key, meta, ctrl, alt, shift}` (`key` in `shortcuts_store` names, e.g. `space`, `keyK`) | `registered`, `conflict`, `unsupported` or `invalid` |
| Dart → runner | `unregister` | — | — |
| runner → Dart | `onHotKey` | — | — |

- Opt-in (off by default) and remappable in **Desktop integration → Quick entry shortcut**. The default is Cmd+Shift+Space on macOS and Ctrl+Shift+Space on Windows and Linux. A press toggles quick entry.
- Dart checks a chord before the runner sees it: it needs Cmd, Ctrl or Alt; the Windows/Super key is refused on Windows and Linux; a short list of system chords is refused (Spotlight, app switching, Task Manager, lock screen …); and it must not equal an in-app shortcut, including the Ctrl form of an uncustomized Cmd shortcut on Windows and Linux. Rebinding an in-app shortcut onto the hotkey releases the hotkey. The runner reports a chord another app owns as `conflict`.
- Unregistered when turned off, before a remap, when Dart disposes, and by the runner when the primary window goes away (exit).
- Windows: `RegisterHotKey` on the primary window with `MOD_NOREPEAT` (`ERROR_HOTKEY_ALREADY_REGISTERED` → conflict); `WM_HOTKEY` allows the quick-entry child to take the foreground.
- macOS: Carbon `RegisterEventHotKey` (no Accessibility permission needed; `eventHotKeyExistsErr` → conflict).
- Linux: a passive `XGrabKey` on the X11 root window, also covering Caps Lock and Num Lock (`BadAccess` → conflict). libX11 (MIT), already a GTK 3 dependency, is linked directly. Wayland has no app-registered global shortcut, so `register` returns `unsupported` and Settings says so; the XDG GlobalShortcuts portal is not used.

## Wake / sleep and keep-awake — `com.hermesagent.ares/power`

| Direction | Method | Arguments | Result |
| --- | --- | --- | --- |
| Dart → runner | `isSupported` | — | `bool` |
| Dart → runner | `setAwake` | `{owner, enabled}` | — |
| runner → Dart | `onPowerEvent` | `suspend`, `resume`, `lock` or `unlock` | — |

- Events feed `SystemSleepGate` (`lib/core/services/system_sleep_gate.dart`). While the computer sleeps **or** the session is locked, every `DesktopGatewayClient` (Classic) and `NextGenGateway` closes its live socket and stops redialling; calls fail fast instead of dialling. Waking onto the lock screen keeps the pause until unlock.
- On resume a client that had a live socket reconnects; the new socket re-binds stored sessions with `session.resume`, and NextGen chats reattach through `reconnected`. Classic normal-chat recovery is held while paused and runs again on resume. **No prompt is sent again**: an in-flight submission is reconciled from history by the existing recovery journal. A NextGen socket the user stopped stays stopped; an idle Classic client dials lazily on its next call.
- Keep-awake (Off / While working / Always): Windows `SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED)`; macOS `IOPMAssertionCreateWithName(kIOPMAssertionTypePreventUserIdleSystemSleep)`; Linux an xdg-desktop-portal `Inhibit` request with the *suspend* flag (released with `Request.Close`), or without a portal `org.freedesktop.ScreenSaver.Inhibit` (released with `UnInhibit`). None of the desktop ones keeps the display on. Android (`MainActivity`) sets `FLAG_KEEP_SCREEN_ON` and iOS (`SceneDelegate`) `UIApplication.isIdleTimerDisabled`, so phones and tablets call it **Keep screen on**. Runners release the request when the window goes away.
- `isSupported` is true only where it works (Linux: a portal or a screensaver service is on the session bus); Settings (Classic and NextGen) shows the card, and its section header, only then.
- Dart (`KeepAwakeController`, owned by `HermesApp`) releases the request when the turn ends however it ends (finished, failed, cancelled), when the app is paused (background) or detached (exit), and takes it again on resume while still wanted. A minimised desktop window reports `hidden` and keeps it, so a long turn can finish while you are away.
- Windows: `WM_POWERBROADCAST` (`PBT_APMSUSPEND`, `PBT_APMRESUMESUSPEND`/`PBT_APMRESUMEAUTOMATIC`) and `WM_WTSSESSION_CHANGE` (`WTSRegisterSessionNotification`, links `wtsapi32.lib`).
- macOS: `NSWorkspace` will-sleep/did-wake and session resign/become active, plus the `com.apple.screenIsLocked`/`Unlocked` distributed notifications.
- Linux: logind `PrepareForSleep` (system bus), the session's `Lock`/`Unlock` signals and `LockedHint` (session found with `GetSessionByPID`), and `ActiveChanged` from `org.freedesktop.ScreenSaver` / `org.gnome.ScreenSaver` (session bus). GIO only; no new library.

## Screen capture — `com.hermesagent.ares/capture`

| Direction | Method | Arguments | Result |
| --- | --- | --- | --- |
| Dart → runner | `status`, `requestPermission` | — | `{supported, permission}` with `granted`, `denied`, `prompt` or `not-required` |
| Dart → runner | `openSettings` | — | `bool` (macOS privacy pane) |
| Dart → runner | `capture` | `{directory}` | PNG path inside `directory`; errors `cancelled`, `permission-denied`, `unsupported`, `failed` |

- **Capture screen** in the attach sheet of both composers (Classic and NextGen, desktop only). The capture becomes an ordinary image draft through each composer's existing attachment path; the user reviews it and presses Send. **Never auto-sends.**
- Dart creates a private `ares-capture-*` folder, accepts only a non-empty PNG (signature checked, ≤ 25 MB) inside that folder, and removes the folder once the draft has its own copy or the capture is rejected.
- macOS (14 or later): `CGPreflightScreenCaptureAccess`; the first request shows the system prompt (`CGRequestScreenCaptureAccess`); afterwards Ares explains the Screen Recording setting and opens it (`x-apple.systempreferences:…Privacy_ScreenCapture`). The capture is the frontmost on-screen window of another app (no Ares process: main, pop-out, companion, quick entry), or the main display without Ares' windows, via ScreenCaptureKit `SCScreenshotManager`. macOS 13 reports `unsupported`.
- Windows: Windows Graphics Capture with the system `GraphicsCapturePicker` (the picker is the consent; the user chooses a window or display). One frame is copied to a staging texture on a worker thread, made opaque and written as PNG with WIC; results return to the UI thread as window messages. Links `d3d11`, `dxgi`, `windowscodecs`.
- Linux: xdg-desktop-portal `Screenshot` with `interactive: true` (the portal dialog is the consent and lets the user pick screen, window or area). The portal's file is copied into Ares' folder; the desktop's own copy stays where it saved it. No portal → `unsupported`.

## Checks without an app build

- `tool/native_tests/ios_typecheck.sh` — type-checks `ios/Runner/SceneDelegate.swift` (keep-awake and deep-link channels) against the iOS SDK and a declarations-only Flutter stub.

- `tool/native_tests/run.sh` — host C++17 unit tests (`clang++ -std=c++17 -Wall -Wextra -Werror -pedantic`) for the platform-free headers `windows/runner/desktop_os_logic.h` and `linux/runner/desktop_os_logic.h`.
- `tool/native_tests/macos_typecheck.sh` — type-checks the macOS runner Swift against the macOS SDK and a declarations-only FlutterMacOS stub, with warnings as errors.
- `tool/native_tests/linux_compile_check.sh <flutter-gtk-dir>` — compiles the Linux runner sources (`-fsyntax-only`) against Debian 12 GTK 3 and the engine's `flutter_linux` headers in a network-less container.
- The Windows runner files that include `windows.h` need the Windows SDK: build on the Windows host (`/W4 /WX`).
