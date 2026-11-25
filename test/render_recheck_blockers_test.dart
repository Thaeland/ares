// Regressions for the targeted re-check of v5/render 8f92cd82. Each group
// names the residual blocker it covers (R1 regex freezes, R2 dead embed
// consent, R3 open-fence revisions). The probes are the re-check's own
// inputs, kept as permanent tests. Only APIs that existed before each fix are
// used, so every group shows red on the tree before its commit.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/render/artifact_library.dart';
import 'package:hermes_android/core/render/plugin_slots.dart';
import 'package:hermes_android/core/render/rich_blocks.dart';
import 'package:hermes_android/core/render/rich_transcript.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/hermes_sign_in.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump_chat_updates.dart';

/// Per call, on the re-check's inputs.
const _callBudgetMs = 50;

/// Per streamed frame in a widget test. The re-check measured 345-419 ms.
const _frameBudgetMs = 150;

SavedConnection _ngConnection(String id) => SavedConnection(
  id: id,
  label: 'Home $id',
  host: '10.0.0.5',
  port: 9119,
  apiKey: 'k',
  desktopGatewayUrl: 'http://10.0.0.5:9119',
  singleLogin: true,
  signInMethod: 'none',
);

/// Times one cold call: caches are cleared first, and the function has
/// already been compiled on a tiny input.
int _coldMs(void Function() warm, void Function() body) {
  warm();
  resetSandboxedRenderer();
  final watch = Stopwatch()..start();
  body();
  return watch.elapsedMilliseconds;
}

NgChatController _ngChat(
  NextGenGateway gateway,
  String id,
  List<Map<String, dynamic>> history,
) {
  final chat = NgChatController(gateway, sessionId: id)..runtimeId = 'rt-$id';
  chat.debugApplyHistory(history);
  addTearDown(chat.dispose);
  return chat;
}

