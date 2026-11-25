import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/workspace_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/connection_mutation_barrier.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_l10n.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/more_page.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/mtls_fixture.dart';

void main() {
  for (final classic in [true, false]) {
    testWidgets(
      '${classic ? 'Classic' : 'NextGen'} More opens and refreshes this gateway roster',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(480, 1000);
        addTearDown(tester.view.reset);
        late HttpServer server;
        final sockets = <WebSocket>[];
        final rosterCalls = <Object?>[];
        var tickets = 0;
        var persona = 'Initial fixture persona';
        final soulRequests = <String>[];
        await tester.runAsync(() async {
          server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          server.listen((req) async {
            final response = req.response;
            if (req.uri.path == '/auth/password-login') {
              response.cookies.add(
                Cookie('hermes_session_at', 'fixture-cookie'),
              );
              response.write('{}');
            } else if (req.uri.path == '/api/auth/ws-ticket' &&
                req.headers.value('cookie') ==
                    'hermes_session_at=fixture-cookie') {
              tickets++;
              response.write('{"ticket":"fixture-ticket"}');
            } else if (req.uri.path == '/api/ws' &&
                !req.uri.hasQuery &&
                (req.headers.value('sec-websocket-protocol') ?? '').contains(
                  'hermes-gateway-ticket.fixture-ticket',
                )) {
              final ws = await WebSocketTransformer.upgrade(req);
              sockets.add(ws);
              ws.add(
                jsonEncode({
                  'jsonrpc': '2.0',
                  'method': 'event',
                  'params': {
                    'type': 'gateway.ready',
                    'payload': {'replay_epoch': 'fixture'},
                  },
                }),
              );
              ws.listen((raw) {
                final frame = jsonDecode(raw as String) as Map;
                final roster = frame['method'] == 'profiles.list';
                if (roster) rosterCalls.add(frame['params']);
                ws.add(
                  jsonEncode({
                    'jsonrpc': '2.0',
                    'id': frame['id'],
                    'result': roster
                        ? {
                            'install_id': 'fixture-machine',
                            'profiles': [
                              {'name': 'fixture-profile-${rosterCalls.length}'},
                              {'name': 'editor'},
                            ],
                          }
                        : <String, Object?>{},
                  }),
                );
              });
              return;
            } else if (req.uri.path == '/api/profiles/editor/soul' &&
                req.uri.queryParameters['profile'] == 'editor' &&
                req.headers.value('cookie') ==
                    'hermes_session_at=fixture-cookie') {
              soulRequests.add(req.method);
              if (req.method == 'PUT') {
                persona =
                    jsonDecode(await utf8.decoder.bind(req).join())['content']
                        as String;
                response.write('{"ok":true}');
              } else {
                response.write(
                  jsonEncode({'content': persona, 'exists': true}),
                );
              }
            } else {
              response.write('{}');
            }
            await response.close();
          });
        });
        final c = SavedConnection(
          id: 'fixture',
          label: 'Fixture gateway',
          host: '127.0.0.1',
          port: server.port,
          apiKey: '',
          dashboardPortOverride: server.port,
          desktopGatewayUrl: 'http://127.0.0.1:${server.port}',
          dashboardUsername: 'fixture',
          dashboardPassword: 'fixture',
          gatewayProfile: 'work',
        );
        NextGenGateway? ng;
        final prefs = await SharedPreferences.getInstance();
        addTearDown(() async {
          ng?.dispose();
          for (final ws in sockets) {
            await ws.close();
          }
          await server.close(force: true);
        });
        Future<void> waitForText(String text) async {
          final clock = Stopwatch()..start();
          while (find.text(text).evaluate().isEmpty &&
              clock.elapsed < const Duration(seconds: 6)) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 10)),
            );
            await tester.pump(const Duration(milliseconds: 25));
          }
          expect(find.text(text), findsWidgets);
        }

        await withPlatformTrust(() async {
          if (!classic) ng = NextGenGateway(c);
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: classic
                  ? hermesTheme(Brightness.dark)
                  : nextGenTheme(Brightness.dark, NextGenLook.instance),
              builder: (context, child) => classic
                  ? child!
                  : NgLocalizationScope(
                      child: NgScope(
                        connManager: ConnectionManager(prefs),
                        gateway: ng!,
                        connections: [c],
                        switchTo: (_) async {},
                        addGateway: () async {},
                        signOut: (_) async {},
                        reload: () async {},
                        signInAgain: () async {},
                        child: child!,
                      ),
                    ),
              home: classic
                  ? WorkspaceScreen(
                      connection: c,
                      sessionsLoader: () async => [],
                    )
                  : NgMorePage(onOpenSession: (_) {}),
            ),
          );
          await tester.pump();
          if (classic) {
            await tester.tap(find.text('More').last);
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(find.text('Profiles'));
          await tester.tap(find.text('Profiles'));
          await waitForText('fixture-profile-1');
          await tester.tap(find.byTooltip('Refresh'));
          await waitForText('fixture-profile-2');
          expect(find.text('fixture-profile-1'), findsNothing);
          await tester.tap(find.text('editor'));
          await waitForText('Edit persona');
          await tester.tap(find.text('Edit persona'));
          await waitForText('Initial fixture persona');
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Persona'),
            'Changed by the fixture',
          );
          await tester.tap(find.text('Confirm'));
          await waitForText('Persona saved.');
          expect(persona, 'Changed by the fixture');
          expect(soulRequests, ['GET', 'GET', 'PUT', 'GET']);
          final edit = ConnectionMutationBarrier.begin(['fixture']);
          edit.release();
          await waitForText('The gateway connection dropped. Try again.');
          expect(find.text('fixture-profile-2'), findsNothing);
          expect(tickets, 2);
          expect(rosterCalls, [
            for (var i = 0; i < 2; i++)
              {'include_sessions': false, 'profile': 'work'},
            {'include_sessions': false, 'profile': 'editor'},
          ]);
          await tester.pumpWidget(const SizedBox());
          ng?.dispose();
          ng = null;
          await tester.runAsync(() async {
            for (final ws in sockets) {
              await ws.close();
            }
          });
          await tester.pump(const Duration(seconds: 6));
        });
      },
    );
  }
}
