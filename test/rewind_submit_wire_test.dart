import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/history/rewind_submit.dart';
import 'package:hermes_android/core/services/ws_client.dart';

void main() {
  test(
    'isSyntheticRendererId rejects renderer keys and keeps platform ids',
    () {
      for (final synthetic in const [
        null,
        '',
        'user-1700000000-abc',
        'assistant-1700000000-xyz',
        '1700000000-0-user',
        '1700000000-2-assistant',
        'msg-synthetic-9',
        'u1',
        'a12',
        'local-draft-1',
        'run:42',
        'reasoning:7',
      ]) {
        expect(
          isSyntheticRendererId(synthetic),
          isTrue,
          reason: 'expected $synthetic to be rejected as synthetic',
        );
      }
      for (final durable in const [
        'plat-msg-99',
        'tg_88412',
        'discord-snowflake',
      ]) {
        expect(isSyntheticRendererId(durable), isFalse);
      }
    },
  );

  test(
    'truncateSubmitParams emits confirm_truncate and one target by priority',
    () {
      expect(truncateSubmitParams(null, null, null), isEmpty);
      expect(truncateSubmitParams(null, 'user-123', null), isEmpty);

      // Row id wins over message id and ordinal.
      expect(truncateSubmitParams(1, 'plat-msg-1', 205), {
        'confirm_truncate': true,
        'truncate_before_row_id': 205,
      });

      // Platform message id wins over ordinal when row id is absent.
      expect(truncateSubmitParams(0, 'plat-msg-1', null), {
        'confirm_truncate': true,
        'truncate_before_message_id': 'plat-msg-1',
        'confirm_empty_truncate': true,
      });

      // Synthetic renderer id is stripped; ordinal takes over.
      expect(truncateSubmitParams(0, '1700000000-0-user', null), {
        'confirm_truncate': true,
        'truncate_before_user_ordinal': 0,
        'confirm_empty_truncate': true,
      });

      // Non-zero ordinal omits confirm_empty_truncate; confirmDeepTruncate adds
      // confirm_deep_truncate only when requested.
      expect(truncateSubmitParams(2, null, null, confirmDeepTruncate: true), {
        'confirm_truncate': true,
        'truncate_before_user_ordinal': 2,
        'confirm_deep_truncate': true,
      });
    },
  );

  test(
    'RewindPlan.resolve prefers session.history row_id, handles ambiguity, and falls back cleanly',
    () async {
      // Unique content match resolves row_id from session.history.
      final resolved = await RewindPlan.resolve(
        requestGateway: (method, params) async {
          expect(method, 'session.history');
          return {
            'messages': [
              {'row_id': 101, 'role': 'user', 'text': 'First question'},
              {'row_id': 102, 'role': 'assistant', 'text': 'First answer'},
              {'row_id': 103, 'role': 'user', 'text': 'Second question'},
            ],
          };
        },
        sessionId: 'rt-1',
        truncateOrdinal: 1,
        truncateMessageId: 'user-synthetic',
        truncateRowId: null,
        sourceText: 'Second question',
      );
      expect(buildRewindParams(resolved, confirmDeepTruncate: false), {
        'confirm_truncate': true,
        'truncate_before_row_id': 103,
        'confirm_empty_truncate': true,
      });

      // Duplicate text in middle of persisted history degrades to plain submit
      // rather than guessing a potentially diverged ordinal.
      final ambiguousMid = await RewindPlan.resolve(
        requestGateway: (_, _) async => {
          'messages': [
            {'row_id': 10, 'role': 'user', 'text': 'retry me'},
            {'row_id': 11, 'role': 'user', 'text': 'retry me'},
            {'row_id': 12, 'role': 'user', 'text': 'later turn'},
          ],
        },
        sessionId: 'rt-1',
        truncateOrdinal: 0,
        truncateMessageId: null,
        truncateRowId: null,
        sourceText: 'retry me',
      );
      expect(
        buildRewindParams(ambiguousMid, confirmDeepTruncate: true),
        isEmpty,
      );

      // Duplicate text at the newest persisted turn resolves to the last row_id.
      final latestMatch = await RewindPlan.resolve(
        requestGateway: (_, _) async => {
          'messages': [
            {'row_id': 10, 'role': 'user', 'text': 'same prompt'},
            {'row_id': 11, 'role': 'user', 'text': 'same prompt'},
          ],
        },
        sessionId: 'rt-1',
        truncateOrdinal: 1,
        truncateMessageId: null,
        truncateRowId: null,
        sourceText: 'same prompt',
      );
      expect(latestMatch.truncateRowId, 11);

      // Legacy gateway with no row_id stamps falls back to ordinal.
      final legacyOrdinal = await RewindPlan.resolve(
        requestGateway: (_, _) async => {
          'messages': [
            {'role': 'user', 'text': 'First'},
          ],
        },
        sessionId: 'rt-legacy',
        truncateOrdinal: 0,
        truncateMessageId: null,
        truncateRowId: null,
        sourceText: 'First',
      );
      expect(buildRewindParams(legacyOrdinal, confirmDeepTruncate: false), {
        'confirm_truncate': true,
        'truncate_before_user_ordinal': 0,
        'confirm_empty_truncate': true,
      });
    },
  );

  test(
    'runRewindSubmit interrupts first and retries once without confirm_deep_truncate on 4000 rejection',
    () async {
      final calls = <({String method, Map<String, dynamic> params})>[];
      var submitAttempts = 0;
      final survivors = await runRewindSubmit(
        requestGateway: (method, params) async {
          calls.add((
            method: method,
            params: Map<String, dynamic>.from(params),
          ));
          if (method == 'prompt.submit') {
            submitAttempts++;
            if (submitAttempts == 1) {
              throw const RewindRpcException(
                code: 4000,
                message:
                    'invalid params for prompt.submit: confirm_deep_truncate: Extra inputs are not permitted',
              );
            }
            return {
              'status': 'streaming',
              'survivor_row_id_map': {'101': 301, '102': null},
            };
          }
          return const {};
        },
        sessionId: 'rt-live',
        text: 'Edited first prompt',
        truncateRowId: 102,
        rebindRowIds: const [101, 102],
        interruptFirst: true,
        confirmDeepTruncate: true,
      );

      expect(calls.map((c) => c.method).toList(), [
        'session.interrupt',
        'prompt.submit',
        'prompt.submit',
      ]);
      expect(calls[1].params['confirm_deep_truncate'], isTrue);
      expect(calls[1].params['confirm_truncate'], isTrue);
      expect(calls[1].params['truncate_before_row_id'], 102);

      // Compatibility retry strips ONLY confirm_deep_truncate.
      expect(calls[2].params.containsKey('confirm_deep_truncate'), isFalse);
      expect(calls[2].params['confirm_truncate'], isTrue);
      expect(calls[2].params['truncate_before_row_id'], 102);
      expect(calls[2].params['confirm_empty_truncate'], isTrue);
      expect(calls[2].params['rebind_survivor_row_ids'], [101, 102]);
      expect(survivors?.byOldRowId, {101: 301, 102: null});
    },
  );

  test(
    'WsClient.submitPrompt wire compatibility retries without confirm_deep_truncate on 4000 rejection',
    () async {
      final submits = <Map<String, dynamic>>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));

      server.listen((req) async {
        final ws = await WebSocketTransformer.upgrade(req);
        ws.add(
          jsonEncode({
            'jsonrpc': '2.0',
            'method': 'event',
            'params': {
              'type': 'gateway.ready',
              'payload': {'session_authority': true},
            },
          }),
        );
        ws.listen((raw) {
          final frame = jsonDecode(raw as String) as Map<String, dynamic>;
          if (frame['method'] == 'prompt.submit') {
            final params = Map<String, dynamic>.from(frame['params'] as Map);
            submits.add(params);
            if (params.containsKey('confirm_deep_truncate')) {
              ws.add(
                jsonEncode({
                  'jsonrpc': '2.0',
                  'id': frame['id'],
                  'error': {
                    'code': 4000,
                    'message':
                        'invalid params for prompt.submit: confirm_deep_truncate: Extra inputs are not permitted',
                  },
                }),
              );
              return;
            }
            ws.add(
              jsonEncode({
                'jsonrpc': '2.0',
                'id': frame['id'],
                'result': {'status': 'streaming', 'execution_generation': 2},
              }),
            );
            ws.add(
              jsonEncode({
                'jsonrpc': '2.0',
                'method': 'event',
                'params': {
                  'type': 'turn.end',
                  'session_id': 'rt-wire',
                  'payload': {'completed': true},
                },
              }),
            );
          }
        });
      });

      final client = WsClient('http://127.0.0.1:${server.port}');
      addTearDown(client.close);
      await client.connect();

      await client.submitPrompt(
        'Edited wire prompt',
        sessionId: 'rt-wire',
        extraSubmitParams: const {
          'confirm_truncate': true,
          'truncate_before_row_id': 77,
          'confirm_empty_truncate': true,
          'confirm_deep_truncate': true,
        },
        onEvent: (_) {},
      );

      expect(submits, hasLength(2));
      expect(submits[0]['confirm_deep_truncate'], isTrue);
      expect(submits[1].containsKey('confirm_deep_truncate'), isFalse);
      expect(submits[1]['confirm_truncate'], isTrue);
      expect(submits[1]['truncate_before_row_id'], 77);
      expect(submits[1]['confirm_empty_truncate'], isTrue);
    },
  );
}
