import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/desktop_gateway_client.dart';
import 'package:hermes_android/core/services/gateway_turn_application_controller.dart';
import 'package:hermes_android/core/services/gateway_turn_coordinator.dart';
import 'package:hermes_android/core/services/normal_gateway_application_session.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/core/services/turn_notification_service.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_voice_composer_adapter.dart';
import 'support/pump_chat_updates.dart';

const _truncationKeys = {
  'confirm_truncate',
  'confirm_empty_truncate',
  'confirm_deep_truncate',
  'truncate_before_row_id',
  'truncate_before_message_id',
  'truncate_before_user_ordinal',
};

bool _hasAnyTruncationKey(Map<String, dynamic> params) =>
    params.keys.any(_truncationKeys.contains);

class _OwnerController extends GatewayTurnApplicationController {
  _OwnerController(this.client, this.rows);
  final _RecordingClassicClient client;
  final List<Map<String, dynamic>> rows;

  @override
  NormalGatewayApplicationSession normalSessionFor(
    SavedConnection connection, {
    NormalGatewayPromptSubmit? submit,
    NormalGatewaySteer? steer,
    NormalGatewayResume? resume,
    NormalGatewayHistory? history,
    TurnNotificationService? notifications,
  }) => NormalGatewayApplicationSession(
    connection: connection,
    scope: 'classic-rewind-test-scope',
    client: client,
    submit: submit,
    resume: ({required localSessionId, required storedSessionId}) async =>
        const ResumedGatewaySession(
          runtimeSessionId: 'rt-classic',
          running: false,
          status: 'completed',
        ),
    history: (_) async => rows,
    notifications: notifications,
  );

  @override
  Future<void> close() async {
    await super.close();
  }
}

class _RecordingClassicClient implements DesktopGatewayClient {
  _RecordingClassicClient(this.connection, {this.onSubmitted}) {
    final db = DashboardClient(
      host: connection.host,
      port: connection.port,
      useHttps: true,
      proxied: true,
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );
    workspace = RemoteWorkspaceOwner(
      connectionId: connection.id,
      expectedBaseUrl: db.baseUrl,
      profile: null,
      dashboard: db,
      connect: () async => throw UnsupportedError('unused'),
      ownsSocket: (_) => false,
    );
  }

  final SavedConnection connection;
  final void Function(Map<String, dynamic> params)? onSubmitted;
  final submits = <Map<String, dynamic>>[];
  final interrupts = <String>[];
  DesktopAsyncEventCallback? _eventListener;

  @override
  late final RemoteWorkspaceOwner workspace;

  @override
  bool get sessionAuthority => true;

  @override
  bool get slashCommandsSupported => false;

  @override
  void setSessionBoundListener(
    GatewayTurnSessionBoundCallback? listener, {
    GatewayTurnSessionBoundCallback? onCreated,
  }) {}

  @override
  void setSessionEventListener(DesktopAsyncEventCallback? listener) {
    _eventListener = listener;
  }

  @override
  void setAsyncEventListener(
    DesktopAsyncEventCallback? listener, {
    DesktopAsyncEventSessionPredicate? acceptsSession,
  }) {}

  @override
  void setConnectionListener(DesktopConnectionCallback? listener) {}

  @override
  void setReconnectAllowed(bool allowed) {}

  @override
  void bindStoredSession(String localSessionId, String storedSessionId) {}

  @override
  String? storedSessionKeyFor(String mobileSessionId) => mobileSessionId;

  @override
  String? boundTerminalBackend(String storedSessionId) => null;

  @override
  Future<void> ensureSession(
    String sessionId, {
    String? workingDirectory,
  }) async {}

  @override
  Future<bool> interruptPrompt({required String sessionId}) async {
    interrupts.add(sessionId);
    return true;
  }

  @override
  Future<Map<String, dynamic>?> sessionRpc(
    String mobileSessionId,
    String method,
    Map<String, dynamic> params,
  ) async {
    if (method == 'session.history') {
      return {
        'messages': [
          {'row_id': 101, 'role': 'user', 'text': 'First question'},
          {'row_id': 102, 'role': 'assistant', 'text': 'First answer'},
          {'row_id': 103, 'role': 'user', 'text': 'Second question'},
          {'row_id': 104, 'role': 'assistant', 'text': 'Second answer'},
        ],
      };
    }
    if (method == 'session.interrupt') {
      interrupts.add(mobileSessionId);
      return const {};
    }
    return const {};
  }

