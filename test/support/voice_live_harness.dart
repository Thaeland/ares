// Widget harness for GPT-Live in both layouts: the real VoiceLiveEngine over
// a fake LiveConversation, mounted in Classic's ChatScreen and NextGen's
// NgChatView. No WebRTC plugin, no gateway socket, no network.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/controllers/hands_free_conversation_controller.dart'
    show HandsFreeSpeechOutcome;
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/gateway_wake_word.dart';
import 'package:hermes_android/core/services/gpt_live_conversation.dart';
import 'package:hermes_android/core/services/hands_free_speech.dart';
import 'package:hermes_android/core/services/voice_live_engine.dart';
import 'package:hermes_android/core/services/voice_live_mode.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_voice_composer_adapter.dart';

/// A live conversation that only records what the engine asked of it.
class HarnessConversation implements LiveConversation {
  bool _active = false;
  int starts = 0;
  int gracefulCloses = 0;
  final forcedCloses = <String>[];
  bool disposed = false;

  /// Holds [start] open until completed (a pending microphone prompt).
  Future<void>? startGate;

  /// True once the session has been ended by any path.
  bool get ended => gracefulCloses > 0 || forcedCloses.isNotEmpty || disposed;

  @override
  bool get active => _active;
  @override
  String? get sessionId => 'harness-session';
  @override
  String? get delegationId => null;

  @override
  Future<bool> start({List<Map<String, dynamic>>? history}) async {
    starts++;
    await startGate;
    if (disposed || forcedCloses.isNotEmpty) return false;
    _active = true;
    return true;
  }

  @override
  void speak(String text, {String? delegationId}) {}
  @override
  void think(String text, {String? delegationId}) {}
  @override
  void instruct(String text) {}
  @override
  void setMuted(bool muted) {}

  @override
  Future<void> close() async {
    gracefulCloses++;
    _active = false;
  }

  @override
  Future<void> forceClose(String reason, [int? usageSeconds]) async {
    forcedCloses.add(reason);
    _active = false;
  }

  @override
  void dispose() {
    disposed = true;
    _active = false;
  }

  /// The vendor (or the transport) ended the session under the engine.
  void endFromOutside(String reason) {
    _active = false;
    onClosed?.call(reason, null);
  }

  @override
  void Function(String id, Map<String, String> prompt)? onDelegation;
  @override
  void Function(LiveFragment fragment)? onTranscript;
  @override
  void Function(String message, bool fatal)? onError;
  @override
  void Function(String reason, int? usageSeconds)? onClosed;
}

/// Host status: GPT-Live selected and available.
class HarnessLiveTransport implements GptLiveTransport {
  int statusCalls = 0;

  @override
  Future<Object?> status() async {
    statusCalls++;
    return {'ok': true, 'mode': 'gpt-live', 'available': true};
  }

  @override
  Future<Object?> createSession({
    required String sdp,
    List<Map<String, dynamic>>? history,
  }) async => null;

  @override
  void dispose() {}
}

class HarnessReplySpeaker implements VoiceReplySpeaker {
  @override
  Future<bool> prepare() async => true;
  @override
  Future<HandsFreeSpeechOutcome> speak(
    String text, {
    required bool Function() isCurrent,
  }) async => HandsFreeSpeechOutcome.completed;
  @override
  Future<void> stop() async {}
}

/// NextGen gateway with no socket: records `prompt.submit`, answers the rest
/// with an empty result.
class HarnessGateway extends NextGenGateway {
  HarnessGateway(super.connection);

  final submits = <Map<String, dynamic>>[];
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    calls.add(method);
    if (method == 'prompt.submit') {
      submits.add(Map<String, dynamic>.from(params));
      return {'status': 'streaming'};
    }
    return {};
  }

  @override
  Future<WsClient> connected({
    Duration timeout = const Duration(seconds: 20),
  }) async => throw StateError('not connected');
}

class _NotFoundHttp extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(
        Stream.value(utf8.encode('{}')),
        404,
        headers: {'content-type': 'application/json'},
      );
}

