import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/bots_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
    'bots roster renders once loaded; rooms show a list; routines render; relay sends and reports a settled delivery',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final api = _BotsFixtureApi();
      final owner = _makeOwner(
        api.client,
        connectionId: 'c-bots',
        profile: 'work',
        api: api,
      );
      addTearDown(owner.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BotsScreen(
            owner: owner,
            route: owner.route(),
            connection: _fixtureConnection,
          ),
        ),
      );

      // Roster renders the two fixture bots.
      await _shown(tester, find.text('WorkBot'));
      expect(find.text('WorkBot'), findsOneWidget);
      expect(find.text('ResearchBot'), findsOneWidget);

      // Switch to Rooms.
      await tester.tap(find.text('Rooms'));
      await _shown(tester, find.text('Ops Room'));
      expect(find.text('Gateway rooms'), findsOneWidget);
      expect(find.textContaining('2 member'), findsOneWidget);

      // Switch to Routines.
      await tester.tap(find.text('Routines'));
      await _shown(tester, find.text('Stand-up'));
      expect(find.text('Stand-up'), findsOneWidget);

      // Switch to Relay and send a message through the wire.
      await tester.tap(find.text('Relay'));
      await _shown(
        tester,
        find.textContaining('Message to the target bot'),
      );
      await tester.enterText(
        find.byType(TextField),
        'Please summarize the room',
      );
      final sendFinder = find.byType(ElevatedButton);
      debugPrint('send finder: ${sendFinder.evaluate().length}');
      final btn = tester.widget<ElevatedButton>(sendFinder.last);
      debugPrint('onPressed null? ${btn.onPressed == null}');
      debugPrint('ctrl text len: ${tester.widget<TextField>(find.byType(TextField)).controller?.text.length}');
      await tester.ensureVisible(sendFinder.last);
      await _step(tester);
      await tester.tap(sendFinder.last, warnIfMissed: true);
      await _step(tester);
      debugPrint('AFTER SEND: calls=${api.calls.map((c) => c.method).join(",")}');
      debugPrint('SCREEN TEXT: ${find.byType(Text).evaluate().map((w) => (w.widget as Text).data).where((d) => d != null && d.isNotEmpty).join(" | ")}');
      await _shown(tester, find.textContaining('Delivery: settled'));

      final relayCall = api.calls.singleWhere(
        (c) => c.method == 'bot_relay.deliver',
      );
      expect(relayCall.params['profile'], 'workbot');
      expect(relayCall.params['message'], 'Please summarize the room');
      expect(relayCall.params['from_connection'], 'c-bots');
      expect(relayCall.params['from_profile'], isNotNull);
      expect(relayCall.params['from_handle'], isNotNull);
    },
  );

  testWidgets(
    'screen tab starts the display, takes over via an observe lease, then hands back',
    (tester) async {
      tester.view.physicalSize = const Size(900, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final api = _BotsFixtureApi();
      final owner = _makeOwner(
        api.client,
        connectionId: 'c-bots',
        profile: 'work',
        api: api,
      );
      addTearDown(owner.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BotsScreen(
            owner: owner,
            route: owner.route(),
            connection: _fixtureConnection,
          ),
        ),
      );
      await _shown(tester, find.text('WorkBot'));

      // Switch to Screen.
      await tester.tap(find.text('Screen'));
      await _shown(tester, find.text('Running'));
      await _step(tester);

      // Take over: observe mints viewer id, then the lease acquire.
      await tester.tap(find.text('Take over'));
      await _step(tester);
      expect(
        api.calls.any((c) => c.method == 'display.observe'),
        isTrue,
      );
      expect(
        api.calls.any((c) => c.method == 'display.lease.acquire'),
        isTrue,
      );

      // Hand back: viewerId is carried, so the release carries it.
      await _shown(tester, find.text('Hand back'));
      await tester.tap(find.text('Hand back'));
      await _step(tester);
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

      final api = _BotsFixtureApi();
      final owner = _makeOwner(
        api.client,
        connectionId: 'c-bots',
        profile: 'work',
        api: api,
      );
      addTearDown(owner.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BotsScreen(
            owner: owner,
            route: owner.route(),
            connection: _fixtureConnection,
          ),
        ),
      );
      await _shown(tester, find.text('WorkBot'));

      await tester.tap(find.text('Rooms'));
      await _shown(tester, find.text('Ops Room'));
      await tester.tap(find.textContaining('Create room'));
      await _shown(tester, find.text('Room name'));
      await tester.enterText(find.byType(TextField), 'QA Room');
      final workChip = find.text('WorkBot').last;
      await tester.ensureVisible(workChip);
      await tester.tap(workChip);
      final researchChip = find.text('ResearchBot').last;
      await tester.ensureVisible(researchChip);
      await tester.tap(researchChip);
      final createBtn = find.byType(FilledButton);
      debugPrint('create btn found: ${createBtn.evaluate().length}');
      final btn = tester.widget<FilledButton>(createBtn.last);
      debugPrint('create onPressed null? ${btn.onPressed == null}');
      await tester.ensureVisible(createBtn.last);
      await _step(tester);
      await tester.tap(createBtn.last, warnIfMissed: true);
      await _step(tester);
      debugPrint('create calls: ${api.calls.map((c) => c.method).join(",")}');

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

Future<void> _shown(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

Future<void> _step(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

final _fixtureConnection = SavedConnection(
  id: 'c-bots',
  label: 'Disposable Bots Host',
  host: '127.0.0.1',
  port: 9,
  apiKey: 'fixture-only',
  dashboardUsername: 'fixture',
  dashboardPassword: 'fixture-password',
  desktopGatewayUrl: 'http://127.0.0.1:9',
  gatewayProfile: 'work',
);

RemoteWorkspaceOwner _makeOwner(
  http.Client client, {
  required String connectionId,
  required String profile,
  required _BotsFixtureApi api,
}) {
  final dashboard = DashboardClient(
    host: '127.0.0.1',
    port: 9,
    username: 'fixture',
    password: 'fixture-password',
    gatewayProfile: profile,
    httpClient: client,
  );
  return RemoteWorkspaceOwner(
    connectionId: connectionId,
    expectedBaseUrl: dashboard.baseUrl,
    profile: profile,
    dashboard: dashboard,
    connect: () async => _BotsFixtureSocket(dashboard.baseUrl, api),
    ownsSocket: (_) => true,
  );
}

class _BotsFixtureSocket extends Fake implements WsClient {
  _BotsFixtureSocket(this.baseUrl, this.api);
  @override
  final String baseUrl;
  final _BotsFixtureApi api;
  @override
  int get socketEpoch => 1;
  @override
  bool get isConnected => true;
  @override
  Future<Map<String, dynamic>> waitForGatewayReady({
    Duration timeout = const Duration(seconds: 15),
  }) async => {};
  @override
  Future<Map<String, dynamic>> send(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
    void Function()? onSent,
    bool includeProfile = true,
  }) async {
    api.calls.add(_RecordedCall(method, Map<String, dynamic>.from(params)));
    return _BotsFixtureApi.respond(method, params);
  }
}

class _RecordedCall {
  _RecordedCall(this.method, this.params);
  final String method;
  final Map<String, dynamic> params;
}

class _BotsFixtureApi {
  _BotsFixtureApi() {
    client = MockClient((request) async => http.Response('{}', 200));
  }

  late final MockClient client;
  final calls = <_RecordedCall>[];

  /// Returns a plausible canned result for [method].
  static Map<String, dynamic> respond(
    String method,
    Map<String, dynamic> params,
  ) {
    switch (method) {
      case 'profiles.list':
        return {
          'result': {
            'profiles': [
              {
                'name': 'workbot',
                'path': '/home/bots/workbot',
                'is_default': false,
                'model': 'claude-sonnet',
                'provider': 'anthropic',
                'description': 'Primary worker bot',
                'display_name': 'WorkBot',
                'skill_count': 4,
                'has_avatar': true,
                'canonical_session': {'id': 'sess-canonical-workbot'},
                'last_session': {'preview': 'last coding turn'},
              },
              {
                'name': 'researchbot',
                'path': '/home/bots/researchbot',
                'is_default': false,
                'model': 'gpt-5',
                'provider': 'openrouter',
                'description': 'Research bot',
                'display_name': 'ResearchBot',
                'skill_count': 2,
              },
            ],
            'bot_mode_protocol': true,
            'install_id': 'fixture-install-1',
          }
        };
      case 'session.list':
        return {
          'result': {
            'sessions': [
              {'id': 'sess-canonical-workbot', 'title': 'Bot Chat'},
            ],
          }
        };
      case 'groups.capabilities':
        return {
          'result': {
            'protocol_version': 2,
            'driver': true,
            'persistent_process': true,
            'authority_gateway_id': 'fixture-gateway',
            'room_link': {'viewer_id': 'fixture-view'},
            'features': ['send', 'rename', 'context', 'stop'],
            'methods': [
              'groups.list',
              'groups.create',
              'groups.state',
              'groups.send',
              'groups.log',
              'groups.stop',
            ],
            'max_log_limit': 500,
            'seatable_profiles': ['workbot', 'researchbot'],
          }
        };
      case 'groups.list':
        return {
          'result': {
            'rooms': [
              {
                'room_id': 'room-ops',
                'name': 'Ops Room',
                'members': [
                  {
                    'member_id': 'workbot',
                    'profile': 'workbot',
                    'handle': 'workbot',
                  },
                  {
                    'member_id': 'researchbot',
                    'profile': 'researchbot',
                    'handle': 'researchbot',
                  },
                ],
                'revision': 3,
              },
            ],
            'next_offset': null,
          }
        };
      case 'groups.state':
        return {
          'result': {
            'room': {
              'room_id': 'room-ops',
              'name': 'Ops Room',
              'members': [
                {
                  'member_id': 'workbot',
                  'profile': 'workbot',
                  'handle': 'workbot',
                },
                {
                  'member_id': 'researchbot',
                  'profile': 'researchbot',
                  'handle': 'researchbot',
                },
              ],
              'revision': 3,
            },
            'driver_status': {
              'running': true,
              'working': true,
              'counts': {'active': 2},
            },
            'context': {
              'purpose': 'Ship v5',
              'routing': 'everyone',
            },
          }
        };
      case 'groups.create':
        return {
          'result': {
            'room': {
              'room_id': params['room_id'],
              'name': params['name'],
              'members': params['members'],
              'revision': 1,
            }
          }
        };
      case 'groups.log':
        return {
          'result': {
            'events': [
              {'seq': 1, 'event_id': 'ev-1', 'kind': 'message', 'actor': 'workbot'},
            ],
            'cursor': 1,
            'latest_seq': 1,
            'has_more': false,
          }
        };
      case 'groups.send':
        return {
          'result': {'client_event_id': 'evt-1', 'accepted': true}
        };
      case 'cron.manage':
        final action = params['action'] as String? ?? 'list';
        if (action == 'list') {
          return {
            'result': {
              'jobs': [
                {
                  'job_id': 'job-standup',
                  'name': '[bot:workbot] Stand-up',
                  'schedule': '0 9 * * 1-5',
                  'enabled': true,
                  'last_status': 'ok',
                },
              ],
              'scoped': 'profile:workbot',
            }
          };
        }
        return {'result': {'ok': true}};
      case 'display.status':
        return {
          'result': {
            'profile': params['profile'] ?? 'workbot',
            'supported': true,
            'installed': true,
            'missing': const <String>[],
            'running': true,
            'pid': 4242,
            'geometry': '1280x800',
            'placement': 'gateway',
            'lease': {'holder': 'agent', 'since': 1, 'epoch': 1, 'reason': ''},
          }
        };
      case 'display.start':
        return {
          'result': {
            'profile': params['profile'] ?? 'workbot',
            'supported': true,
            'installed': true,
            'missing': const <String>[],
            'running': true,
            'pid': 4242,
            'geometry': '1280x800',
            'placement': 'gateway',
            'lease': {'holder': 'agent', 'since': 1, 'epoch': 1, 'reason': ''},
          }
        };
      case 'display.stop':
        return {
          'result': {
            'profile': params['profile'] ?? 'workbot',
            'supported': true,
            'installed': true,
            'missing': const <String>[],
            'running': false,
            'lease': {'holder': 'agent', 'since': 1, 'epoch': 2, 'reason': ''},
          }
        };
      case 'display.observe':
        return {
          'result': {
            'profile': params['profile'] ?? 'workbot',
            'supported': true,
            'installed': true,
            'missing': const <String>[],
            'running': true,
            'pid': 4242,
            'geometry': '1280x800',
            'placement': 'gateway',
            'lease': {'holder': 'agent', 'since': 1, 'epoch': 1, 'reason': ''},
            'ticket': 'ticket-fixture',
            'path': '/api/display/ws',
            'viewer_id': 'viewer-fixture-1',
          }
        };
      case 'display.thumbnail':
        return {'result': {'data_url': null, 'suppressed': null}};
      case 'display.lease.acquire':
        return {
          'result': {
            'lease': {
              'holder': 'human',
              'viewer_hash': 'hash-fixture',
              'since': 2,
              'epoch': 3,
              'reason': params['reason'] ?? '',
            }
          }
        };
      case 'display.lease.release':
        return {
          'result': {
            'lease': {
              'holder': 'agent',
              'since': 3,
              'epoch': 4,
              'reason': '',
            }
          }
        };
      case 'display.install':
        return {
          'result': {
            'started': true,
            'command': 'fake install',
            'profile_key': 'fixture',
          }
        };
      case 'display.switchSandboxImage':
        return {
          'result': {
            'profile': params['profile'] ?? 'workbot',
            'supported': true,
            'installed': true,
            'missing': const <String>[],
            'running': true,
            'lease': {'holder': 'agent', 'since': 1, 'epoch': 1, 'reason': ''},
            'image_switch': null,
          }
        };
      case 'bot_relay.deliver':
        return {
          'result': {
            'status': 'settled',
            'delivery_id': 'delivery-1',
            'admission_id': null,
            'refused': false,
            'reply': 'Summary reply',
          }
        };
      default:
        return {'result': {'ok': true}};
    }
  }
}
