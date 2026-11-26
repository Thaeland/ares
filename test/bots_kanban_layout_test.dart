// Probes K5 and B8 of the review of v5/bots @ d74ba224: the Kanban board and
// the bots screen at 320x640 with 2.0x text, in the Classic and the NextGen
// theme, with a 300 px keyboard over their forms.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/bots_screen.dart';
import 'package:hermes_android/core/screens/kanban_board_screen.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/bots_review_fixture.dart';
import 'support/kanban_review_fixture.dart';

const _keyboard = 300.0;
const _visibleBottom = 640.0 - _keyboard;

enum _Layout { classic, nextGen }

ThemeData _theme(_Layout layout) => switch (layout) {
  _Layout.classic => hermesTheme(Brightness.light),
  _Layout.nextGen => nextGenTheme(Brightness.light, NextGenLook.instance),
};

Widget _app(_Layout layout, Widget home) => MaterialApp(
  theme: _theme(layout),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: const TextScaler.linear(2.0)),
    child: child!,
  ),
  home: home,
);

/// Every layout error while [body] runs, as `message @ first source line`.
Future<List<String>> _overflows(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (!text.contains('overflowed')) {
      previous?.call(details);
      return;
    }
    final source = details
        .toString()
        .split('\n')
        .firstWhere((l) => l.contains('lib/'), orElse: () => '');
    errors.add('${text.split('\n').first} @ ${source.trim()}');
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(tester.view.resetViewInsets);
}

/// The focused field's box must end above the keyboard.
void _expectAboveKeyboard(WidgetTester tester, Finder field) {
  final rect = tester.getRect(field);
  expect(
    rect.bottom,
    lessThanOrEqualTo(_visibleBottom),
    reason: 'field at $rect is under a $_keyboard px keyboard',
  );
  expect(rect.top, greaterThanOrEqualTo(0));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // A tap that lands on nothing is a layout failure here, not a warning.
    WidgetController.hitTestWarningShouldBeFatal = true;
  });
  tearDown(() => WidgetController.hitTestWarningShouldBeFatal = false);

  for (final layout in _Layout.values) {
    group(layout.name, () {
      testWidgets('K5 the Kanban board, its filters and the New task form', (
        tester,
      ) async {
        _phone(tester);
        final api = KanbanReviewApi();
        final owner = kanbanReviewOwner(api.client);
        addTearDown(owner.close);
        final errors = await _overflows(tester, () async {
          await tester.pumpWidget(
            _app(
              layout,
              KanbanBoardScreen(
                owner: owner,
                route: owner.route(),
                connection: kanbanReviewConnection,
                enableLivePolling: false,
              ),
            ),
          );
          await kanbanShown(
            tester,
            find.byKey(const Key('kanban-new-task-button')),
          );
          await kanbanStep(tester);
          // The selection bar.
          await tester.longPress(
            find.byKey(const Key('kanban-card-t_ready_0')),
          );
          await kanbanStep(tester, 3);
          expect(find.byKey(const Key('kanban-selection-bar')), findsOneWidget);

          await tester.tap(find.byKey(const Key('kanban-new-task-button')));
          await kanbanStep(tester);
          tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
          await kanbanStep(tester);
          _expectAboveKeyboard(
            tester,
            find.byKey(const Key('kanban-new-title')),
          );
          // Each later field can be brought above the keyboard too.
          for (final key in [
            'kanban-new-column',
            'kanban-new-assignee',
            'kanban-new-workspace-kind',
            'kanban-new-parent',
            'kanban-new-model',
          ]) {
            final field = find.byKey(Key(key));
            await tester.ensureVisible(field);
            await kanbanStep(tester, 2);
            _expectAboveKeyboard(tester, field);
          }
          await tester.ensureVisible(
            find.byKey(const Key('kanban-new-assignee')),
          );
          await kanbanStep(tester, 2);
          await tester.tap(find.byKey(const Key('kanban-new-assignee')));
          await kanbanStep(tester, 3);
          await tester.tapAt(const Offset(4, 4));
          await kanbanStep(tester, 3);
        });
        expect(errors, isEmpty, reason: errors.join('\n'));
      });

      testWidgets('B8 the bots screen, every tab, and the routine form', (
        tester,
      ) async {
        _phone(tester);
        final gateway = BotsReviewGateway();
        final owner = botsReviewOwner(gateway);
        addTearDown(owner.close);
        final errors = await _overflows(tester, () async {
          await tester.pumpWidget(
            _app(
              layout,
              BotsScreen(
                owner: owner,
                route: owner.route(),
                connection: botsReviewConnection,
              ),
            ),
          );
          await botsShown(tester, find.text('WorkBot'));
          for (final tab in const [
            Icons.groups_outlined,
            Icons.desktop_windows_outlined,
            Icons.schedule_outlined,
            Icons.people_outline,
            Icons.schedule_outlined,
          ]) {
            await tester.tap(find.byIcon(tab).first);
            await botsStep(tester);
          }
          final add = find.byTooltip('Add routine');
          expect(add.hitTestable(), findsOneWidget);
          await tester.tap(add);
          await botsStep(tester);
          tester.view.viewInsets = const FakeViewPadding(bottom: _keyboard);
          await botsStep(tester);
          _expectAboveKeyboard(
            tester,
            find.byKey(const Key('bots-routine-title')),
          );
          for (final key in [
            'bots-routine-instruction',
            'bots-routine-schedule-kind',
            'bots-routine-cron',
            'bots-routine-repeat',
            'bots-routine-deliver',
          ]) {
            final field = find.byKey(Key(key));
            await tester.ensureVisible(field);
            await botsStep(tester, 2);
            _expectAboveKeyboard(tester, field);
          }
          final addButton = find.byKey(const Key('bots-routine-add'));
          await tester.ensureVisible(addButton);
          await botsStep(tester, 2);
          expect(tester.getRect(addButton).bottom, lessThanOrEqualTo(640));
        });
        expect(errors, isEmpty, reason: errors.join('\n'));
      });
    });
  }
}