SavedConnection harnessNextGenConnection({String id = 'c1'}) => SavedConnection(
  id: id,
  label: 'Home',
  host: '10.0.0.5',
  port: 9119,
  apiKey: '',
  desktopGatewayUrl: 'http://10.0.0.5:9119',
  singleLogin: true,
  signInMethod: 'none',
);

final harnessClassicConnection = SavedConnection(
  id: 'voice-fixture',
  label: 'Voice fixture',
  host: 'voice.fixture',
  port: 8642,
  apiKey: 'synthetic-key',
);

/// One Classic chat's live-voice seams. Keep the instance across re-pumps
/// (for example `active: false`) so the State sees the same collaborators.
class ClassicLiveFixture {
  ClassicLiveFixture({HarnessConversation? conversation})
    : conversation = conversation ?? HarnessConversation();

  final HarnessConversation conversation;
  final transport = HarnessLiveTransport();
  late final mode = VoiceLiveModeController(
    connectionId: harnessClassicConnection.id,
    transport: transport,
    registerShared: false,
  );
  VoiceLiveEngine? engine;

  VoiceLiveEngine engineFactory(GptLiveTransport transport) =>
      engine = VoiceLiveEngine(transport: transport, session: conversation);

  Widget app({
    bool active = true,
    GlobalKey<NavigatorState>? navigatorKey,
    String sessionId = 'voice-session',
  }) => MaterialApp(
    navigatorKey: navigatorKey,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ChatScreen(
      active: active,
      connection: harnessClassicConnection,
      session: Session(
        id: sessionId,
        title: 'Voice chat',
        model: 'fixture-model',
        source: 'test',
        messageCount: 0,
        isActive: true,
        preview: '',
        startedAt: 1,
      ),
      testApiClient: ApiClient(
        baseUrl: 'http://voice.fixture',
        apiKey: 'synthetic-key',
        httpClient: _NotFoundHttp(),
      ),
      testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
      testVoiceReplySpeaker: HarnessReplySpeaker(),
      testVoiceLiveMode: mode,
      testVoiceLiveEngineFactory: engineFactory,
    ),
  );
}

/// One NextGen chat's live-voice seams.
class NextGenLiveFixture {
  NextGenLiveFixture({
    HarnessConversation? conversation,
    HarnessGateway? gateway,
    this.wake,
  }) : conversation = conversation ?? HarnessConversation(),
       gateway = gateway ?? HarnessGateway(harnessNextGenConnection());

  final HarnessConversation conversation;
  final HarnessGateway gateway;
  final GatewayWakeWordController? wake;
  final transport = HarnessLiveTransport();
  late final mode = VoiceLiveModeController(
    connectionId: gateway.connection.id,
    transport: transport,
    registerShared: false,
  );
  late final chat = NgChatController(gateway, sessionId: 'stored')
    ..runtimeId = 'stored'
    ..debugApplyHistory(const []);
  VoiceLiveEngine? engine;

  VoiceLiveEngine engineFactory(GptLiveTransport transport) =>
      engine = VoiceLiveEngine(transport: transport, session: conversation);

  Future<Widget> app({GlobalKey<NavigatorState>? navigatorKey}) async {
    final prefs = await SharedPreferences.getInstance();
    return MaterialApp(
      navigatorKey: navigatorKey,
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
        child: Scaffold(
          body: NgChatView(
            chat: chat,
            onOpenSidebar: () {},
            onNewChat: () {},
            wakeController: wake,
            voiceModeController: mode,
            voiceLiveEngineFactory: engineFactory,
          ),
        ),
      ),
    );
  }
}

/// Bounded settle: live controls and banners never reach `pumpAndSettle`.
Future<void> settleLive(WidgetTester tester, {int frames = 6}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Taps the composer's live Start and waits for the session to open.
Future<void> startLiveFromComposer(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('voice-live-start')));
  await settleLive(tester);
}

/// Unmounts the tree and drains its teardown timers.
Future<void> unmountLive(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await settleLive(tester);
}
