import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/projects_root_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/core/widgets/project_detail_screen.dart';
import 'package:hermes_android/core/widgets/projects_pane.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/main_page.dart';
import 'package:hermes_android/nextgen/ui/more_page.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/mtls_fixture.dart';

SavedConnection _connection({String id = 'c1', String profile = 'work'}) =>
    SavedConnection(
      id: id,
      label: profile,
      host: 'gateway.example',
      port: 443,
      apiKey: '',
      useHttps: true,
      desktopGatewayUrl: 'https://gateway.example/hermes',
      dashboardPrefix: '/hermes',
      dashboardProxied: true,
      gatewayProfile: profile,
      singleLogin: true,
      signInMethod: 'none',
    );

class _Gateway extends NextGenGateway {
  _Gateway(super.connection)
    : super(
        dashboard: DashboardClient.fromConnection(
          connection,
          httpClient: MockClient((request) async {
            expectSync(request.method, 'GET', reason: 'no settings writes');
            expectSync(request.url.path, startsWith('/hermes/api/'));
            if (request.url.path.endsWith('/messages')) {
              return http.Response(jsonEncode({'messages': []}), 200);
            }
            if (request.url.path.endsWith('/sessions')) {
              return http.Response(jsonEncode({'sessions': []}), 200);
            }
            return http.Response(jsonEncode({'model': 'test-model'}), 200);
          }),
        ),
      );

  final calls = <({String method, Map<String, dynamic> params})>[];
  final dummy = WsClient('https://gateway.example/hermes');
  Completer<void>? listGate;
  Completer<void>? treeGate;
  Completer<void>? detailGate;
  bool folderless = false;
  bool unsupported = false;
  int count = 2;

  Map<String, dynamic> get project => {
    'id': 'p1',
    'slug': 'project',
    'name': '${profile!} project',
    'primary_path': folderless ? null : '/srv/${profile!}/project',
    'folders': [],
  };

  @override
  Future<WsClient> connected({
    Duration timeout = const Duration(seconds: 20),
  }) async => dummy;

  @override
  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    calls.add((method: method, params: Map.of(params)));
    switch (method) {
      case 'projects.list':
        await listGate?.future;
        if (unsupported) {
          throw JsonRpcError(method, 'Method not found', code: -32601);
        }
        return {
          'projects': [project],
        };
      case 'projects.tree':
        final snapshot = count;
        await treeGate?.future;
        return {
          'projects': [
            {'id': 'p1', 'label': project['name'], 'sessionCount': snapshot},
          ],
        };
      case 'projects.project_sessions':
        await detailGate?.future;
        return {
          'project': {
            'id': 'p1',
            'label': project['name'],
            'sessionCount': count,
            'repos': [
              {
                'id': 'repo',
                'label': 'repo',
                'groups': [
                  {
                    'id': 'main',
                    'label': 'main',
                    'isMain': true,
                    'sessions': [
                      {
                        'id': 'stored-project-chat',
                        'title': 'Existing project conversation',
                        'source': 'cli',
                        'message_count': 2,
                        'started_at': 1750000000,
                      },
                    ],
                  },
                ],
              },
            ],
          },
        };
      case 'session.resume':
        return {'session_id': 'runtime-existing', 'running': false};
      case 'session.create':
        return {'session_id': 'runtime-new', 'stored_session_id': 'stored-new'};
      case 'prompt.submit':
        return {'status': 'started'};
      default:
        return {};
    }
  }

  int reads(String method) => calls.where((c) => c.method == method).length;
}

