// GPT-Live teardown in the composers of both layouts: what the person sees
// when the session is lost, and that a chat which is hidden, covered or in
// the background never keeps a live microphone (review probes G6, G8, U1,
// U2, U3). The real VoiceLiveEngine runs over a fake LiveConversation.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/auto_speak_replies.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/voice_live_harness.dart';

const _lostCopy = 'The live voice session lost its connection.';
const _closedCopy = 'The live voice session was closed by the service.';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': false});
    autoSpeakRepliesEnabled.value = false;
  });

  group('a lost session is shown', () {
    testWidgets('Classic: connection loss hides the controls and says why', (
      tester,
    ) async {
      final fixture = ClassicLiveFixture();
      await tester.pumpWidget(fixture.app());
      await settleLive(tester);
      await startLiveFromComposer(tester);
      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsOneWidget,
      );

      fixture.conversation.endFromOutside('connection_lost');
      await settleLive(tester);

      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('voice-live-start')), findsOneWidget);
      expect(find.text(_lostCopy), findsOneWidget);
      await unmountLive(tester);
    });

    testWidgets('NextGen: connection loss hides the controls and says why', (
      tester,
    ) async {
      final fixture = NextGenLiveFixture();
      await tester.pumpWidget(await fixture.app());
      await settleLive(tester);
      await startLiveFromComposer(tester);
      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsOneWidget,
      );

      fixture.conversation.endFromOutside('connection_lost');
      await settleLive(tester);

      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('voice-live-start')), findsOneWidget);
      expect(find.text(_lostCopy), findsOneWidget);
      // The toast clears itself; drain its timer before unmounting.
      await tester.pump(const Duration(seconds: 6));
      await unmountLive(tester);
    });

    testWidgets('a close by the service has its own copy; a server-sent '
        'reason passes through verbatim; our own stop says nothing', (
      tester,
    ) async {
      final fixture = ClassicLiveFixture();
      await tester.pumpWidget(fixture.app());
      await settleLive(tester);

      await startLiveFromComposer(tester);
      fixture.conversation.endFromOutside('closed');
      await settleLive(tester);
      expect(find.text(_closedCopy), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).clearSnackBars();
      await settleLive(tester);

      await startLiveFromComposer(tester);
      fixture.conversation.endFromOutside('quota_exhausted');
      await settleLive(tester);
      expect(find.text('quota_exhausted'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).clearSnackBars();
      await settleLive(tester);

      await startLiveFromComposer(tester);
      await tester.tap(find.byKey(const ValueKey('voice-live-stop')));
      await settleLive(tester);
      expect(fixture.conversation.gracefulCloses, 1);
      expect(find.byType(SnackBar), findsNothing);
      await unmountLive(tester);
    });
  });

  group('app lifecycle', () {
    // The OS microphone prompt on first use takes the app to `inactive`
    // while getUserMedia is still pending. That must not end the session it
    // is granting; only a real background (paused / hidden) does.
    Future<void> lifecycle(WidgetTester tester, AppLifecycleState state) async {
      tester.binding.handleAppLifecycleStateChanged(state);
      await settleLive(tester);
    }

    Future<void> exercise(
      WidgetTester tester,
      HarnessConversation conversation,
    ) async {
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      final prompt = Completer<void>();
      conversation.startGate = prompt.future;
      await startLiveFromComposer(tester);
      expect(conversation.starts, 1);
      expect(conversation.active, isFalse);

      await lifecycle(tester, AppLifecycleState.inactive);
      prompt.complete();
      await settleLive(tester);
      await lifecycle(tester, AppLifecycleState.resumed);

      expect(conversation.ended, isFalse);
      expect(conversation.active, isTrue);
      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsOneWidget,
      );

      // A later `inactive` (notification shade, app switcher peek) keeps
      // the conversation too.
      await lifecycle(tester, AppLifecycleState.inactive);
      await lifecycle(tester, AppLifecycleState.resumed);
      expect(conversation.active, isTrue);

      await lifecycle(tester, AppLifecycleState.inactive);
      await lifecycle(tester, AppLifecycleState.hidden);
      expect(conversation.active, isFalse);
      expect(conversation.ended, isTrue);

      await lifecycle(tester, AppLifecycleState.inactive);
      await lifecycle(tester, AppLifecycleState.resumed);
      expect(
        find.byKey(const ValueKey('voice-live-inline-controls')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('voice-live-start')), findsOneWidget);
    }

    testWidgets('Classic: inactive keeps a starting and a live session; '
        'background ends it', (tester) async {
      final fixture = ClassicLiveFixture();
      await tester.pumpWidget(fixture.app());
      await settleLive(tester);
      await exercise(tester, fixture.conversation);
      await unmountLive(tester);
    });

    testWidgets('NextGen: inactive keeps a starting and a live session; '
        'background ends it', (tester) async {
      final fixture = NextGenLiveFixture();
      await tester.pumpWidget(await fixture.app());
      await settleLive(tester);
      await exercise(tester, fixture.conversation);
      await unmountLive(tester);
    });
  });
}
