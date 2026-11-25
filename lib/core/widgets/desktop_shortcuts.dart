/// macOS/desktop keyboard shortcuts for Ares.
///
/// Actions are broadcast on a tiny stream so the active shell (Classic or
/// NextGen) can own the concrete implementation without the app root needing
/// to know which shell is mounted. On touch platforms the wrapper is a plain
/// passthrough, so mobile behaviour and widget tests are untouched.
library;

import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Primary desktop actions exposed by the shells.
enum DesktopShortcut { newChat, search, settings, tab1, tab2, tab3, tab4 }

/// Broadcast bus between [DesktopShortcuts] and the active shell.
final StreamController<DesktopShortcut> desktopShortcutBus =
    StreamController<DesktopShortcut>.broadcast();

/// Fires a shortcut. Used by the key handler and by tests.
void fireDesktopShortcut(DesktopShortcut shortcut) {
  if (!desktopShortcutBus.isClosed) desktopShortcutBus.add(shortcut);
}

/// Wraps [child] with desktop shortcut bindings when running on a desktop
/// platform. Pass [forceEnabled] in tests to exercise the bindings without
/// changing the process-wide target platform.
class DesktopShortcuts extends StatelessWidget {
  const DesktopShortcuts({required this.child, this.forceEnabled, super.key});

  final Widget child;

  /// Overrides the platform gate. Null uses the real target platform.
  final bool? forceEnabled;

  static bool _isDesktop(TargetPlatform platform) =>
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux ||
      platform == TargetPlatform.windows;

  bool get _enabled => forceEnabled ?? _isDesktop(defaultTargetPlatform);

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return child;

    final meta = <ShortcutActivator, VoidCallback>{
      SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.newChat),
      SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
          fireDesktopShortcut(DesktopShortcut.newChat),
      SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.search),
      SingleActivator(LogicalKeyboardKey.keyF, meta: true, shift: true): () =>
          fireDesktopShortcut(DesktopShortcut.search),
      SingleActivator(
        LogicalKeyboardKey.keyF,
        control: true,
        shift: true,
      ): () =>
          fireDesktopShortcut(DesktopShortcut.search),
      SingleActivator(LogicalKeyboardKey.keyF, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.search),
      SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
          fireDesktopShortcut(DesktopShortcut.search),
      SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.settings),
      SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.tab1),
      SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.tab2),
      SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.tab3),
      SingleActivator(LogicalKeyboardKey.digit4, meta: true): () =>
          fireDesktopShortcut(DesktopShortcut.tab4),
    };

    return Focus(
      autofocus: true,
      child: CallbackShortcuts(bindings: meta, child: child),
    );
  }
}

/// Wraps a composer field so plain Enter (without Shift) triggers [onSend]
/// on desktop. Key events from the focused descendant bubble to this Focus.
class SendOnEnter extends StatelessWidget {
  const SendOnEnter({
    required this.child,
    required this.onSend,
    this.onNavigate,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback onSend;
  final KeyEventResult Function(KeyEvent)? onNavigate;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Focus(
    onKeyEvent: (node, event) {
      if (enabled && shouldSendOnEnter(event)) {
        onSend();
        return KeyEventResult.handled;
      }
      return onNavigate?.call(event) ?? KeyEventResult.ignored;
    },
    child: child,
  );
}

/// Whether an Enter key event should send the composer rather than insert a
/// newline: plain Enter sends, Shift+Enter inserts a newline (the desktop
/// convention; mobile soft keyboards keep their own action button).
bool shouldSendOnEnter(KeyEvent event) =>
    (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
    !HardwareKeyboard.instance.isShiftPressed;
