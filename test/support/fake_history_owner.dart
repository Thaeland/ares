import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// In-memory owner + dashboard + RPC double for [SessionHistoryPage] and
/// chat-level history/foreign-import widget tests. No socket or HttpServer.
class FakeHistoryBackend {
  FakeHistoryBackend({
    this.profile = 'field-work',
    this.foreignSupported = true,
  }) {
    dashboard = DashboardClient(
      host: 'history.invalid',
      port: 443,
      useHttps: true,
      proxied: true,
      gatewayProfile: profile,
      httpClient: MockClient(_http),
    );
    apiClient = ApiClient(
      baseUrl: dashboard.baseUrl,
      apiKey: '',
      httpClient: MockClient(_http),
    );
    socket = _FakeHistorySocket(dashboard.baseUrl, _rpc);
    owner = RemoteWorkspaceOwner(
      connectionId: connectionId,
      expectedBaseUrl: dashboard.baseUrl,
      profile: profile,
      dashboard: dashboard,
      connect: () async => socket,
      ownsSocket: (candidate) => identical(candidate, socket),
    );
  }

  static const connectionId = 'history-widget-fixture';
  static const session = 'stored-history';
  static const cwd = '/srv/history';
  static const claudeHandle =
      'abababababababababababababababababababababababababababababababab';
  static const codexHandle =
      'cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd';
  static String get fixtureToken =>
      'gh'
      'p_ABCDEFGH12345678';

  final String profile;
  bool foreignSupported;
  int revision = 4;
  int generation = 9;

  final rpcCalls = <({String method, Map<String, dynamic> params})>[];
  final mutations = <Map<String, dynamic>>[];
  final restores = <Map<String, dynamic>>[];
  final exports = <Map<String, dynamic>>[];
  final foreignLists = <Map<String, dynamic>>[];
  final foreignPreviews = <Map<String, dynamic>>[];
  final foreignImports = <Map<String, dynamic>>[];

  late final DashboardClient dashboard;
  late final ApiClient apiClient;
  late final WsClient socket;
  late final RemoteWorkspaceOwner owner;

  SavedConnection get connection => SavedConnection(
    id: connectionId,
    label: 'History fixture',
    host: 'history.invalid',
    port: 443,
    useHttps: true,
    dashboardPortOverride: 443,
    desktopGatewayUrl: 'https://history.invalid:443',
    gatewayProfile: profile,
    singleLogin: true,
    signInMethod: 'none',
    apiKey: '',
    dashboardProxied: true,
  );

  void close() => owner.close();

  Future<http.Response> _http(http.Request req) async {
    final path = req.url.path;
    final query = req.url.queryParameters;
    if (path == '/api/sessions/$session' && query['profile'] == profile) {
      return http.Response(
        jsonEncode({
          'id': session,
          'profile': profile,
          'cwd': cwd,
          'git_metadata_generation': 1,
        }),
        200,
      );
    }
    if (path == '/api/sessions/$session/mutation-snapshot' &&
        query['profile'] == profile) {
      return http.Response(
        jsonEncode({
          'session_id': session,
          'exists': true,
          'runtime_revision': revision,
          'runtime_generation': generation,
        }),
        200,
      );
    }
    if (path.startsWith('/api/sessions/') && path.endsWith('/messages')) {
      return http.Response(
        jsonEncode({
          'data': [
            {'id': 7, 'role': 'user', 'content': 'Keep this'},
            {
              'id': 8,
              'role': 'assistant',
              'content': 'Noted',
              'finish_reason': 'stop',
            },
          ],
        }),
        200,
      );
    }
    if (path.startsWith('/api/sessions/')) {
      final seg = path.split('/').last;
      return http.Response(
        jsonEncode({
          'id': seg,
          'profile': profile,
          'cwd': cwd,
          'archived': false,
        }),
        200,
      );
    }
    return http.Response('{}', 200);
  }

