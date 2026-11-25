import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hermes_android/core/models/connection.dart';

import 'markdown_file_fixture.dart';

/// A stored chat and its host filesystem, served only on an ephemeral loopback
/// port. No widget, workspace owner, gateway client or chat route is faked.
class SessionFilesGateway {
  SessionFilesGateway._(this._server);
  final HttpServer _server;
  final _sockets = <WebSocket>[];
  final methods = <String>[];
  final requests = <(String, Uri)>[];
  final replacements = <Map<String, dynamic>>[];
  final reads = <String>[];
  static const session = 'stored-field-chat';
  static const profile = 'field-work';
  static const root = '/srv/field-work';
  static const folder = '$root/docs';
  static const name = 'notes.MD';
  static const path = '$folder/$name';
  static const transcript = 'Check the field notes';
  String text = markdownFixture;
  String sibling = 'before.txt';
  // Simulates another writer AFTER the client's preflight GET, before the CAS.
  String? competingWrite;

  SavedConnection get connection => SavedConnection(
    id: 'files-fixture',
    label: 'Files fixture',
    host: '127.0.0.1',
    port: _server.port,
    dashboardPortOverride: _server.port,
    desktopGatewayUrl: 'http://127.0.0.1:${_server.port}',
    gatewayProfile: profile,
    singleLogin: true,
    signInMethod: 'none',
    apiKey: '',
    dashboardProxied: true,
  );

  static Future<SessionFilesGateway> start() async {
    final f = SessionFilesGateway._(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
    f._server.listen(f._handle);
    return f;
  }

  static String hash(String text) =>
      sha256.convert(utf8.encode(text)).toString();
  Map<String, Object> _entry(
    String parent,
    String name, {
    bool directory = false,
  }) => {'name': name, 'path': '$parent/$name', 'isDirectory': directory};

  Future<void> _handle(HttpRequest req) async {
    final uri = req.uri;
    requests.add((req.method, uri));
    final q = uri.queryParameters;
    final res = req.response;
    Object? body;
    switch ((req.method, uri.path)) {
      case ('POST', '/api/auth/ws-ticket'):
        body = {'ticket': 'loopback-fixture'};
      case ('GET', '/api/ws'):
        final ws = await WebSocketTransformer.upgrade(
          req,
          protocolSelector: (_) => 'hermes-gateway-v1',
        );
        _sockets.add(ws);
        ws.add(
          jsonEncode({
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {'type': 'gateway.ready', 'payload': {}},
          }),
        );
        ws.listen((raw) {
          final frame = jsonDecode(raw as String) as Map;
          final method = frame['method'] as String?;
          if (method == null) return;
          methods.add(method);
          final result = switch (method) {
            'session.resume' when frame['params']['session_id'] == session => {
              'session_id': 'live-field-chat',
              'stored_session_id': session,
              'info': {
                'profile_name': profile,
                'cwd': root,
                'terminal_backend': 'local',
              },
              'running': false,
            },
            'config.get' => {'config': {}},
            _ => null,
          };
          ws.add(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': frame['id'],
              if (result != null)
                'result': result
              else
                'error': {'code': -32601, 'message': 'unsupported in fixture'},
            }),
          );
        });
        return;
      case ('GET', '/api/sessions/$session/messages'):
        body = {
          'session_id': session,
          'messages': [
            {'id': 1, 'role': 'user', 'content': transcript, 'timestamp': 1},
          ],
        };
      case ('GET', '/api/sessions/$session') when q['profile'] == profile:
        body = {
          'id': session,
          'profile': profile,
          'cwd': root,
          'git_metadata_generation': 1,
        };
      case ('GET', '/api/tools/terminal/backends') when q['profile'] == profile:
        body = {'active': 'local', 'backends': []};
      case ('GET', '/api/fs/git-root')
          when q['path'] == root && q['profile'] == profile:
        body = {'root': null};
      case ('GET', '/api/fs/list')
          when q['profile'] == profile &&
              q['git_flags'] == 'true' &&
              (q['path'] == root || q['path'] == folder):
        body = {
          'entries': q['path'] == root
              ? [_entry(root, 'docs', directory: true)]
              : [_entry(folder, name), _entry(folder, sibling)],
        };
      case ('GET', '/api/fs/read-text')
          when q['path'] == path &&
              q['profile'] == profile &&
              q['session_id'] == session:
        reads.add(text);
        body = {
          'path': path,
          'text': text,
          'byteSize': utf8.encode(text).length,
          'truncated': false,
          'binary': false,
        };
      case ('POST', '/api/fs/replace-text-v1') when q['profile'] == profile:
        final data =
            jsonDecode(await utf8.decoder.bind(req).join())
                as Map<String, dynamic>;
        replacements.add(data);
        if (data['cwd'] != root ||
            data['path'] != path ||
            data['session_id'] != session ||
            data['content'] is! String) {
          res.statusCode = 400;
          break;
        }
        text = competingWrite ?? text;
        competingWrite = null;
        if (data['expected_sha256'] != hash(text)) {
          res.statusCode = HttpStatus.conflict;
        } else {
          text = data['content'] as String;
          body = {'ok': true, 'path': path, 'sha256': hash(text)};
        }
      default:
        res.statusCode = HttpStatus.notFound;
    }
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(body));
    await res.close();
  }

  Future<void> close() async {
    for (final ws in _sockets) {
      await ws.close();
    }
    await _server.close(force: true);
  }
}
