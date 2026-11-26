// Regression tests cut from the independent review of v5/bots @ d74ba224
// (evidence/bots-review-d74ba224, probes B1-B10). Each test failed on the
// reviewed code and names the probe it replaces.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/bots_review_fixture.dart';

void wide(WidgetTester tester, [Size size = const Size(900, 1200)]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('B7 relay', () {
    test('the fixture refuses bot_relay.deliver without a 32-64 hex id, as '
        'tools/bot_live_delivery.py does', () async {
      final gateway = BotsReviewGateway();
      final refused = await gateway.handle('bot_relay.deliver', {
        'profile': 'workbot',
        'message': 'hello',
        'from_profile': 'work',
        'from_handle': 'work',
        'from_connection': 'c-bots',
      });
      expect(refused['error'], containsPair('code', 4090));
      final accepted = await gateway.handle('bot_relay.deliver', {
        'id': '0123456789abcdef0123456789abcdef',
        'profile': 'workbot',
        'message': 'hello',
      });
      expect(accepted['result'], containsPair('status', 'settled'));
      final unknown = await gateway.handle('bots.not_a_method', {});
      expect(unknown['error'], containsPair('code', -32601));
    });

    testWidgets('there is no Relay tab or Send relay action, and nothing '
        'sends bot_relay.deliver', (tester) async {
      wide(tester);
      final gateway = BotsReviewGateway();
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await botsShown(tester, find.text('WorkBot'));
      expect(find.text('Relay'), findsNothing);
      for (final tab in ['Rooms', 'Screen', 'Routines', 'Roster']) {
        await tester.tap(find.text(tab));
        await botsStep(tester, 4);
        expect(find.text('Relay'), findsNothing);
      }
      await tester.tap(find.text('WorkBot'));
      await botsShown(tester, find.text('Open Bot Chat'));
      expect(find.text('Send relay'), findsNothing);
      expect(gateway.named('bot_relay.deliver'), isEmpty);
      // Every call the screen made was one the gateway accepts.
      expect(gateway.refusals, isEmpty);
    });
  });

  group('B10 New routine form', () {
    Future<BotsReviewGateway> openForm(WidgetTester tester) async {
      wide(tester);
      final gateway = BotsReviewGateway();
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await openBotsRoutinesTab(tester);
      await tester.tap(find.byTooltip('Add routine'));
      await botsStep(tester, 4);
      return gateway;
    }

    FilledButton addButton(WidgetTester tester) =>
        tester.widget<FilledButton>(find.byKey(const Key('bots-routine-add')));

    testWidgets('Add enables as the user types, and a daily routine created '
        'with the defaults keeps running', (tester) async {
      final gateway = await openForm(tester);
      expect(addButton(tester).onPressed, isNull);
      await tester.enterText(
        find.byKey(const Key('bots-routine-title')),
        'Digest',
      );
      await tester.pump();
      expect(addButton(tester).onPressed, isNull, reason: 'no instruction');
      await tester.enterText(
        find.byKey(const Key('bots-routine-instruction')),
        'Summarise the day',
      );
      await tester.pump();
      expect(addButton(tester).onPressed, isNotNull);
      // The run limit starts empty: unlimited.
      final repeat = tester.widget<TextField>(
        find.byKey(const Key('bots-routine-repeat')),
      );
      expect(repeat.controller!.text, isEmpty);
      expect(find.text('Repeat (days)'), findsNothing);

      await tester.tap(find.byKey(const Key('bots-routine-add')));
      await botsStep(tester);
      final add = gateway
          .named('cron.manage')
          .singleWhere((c) => c.params['action'] == 'add');
      expect(add.params['name'], '[bot:workbot] Digest');
      expect(add.params['prompt'], 'Summarise the day');
      expect(add.params['schedule'], '0 9 * * *');
      expect(add.params['profile'], 'workbot');
      expect(add.params.containsKey('repeat'), isFalse);
      // The gateway's own row says the job never retires.
      expect(gateway.jobs['workbot']!.last['repeat'], 'forever');
      expect(gateway.refusals, isEmpty);
      expect(find.byType(AlertDialog), findsNothing);
      await botsShown(tester, find.text('Digest'));
    });

    testWidgets('an interval with a run limit sends "every <n><unit>" and '
        'the limit as a count', (tester) async {
      final gateway = await openForm(tester);
      await tester.enterText(
        find.byKey(const Key('bots-routine-title')),
        'Poll',
      );
      await tester.enterText(
        find.byKey(const Key('bots-routine-instruction')),
        'Check the queue',
      );
      await tester.tap(find.byKey(const Key('bots-routine-schedule-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interval').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bots-routine-interval')),
        '2',
      );
      await tester.enterText(find.byKey(const Key('bots-routine-repeat')), '3');
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('bots-routine-add')));
      await tester.tap(find.byKey(const Key('bots-routine-add')));
      await botsStep(tester);
      final add = gateway
          .named('cron.manage')
          .singleWhere((c) => c.params['action'] == 'add');
      expect(add.params['schedule'], 'every 2h');
      expect(add.params['repeat'], 3);
      expect(gateway.jobs['workbot']!.last['repeat'], '3 times');
      expect(gateway.refusals, isEmpty);
    });

    testWidgets('an interval of 0 is not a schedule: Add stays disabled and '
        'nothing is sent', (tester) async {
      final gateway = await openForm(tester);
      await tester.enterText(
        find.byKey(const Key('bots-routine-title')),
        'Digest',
      );
      await tester.enterText(
        find.byKey(const Key('bots-routine-instruction')),
        'Summarise the day',
      );
      await tester.tap(find.byKey(const Key('bots-routine-schedule-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interval').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('bots-routine-interval')),
        '0',
      );
      await tester.pump();
      expect(addButton(tester).onPressed, isNull);
      expect(
        gateway.named('cron.manage').where((c) => c.params['action'] == 'add'),
        isEmpty,
      );
    });
  });

  group('destructive bot actions ask first; Cancel sends nothing', () {
    final dialog = find.byKey(const Key('bots-confirm-dialog'));
    Future<void> answer(WidgetTester tester, {required bool ok}) async {
      expect(dialog, findsOneWidget);
      await tester.tap(
        find.byKey(Key(ok ? 'bots-confirm-ok' : 'bots-confirm-cancel')),
      );
      await botsStep(tester);
      expect(dialog, findsNothing);
    }

    Future<BotsReviewGateway> open(
      WidgetTester tester, {
      Map<String, dynamic>? display,
      bool routines = false,
    }) async {
      wide(tester, const Size(900, 900));
      final gateway = BotsReviewGateway()..displayOverride = display;
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await (routines
          ? openBotsRoutinesTab(tester)
          : openBotsScreenTab(tester));
      return gateway;
    }

    testWidgets('B2 Stop Bot Desktop', (tester) async {
      final gateway = await open(tester);
      await tester.tap(find.text('Stop'));
      await botsStep(tester, 3);
      expect(find.text('Stop Bot Desktop for workbot?'), findsOneWidget);
      expect(gateway.named('display.stop'), isEmpty);
      await answer(tester, ok: false);
      expect(gateway.named('display.stop'), isEmpty);
      expect(find.text('Running'), findsOneWidget);
      await tester.tap(find.text('Stop'));
      await botsStep(tester, 3);
      await answer(tester, ok: true);
      expect(gateway.named('display.stop'), hasLength(1));
      await botsShown(tester, find.text('Stopped'));
      expect(gateway.refusals, isEmpty);
    });

    testWidgets('B3 Adopt sandbox image', (tester) async {
      final gateway = await open(
        tester,
        display: {
          'image_switch': {'current_image': 'a:1', 'target_image': 'b:2'},
        },
      );
      await botsShown(tester, find.text('Adopt image'));
      await tester.tap(find.text('Adopt image'));
      await botsStep(tester, 3);
      expect(find.text('Adopt the new sandbox image?'), findsOneWidget);
      expect(find.textContaining('a:1 to b:2'), findsOneWidget);
      await answer(tester, ok: false);
      expect(gateway.named('display.switchSandboxImage'), isEmpty);
      await tester.tap(find.text('Adopt image'));
      await botsStep(tester, 3);
      await answer(tester, ok: true);
      final call = gateway.named('display.switchSandboxImage').single;
      expect(call.params['approve'], isTrue);
      expect(call.params['profile'], 'workbot');
      expect(gateway.refusals, isEmpty);
    });

    testWidgets('B4 Remove routine', (tester) async {
      final gateway = await open(tester, routines: true);
      Iterable<BotsReviewCall> removes() => gateway
          .named('cron.manage')
          .where((c) => c.params['action'] == 'remove');
      await tester.tap(find.byTooltip('Remove'));
      await botsStep(tester, 3);
      expect(find.text('Remove routine Stand-up?'), findsOneWidget);
      await answer(tester, ok: false);
      expect(removes(), isEmpty);
      expect(find.text('Stand-up'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove'));
      await botsStep(tester, 3);
      await answer(tester, ok: true);
      expect(removes().single.params, containsPair('name', 'job-standup'));
      await botsShown(tester, find.text('No routines for this bot.'));
      expect(gateway.refusals, isEmpty);
    });
  });

  group('a late reply for another bot is dropped', () {
    Future<void> pickBot(WidgetTester tester, String name) async {
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await botsStep(tester, 6);
      await tester.tap(find.text(name).last);
      await botsStep(tester);
    }

    testWidgets("B5 routines: workbot's list arriving after the switch to "
        'researchbot is not shown', (tester) async {
      wide(tester, const Size(900, 900));
      final gateway = BotsReviewGateway();
      final hold = Completer<void>();
      gateway.holds['cron.manage:workbot:list'] = hold;
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await botsShown(tester, find.text('WorkBot'));
      await tester.tap(find.text('Routines'));
      await botsStep(tester, 3);
      await pickBot(tester, 'researchbot');
      expect(find.text('No routines for this bot.'), findsOneWidget);
      hold.complete();
      await botsStep(tester);
      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdown.initialValue, 'researchbot');
      expect(find.text('Stand-up'), findsNothing);
      expect(find.text('No routines for this bot.'), findsOneWidget);
    });

    testWidgets("B6 screen: workbot's status arriving after the switch to "
        'researchbot is not shown', (tester) async {
      wide(tester, const Size(900, 900));
      final gateway = BotsReviewGateway();
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await openBotsScreenTab(tester);
      final hold = Completer<void>();
      gateway.holds['display.status:workbot:'] = hold;
      await pickBot(tester, 'researchbot');
      expect(find.text('Not installed'), findsOneWidget);
      // Back to workbot (its status is held), then away again.
      await pickBot(tester, 'workbot');
      await pickBot(tester, 'researchbot');
      expect(find.text('Not installed'), findsOneWidget);
      hold.complete();
      await botsStep(tester);
      expect(find.text('Running'), findsNothing);
      expect(find.text('Not installed'), findsOneWidget);
      // And its thumbnail poll is not left running for the other bot.
      final before = gateway.named('display.thumbnail').length;
      await tester.pump(const Duration(seconds: 9));
      await botsStep(tester, 2);
      expect(gateway.named('display.thumbnail'), hasLength(before));
    });

    testWidgets('a start reply for the bot that was left does not paint the '
        'bot now selected', (tester) async {
      wide(tester, const Size(900, 900));
      final gateway = BotsReviewGateway()..running.clear();
      final owner = botsReviewOwner(gateway);
      addTearDown(owner.close);
      await tester.pumpWidget(botsReviewApp(owner));
      await botsShown(tester, find.text('WorkBot'));
      await tester.tap(find.text('Screen'));
      await botsShown(tester, find.text('Stopped'));
      final hold = Completer<void>();
      gateway.holds['display.start:workbot:'] = hold;
      await tester.tap(find.text('Start'));
      await botsStep(tester, 2);
      await pickBot(tester, 'researchbot');
      hold.complete();
      await botsStep(tester);
      expect(find.text('Running'), findsNothing);
      expect(find.text('Not installed'), findsOneWidget);
    });
  });
}
