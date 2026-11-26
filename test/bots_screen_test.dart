import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/bots_review_fixture.dart';

void main() {
  testWidgets(
    'bots roster renders once loaded; rooms show a list; routines render',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // The shared fixture refuses what the real gateway refuses.
      final api = BotsReviewGateway();
      final owner = botsReviewOwner(api);
      addTearDown(owner.close);

      await tester.pumpWidget(botsReviewApp(owner));

      // Roster renders the two fixture bots.
      await botsShown(tester, find.text('WorkBot'));
      expect(find.text('WorkBot'), findsOneWidget);
      expect(find.text('ResearchBot'), findsOneWidget);

      // Switch to Rooms.
      await tester.tap(find.text('Rooms'));
      await botsShown(tester, find.text('Ops Room'));
      expect(find.text('Gateway rooms'), findsOneWidget);
      expect(find.textContaining('2 member'), findsOneWidget);

      // Switch to Routines.
      await tester.tap(find.text('Routines'));
      await botsShown(tester, find.text('Stand-up'));
      expect(find.text('Stand-up'), findsOneWidget);
    },
  );

  testWidgets(
    'screen tab starts the display, takes over via an observe lease, then hands back',
    (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // The shared fixture refuses what the real gateway refuses.
      final api = BotsReviewGateway();
      final owner = botsReviewOwner(api);
      addTearDown(owner.close);

      await tester.pumpWidget(botsReviewApp(owner));
      await botsShown(tester, find.text('WorkBot'));

      // Switch to Screen.
      await tester.tap(find.text('Screen'));
      await botsShown(tester, find.text('Running'));
      await botsStep(tester);

      // Take over: observe mints viewer id, then the lease acquire.
      await tester.tap(find.text('Take over'));
      await botsStep(tester);
      expect(api.calls.any((c) => c.method == 'display.observe'), isTrue);
      expect(api.calls.any((c) => c.method == 'display.lease.acquire'), isTrue);

      // Hand back: viewerId is carried, so the release carries it.
      await botsShown(tester, find.text('Hand back'));
      await tester.tap(find.text('Hand back'));
      await botsStep(tester);
      expect(
        api.calls.any(
          (c) =>
              c.method == 'display.lease.release' &&
              c.params.containsKey('viewer_id'),
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'room create pushes one groups.create call with the selected members',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // The shared fixture refuses what the real gateway refuses.
      final api = BotsReviewGateway();
      final owner = botsReviewOwner(api);
      addTearDown(owner.close);

      await tester.pumpWidget(botsReviewApp(owner));
      await botsShown(tester, find.text('WorkBot'));

      await tester.tap(find.text('Rooms'));
      await botsShown(tester, find.text('Ops Room'));
      await tester.tap(find.textContaining('Create room'));
      await botsShown(tester, find.text('Room name'));
      await botsStep(tester);
      await tester.enterText(find.byType(TextField), 'QA Room');
      await botsStep(tester);
      final workChip = find.widgetWithText(FilterChip, 'WorkBot');
      await tester.ensureVisible(workChip);
      await tester.tap(workChip);
      await tester.pump();
      final researchChip = find.widgetWithText(FilterChip, 'ResearchBot');
      await tester.ensureVisible(researchChip);
      await tester.tap(researchChip);
      await tester.pump();
      final createBtn = find.widgetWithText(FilledButton, 'Create room');
      await tester.ensureVisible(createBtn);
      await botsStep(tester);
      await tester.tap(createBtn, warnIfMissed: true);
      await botsStep(tester);

      final createCall = api.calls.singleWhere(
        (c) => c.method == 'groups.create',
      );
      final members = createCall.params['members'] as List;
      expect(createCall.params['name'], 'QA Room');
      expect(members.length, 2);
      expect(
        members.map((m) => m['profile']),
        containsAll(['workbot', 'researchbot']),
      );
    },
  );
}
