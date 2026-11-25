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

## Checks without an app build

- `tool/native_tests/run.sh` — host C++17 unit tests (`clang++ -std=c++17 -Wall -Wextra -Werror -pedantic`) for the platform-free headers `windows/runner/desktop_os_logic.h` and `linux/runner/desktop_os_logic.h`.
- `tool/native_tests/macos_typecheck.sh` — type-checks the macOS runner Swift against the macOS SDK and a declarations-only FlutterMacOS stub, with warnings as errors.
- `tool/native_tests/linux_compile_check.sh <flutter-gtk-dir>` — compiles the Linux runner sources (`-fsyntax-only`) against Debian 12 GTK 3 and the engine's `flutter_linux` headers in a network-less container.
- The Windows runner files that include `windows.h` need the Windows SDK: build on the Windows host (`/W4 /WX`).
