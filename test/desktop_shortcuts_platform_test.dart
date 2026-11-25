// Regressions from the review of 8d733edd: the in-app shortcuts must match
// what actually fires on each platform.
//
// PROBE-5: macOS gets no automatic Ctrl twins, so Ctrl+K in a text field stays
// Cocoa's delete-to-end-of-line instead of opening the palette.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/shortcuts_store.dart';
import 'package:hermes_android/core/widgets/desktop_shortcuts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<DesktopShortcut>> _press(
  WidgetTester tester,
  LogicalKeyboardKey modifier,
  LogicalKeyboardKey key,
) async {
  final fired = <DesktopShortcut>[];
  final sub = desktopShortcutBus.stream.listen(fired.add);
  await tester.sendKeyDownEvent(modifier);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(modifier);
  await tester.pump();
  unawaited(sub.cancel());
  return fired;
}

Future<TextEditingController> _pumpComposer(
  WidgetTester tester,
  ShortcutsStore store,
) async {
  final controller = TextEditingController(text: 'hello world');
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) =>
          DesktopShortcuts(forceEnabled: true, store: store, child: child!),
      home: Scaffold(body: TextField(controller: controller)),
    ),
  );
  await tester.tap(find.byType(TextField));
  await tester.pump();
  return controller;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets(
    'macOS: Ctrl+K in a text field is not stolen by the palette; Cmd+K still '
    'opens it (PROBE-5)',
    (tester) async {
      final store = ShortcutsStore(await SharedPreferences.getInstance());
      await _pumpComposer(tester, store);
      expect(
        await _press(
          tester,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.keyK,
        ),
        isEmpty,
      );
      expect(
        await _press(
          tester,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.keyN,
        ),
        isEmpty,
      );
      expect(
        await _press(
          tester,
          LogicalKeyboardKey.metaLeft,
          LogicalKeyboardKey.keyK,
        ),
        [DesktopShortcut.commandPalette],
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets(
    'Windows and Linux: the Ctrl twin of each default still fires',
    (tester) async {
      final store = ShortcutsStore(await SharedPreferences.getInstance());
      await _pumpComposer(tester, store);
      expect(
        await _press(
          tester,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.keyK,
        ),
        [DesktopShortcut.commandPalette],
      );
      expect(
        await _press(
          tester,
          LogicalKeyboardKey.controlLeft,
          LogicalKeyboardKey.keyN,
        ),
        [DesktopShortcut.newChat],
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  test('Ctrl twins are a Windows/Linux/Android convention, never Apple', () {
    expect(shortcutsAddCtrlTwins(TargetPlatform.windows), isTrue);
    expect(shortcutsAddCtrlTwins(TargetPlatform.linux), isTrue);
    expect(shortcutsAddCtrlTwins(TargetPlatform.android), isTrue);
    expect(shortcutsAddCtrlTwins(TargetPlatform.macOS), isFalse);
    expect(shortcutsAddCtrlTwins(TargetPlatform.iOS), isFalse);
  });
}
