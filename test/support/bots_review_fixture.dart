import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/bots_screen.dart';
import 'package:hermes_android/core/services/bot_desktop_session.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Waits (real and fake time) until [finder] matches, then asserts it does.
Future<void> botsShown(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 60 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

/// Lets queued gateway replies and their rebuilds land.
Future<void> botsStep(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

final botsReviewConnection = SavedConnection(
  id: 'c-bots',
  label: 'Review Bots Host',
  host: '127.0.0.1',
  port: 9,
  apiKey: 'fixture-key',
  dashboardUsername: 'fixture',
  dashboardPassword: 'fixture-password',
  desktopGatewayUrl: 'http://127.0.0.1:9',
  gatewayProfile: 'work',
);

class BotsReviewCall {
  BotsReviewCall(this.method, this.params);
  final String method;
  final Map<String, dynamic> params;

  @override
  String toString() => '$method $params';
}

/// A gateway that answers the Bot Mode RPCs the way `tui_gateway` does at
/// b7ee21c14e, and REFUSES what the real one refuses: a call with a missing
/// or malformed param fails here too, so a test cannot pass against a wire
/// shape the gateway would reject. An unknown method is method-not-found.
class BotsReviewGateway {
  final calls = <BotsReviewCall>[];

  /// Every call this gateway refused, with its reply.
  final refusals = <String>[];

  /// `method:profile:action` to a completer the reply waits on.
  final holds = <String, Completer<void>>{};

  /// Merged into every display status (e.g. a pending `image_switch`).
  Map<String, dynamic>? displayOverride;

  /// Profiles whose host has the screen packages / a running screen.
  final installed = <String>{'workbot'};
  final running = <String>{'workbot'};

  /// What `display.thumbnail` returns while the agent holds the screen.
  String? thumbnailDataUrl;

  /// Per-profile cron stores, rows as `cron/job_args.py::_format_job`.
  final jobs = <String, List<Map<String, dynamic>>>{
    'workbot': [
      {
        'job_id': 'job-standup',
        'name': '[bot:workbot] Stand-up',
        'prompt_preview': 'Post the stand-up summary',
        'schedule': '0 9 * * 1-5',
        'repeat': 'forever',
        'deliver': 'local',
        'enabled': true,
        'state': 'scheduled',
        'last_status': 'ok',
      },
    ],
    'researchbot': [],
  };

  /// Viewer ids `display.observe` minted on this connection.
  final minted = <String>{};
  final _leases = <String, Map<String, dynamic>>{};
  var _viewerSeq = 0;
  var _jobSeq = 0;

  Iterable<BotsReviewCall> named(String method) =>
      calls.where((c) => c.method == method);

  /// The lease the gateway holds for [profile] right now.
  Map<String, dynamic> leaseOf(String profile) =>
      _leases[profile] ??
      {
        'holder': 'agent',
        'viewer_hash': null,
        'since': 1,
        'epoch': 1,
        'reason': '',
      };

  String? leaseViewer(String profile) =>
      _leases[profile]?['_viewer_id'] as String?;

  Map<String, dynamic> _publicLease(String profile) =>
      Map<String, dynamic>.from(leaseOf(profile))..remove('_viewer_id');

  void _setLease(String profile, String holder, {String? viewer, String? why}) {
    final epoch = (leaseOf(profile)['epoch'] as int) + 1;
    _leases[profile] = {
      'holder': holder,
      'viewer_hash': viewer == null ? null : botDisplayViewerHash(viewer),
      '_viewer_id': viewer,
      'since': epoch,
      'epoch': epoch,
      'reason': why ?? '',
    };
  }

  Future<Map<String, dynamic>> handle(
    String method,
    Map<String, dynamic> params,
  ) async {
    calls.add(BotsReviewCall(method, Map<String, dynamic>.from(params)));
    final key = '$method:${params['profile']}:${params['action'] ?? ''}';
    final hold = holds[key];
    if (hold != null) await hold.future;
    final reply = _respond(method, params);
    if (reply['error'] != null) refusals.add('$method $params -> $reply');
    return reply;
  }

  static Map<String, dynamic> _error(
    int code,
    String message, {
    Map<String, dynamic>? data,
  }) => {
    'error': {'code': code, 'message': message, 'data': ?data},
  };

  static Map<String, dynamic> _ok(Map<String, dynamic> result) => {
    'result': result,
  };

  /// Pydantic `Params` models are closed: an unknown key is invalid params.
  static Map<String, dynamic>? _closed(
    Map<String, dynamic> params,
    Set<String> allowed,
  ) {
    final extra = params.keys.where((k) => !allowed.contains(k)).toList();
    return extra.isEmpty ? null : _error(-32602, 'invalid params: $extra');
  }

  Map<String, dynamic> _status(String profile) => {
    'profile': profile,
    'profile_key': 'key-$profile',
    'supported': true,
    'installed': installed.contains(profile),
    'missing': installed.contains(profile) ? const <String>[] : ['xvnc'],
    'running': running.contains(profile),
    'pid': running.contains(profile) ? 4242 : null,
    'geometry': '1280x800',
    'placement': 'gateway',
    'lease': _publicLease(profile),
    ...?displayOverride,
  };

  static String repeatDisplay(String schedule, int? repeat) {
    final recurring =
        schedule.startsWith('every ') || schedule.trim().contains(' ');
    final times = repeat ?? (recurring ? null : 1);
    if (times == null) return 'forever';
    return times == 1 ? 'once' : '$times times';
  }

  Map<String, dynamic> _respond(String method, Map<String, dynamic> p) {
    final profile = p['profile'] is String ? p['profile'] as String : 'workbot';
    switch (method) {
      case 'profiles.list':
        return _ok({
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
        });
      case 'session.list':
        return _ok({
          'sessions': [
            if (profile == 'workbot')
              {'id': 'sess-canonical-workbot', 'title': 'Bot Chat'},
          ],
        });
      case 'session.create':
        return _ok({
          'session_id': 'runtime-$profile',
          'stored_session_id': 'sess-canonical-$profile',
        });
      case 'session.title':
        return _ok({'ok': true});
      case 'groups.capabilities':
        return _ok({
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
        });
      case 'groups.list':
        return _ok({
          'rooms': [_room('room-ops', 'Ops Room')],
          'next_offset': null,
        });
      case 'groups.state':
        return _ok({
          'room': _room('room-ops', 'Ops Room'),
          'driver_status': {
            'running': true,
            'working': true,
            'counts': {'active': 2},
          },
          'context': {'purpose': 'Ship v5', 'routing': 'everyone'},
        });
      case 'groups.create':
        if (p['room_id'] is! String || p['name'] is! String) {
          return _error(-32602, 'invalid params');
        }
        return _ok({
          'room': {
            'room_id': p['room_id'],
            'name': p['name'],
            'members': p['members'],
            'revision': 1,
          },
        });
      case 'groups.log':
        return _ok({
          'events': [
            {
              'seq': 1,
              'event_id': 'ev-1',
              'kind': 'message',
              'actor': 'workbot',
            },
          ],
          'cursor': 1,
          'latest_seq': 1,
          'has_more': false,
        });
      case 'groups.send':
        return _ok({'client_event_id': 'evt-1', 'accepted': true});
      case 'groups.stop':
        return _ok({'cancelled': 0});
      case 'cron.manage':
        return _cron(profile, p);
      case 'display.status':
        return _ok(_status(profile));
      case 'display.start':
        if (!installed.contains(profile)) {
          return _error(5031, 'Bot Desktop is not installed on this host');
        }
        running.add(profile);
        return _ok(_status(profile));
      case 'display.stop':
        // methods_display.py: refused while a human holds unless `force`.
        if (leaseOf(profile)['holder'] == 'human' && p['force'] != true) {
          return _error(
            5031,
            'a human holds this screen; pass force: true to stop it anyway',
            data: {'code': 'viewer_mismatch'},
          );
        }
        _setLease(profile, 'agent');
        running.remove(profile);
        return _ok({..._status(profile), 'stopped': true});
      case 'display.observe':
        if (!running.contains(profile)) {
          return _error(
            5031,
            "this profile's Bot Desktop is not running; "
            'call display.start first',
          );
        }
        final asked = p['viewer_id'];
        final viewer = asked is String && minted.contains(asked)
            ? asked
            : 'viewer-${++_viewerSeq}';
        minted.add(viewer);
        return _ok({
          'ticket': 'ticket-$viewer',
          'path': '/api/display/ws',
          'viewer_id': viewer,
          ..._status(profile),
        });
      case 'display.thumbnail':
        return _ok(
          leaseOf(profile)['holder'] == 'human'
              ? {'data_url': null, 'suppressed': 'human_has_control'}
              : {
                  'data_url': running.contains(profile)
                      ? thumbnailDataUrl
                      : null,
                },
        );
      case 'display.lease.acquire':
        final viewer = p['viewer_id'];
        if (viewer is! String || viewer.trim().isEmpty) {
          return _error(5031, 'viewer_id required');
        }
        if (!minted.contains(viewer)) return _foreignViewer();
        _setLease(
          profile,
          'human',
          viewer: viewer,
          why: p['reason'] as String?,
        );
        return _ok({'lease': _publicLease(profile)});
      case 'display.lease.release':
        final viewer = p['viewer_id'] is String
            ? p['viewer_id'] as String
            : null;
        final force = p['force'] == true;
        if (viewer != null && !force && !minted.contains(viewer)) {
          return _foreignViewer();
        }
        final lease = leaseOf(profile);
        if (lease['holder'] == 'human') {
          if (viewer == null && !force) {
            return _error(
              5031,
              "viewer_id required to release another viewer's lease "
              '(or pass force: true)',
              data: {'code': 'viewer_mismatch'},
            );
          }
          // lease.release(viewer): only the holder (or force) hands back.
          if (force || lease['_viewer_id'] == viewer) {
            _setLease(profile, 'agent');
          }
        }
        return _ok({'lease': _publicLease(profile)});
      case 'display.install':
        if (installed.contains(profile)) {
          return _error(5031, 'already installed');
        }
        return _ok({
          'started': true,
          'command': 'sudo apt-get install -y tigervnc-standalone-server',
          'profile_key': 'key-$profile',
        });
      case 'display.switchSandboxImage':
        if (displayOverride?['image_switch'] == null) {
          return _error(
            5031,
            'no sandbox image switch is pending for this profile',
          );
        }
        final target =
            (displayOverride!['image_switch'] as Map)[p['approve'] == false
                ? 'current_image'
                : 'target_image'];
        displayOverride = {...displayOverride!}..remove('image_switch');
        return _ok({'docker_image': target, ..._status(profile)});
      case 'bot_relay.deliver':
        // tools/bot_live_delivery.py `_delivery_id`: 32-64 lowercase hex.
        final id = p['id'];
        if (id is! String || !RegExp(r'^[0-9a-f]{32,64}$').hasMatch(id)) {
          return _error(
            4090,
            'invalid_params',
            data: {'reason': 'invalid_params'},
          );
        }
        return _ok({'status': 'settled', 'reply': 'ok'});
      default:
        return _error(-32601, 'method not found: $method');
    }
  }

  static Map<String, dynamic> _foreignViewer() => _error(
    5031,
    'viewer_id was not minted for this connection; call display.observe first',
    data: {'code': 'viewer_mismatch'},
  );

  static Map<String, dynamic> _room(String id, String name) => {
    'room_id': id,
    'name': name,
    'members': [
      {'member_id': 'workbot', 'profile': 'workbot', 'handle': 'workbot'},
      {
        'member_id': 'researchbot',
        'profile': 'researchbot',
        'handle': 'researchbot',
      },
    ],
    'revision': 3,
  };

  /// `tui_gateway/methods_tools.py` cron.manage with `CronManageParams`.
  Map<String, dynamic> _cron(String profile, Map<String, dynamic> p) {
    final refused = _closed(p, const {
      'action',
      'name',
      'include_disabled',
      'schedule',
      'prompt',
      'repeat',
      'continuity',
      'deliver',
      'profile',
    });
    if (refused != null) return refused;
    final store = jobs.putIfAbsent(profile, () => []);
    final action = p['action'] as String? ?? 'list';
    final name = p['name'];
    switch (action) {
      case 'list':
        return _ok({
          'jobs': [
            for (final job in store)
              if (p['include_disabled'] == true || job['enabled'] != false)
                Map<String, dynamic>.from(job),
          ],
          'scoped': ?(p['profile'] as String?),
        });
      case 'add':
        final schedule = p['schedule'];
        final prompt = p['prompt'];
        if (name is! String ||
            name.trim().isEmpty ||
            schedule is! String ||
            schedule.trim().isEmpty ||
            prompt is! String ||
            prompt.trim().isEmpty) {
          return _error(5023, 'name, schedule and prompt are required');
        }
        final rawRepeat = p['repeat'];
        if (rawRepeat != null && (rawRepeat is! int || rawRepeat < 1)) {
          return _error(-32602, 'repeat must be a positive run count');
        }
        final row = {
          'job_id': 'job-${++_jobSeq}',
          'name': name,
          'prompt_preview': prompt,
          'schedule': schedule,
          'repeat': repeatDisplay(schedule, rawRepeat as int?),
          'deliver': p['deliver'] ?? 'local',
          'continuity': p['continuity'] == true,
          'enabled': true,
          'state': 'scheduled',
        };
        store.add(row);
        return _ok({
          'success': true,
          'job_id': row['job_id'],
          'name': name,
          'schedule': schedule,
          'repeat': row['repeat'],
        });
      case 'pause':
      case 'resume':
      case 'remove':
        final job = store.where((j) => j['job_id'] == name).firstOrNull;
        if (job == null) return _error(5023, 'job not found: $name');
        if (action == 'remove') {
          store.remove(job);
        } else {
          job['enabled'] = action == 'resume';
          job['state'] = action == 'resume' ? 'scheduled' : 'paused';
        }
        return _ok({'success': true, 'job_id': name});
      default:
        return _error(4016, 'unknown cron action: $action');
    }
  }
}

class BotsReviewSocket extends Fake implements WsClient {
  BotsReviewSocket(this.baseUrl, this.gateway);
  @override
  final String baseUrl;
  final BotsReviewGateway gateway;
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
  }) => gateway.handle(method, params);
}