Future<void> _pumpNg(
  WidgetTester tester,
  NextGenGateway gateway,
  NgChatController chat,
) async {
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: nextGenTheme(Brightness.light, NextGenLook.instance),
      home: NgScope(
        connManager: ConnectionManager(prefs),
        gateway: gateway,
        connections: [gateway.connection],
        switchTo: (_) async {},
        addGateway: () async {},
        signOut: (_) async {},
        reload: () async {},
        signInAgain: () async {},
        child: Scaffold(
          body: NgChatView(
            key: ObjectKey(chat),
            chat: chat,
            onOpenSidebar: () {},
            onNewChat: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void _emit(
  NextGenGateway gateway,
  String runtime,
  String type, [
  Map<String, dynamic>? data,
]) => gateway.debugEmit(
  StreamEvent(type: type, data: data ?? const {}, sessionId: runtime),
);

String _base64(int length) =>
    List.generate(length, (i) => 'ABCDEFGHabcdefgh0123+/'[i % 22]).join();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(mockChatImageRecovery);
  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': true});
    HermesSignInVault.resetForTesting(MemorySignInSecretStore());
    resetSandboxedRenderer();
  });
  tearDown(resetSandboxedRenderer);

  group('R1 agent and tool text scans are linear and bounded', () {
    test('R1a a directive with a long word run splits within budget', () {
      for (final n in [5000, 10000]) {
        final input = 'Before\n\n::x{${'a' * n}}\n\nAfter';
        final ms = _coldMs(
          () => splitRichProse('::x{a="b"}'),
          () => splitRichProse(input),
        );
        expect(ms, lessThan(_callBudgetMs), reason: '::x{a x $n}: ${ms}ms');
      }
    });

    test('R1a directive attributes keep what the pattern found', () {
      final pieces = splitRichProse(
        'Note:\n\n::notes{text="hello world" title=\'Plan\' n = "2"}\n',
      );
      final directive =
          pieces.whereType<RichPiece>().single.value as DirectivePiece;
      expect(directive.name, 'notes');
      expect(directive.attrs, {
        'text': 'hello world',
        'title': 'Plan',
        'n': '2',
      });
      expect(
        directive.raw,
        '::notes{text="hello world" title=\'Plan\' n = "2"}',
      );
      // A body with a brace is not a directive; neither is an upper-case name.
      expect(splitRichProse('::x{a{b}}').whereType<RichPiece>(), isEmpty);
      expect(
        splitRichProse('::Notes{text="a"}').whereType<RichPiece>(),
        isEmpty,
      );
    });

    test('R1a a directive body over 1 KB stays prose', () {
      final long = '::notes{text="${'a' * 1100}"}';
      expect(splitRichProse(long).whereType<RichPiece>(), isEmpty);
      final short = '::notes{text="${'a' * 900}"}';
      expect(splitRichProse(short).whereType<RichPiece>(), hasLength(1));
    });

    test('R1b a long token in tool text is searched within budget', () {
      for (final n in [4000, 8000, 16000]) {
        final input = 'A' * n;
        final ms = _coldMs(
          () => inspectedImagePath('a.png'),
          () => inspectedImagePath(input),
        );
        expect(ms, lessThan(_callBudgetMs), reason: '$n non-space: ${ms}ms');
      }
      final dataUrl =
          '{"image_url": "data:image/png;base64,${_base64(16000)}"}';
      final ms = _coldMs(
        () => inspectedImagePath('a.png'),
        () => inspectedImagePath(dataUrl),
      );
      expect(ms, lessThan(_callBudgetMs), reason: '16 KB data URL: ${ms}ms');
      expect(inspectedImagePath(dataUrl), isNull);
    });

    test('R1b the image path is the one the pattern found', () {
      expect(
        inspectedImagePath('Screenshot path: /tmp/shot.png\nok'),
        '/tmp/shot.png',
      );
      expect(inspectedImagePath('Screenshot path:/tmp/a.PNG'), '/tmp/a.PNG');
      expect(
        inspectedImagePath('{"image_url": "/home/me/cat.jpeg"}'),
        '"/home/me/cat.jpeg',
      );
      expect(inspectedImagePath('saved x.jpg.bak then y.gif'), 'x.jpg');
      expect(inspectedImagePath('a.png.gif.txt'), 'a.png.gif');
      expect(inspectedImagePath('.png alone'), isNull);
      expect(inspectedImagePath('see https://example.org/a.png'), isNull);
      expect(inspectedImagePath('no image here'), isNull);
    });

    test('R1c the Assets index reads hostile text within budget', () {
      List<IndexedArtifact> index(String role, String text, {String? name}) =>
          indexArtifactsFromMessages(
            sessionId: 's',
            sessionTitle: 't',
            messages: [
              {'role': role, 'content': text, 'name': ?name, 'timestamp': 1},
            ],
          );
      void warm() => index('assistant', '[a](https://x.org/a.pdf)');
      for (final n in [5000, 10000]) {
        final input = '[' * n;
        final ms = _coldMs(warm, () => index('assistant', input));
        expect(ms, lessThan(_callBudgetMs), reason: '"[" x $n: ${ms}ms');
      }
      final ansi = List.filled(
        2000,
        '\x1b[32mPASSED\x1b[0m tests/test_mod.py::test_case\n',
      ).join();
      expect(ansi.length, greaterThan(85000));
      final ms = _coldMs(warm, () => index('tool', ansi, name: 'terminal'));
      expect(ms, lessThan(_callBudgetMs), reason: '90 KB ANSI: ${ms}ms');
      final links = '[a](${'x' * 5000}' * 4;
      final linkMs = _coldMs(warm, () => index('assistant', links));
      expect(linkMs, lessThan(_callBudgetMs), reason: 'open targets');
      final dots = 'https://example.org/${'.' * 20000}x';
      final dotMs = _coldMs(warm, () => index('assistant', dots));
      expect(dotMs, lessThan(_callBudgetMs), reason: 'long dot run');
    });

    test('R1c Markdown links and images are still indexed', () {
      final found = indexArtifactsFromMessages(
        sessionId: 's',
        sessionTitle: 't',
        messages: [
          {
            'role': 'assistant',
            'content':
                'See [the report](https://example.org/r.pdf) and '
                '![chart](https://example.org/c.png), '
                '[${'x' * 250}](https://example.org/long.pdf) and '
                '[[nested](https://example.org/n.csv).',
            'timestamp': 1,
          },
        ],
      ).map((item) => '${item.kind.name}:${item.value}').toSet();
      expect(found, contains('file:https://example.org/r.pdf'));
      expect(found, contains('image:https://example.org/c.png'));
      expect(found, contains('file:https://example.org/n.csv'));
      // The bare URL scan still finds the long-label target; the link scan
      // does not read a 250-character label as link text.
      expect(found, contains('file:https://example.org/long.pdf'));
    });

    test('R1 audit: every other scan over agent text stays in budget', () {
      final header = '| a | b |\n';
      final cases = <String, void Function()>{
        'table separator after 10 KB of spaces': () =>
            splitRichProse('$header${' ' * 10000}x'),
        'table separator of 10 KB dashes': () =>
            splitRichProse('|${'-' * 10000}x\n|${'-' * 10000}x'),
        'table separator of 2000 cells then x': () =>
            splitRichProse('$header${'|---' * 2000}x'),
        r'inline maths "$a_" x5000': () => splitRichProse(r'$a_' * 5000),
        r'display maths "$$" x5000': () => splitRichProse(r'$$' * 5000),
        r'unclosed "$" then 10 KB': () => splitRichProse('\$${'a' * 10000}'),
        '"::" x10000': () => splitRichProse('::' * 10000),
        '"::a{" x5000': () => splitRichProse('::a{' * 5000),
        '"::a{" + 1 KB body x10': () =>
            splitRichProse('::a{${'b' * 1100}' * 10),
        'directive attrs "a=" x5000': () =>
            splitRichProse('::x{${'a=' * 500}}'),
        'quote lines after an alert header x5000': () =>
            splitRichProse('> [!NOTE]\n${'> x\n' * 5000}'),
        'history of "```\\n" x5000': () =>
            artifactHistoryFromText('```\n' * 5000),
        'history of "```a" x5000': () => artifactHistoryFromText('```a' * 5000),
        'history with a 16 KB fence info line': () =>
            artifactHistoryFromText('```${'a' * 16000}\nx\n```'),
        'code artefact titled by a 2 KB dashed file name': () =>
            artifactDownloadName(
              detectArtifact('py', '# a${'-' * 1990}a.py\n${'x = 1\n' * 600}')!,
            ),
        'Mermaid sequence at the caps': () => parseMermaid(
          'sequenceDiagram\n${List.filled(40, 'a->' * 133).join('\n')}',
        ),
        'index "Screenshot path:" x5000 (vision tool)': () =>
            indexArtifactsFromMessages(
              sessionId: 's',
              sessionTitle: 't',
              messages: [
                {
                  'role': 'tool',
                  'name': 'vision_analyze',
                  'content': 'Screenshot path: x\n' * 5000,
                },
              ],
            ),
        'index a 90 KB URL and a 90 KB path': () => indexArtifactsFromMessages(
          sessionId: 's',
          sessionTitle: 't',
          messages: [
            {
              'role': 'assistant',
              'content':
                  'https://example.org/${'a' * 90000} /tmp/${'b/' * 45000}',
            },
          ],
        ),
        'index "![" x10000': () => indexArtifactsFromMessages(
          sessionId: 's',
          sessionTitle: 't',
          messages: [
            {'role': 'assistant', 'content': '![' * 10000},
          ],
        ),
        'tool image path with 10000 dots': () =>
            inspectedImagePath('a${'.' * 10000}'),
      };
      final slow = <String>[];
      for (final entry in cases.entries) {
        final ms = _coldMs(() => splitRichProse('x'), entry.value);
        if (ms >= _callBudgetMs) slow.add('${entry.key}: ${ms}ms');
      }
      expect(slow, isEmpty);
      // The separator scan keeps what the pattern matched.
      bool table(String separator) => splitRichProse(
        '| a | b |\n$separator\n| 1 | 2 |',
      ).whereType<RichPiece>().any((piece) => piece.value is TablePiece);
      expect(table('|---|---|'), isTrue);
      expect(table(' | :--- | ---: | '), isTrue);
      expect(table('--- | ---'), isTrue);
      expect(table('|---|'), isFalse);
      expect(table('|--|---|'), isFalse);
      expect(table('|---||'), isFalse);
      expect(table('|---|-x-|'), isFalse);
    });

    testWidgets('R1a NextGen streams after a long directive within budget', (
      tester,
    ) async {
      final gateway = NextGenGateway(_ngConnection('c1'));
      addTearDown(gateway.dispose);
      final chat = _ngChat(gateway, 's', [
        {'role': 'user', 'content': 'go'},
      ]);
      await _pumpNg(tester, gateway, chat);
      _emit(gateway, 'rt-s', 'message.start');
      _emit(gateway, 'rt-s', 'message.delta', {
        'text': 'Result:\n\n::x{${'a' * 4000}}\n\nThen ',
      });
      await tester.pump(const Duration(milliseconds: 16));
      final frames = <int>[];
      for (var i = 0; i < 4; i++) {
        _emit(gateway, 'rt-s', 'message.delta', {'text': 'more words. '});
        final watch = Stopwatch()..start();
        await tester.pump(const Duration(milliseconds: 16));
        frames.add(watch.elapsedMilliseconds);
      }
      frames.sort();
      expect(frames[2], lessThan(_frameBudgetMs), reason: 'frames $frames');
      _emit(gateway, 'rt-s', 'message.complete', {'status': 'complete'});
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('R1b NextGen expands a vision row with a data URL in budget', (
      tester,
    ) async {
      final gateway = NextGenGateway(_ngConnection('c1'));
      addTearDown(gateway.dispose);
      final chat = _ngChat(gateway, 's', [
        {'role': 'user', 'content': 'look'},
        {
          'role': 'assistant',
          'content': '',
          'id': 'a1',
          'tool_calls': [
            {
              'id': 't-1',
              'function': {
                'name': 'vision_analyze',
                'arguments': jsonEncode({
                  'image_url': 'data:image/png;base64,${_base64(6000)}',
                  'question': 'what is it',
                }),
              },
            },
          ],
        },
        {
          'role': 'tool',
          'tool_call_id': 't-1',
          'content': 'A cat. Screenshot path: /tmp/cat.png',
        },
        {'role': 'assistant', 'content': 'It is a cat.'},
      ]);
      await _pumpNg(tester, gateway, chat);
      await tester.tap(find.text('Used vision_analyze'));
      await tester.pump();
      final watch = Stopwatch()..start();
      await tester.tap(find.text('vision_analyze'));
      await tester.pump();
      final ms = watch.elapsedMilliseconds;
      expect(ms, lessThan(_frameBudgetMs), reason: 'expand frame ${ms}ms');
      expect(find.text('cat.png'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
