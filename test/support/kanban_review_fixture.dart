import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/kanban_board_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Waits (real and fake time) until [finder] matches, then asserts it does.
Future<void> kanbanShown(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(finder, findsWidgets);
}

/// Lets queued HTTP replies and their rebuilds land.
Future<void> kanbanStep(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

final kanbanReviewConnection = SavedConnection(
  id: 'c-kanban',
  label: 'Review Kanban Host',
  host: '127.0.0.1',
  port: 9,
  apiKey: 'fixture-key',
  dashboardUsername: 'fixture',
  dashboardPassword: 'fixture-password',
  desktopGatewayUrl: 'http://127.0.0.1:9',
  gatewayProfile: 'work',
);

class KanbanReviewCall {
  KanbanReviewCall(this.method, this.path, this.query, this.body);
  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, dynamic>? body;

  @override
  String toString() => '$method $path?$query $body';
}

/// The dashboard Kanban plugin as `plugins/kanban/dashboard/plugin_api.py`
/// answers it (b7ee21c14e), with two boards whose cards have different ids so
/// a result landing on the wrong board is visible.
class KanbanReviewApi {
  KanbanReviewApi({this.readyCount = 2}) {
    client = MockClient(_handle);
  }

  final int readyCount;
  late final MockClient client;
  final calls = <KanbanReviewCall>[];

  /// `METHOD path` (and, when the request names one, `METHOD path@board`)
  /// to a completer the reply waits on.
  final holds = <String, Completer<void>>{};

  /// The reply of `POST /tasks/<id>/decompose` (plugin_api.py:1600-1607).
  Map<String, dynamic> decomposeReply = {
    'ok': true,
    'task_id': 't_run_1',
    'reason': 'decomposed into 3 children',
    'fanout': true,
    'child_ids': ['t_c1', 't_c2', 't_c3'],
    'new_title': null,
  };

  int count(String method, String pathSuffix) => calls
      .where((c) => c.method == method && c.path.endsWith(pathSuffix))
      .length;

  List<Map<String, dynamic>> tasksOn(String board) => board == 'ops-board'
      ? [
          for (var i = 0; i < 2; i++)
            {
              'id': 't_ops_$i',
              'title': 'Ops card $i',
              'status': 'ready',
              'assignee': 'work',
              'priority': 1,
            },
        ]
      : [
          for (var i = 0; i < readyCount; i++)
            {
              'id': 't_ready_$i',
              'title': 'Ready card $i',
              'status': 'ready',
              'assignee': 'work',
              'priority': 1,
            },
          {
            'id': 't_run_1',
            'title': 'Running worker card',
            'status': 'running',
            'assignee': 'work',
            'priority': 3,
            'current_run_id': 7,
          },
        ];

  Future<http.Response> _handle(http.Request request) async {
    Map<String, dynamic>? body;
    if (request.body.isNotEmpty) {
      try {
        final raw = jsonDecode(request.body);
        if (raw is Map<String, dynamic>) body = raw;
      } catch (_) {}
    }
    final path = request.url.path;
    final query = request.url.queryParameters;
    calls.add(KanbanReviewCall(request.method, path, query, body));
    final board = query['board'] ?? 'default';
    final hold =
        holds['${request.method} $path@$board'] ??
        holds['${request.method} $path'];
    if (hold != null) await hold.future;
    if (path == '/auth/password-login') {
      return http.Response(
        jsonEncode({'ok': true}),
        200,
        headers: {'set-cookie': 'hermes_session_at=fixture-cookie'},
      );
    }
    if (path == '/api/auth/ws-ticket') return _json({'ticket': 'tkt-fixture'});
    const root = '/api/plugins/kanban';
    if (path == '$root/boards' && request.method == 'GET') {
      return _json({
        'current': 'default',
        'boards': [
          {
            'slug': 'default',
            'name': 'Default',
            'total': tasksOn('default').length,
          },
          {
            'slug': 'ops-board',
            'name': 'Ops Board',
            'total': tasksOn('ops-board').length,
          },
        ],
      });
    }
    if (path == '$root/board') {
      final tasks = tasksOn(board);
      return _json({
        'columns': [
          for (final col in kanbanWorkflowColumns)
            {
              'name': col,
              'tasks': [
                for (final t in tasks)
                  if (t['status'] == col) t,
              ],
            },
        ],
        'tenants': const <String>[],
        'assignees': const ['work'],
        'latest_event_id': 12,
        'now': 1700000000,
      });
    }
    if (path == '$root/profiles') {
      return _json({
        'profiles': [
          {'name': 'work', 'is_default': true},
          {'name': 'reviewer', 'is_default': false},
        ],
      });
    }
    if (path == '$root/projects') return _json({'projects': []});
    if (path == '$root/orchestration') {
      return _json({'auto_decompose': false});
    }
    if (path == '$root/tasks/bulk') {
      final ids = (body?['ids'] as List? ?? const []).cast<String>();
      return _json({
        'results': [
          for (final id in ids) {'id': id, 'ok': true},
        ],
      });
    }
    if (path == '$root/tasks/t_run_1/decompose') {
      return _json(decomposeReply);
    }
    final detail = RegExp('^$root/tasks/([A-Za-z0-9_]+)\$').firstMatch(path);
    if (detail != null && request.method == 'GET') {
      final id = detail.group(1)!;
      final task = tasksOn(
        board,
      ).firstWhere((t) => t['id'] == id, orElse: () => tasksOn(board).last);
      return _json({
        'task': task,
        'comments': const [],
        'links': {'parents': const <String>[], 'children': const <String>[]},
        'link_tasks': const [],
        'attachments': const [],
        'runs': const [],
        'events': const [],
      });
    }
    if (path.endsWith('/log')) {
      return _json({'task_id': 't_run_1', 'exists': false, 'content': ''});
    }
    return _json({'ok': true});
  }

  http.Response _json(Map<String, dynamic> data) =>
      http.Response(jsonEncode(data), 200);
}

class _ReadySocket extends Fake implements WsClient {
  _ReadySocket(this.baseUrl);
  @override
  final String baseUrl;
  @override
  int get socketEpoch => 1;
  @override
  bool get isConnected => true;
  @override
  Future<Map<String, dynamic>> waitForGatewayReady({
    Duration timeout = const Duration(seconds: 15),
  }) async => {};
}

RemoteWorkspaceOwner kanbanReviewOwner(http.Client client, {int port = 9}) {
  final dashboard = DashboardClient(
    host: '127.0.0.1',
    port: port,
    username: 'fixture',
    password: 'fixture-password',
    gatewayProfile: 'work',
    httpClient: client,
  );
  return RemoteWorkspaceOwner(
    connectionId: 'c-kanban',
    expectedBaseUrl: dashboard.baseUrl,
    profile: 'work',
    dashboard: dashboard,
    connect: () async => _ReadySocket(dashboard.baseUrl),
    ownsSocket: (_) => true,
  );
}

Widget kanbanReviewApp(
  RemoteWorkspaceOwner owner, {
  double textScale = 1.0,
  bool live = false,
  Locale? locale,
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
  home: KanbanBoardScreen(
    owner: owner,
    route: owner.route(),
    connection: kanbanReviewConnection,
    enableLivePolling: live,
  ),
);