  Future<Map<String, dynamic>> _rpc(
    String method,
    Map<String, dynamic> params,
  ) async {
    rpcCalls.add((method: method, params: Map<String, dynamic>.from(params)));
    switch (method) {
      case 'session.history':
        return {
          'result': {
            'count': 2,
            'messages': [
              {'row_id': 7, 'role': 'user', 'text': 'Keep this'},
              {'row_id': 8, 'role': 'assistant', 'text': 'Noted'},
            ],
          },
        };
      case 'session.list':
        return {
          'result': {
            'sessions': [
              {'id': 'parent', 'title': 'Parent chat', 'last_active': 1},
              {
                'id': session,
                'title': 'Current',
                '_branched_from': 'parent',
                'last_active': 3,
              },
              {
                'id': 'sibling',
                'title': 'Sibling',
                '_branched_from': 'parent',
                'last_active': 4,
              },
            ],
          },
        };
      case 'session.mutate':
        mutations.add(Map<String, dynamic>.from(params));
        revision += 1;
        final operation = params['operation'];
        return {
          'result': {
            'session_id': session,
            'operation': operation,
            'revision': revision,
            if (operation == 'branch') 'branched_session_id': 'child-1',
            if (operation == 'branch') 'title': 'Branched chat',
            if (operation == 'rewind') 'removed': 2,
          },
        };
      case 'rollback.list':
        return {
          'result': {
            'enabled': true,
            'checkpoints': [
              {
                'hash': 'abc1234',
                'timestamp': '2026-11-25T00:00:00Z',
                'message': 'before edit',
              },
            ],
          },
        };
      case 'rollback.diff':
        return {
          'result': {'diff': 'line with $fixtureToken\n'},
        };
      case 'rollback.restore':
        restores.add(Map<String, dynamic>.from(params));
        return {
          'result': {
            'success': true,
            'history_removed': 1,
            'restored_files': ['a.txt'],
          },
        };
      case 'session.export':
        exports.add(Map<String, dynamic>.from(params));
        return {
          'result': {
            'format': params['format'],
            'filename': 'transcript.${params['format']}',
            'content': 'exported $fixtureToken end',
          },
        };
      case 'session.foreign.list':
        if (!foreignSupported) {
          return {
            'error': {'code': -32601, 'message': 'Method not found'},
          };
        }
        foreignLists.add(Map<String, dynamic>.from(params));
        final offset = params['offset'] is int ? params['offset'] as int : 0;
        final source = params['source'] as String?;
        if (offset > 0) {
          return {
            'result': {
              'sessions': [
                if (source == null || source == 'codex')
                  {
                    'id': codexHandle,
                    'source': 'codex',
                    'label': 'Codex',
                    'title': 'Migrate database',
                    'cwd': '/srv/codex-project',
                    'mtime': 1700000100.0,
                    'turn_count': 4,
                    'excerpt': 'Schema check $fixtureToken',
                  },
              ],
              'host': 'dev-host',
              'unreadable': 1,
              'next_offset': null,
            },
          };
        }
        return {
          'result': {
            'sessions': [
              if (source == null || source == 'claude')
                {
                  'id': claudeHandle,
                  'source': 'claude',
                  'label': 'Claude Code',
                  'title': 'Plan the release',
                  'cwd': '/srv/claude-project',
                  'mtime': 1700000200.0,
                  'turn_count': 2,
                  'excerpt': 'Checklist draft',
                },
            ],
            'host': 'dev-host',
            'unreadable': 0,
            'next_offset': source == null ? 25 : null,
          },
        };
      case 'session.foreign.preview':
        if (!foreignSupported) {
          return {
            'error': {'code': -32601, 'message': 'Method not found'},
          };
        }
        foreignPreviews.add(Map<String, dynamic>.from(params));
        return {
          'result': {
            'messages': [
              {
                'role': 'user',
                'content': 'Please review $fixtureToken before shipping.',
              },
              {'role': 'assistant', 'content': 'Checklist looks ready.'},
            ],
            'total': 2,
            'truncated': false,
            'already_imported': null,
            'cwd': '/srv/claude-project',
          },
        };
      case 'session.foreign.import':
        if (!foreignSupported) {
          return {
            'error': {'code': -32601, 'message': 'Method not found'},
          };
        }
        foreignImports.add(Map<String, dynamic>.from(params));
        return {
          'result': {
            'session_id': 'imported-host-1',
            'already_imported': false,
          },
        };
      default:
        return {'result': <String, dynamic>{}};
    }
  }
}

class _FakeHistorySocket extends Fake implements WsClient {
  _FakeHistorySocket(this.baseUrl, this._handler);

  @override
  final String baseUrl;
  final Future<Map<String, dynamic>> Function(
    String method,
    Map<String, dynamic> params,
  )
  _handler;

  @override
  int get socketEpoch => 1;

  @override
  bool get isConnected => true;

  @override
  WorkspaceRuntime? workspaceBinding(String storedId) => null;

  @override
  Future<Map<String, dynamic>> waitForGatewayReady({
    Duration timeout = const Duration(seconds: 15),
  }) async => {'session_authority': true};

  @override
  Future<Map<String, dynamic>> send(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
    void Function()? onSent,
    bool includeProfile = true,
  }) {
    onSent?.call();
    return _handler(method, params);
  }
}
