import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/widgets/command_palette.dart';

void _noop(PaletteAction _) {}

void main() {
  const actions = [
    PaletteAction(
      id: 'new-chat',
      label: 'New chat',
      icon: Icons.add,
      keywords: ['compose', 'start'],
    ),
    PaletteAction(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings,
      keywords: ['preferences'],
    ),
    PaletteAction(
      id: 'search',
      label: 'Search',
      icon: Icons.search,
      keywords: ['find'],
    ),
  ];

  Future<void> pumpPalette(
    WidgetTester tester, {
    void Function(PaletteAction)? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CommandPalette(
                  actions: actions,
                  onSelected: onSelected ?? (_) {},
                ),
              ),
            ),
            child: const Text('open palette'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open palette'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders actions and filters by label', (tester) async {
    await pumpPalette(tester);
    expect(find.text('New chat'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'set');
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('New chat'), findsNothing, reason: 'filter by label');
  });

  testWidgets('Escape closes the palette', (tester) async {
    await pumpPalette(tester);
    expect(find.byType(CommandPalette), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(CommandPalette), findsNothing);
  });

  testWidgets('narrow panes render a full-screen takeover, not a dialog',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(() {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 600);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: const CommandPalette(
          actions: actions,
          onSelected: _noop,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(CommandPalette), findsOneWidget);
  });
}