  @override
  Future<void> submitPrompt({
    required String sessionId,
    required String text,
    required StreamCallback onEvent,
    required void Function() onSent,
    bool Function()? maySend,
    Future<bool> Function()? beforeSend,
    void Function()? onAccepted,
    String? submissionId,
    Map<String, dynamic>? extraSubmitParams,
    Future<void> Function()? beforeLegacy,
    Future<void> Function(Object?, String)? onReceipt,
  }) async {
    if (beforeSend != null && !await beforeSend()) {
      throw StateError('revoked');
    }
    if (maySend?.call() == false) {
      throw StateError('not owned');
    }
    final recorded = <String, dynamic>{
      ...?extraSubmitParams,
      'session_id': sessionId,
      'text': text,
    };
    submits.add(recorded);
    onSubmitted?.call(recorded);
    onSent();
    onAccepted?.call();
    final delta = StreamEvent(
      type: 'message.delta',
      sessionId: sessionId,
      data: const {'text': 'Updated reply'},
    );
    final done = StreamEvent(
      type: 'turn.end',
      sessionId: sessionId,
      isComplete: true,
      data: const {'completed': true},
    );
    _eventListener?.call(sessionId, delta);
    onEvent(delta);
    _eventListener?.call(sessionId, done);
    onEvent(done);
  }

  @override
  bool ownsApprovalRequest(String sessionId, {String? requestId}) => false;

  @override
  void close() => workspace.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected DesktopGatewayClient.${invocation.memberName}',
  );
}

class _FakeNgSocket extends Fake implements WsClient {
  @override
  int get socketEpoch => 1;
  @override
  bool get isConnected => true;
}

class _RecordingNgGateway extends NextGenGateway {
  _RecordingNgGateway(super.connection)
    : super(
        dashboard: DashboardClient(
          host: connection.host,
          port: connection.port,
          useHttps: true,
          proxied: true,
          httpClient: MockClient((_) async => http.Response('{}', 200)),
        ),
      );

  final _fakeSocket = _FakeNgSocket();
  final submits = <Map<String, dynamic>>[];
  final interrupts = <Map<String, dynamic>>[];

  @override
  WsClient? get socket => _fakeSocket;

  @override
  Future<WsClient> connected({
    Duration timeout = const Duration(seconds: 20),
  }) async => _fakeSocket;

  @override
  NgConnectionState get state =>
      const NgConnectionState(NgConnectionPhase.connected);

  @override
  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    switch (method) {
      case 'session.resume':
        return {
          'session_id': 'rt-ng',
          'stored_session_id': 'stored-rewind',
          'info': {'stored_session_id': 'stored-rewind'},
        };
      case 'session.history':
        return {
          'messages': [
            {'row_id': 101, 'role': 'user', 'text': 'First question'},
            {'row_id': 102, 'role': 'assistant', 'text': 'First answer'},
            {'row_id': 103, 'role': 'user', 'text': 'Second question'},
            {'row_id': 104, 'role': 'assistant', 'text': 'Second answer'},
          ],
        };
      case 'session.interrupt':
        interrupts.add(Map<String, dynamic>.from(params));
        return const {};
      case 'prompt.submit':
        submits.add(Map<String, dynamic>.from(params));
        return {'status': 'streaming', 'execution_generation': submits.length};
      default:
        return const {};
    }
  }
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  await tester.pump();
}

