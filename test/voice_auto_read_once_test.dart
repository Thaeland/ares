// Auto-read reads a reply once, and only a reply that completes while its
// chat is open: opening or switching to a chat never reads the reply already
// at its bottom (Desktop use-auto-speak-replies), in both layouts (voice
// review of 46683e29, probes U4 and R2).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/auto_speak_replies.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/read_aloud.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/voice_live_harness.dart';

class _RecordingReadAloud extends NgReadAloud {
  _RecordingReadAloud() : super(speaker: HarnessReplySpeaker());
  final reads = <String>[];
  @override
  Future<void> read(String key, String text) async => reads.add(text);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': false});
    autoSpeakRepliesEnabled.value = true;
  });

  tearDown(() => autoSpeakRepliesEnabled.value = false);

  group('NextGen', () {
    late HarnessGateway gateway;
    late _RecordingReadAloud reader;

    NgChatController chatFor(String id) =>
        NgChatController(gateway, sessionId: id)..runtimeId = id;

    Future<void> show(WidgetTester tester, NgChatController chat) async {
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: nextGenTheme(Brightness.light, NextGenLook.instance),
          home: NgScope(
            connManager: ConnectionManager(prefs),
            gateway: gateway,
            connections: [gateway.connection],
            switchTo: (_) async {},
            addGateway: () async {},
            signOut: (_) async {},
            reload: () async {},
            signInAgain: () async {},
            // No key: switching chats keeps this view (didUpdateWidget), as
            // a pane that swaps its chat does.
            child: Scaffold(
              body: NgChatView(
                chat: chat,
                onOpenSidebar: () {},
                onNewChat: () {},
                readAloudFactory: () => reader,
              ),
            ),
          ),
        ),
      );
      await settleLive(tester);
    }

    void emit(String sessionId, String type, [Map<String, dynamic>? data]) =>
        gateway.debugEmit(
          StreamEvent(type: type, data: data ?? const {}, sessionId: sessionId),
        );

    setUp(() {
      gateway = HarnessGateway(harnessNextGenConnection());
      reader = _RecordingReadAloud();
    });

    testWidgets('opening a chat never reads the reply it already has '
        '(history hydrated after mount, probe U4)', (tester) async {
      final chat = chatFor('stored');
      await show(tester, chat);
      chat.debugApplyHistory(const [
        {'role': 'user', 'content': 'yesterday question'},
        {'role': 'assistant', 'content': 'An old answer from yesterday.'},
      ]);
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      chat.notifyListeners();
      await settleLive(tester);
      expect(reader.reads, isEmpty);
      await unmountLive(tester);
    });

    testWidgets('opening a chat that already shows a reply never reads it', (
      tester,
    ) async {
      final chat = chatFor('stored')
        ..debugApplyHistory(const [
          {'role': 'user', 'content': 'Q'},
          {'role': 'assistant', 'content': 'Already here.'},
        ]);
      await show(tester, chat);
      expect(reader.reads, isEmpty);
      await unmountLive(tester);
    });

    testWidgets('a reply that completes while the chat is open is read once', (
      tester,
    ) async {
      final chat = chatFor('stored')
        ..debugApplyHistory(const [
          {'role': 'user', 'content': 'Q'},
          {'role': 'assistant', 'content': 'Old reply.'},
        ]);
      await show(tester, chat);
      emit('stored', 'message.start');
      await settleLive(tester);
      emit('stored', 'message.delta', {'text': 'Fresh reply.'});
      emit('stored', 'message.complete', {'status': 'complete'});
      await settleLive(tester);
      expect(reader.reads, ['Fresh reply.']);
      // Later notifications (a reload, a reconnect) never read it again.
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      chat.notifyListeners();
      await settleLive(tester);
      expect(reader.reads, ['Fresh reply.']);
      await unmountLive(tester);
    });

    testWidgets('switching to another chat never reads its bottom reply', (
      tester,
    ) async {
      final first = chatFor('first')
        ..debugApplyHistory(const [
          {'role': 'user', 'content': 'Q1'},
          {'role': 'assistant', 'content': 'First chat reply.'},
        ]);
      final second = chatFor('second');
      await show(tester, first);
      await show(tester, second);
      second.debugApplyHistory(const [
        {'role': 'user', 'content': 'Q2'},
        {'role': 'assistant', 'content': 'Second chat reply.'},
      ]);
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      second.notifyListeners();
      await settleLive(tester);
      expect(reader.reads, isEmpty);
      // A reply completing in the chat now shown is read.
      emit('second', 'message.start');
      await settleLive(tester);
      emit('second', 'message.delta', {'text': 'New in second.'});
      emit('second', 'message.complete', {'status': 'complete'});
      await settleLive(tester);
      expect(reader.reads, ['New in second.']);
      await unmountLive(tester);
    });
  });
}
