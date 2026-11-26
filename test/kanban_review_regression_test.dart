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

  group('destructive Kanban actions ask first; Cancel sends nothing', () {
    Future<KanbanReviewApi> openBoard(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final api = KanbanReviewApi();
      final owner = kanbanReviewOwner(api.client);
      addTearDown(owner.close);
      await tester.pumpWidget(kanbanReviewApp(owner));
      await kanbanShown(tester, find.byKey(const Key('kanban-card-t_ready_0')));
      await kanbanStep(tester);
      return api;
    }

    final dialog = find.byKey(const Key('kanban-confirm-dialog'));
    Future<void> answer(WidgetTester tester, {required bool ok}) async {
      expect(dialog, findsOneWidget);
      await tester.tap(
        find.byKey(Key(ok ? 'kanban-confirm-ok' : 'kanban-confirm-cancel')),
      );
      await kanbanStep(tester);
      expect(dialog, findsNothing);
    }

    List<Map<String, dynamic>?> bulks(KanbanReviewApi api) => [
      for (final c in api.calls)
        if (c.path.endsWith('/tasks/bulk')) c.body,
    ];

    Future<void> selectTwo(WidgetTester tester) async {
      await tester.longPress(find.byKey(const Key('kanban-card-t_ready_0')));
      await kanbanStep(tester);
      await tester.tap(find.byKey(const Key('kanban-card-t_ready_1')));
      await kanbanStep(tester);
      expect(find.text('2 selected'), findsOneWidget);
    }

    testWidgets('K1 archive board', (tester) async {
      final api = await openBoard(tester);
      await tester.tap(find.byKey(const Key('kanban-board-switcher')));
      await kanbanStep(tester);
      Future<void> pickArchive() async {
        await tester.tap(find.byKey(const Key('kanban-board-menu-ops-board')));
        await kanbanStep(tester);
        await tester.tap(find.text('Archive board'));
        await kanbanStep(tester);
      }

      await pickArchive();
      expect(find.textContaining('Archive board ops-board?'), findsOneWidget);
      expect(api.count('DELETE', '/boards/ops-board'), 0);
      await answer(tester, ok: false);
      expect(api.count('DELETE', '/boards/ops-board'), 0);
      await pickArchive();
      await answer(tester, ok: true);
      expect(api.count('DELETE', '/boards/ops-board'), 1);
    });

    testWidgets('K2 bulk move, bulk archive and bulk assign', (tester) async {
      final api = await openBoard(tester);
      await selectTwo(tester);

      Future<void> pickMove() async {
        await tester.tap(find.byKey(const Key('kanban-bulk-move')));
        await kanbanStep(tester);
        await tester.tap(find.text('Move to Triage').last);
        await kanbanStep(tester);
      }

      await pickMove();
      expect(find.text('Move 2 cards to Triage?'), findsOneWidget);
      await answer(tester, ok: false);
      expect(bulks(api), isEmpty);
      expect(find.text('2 selected'), findsOneWidget);
      await pickMove();
      await answer(tester, ok: true);
      expect(bulks(api).single, {
        'ids': ['t_ready_0', 't_ready_1'],
        'status': 'triage',
      });

      await selectTwo(tester);
      await tester.tap(find.byKey(const Key('kanban-bulk-archive')));
      await kanbanStep(tester);
      expect(find.text('Archive 2 cards?'), findsOneWidget);
      await answer(tester, ok: false);
      expect(bulks(api), hasLength(1));
      await tester.tap(find.byKey(const Key('kanban-bulk-archive')));
      await kanbanStep(tester);
      await answer(tester, ok: true);
      expect(bulks(api).last, containsPair('archive', true));

      await selectTwo(tester);
      Future<void> pickAssign() async {
        await tester.tap(find.byKey(const Key('kanban-bulk-assign')));
        await kanbanStep(tester);
        await tester.tap(find.text('@reviewer').last);
        await kanbanStep(tester);
      }

      await pickAssign();
      expect(find.text('Assign 2 cards to @reviewer?'), findsOneWidget);
      expect(find.textContaining('workers are stopped'), findsOneWidget);
      await answer(tester, ok: false);
      expect(bulks(api), hasLength(2));
      await pickAssign();
      await answer(tester, ok: true);
      expect(bulks(api).last, containsPair('assignee', 'reviewer'));
      expect(bulks(api).last, containsPair('reclaim_first', true));
    });

    testWidgets('K3 requeue, and reassigning a running card', (tester) async {
      final api = await openRunningCard(tester);
      Future<void> pickRequeue() async {
        await tester.ensureVisible(
          find.byKey(const Key('kanban-detail-reclaim')),
        );
        await tester.tap(find.byKey(const Key('kanban-detail-reclaim')));
        await kanbanStep(tester);
      }

      await pickRequeue();
      expect(find.text('Requeue t_run_1?'), findsOneWidget);
      await answer(tester, ok: false);
      expect(api.count('POST', '/tasks/t_run_1/reclaim'), 0);
      await pickRequeue();
      await answer(tester, ok: true);
      expect(api.count('POST', '/tasks/t_run_1/reclaim'), 1);

      Future<void> pickReviewer() async {
        await tester.tap(find.byKey(const Key('kanban-detail-assignee')));
        await kanbanStep(tester);
        await tester.tap(find.text('@reviewer').last);
        await kanbanStep(tester);
      }

      await pickReviewer();
      expect(find.text('Reassign t_run_1 to @reviewer?'), findsOneWidget);
      await answer(tester, ok: false);
      expect(api.count('POST', '/tasks/t_run_1/reassign'), 0);
      // The dropdown is back on the assignee the card still has.
      expect(
        find.descendant(
          of: find.byKey(const Key('kanban-detail-assignee')),
          matching: find.text('@work'),
        ),
        findsOneWidget,
      );
      await pickReviewer();
      await answer(tester, ok: true);
      final reassign = api.calls.singleWhere(
        (c) => c.path.endsWith('/tasks/t_run_1/reassign'),
      );
      expect(reassign.body, containsPair('profile', 'reviewer'));
      expect(reassign.body, containsPair('reclaim_first', true));
    });
  });
}
