// Regression tests from the independent review of v5/composer at 7d750d1d
// (probes C1-C4), Classic layout. Each failed at 7d750d1d:
//   C1 an async error frame armed a Retry that resent the accepted prompt
//      and overwrote the newer draft
//   C2 a btw.complete answer never reached the chat
//   C3 /resume from an embedded chat replaced the whole shell
//   C4 no @-reference completion or status bar in Classic
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';
import 'package:hermes_android/core/widgets/composer_drop_surface.dart';
import 'package:hermes_android/core/widgets/failure_recovery_card.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_voice_composer_adapter.dart';
import 'support/pump_chat_updates.dart';

const _composerKey = Key('chat-message-composer');

Widget _app(Widget home) => MaterialApp(
  theme: hermesTheme(Brightness.light),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

const _session = Session(
  id: 'probe-parent',
  title: 'Parent',
  model: 'fixture',
  source: 'api_server',
  messageCount: 2,
  isActive: true,
  preview: '',
  startedAt: 1,
);

SavedConnection _conn(String id) => SavedConnection(
  id: id,
  label: id,
  host: 'probe.fixture',
  port: 8642,
  apiKey: 'fixture',
);

String _composer(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(_composerKey)).controller!.text;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': true});
    mockChatImageRecovery();
  });

  ({ChatScreen screen, List<http.BaseRequest> writes}) classic(
    TestDesktopAsyncEventHook hook,
    String connId,
  ) {
    final writes = <http.BaseRequest>[];
    final screen = ChatScreen(
      connection: _conn(connId),
      session: _session,
      testApiClient: ApiClient(
        baseUrl: 'http://probe.fixture',
        apiKey: 'fixture',
        httpClient: MockClient((request) async {
          if (request.method != 'GET') writes.add(request);
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 1, 'role': 'user', 'content': 'Earlier question'},
                {'id': 2, 'role': 'assistant', 'content': 'Earlier answer'},
              ],
            }),
            200,
          );
        }),
      ),
      testDesktopAsyncEventHook: hook,
      testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
    );
    return (screen: screen, writes: writes);
  }

  testWidgets('PROBE C1 an async error frame arms a Retry that resends the '
      'already-answered prompt and overwrites the newer draft', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final hook = TestDesktopAsyncEventHook();
    final c = classic(hook, 'probe-c1');
    await tester.pumpWidget(_app(c.screen));
    await pumpChatUpdates(tester);
    expect(find.textContaining('Earlier answer'), findsWidgets);

    // The Desktop client delivers every terminal frame (incl. `error`) on
    // the async channel too (desktop_gateway_client.dart:94-101).
    hook.handler!(
      StreamEvent(type: 'error', data: {'message': 'Upstream provider error'}),
    );
    await pumpChatUpdates(tester);
    expect(find.byType(FailureRecoveryCard), findsOneWidget);

    await tester.enterText(find.byKey(_composerKey), 'my newer unsent draft');
    await tester.pump();
    final before = c.writes.length;
    await tester.tap(find.text('Retry'));
    await pumpChatUpdates(tester);
    // ignore: avoid_print
    print(
      'C1 writes after Retry: ${c.writes.skip(before).map((r) => '${r.method} ${r.url.path}').toList()} '
      'composer="${_composer(tester)}"',
    );
    expect(
      c.writes.length,
      before,
      reason: 'Retry must not resubmit a turn the gateway already accepted',
    );
    expect(_composer(tester), 'my newer unsent draft');
  }, skip: _pendingRetry);

  testWidgets('PROBE C2 a btw.complete answer is shown in Classic', (
    tester,
  ) async {
    final hook = TestDesktopAsyncEventHook();
    final c = classic(hook, 'probe-c2');
    await tester.pumpWidget(_app(c.screen));
    await pumpChatUpdates(tester);
    hook.handler!(
      StreamEvent(
        type: 'btw.complete',
        data: {
          'task_id': 'btw_1',
          'question': 'q',
          'text': 'CLASSIC-SIDE-ANSWER',
          'session_id': 'probe-parent',
        },
      ),
    );
    await pumpChatUpdates(tester);
    expect(find.textContaining('CLASSIC-SIDE-ANSWER'), findsOneWidget);
  });

  testWidgets('PROBE C4 Classic composer offers @-reference completion and the '
      'status bar (F19/F25 in both layouts)', (tester) async {
    final hook = TestDesktopAsyncEventHook();
    final c = classic(hook, 'probe-c4');
    await tester.pumpWidget(_app(c.screen));
    await pumpChatUpdates(tester);
    await tester.enterText(find.byKey(_composerKey), 'look at @fi');
    await pumpChatUpdates(tester);
    final starters = find.text('@file:').evaluate().length;
    final status = find.text('Status').evaluate().length;
    final drop = find.byType(ComposerDropSurface).evaluate().length;
    // ignore: avoid_print
    print(
      'C4 @file: rows=$starters Status controls=$status dropSurfaces=$drop',
    );
    expect(starters, greaterThan(0), reason: '@ completion missing');
    expect(status, greaterThan(0), reason: 'status bar missing');
  }, skip: _pendingClassicParity);

  testWidgets('PROBE C3 /resume from a chat embedded in a shell route never '
      'replaces the shell', (tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previous);
    late HttpServer server;
    await tester.runAsync(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((req) async {
        final path = req.uri.path;
        req.response.headers.contentType = ContentType.json;
        if (path == '/api/sessions') {
          req.response.write(
            jsonEncode({
              'object': 'list',
              'data': [
                {
                  'id': 'other-chat',
                  'title': 'Other chat',
                  'model': 'm',
                  'message_count': 1,
                  'started_at': 1.7e9,
                  'ended_at': null,
                  'preview': 'hi',
                  'source': 'cli',
                },
              ],
              'has_more': false,
            }),
          );
        } else if (path.endsWith('/messages')) {
          req.response.write(jsonEncode({'data': []}));
        } else {
          req.response.statusCode = 404;
          req.response.write('{}');
        }
        await req.response.close();
      });
    });
    addTearDown(() async {
      await tester.runAsync(() => server.close(force: true));
    });
    final connection = SavedConnection(
      id: 'probe-c3',
      label: 'probe',
      host: '127.0.0.1',
      port: server.port,
      dashboardPortOverride: server.port,
      apiKey: 'fixture',
    );
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 120, child: Text('WORKSPACE-SHELL')),
              Expanded(
                child: ChatScreen(
                  connection: connection,
                  session: const Session(
                    id: 'embedded-chat',
                    title: 'Embedded',
                    model: 'm',
                    source: 'api_server',
                    messageCount: 0,
                    isActive: true,
                    preview: '',
                    startedAt: 1,
                  ),
                  testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)),
        );
        await tester.pump(const Duration(milliseconds: 60));
      }
    }

    await settle();
    await tester.enterText(find.byKey(_composerKey), '/resume');
    await tester.pump();
    await tester.tap(find.byTooltip('Send'));
    await settle();
    // ignore: avoid_print
    print(
      'C3 picker rows: Other chat=${find.text('Other chat').evaluate().length} '
      'unavailable=${find.text('This pane has no chat list to search.').evaluate().length}',
    );
    expect(find.text('Other chat'), findsOneWidget);
    await tester.tap(find.text('Other chat'));
    await settle();
    // ignore: avoid_print
    print(
      'C3 shell after pick: ${find.text('WORKSPACE-SHELL').evaluate().length}',
    );
    expect(find.text('WORKSPACE-SHELL'), findsOneWidget);
  }, skip: _pendingResume);
}

// Each flag goes once its review item lands (one commit per item).
const _pendingRetry = true;
const _pendingResume = true;
const _pendingClassicParity = true;
