// Regression tests cut from the independent review of v5/bots @ d74ba224
// (evidence/bots-review-d74ba224, probes B1-B10). Each test failed on the
// reviewed code and names the probe it replaces.
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
}