Future<void> _frames(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _app(
  WidgetTester tester,
  ValueNotifier<NextGenGateway> selected, {
  bool main = false,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final manager = ConnectionManager(prefs);
  await tester.pumpWidget(
    ValueListenableBuilder<NextGenGateway>(
      valueListenable: selected,
      builder: (_, gateway, _) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: nextGenTheme(Brightness.dark, NextGenLook.instance),
        builder: (_, child) => NgScope(
          connManager: manager,
          gateway: gateway,
          connections: [gateway.connection],
          switchTo: (_) async {},
          addGateway: () async {},
          signOut: (_) async {},
          reload: () async {},
          signInAgain: () async {},
          child: child!,
        ),
        home: main ? const NgMainPage() : NgMorePage(onOpenSession: (_) {}),
      ),
    ),
  );
  await _frames(tester);
}

Future<void> _browse(WidgetTester tester, {bool main = false}) async {
  if (main) {
    final chat = tester.widget<NgChatView>(find.byType(NgChatView));
    chat.onOpenSidebar();
    await _frames(tester);
    await tester.tap(find.text('More'));
    await _frames(tester);
  }
  await tester.tap(find.text('Projects'));
  await _frames(tester);
  expect(find.byType(ProjectsPane), findsOneWidget);
  expect(find.byType(ProjectsRootScreen), findsNothing);
}

Future<void> _detail(WidgetTester tester, NextGenGateway gateway) async {
  await tester.tap(find.text('${gateway.profile} project'));
  await _frames(tester);
  expect(find.byType(ProjectDetailScreen), findsOneWidget);
}

Future<void> _close(WidgetTester tester, List<_Gateway> gateways) async {
  await tester.pumpWidget(const SizedBox());
  for (final gateway in gateways) {
    gateway.dispose();
  }
  await _frames(tester);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    nextGenOpenRequest.value = null;
    nextGenNotificationAnswer.value = null;
  });

  testWidgets('More browses Classic projects and refreshes counts on return', (
    tester,
  ) async {
    final gateway = _Gateway(_connection());
    await _app(tester, ValueNotifier(gateway));
    await _browse(tester);
    expect(find.text('work project'), findsOneWidget);
    expect(find.text('2 chats'), findsOneWidget);
    expect(gateway.reads('session.create'), 0);
    expect(gateway.reads('session.resume'), 0);
    await _detail(tester, gateway);
    gateway.count = 7;
    await tester.pageBack();
    await _frames(tester);
    expect(find.text('7 chats'), findsOneWidget);
    expect(gateway.reads('projects.tree'), 2);
    await tester.pageBack();
    await _frames(tester);
    await tester.tap(find.text('Projects folder on the server'));
    await _frames(tester);
    expect(find.byType(ProjectsRootScreen), findsOneWidget);
    await _close(tester, [gateway]);
  });

  testWidgets('existing project chat uses the normal NextGen owner and route', (
    tester,
  ) async {
    final gateway = _Gateway(_connection());
    await _app(tester, ValueNotifier(gateway), main: true);
    await _browse(tester, main: true);
    await _detail(tester, gateway);
    await tester.tap(find.text('Existing project conversation'));
    await _frames(tester);
    expect(find.byType(ProjectDetailScreen), findsNothing);
    final chat = tester.widget<NgChatView>(find.byType(NgChatView)).chat;
    expect(chat.storedId, 'stored-project-chat');
    expect(chat.gateway, same(gateway));
    expect(gateway.reads('session.create'), 0);
    final resume = gateway.calls.singleWhere(
      (c) => c.method == 'session.resume',
    );
    expect(resume.params['session_id'], 'stored-project-chat');
    expect(
      NextGenPreferences.lastSession(
        await SharedPreferences.getInstance(),
        'c1',
      ),
      'stored-project-chat',
    );
    await _close(tester, [gateway]);
  });

  testWidgets('new project chat binds cwd on its first actual create', (
    tester,
  ) async {
    final gateway = _Gateway(_connection());
    await _app(tester, ValueNotifier(gateway), main: true);
    await _browse(tester, main: true);
    await _detail(tester, gateway);
    await tester.tap(find.byKey(kProjectNewChatButtonKey));
    await _frames(tester);
    final chat = tester.widget<NgChatView>(find.byType(NgChatView)).chat;
    expect(chat.isNew, isTrue);
    expect(chat.gateway, same(gateway));
    expect(chat.workingDirectory, '/srv/work/project');
    expect(gateway.reads('session.create'), 0);
    await chat.send('Project prompt');
    await _frames(tester);
    final create = gateway.calls.singleWhere(
      (c) => c.method == 'session.create',
    );
    expect(create.params['cwd'], '/srv/work/project');
    expect(gateway.reads('projects.assign_session'), 0);
    expect(gateway.reads('config.set'), 0);
    await _close(tester, [gateway]);
  });

  testWidgets('folderless project cannot replace the open draft', (
    tester,
  ) async {
    final gateway = _Gateway(_connection())..folderless = true;
    await _app(tester, ValueNotifier(gateway), main: true);
    final original = tester.widget<NgChatView>(find.byType(NgChatView)).chat;
    await tester.enterText(find.byType(TextField).last, 'Unsent draft');
    await _browse(tester, main: true);
    await _detail(tester, gateway);
    await tester.tap(find.byKey(kProjectNewChatButtonKey));
    await _frames(tester);
    expect(find.textContaining('This Project needs a folder'), findsOneWidget);
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(gateway.reads('session.create'), 0);
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.popUntil((route) => route.isFirst);
    await _frames(tester);
    expect(
      tester.widget<NgChatView>(find.byType(NgChatView)).chat,
      same(original),
    );
    expect(find.text('Unsent draft'), findsOneWidget);
    await _close(tester, [gateway]);
  });

  testWidgets('normal New chat clears Project cwd without creating a session', (
    tester,
  ) async {
    final gateway = _Gateway(_connection());
    await _app(tester, ValueNotifier(gateway), main: true);
    await _browse(tester, main: true);
    await _detail(tester, gateway);
    await tester.tap(find.byKey(kProjectNewChatButtonKey));
    await _frames(tester);
    var view = tester.widget<NgChatView>(find.byType(NgChatView));
    expect(view.chat.workingDirectory, '/srv/work/project');
    view.onNewChat();
    await _frames(tester);
    view = tester.widget<NgChatView>(find.byType(NgChatView));
    expect(view.chat.workingDirectory, isNull);
    expect(gateway.reads('session.create'), 0);
    await _close(tester, [gateway]);
  });

  testWidgets(
    'leaving Projects during a held read cannot publish after disposal',
    (tester) async {
      final gateway = _Gateway(_connection())..detailGate = Completer<void>();
      await _app(tester, ValueNotifier(gateway));
      await _browse(tester);
      await _detail(tester, gateway);
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.popUntil((route) => route.isFirst);
      await _frames(tester);
      gateway.detailGate!.complete();
      await _frames(tester);
      expect(find.byType(ProjectDetailScreen), findsNothing);
      expect(gateway.reads('session.resume'), 0);
      expect(tester.takeException(), isNull);
      await _close(tester, [gateway]);
    },
  );

  testWidgets('profile cache is hidden while the replacement list waits', (
    tester,
  ) async {
    final old = _Gateway(_connection(profile: 'old'));
    final next = _Gateway(_connection(profile: 'next'))
      ..listGate = Completer<void>();
    final selected = ValueNotifier<NextGenGateway>(old);
    await _app(tester, selected);
    await _browse(tester);
    expect(find.text('old project'), findsOneWidget);
    selected.value = next;
    await _frames(tester);
    expect(find.text('old project'), findsNothing);
    expect(find.text('next project'), findsNothing);
    next.listGate!.complete();
    await _frames(tester);
    expect(find.text('next project'), findsOneWidget);
    await _close(tester, [old, next]);
  });

  for (final held in [
    'projects.list',
    'projects.tree',
    'projects.project_sessions',
  ]) {
    for (final differentConnection in [false, true]) {
      testWidgets(
        'scope switch fences held $held (${differentConnection ? 'connection' : 'profile'})',
        (tester) async {
          final gate = Completer<void>();
          final old = _Gateway(_connection(profile: 'old'));
          final next = _Gateway(
            _connection(id: differentConnection ? 'c2' : 'c1', profile: 'next'),
          );
          if (held == 'projects.list') old.listGate = gate;
          if (held == 'projects.tree') old.treeGate = gate;
          if (held == 'projects.project_sessions') old.detailGate = gate;
          final selected = ValueNotifier<NextGenGateway>(old);
          await _app(tester, selected);
          await _browse(tester);
          if (held == 'projects.project_sessions') await _detail(tester, old);
          expect(old.reads(held), 1);
          selected.value = next;
          await _frames(tester);
          expect(find.text('old project'), findsNothing);
          expect(find.text('next project'), findsOneWidget);
          gate.complete();
          await _frames(tester);
          expect(find.text('old project'), findsNothing);
          expect(find.text('next project'), findsOneWidget);
          expect(tester.takeException(), isNull);
          // Reopen: no profile-A disk cache can masquerade as profile B content.
          await tester.pageBack();
          await _frames(tester);
          next.listGate = Completer<void>();
          await _browse(tester);
          expect(find.text('old project'), findsNothing);
          expect(find.text('next project'), findsOneWidget);
          next.listGate!.complete();
          await _frames(tester);
          await _close(tester, [old, next]);
        },
      );
    }
  }

  testWidgets(
    'Projects reuses selected authenticated prefix/profile/mTLS socket',
    (tester) async {
      final fixture = MutualTlsFixture();
      var logins = 0;
      var tickets = 0;
      await tester.runAsync(() async {
        await fixture.start((request) async {
          final path = request.uri.path;
          if (path == '/hermes/auth/password-login') {
            logins++;
            request.response.headers.add(
              'set-cookie',
              'hermes_session_at=fixture-cookie; Path=/',
            );
            fixture.json(request, {'ok': true});
          } else if (path == '/hermes/api/ws') {
            // The ticket, not a cookie or API-server key, authenticates this hop.
            expect(
              request.headers.value('sec-websocket-protocol'),
              contains('fixture-ticket'),
            );
            final socket = await WebSocketTransformer.upgrade(request);
            fixture.sockets.add(socket);
            socket.add(
              jsonEncode({
                'jsonrpc': '2.0',
                'method': 'event',
                'params': {'type': 'gateway.ready', 'payload': {}},
              }),
            );
            socket.listen((raw) {
              final frame = jsonDecode(raw as String) as Map<String, dynamic>;
              fixture.rpcRequests.add(frame);
              final result = switch (frame['method']) {
                'projects.list' => {
                  'projects': [
                    {
                      'id': 'p1',
                      'slug': 'project',
                      'name': 'work project',
                      'primary_path': '/srv/work/project',
                      'folders': [],
                    },
                  ],
                },
                'projects.tree' => {
                  'projects': [
                    {'id': 'p1', 'label': 'work project', 'sessionCount': 5},
                  ],
                },
                'projects.project_sessions' => {
                  'project': {
                    'id': 'p1',
                    'label': 'work project',
                    'sessionCount': 5,
                    'repos': [],
                  },
                },
                _ => <String, dynamic>{},
              };
              socket.add(
                jsonEncode({
                  'jsonrpc': '2.0',
                  'id': frame['id'],
                  'result': result,
                }),
              );
            });
            return;
          } else {
            expect(path, '/hermes/api/auth/ws-ticket');
            expect(
              request.headers.value('cookie'),
              contains('hermes_session_at=fixture-cookie'),
            );
            tickets++;
            expect(request.method, 'POST');
            fixture.json(request, {'ticket': 'fixture-ticket'});
          }
          await request.response.close();
        });
      });
      final connection = _connection().copyWith(
        host: '127.0.0.1',
        port: fixture.server.port,
        desktopGatewayUrl: '${fixture.origin}/hermes',
        dashboardProxied: false,
        dashboardUsername: 'fixture-user',
        dashboardPassword: 'fixture-password',
        clientCertificate: loopbackIdentity,
      );
      late NextGenGateway gateway;
      var closed = false;
      Future<void> close() async {
        if (closed) return;
        closed = true;
        gateway.dispose();
        await fixture.close();
      }

      addTearDown(close);
      await tester.runAsync(
        () => withLoopbackTrust(() async {
          gateway = NextGenGateway(connection);
          await gateway.connected();
        }),
      );
      await _app(tester, ValueNotifier(gateway));
      await _browse(tester);
      Future<void> waitFor(String method) async {
        for (var i = 0; i < 100; i++) {
          await _frames(tester);
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)),
          );
          if (fixture.rpcRequests.any((r) => r['method'] == method)) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)),
            );
            await _frames(tester);
            return;
          }
        }
        fail('No $method request');
      }

      await waitFor('projects.tree');
      expect(find.text('work project'), findsOneWidget);
      expect(find.text('5 chats'), findsOneWidget);
      await _detail(tester, gateway);
      await waitFor('projects.project_sessions');
      expect(logins, 1);
      expect(tickets, 1, reason: 'Projects must reuse the main gateway socket');
      expect(fixture.anonymousRequests, 0);
      final methods = fixture.rpcRequests
          .where((r) => (r['method'] as String).startsWith('projects.'))
          .toList();
      expect(
        methods.map((r) => r['method']),
        containsAll([
          'projects.list',
          'projects.tree',
          'projects.project_sessions',
        ]),
      );
      for (final call in methods) {
        expect((call['params'] as Map)['profile'], 'work');
      }
      expect(
        fixture.rpcRequests.where(
          (r) => (r['method'] as String).startsWith('session.'),
        ),
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(close);
      await _frames(tester);
    },
  );

  testWidgets(
    'unsupported Projects stays separate from server folder settings',
    (tester) async {
      final gateway = _Gateway(_connection())..unsupported = true;
      await _app(tester, ValueNotifier(gateway));
      await _browse(tester);
      expect(
        find.textContaining('Update Hermes', findRichText: true),
        findsWidgets,
      );
      expect(find.byType(ProjectsRootScreen), findsNothing);
      await _close(tester, [gateway]);
    },
  );
}
