// Regression tests cut from the independent review of v5/bots @ d74ba224
// (evidence/bots-review-d74ba224, probes K1-K6). Each test failed on the
// reviewed code and names the probe it replaces.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/kanban_review_fixture.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<KanbanReviewApi> openRunningCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final api = KanbanReviewApi();
    final owner = kanbanReviewOwner(api.client);
    addTearDown(owner.close);
    await tester.pumpWidget(kanbanReviewApp(owner));
    await kanbanShown(tester, find.byKey(const Key('kanban-card-t_run_1')));
    await tester.tap(find.byKey(const Key('kanban-card-t_run_1')));
    await kanbanShown(tester, find.byKey(const Key('kanban-detail-decompose')));
    await tester.ensureVisible(
      find.byKey(const Key('kanban-detail-decompose')),
    );
    return api;
  }

  group('K3 decompose result (plugin_api.py:1600-1607)', () {
    testWidgets('child_ids are counted', (tester) async {
      final api = await openRunningCard(tester);
      await tester.tap(find.byKey(const Key('kanban-detail-decompose')));
      await kanbanStep(tester);
      expect(api.count('POST', '/tasks/t_run_1/decompose'), 1);
      expect(find.text('Decomposed into 3 child tasks'), findsWidgets);
      expect(find.textContaining('0 child'), findsNothing);
    });

    testWidgets('ok:false shows the reason as an error, not a success', (
      tester,
    ) async {
      final api = await openRunningCard(tester);
      api.decomposeReply = {
        'ok': false,
        'task_id': 't_run_1',
        'reason': 'auxiliary client unavailable',
        'fanout': false,
        'child_ids': <String>[],
        'new_title': null,
      };
      await tester.tap(find.byKey(const Key('kanban-detail-decompose')));
      await kanbanStep(tester);
      expect(find.textContaining('auxiliary client unavailable'), findsWidgets);
      expect(find.textContaining('Decomposed into'), findsNothing);
      // The sheet keeps the refusal on screen in its error line too.
      expect(find.byKey(const Key('kanban-detail-error')), findsOneWidget);
    });

    testWidgets('ok without fan-out says no child tasks were created', (
      tester,
    ) async {
      final api = await openRunningCard(tester);
      api.decomposeReply = {
        'ok': true,
        'task_id': 't_run_1',
        'reason': 'single task; title tightened',
        'fanout': false,
        'child_ids': <String>[],
        'new_title': 'Tighter title',
      };
      await tester.tap(find.byKey(const Key('kanban-detail-decompose')));
      await kanbanStep(tester);
      expect(find.textContaining('single task; title tightened'), findsWidgets);
      expect(find.textContaining('Decomposed into'), findsNothing);
      expect(find.byKey(const Key('kanban-detail-error')), findsNothing);
    });
  });
}