RemoteWorkspaceOwner botsReviewOwner(BotsReviewGateway gateway) {
  final dashboard = DashboardClient(
    host: '127.0.0.1',
    port: 9,
    username: 'fixture',
    password: 'fixture-password',
    gatewayProfile: 'work',
    httpClient: MockClient((_) async => http.Response('{}', 200)),
  );
  final socket = BotsReviewSocket(dashboard.baseUrl, gateway);
  return RemoteWorkspaceOwner(
    connectionId: 'c-bots',
    expectedBaseUrl: dashboard.baseUrl,
    profile: 'work',
    dashboard: dashboard,
    connect: () async => socket,
    ownsSocket: (_) => true,
  );
}

Widget botsReviewApp(
  RemoteWorkspaceOwner owner, {
  double textScale = 1.0,
  Locale? locale,
  BotDisplayConnector? displayConnector,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: BotsScreen(
    owner: owner,
    route: owner.route(),
    connection: botsReviewConnection,
    displayConnector: displayConnector,
  ),
);

/// Opens the Screen tab on the first bot (workbot: installed and running).
Future<void> openBotsScreenTab(WidgetTester tester) async {
  await botsShown(tester, find.text('WorkBot'));
  await tester.tap(find.text('Screen'));
  await botsShown(tester, find.text('Running'));
  await botsStep(tester);
}

/// Opens the Routines tab on the first bot (workbot: one routine).
Future<void> openBotsRoutinesTab(WidgetTester tester) async {
  await botsShown(tester, find.text('WorkBot'));
  await tester.tap(find.text('Routines'));
  await botsShown(tester, find.text('Stand-up'));
  await botsStep(tester);
}