void main() {
  setUp(mockChatImageRecovery);

  testWidgets(
    'Classic edit and regenerate each send one truncating prompt.submit and ordinary sends never truncate',
    (tester) async {
      SharedPreferences.setMockInitialValues({'verbose_mode': false});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1400);
      addTearDown(tester.view.reset);

      final conn = SavedConnection(
        id: 'classic-rewind',
        label: 'Classic rewind',
        host: 'rewind.invalid',
        port: 443,
        useHttps: true,
        dashboardPortOverride: 443,
        desktopGatewayUrl: 'https://rewind.invalid:443',
        singleLogin: true,
        signInMethod: 'none',
        apiKey: '',
        dashboardProxied: true,
      );
      final rows = <Map<String, dynamic>>[
        {'id': 101, 'role': 'user', 'content': 'First question'},
        {
          'id': 102,
          'role': 'assistant',
          'content': 'First answer',
          'finish_reason': 'stop',
        },
        {'id': 103, 'role': 'user', 'content': 'Second question'},
        {
          'id': 104,
          'role': 'assistant',
          'content': 'Second answer',
          'finish_reason': 'stop',
        },
      ];

      late final _RecordingClassicClient client;
      var nextRowId = 200;
      client = _RecordingClassicClient(
        conn,
        onSubmitted: (params) {
          final cut = params['truncate_before_row_id'];
          if (params['confirm_truncate'] == true && cut is int) {
            rows.removeWhere((r) => (r['id'] as int) >= cut);
          }
          rows.add({
            'id': ++nextRowId,
            'role': 'user',
            'content': params['text'],
          });
          rows.add({
            'id': ++nextRowId,
            'role': 'assistant',
            'content': 'Updated reply',
            'finish_reason': 'stop',
          });
        },
      );
      final controller = _OwnerController(client, rows);
      var gatewayAttached = false;
      final api = ApiClient(
        baseUrl: conn.baseUrl,
        apiKey: '',
        httpClient: MockClient((req) async {
          if (req.url.path.endsWith('/messages')) {
            return http.Response(jsonEncode({'data': rows}), 200);
          }
          return http.Response(
            jsonEncode({'id': 'stored-rewind', 'archived': false}),
            200,
          );
        }),
      );

      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChatScreen(
              connection: conn,
              session: Session(
                id: 'stored-rewind',
                title: 'Rewind chat',
                model: 'fixture',
                source: 'desktop',
                messageCount: 4,
                isActive: false,
                preview: '',
                startedAt: 1,
              ),
              turnApplicationController: controller,
              testApiClient: api,
              testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
              testDesktopGateway: (_) => gatewayAttached = true,
              testRemotePromptSubmit: ({
                required sessionId,
                required text,
                required onEvent,
                required onSent,
                extraSubmitParams,
              }) async {
                final recorded = <String, dynamic>{
                  'session_id': sessionId,
                  'text': text,
                  ...?extraSubmitParams,
                };
                // ignore: avoid_print
                print('SEAM submit: $recorded');
                client.submits.add(recorded);
                client.onSubmitted?.call(recorded);
                onSent();
                const turn = 'rewind-turn';
                onEvent(
                  StreamEvent(type: 'message.start', data: const {}, turnId: turn),
                );
                onEvent(
                  StreamEvent(
                    type: 'turn.end',
                    data: const {'status': 'completed'},
                    turnId: turn,
                  ),
                );
              },
            ),
          ),
        );
        await _pumpFrames(tester);

        // 1. Tail regenerate sends exactly one truncating submit without deep confirm.
        expect(gatewayAttached, isTrue, reason: 'desktop gateway never attached');
        await tester.tap(find.byKey(const Key('message-action-retry')));
        await _pumpFrames(tester);
        // ignore: avoid_print
        print('client.submits length = ${client.submits.length}');
        expect(client.submits, hasLength(1));
        expect(client.submits.single['text'], 'Second question');
        expect(client.submits.single['confirm_truncate'], isTrue);
        expect(client.submits.single['truncate_before_row_id'], 103);
        expect(
          client.submits.single.containsKey('confirm_deep_truncate'),
          isFalse,
        );
        client.submits.clear();

        // 2. Edit the FIRST user turn (later user turn exists -> requires deep confirm).
        final firstUser = find.byWidgetPredicate(
          (w) =>
              w is MessageBubble && w.isUser && w.content == 'First question',
        );
        await tester.longPress(
          find.descendant(
            of: firstUser,
            matching: find.byKey(const Key('message-bubble')),
          ),
        );
        await _pumpFrames(tester);
        await tester.tap(find.text('Edit and resend'));
        await _pumpFrames(tester);
        expect(
          find.byKey(const ValueKey('classic-editing-banner')),
          findsOneWidget,
        );
        expect(client.submits, isEmpty);

        final composer = find.byKey(const Key('chat-message-composer'));
        await tester.enterText(composer, 'First question edited');
        await _pumpFrames(tester);

        // Send triggers deep-cut confirmation; declining sends nothing.
        await tester.tap(find.byKey(const Key('chat-send-message')));
        await _pumpFrames(tester);
        expect(
          find.byKey(const ValueKey('confirm-deep-truncate')),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await _pumpFrames(tester);
        expect(client.submits, isEmpty);

        // Confirming sends exactly ONE truncating submit with confirm_deep_truncate.
        await tester.tap(find.byKey(const Key('chat-send-message')));
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const ValueKey('confirm-deep-truncate')));
        await _pumpFrames(tester);
        expect(client.submits, hasLength(1));
        expect(client.submits.single['text'], 'First question edited');
        expect(client.submits.single['confirm_truncate'], isTrue);
        expect(client.submits.single['truncate_before_row_id'], 101);
        expect(client.submits.single['confirm_empty_truncate'], isTrue);
        expect(client.submits.single['confirm_deep_truncate'], isTrue);
        expect(
          find.byKey(const ValueKey('classic-editing-banner')),
          findsNothing,
        );
        client.submits.clear();

        // 3. Subsequent ordinary send NEVER carries truncation parameters.
        await tester.enterText(composer, 'Ordinary follow-up');
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const Key('chat-send-message')));
        await _pumpFrames(tester);
        expect(client.submits, hasLength(1));
        expect(client.submits.single['text'], 'Ordinary follow-up');
        expect(_hasAnyTruncationKey(client.submits.single), isFalse);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await controller.close();
        client.close();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'NextGen edit and regenerate each send one truncating prompt.submit and ordinary sends never truncate',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1400);
      addTearDown(tester.view.reset);

      final conn = SavedConnection(
        id: 'ng-rewind',
        label: 'NextGen rewind',
        host: 'rewind.invalid',
        port: 443,
        useHttps: true,
        apiKey: '',
      );
      final prefs = await SharedPreferences.getInstance();
      final gateway = _RecordingNgGateway(conn);
      final chat = NgChatController(gateway, sessionId: 'stored-rewind');
      final u1 = NgUserItem('u1', 'First question', rowId: 101);
      final a1 = NgAssistantItem('a1', open: false)..text = 'First answer';
      final u2 = NgUserItem('u2', 'Second question', rowId: 103);
      final a2 = NgAssistantItem('a2', open: false)..text = 'Second answer';
      chat.items.addAll([u1, a1, u2, a2]);

      try {
        await tester.pumpWidget(
          MaterialApp(
            theme: nextGenTheme(Brightness.dark, NextGenLook.instance),
            home: NgScope(
              connManager: ConnectionManager(prefs),
              gateway: gateway,
              connections: [conn],
              switchTo: (_) async {},
              addGateway: () async {},
              signOut: (_) async {},
              reload: () async {},
              signInAgain: () async {},
              child: NgChatView(
                chat: chat,
                onOpenSidebar: () {},
                onNewChat: () {},
              ),
            ),
          ),
        );
        await _pumpFrames(tester);

        // 1. Tail regenerate sends ONE truncating submit without deep confirm.
        await tester.tap(find.byKey(const ValueKey('ng-regenerate-a2')));
        await _pumpFrames(tester);
        expect(gateway.submits, hasLength(1));
        expect(gateway.submits.single['text'], 'Second question');
        expect(gateway.submits.single['confirm_truncate'], isTrue);
        expect(gateway.submits.single['truncate_before_row_id'], 103);
        expect(
          gateway.submits.single.containsKey('confirm_deep_truncate'),
          isFalse,
        );
        chat.running = false;
        chat.items
          ..clear()
          ..addAll([u1, a1, u2, a2]);
        gateway.submits.clear();
        await tester.pumpWidget(
          MaterialApp(
            theme: nextGenTheme(Brightness.dark, NextGenLook.instance),
            home: NgScope(
              connManager: ConnectionManager(prefs),
              gateway: gateway,
              connections: [conn],
              switchTo: (_) async {},
              addGateway: () async {},
              signOut: (_) async {},
              reload: () async {},
              signInAgain: () async {},
              child: NgChatView(
                key: const ValueKey('rebuilt'),
                chat: chat,
                onOpenSidebar: () {},
                onNewChat: () {},
              ),
            ),
          ),
        );
        await _pumpFrames(tester);

        // 2. Edit first user turn (while running -> interrupts first, confirms deep cut).
        await tester.tap(find.byKey(const ValueKey('ng-edit-u1')));
        await _pumpFrames(tester);
        expect(find.byKey(const ValueKey('ng-editing-banner')), findsOneWidget);
        final composer = find.byKey(const ValueKey('ng-composer-field'));
        await tester.enterText(composer, 'First question edited');
        await _pumpFrames(tester);

        // Simulate live turn running when edit is submitted: must interrupt first.
        chat.running = true;
        await tester.tap(find.byKey(const ValueKey('ng-send-button')));
        await _pumpFrames(tester);

        // Deep-cut confirm appears; cancelling sends nothing.
        expect(
          find.byKey(const ValueKey('confirm-deep-truncate')),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancel'));
        await _pumpFrames(tester);
        expect(gateway.submits, isEmpty);

        // Confirming interrupts first and sends ONE truncating submit.
        await tester.tap(find.byKey(const ValueKey('ng-send-button')));
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const ValueKey('confirm-deep-truncate')));
        await _pumpFrames(tester);
        expect(gateway.interrupts, hasLength(1));
        expect(gateway.submits, hasLength(1));
        expect(gateway.submits.single['text'], 'First question edited');
        expect(gateway.submits.single['confirm_truncate'], isTrue);
        expect(gateway.submits.single['truncate_before_row_id'], 101);
        expect(gateway.submits.single['confirm_empty_truncate'], isTrue);
        expect(gateway.submits.single['confirm_deep_truncate'], isTrue);
        expect(find.byKey(const ValueKey('ng-editing-banner')), findsNothing);
        gateway.submits.clear();

        // 3. Ordinary send after edit NEVER truncates.
        chat.running = false;
        await tester.enterText(composer, 'Plain follow-up');
        await _pumpFrames(tester);
        await tester.tap(find.byKey(const ValueKey('ng-send-button')));
        await _pumpFrames(tester);
        expect(gateway.submits, hasLength(1));
        expect(gateway.submits.single['text'], 'Plain follow-up');
        expect(_hasAnyTruncationKey(gateway.submits.single), isFalse);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        chat.dispose();
        gateway.dispose();
        await tester.pump();
      }
    },
  );
}
