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

## Checks without an app build

- `tool/native_tests/run.sh` — host C++17 unit tests (`clang++ -std=c++17 -Wall -Wextra -Werror -pedantic`) for the platform-free headers `windows/runner/desktop_os_logic.h` and `linux/runner/desktop_os_logic.h`.
- `tool/native_tests/macos_typecheck.sh` — type-checks the macOS runner Swift against the macOS SDK and a declarations-only FlutterMacOS stub, with warnings as errors.
- `tool/native_tests/linux_compile_check.sh <flutter-gtk-dir>` — compiles the Linux runner sources (`-fsyntax-only`) against Debian 12 GTK 3 and the engine's `flutter_linux` headers in a network-less container.
- The Windows runner files that include `windows.h` need the Windows SDK: build on the Windows host (`/W4 /WX`).
