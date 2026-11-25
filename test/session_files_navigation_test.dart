import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/gateway_turn_application_controller.dart';
import 'package:hermes_android/core/widgets/markdown_file_preview.dart';
import 'package:hermes_android/core/widgets/session_files_view.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_voice_composer_adapter.dart';
import 'support/markdown_file_fixture.dart';
import 'support/pump_chat_updates.dart';
import 'support/session_files_gateway.dart';

enum _Chat { classic, nextGen }

// Keep Flutter's network isolation for everything except this test's server,
// including the remote image embedded in the Markdown preview fixture.
class _FixtureOnly extends HttpOverrides {
  _FixtureOnly(this.port);
  final int port;
  final blocked = <Uri>[];

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..findProxy = ((_) => 'DIRECT')
        ..connectionFactory = (uri, _, _) {
          if (uri.host != '127.0.0.1' || uri.port != port) {
            blocked.add(uri);
            throw StateError('Request outside the Session files fixture: $uri');
          }
          return Socket.startConnect(InternetAddress.loopbackIPv4, port);
        };
}

Finder get _pane => find.byType(SessionFilesView);
Finder _inside(Finder match) => find.descendant(of: _pane, matching: match);
Finder get _file => _inside(find.text(SessionFilesGateway.name));
Finder get _source => _inside(find.byType(TextField));
Finder _composer(_Chat chat, {bool skipOffstage = true}) => find.byKey(
  ValueKey(
    chat == _Chat.classic ? 'chat-message-composer' : 'ng-composer-field',
  ),
  skipOffstage: skipOffstage,
);

// Socket and HTTP replies advance in real time; pump only until the requested
// UI is present (dialogs can animate while the pane still has a busy bar).
Future<void> _wait(WidgetTester tester, Finder match) async {
  for (var i = 0; i < 250; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (match.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  expect(match, findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder match) async {
  await _wait(tester, match.hitTestable());
  await tester.tap(match.hitTestable());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _withChat(
  WidgetTester tester,
  _Chat shell,
  Future<void> Function(SessionFilesGateway wire) exercise,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(412, 900);
  addTearDown(tester.view.reset);
  final wire = (await tester.runAsync(SessionFilesGateway.start))!;
  final connection = wire.connection;
  final previous = HttpOverrides.current;
  final network = _FixtureOnly(connection.port);
  HttpOverrides.global = network;
  addTearDown(() => HttpOverrides.global = previous);
  final Widget home;
  final Future<void> Function() close;
  if (shell == _Chat.classic) {
    final owner = GatewayTurnApplicationController();
    close = owner.close;
    home = ChatScreen(
      connection: connection,
      session: const Session(
        id: SessionFilesGateway.session,
        title: 'Field chat',
        model: 'fixture',
        source: 'desktop',
        messageCount: 1,
        isActive: false,
        preview: '',
        startedAt: 1,
      ),
      turnApplicationController: owner,
      testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
    );
  } else {
    final gateway = NextGenGateway(connection);
    final chat = NgChatController(
      gateway,
      sessionId: SessionFilesGateway.session,
      title: 'Field chat',
    );
    close = () async {
      chat.dispose();
      gateway.dispose();
    };
    await tester.runAsync(chat.open);
    home = NgScope(
      gateway: gateway,
      connManager: ConnectionManager(await SharedPreferences.getInstance()),
      connections: [connection],
      switchTo: (_) async {},
      addGateway: () async {},
      signOut: (_) async {},
      reload: () async {},
      signInAgain: () async {},
      child: NgChatView(chat: chat, onOpenSidebar: () {}, onNewChat: () {}),
    );
  }
  try {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: shell == _Chat.nextGen
            ? nextGenTheme(Brightness.light, NextGenLook.instance)
            : null,
        home: home,
      ),
    );
    await _wait(
      tester,
      find.text(SessionFilesGateway.transcript, findRichText: true),
    );
    expect(_pane, findsNothing);
    await exercise(wire);
    expect(network.blocked, isEmpty);
    expect(wire.methods, isNot(contains('prompt.submit')));
    expect(wire.methods, isNot(contains('session.create')));
    expect(
      wire.requests.map((r) => r.$2.path),
      isNot(contains('/api/fs/write-text')),
    );
    expect(tester.takeException(), isNull);
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await close();
    await tester.runAsync(wire.close);
    await tester.pump(const Duration(seconds: 16));
  }
}

Future<void> _openFolder(WidgetTester tester) async {
  await _tap(tester, find.byTooltip('Session files'));
  await _tap(tester, _inside(find.text('docs')));
  await _wait(tester, _file);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(mockChatImageRecovery);
  setUp(() => SharedPreferences.setMockInitialValues({'verbose_mode': false}));

  for (final shell in _Chat.values) {
    testWidgets(
      '${shell.name}: Session files refreshes an expanded tree, previews Markdown and attaches to the existing draft across a resize',
      (tester) async {
        await _withChat(tester, shell, (wire) async {
          final composer = _composer(shell);
          await tester.enterText(composer, 'My unsent question');
          final draft = tester.widget<TextField>(composer).controller!;
          await _openFolder(tester);
          expect(
            composer,
            findsNothing,
            reason: 'Phone: only the pane is visible.',
          );
          expect(
            tester
                .widget<TextField>(_composer(shell, skipOffstage: false))
                .controller,
            same(draft),
          );
          expect(_inside(find.text('before.txt')), findsOneWidget);
          wire.sibling = 'after.txt';
          await _tap(tester, find.byTooltip('Refresh tree'));
          await _wait(tester, _inside(find.text('after.txt')));
          expect(_inside(find.text('before.txt')), findsNothing);
          await _tap(tester, _file);
          await _wait(tester, find.byType(MarkdownFilePreview));
          await verifyMarkdownPreview(tester);

          tester.view.physicalSize = const Size(1120, 900);
          await tester.pumpAndSettle();
          expect(
            tester.getRect(composer).right,
            lessThanOrEqualTo(tester.getRect(_pane).left),
            reason: 'Wide: the composer and pane do not overlap.',
          );
          expect(
            find.text(SessionFilesGateway.transcript, findRichText: true),
            findsOneWidget,
          );
          await _tap(tester, _inside(find.text('Select lines')));
          final field = tester.widget<TextField>(_source);
          expect(field.readOnly, isTrue);
          expect(field.controller!.text, markdownFixture);
          // Set a selection just as the platform text controls do. An end offset
          // at the next line's start must not include that next line.
          field.controller!.selection = TextSelection(
            baseOffset: markdownFixture.indexOf('## Observations'),
            extentOffset: markdownFixture.indexOf('- Gamma'),
          );
          await _tap(tester, _inside(find.text('Attach selected lines')));
          await _wait(tester, find.byTooltip('Session files'));
          expect(_pane, findsNothing);
          expect(tester.widget<TextField>(composer).controller, same(draft));
          expect(
            draft.text,
            'My unsent question\n@file ${SessionFilesGateway.path}:3-5 ',
          );
          expect(wire.replacements, isEmpty);
        });
      },
    );
    testWidgets(
      '${shell.name}: guarded save preserves a conflicting draft, reviews the current host version, then saves and reads it back',
      (tester) async {
        await _withChat(tester, shell, (wire) async {
          await _openFolder(tester);
          await _tap(tester, _file);
          await _tap(tester, _inside(find.text('Edit')));
          const edit = '# My reconciled café notes\n';
          const other = '# Changed on the gateway\n';
          await tester.enterText(_source, edit);
          wire.competingWrite = other;
          await _tap(tester, _inside(find.text('Save')));
          expect(
            wire.replacements,
            isEmpty,
            reason: 'Confirmation precedes dispatch.',
          );
          await _tap(tester, find.widgetWithText(FilledButton, 'Save changes'));
          final review = _inside(find.text('Review gateway version'));
          await _wait(tester, review);
          expect(wire.replacements.single, {
            'session_id': SessionFilesGateway.session,
            'cwd': SessionFilesGateway.root,
            'path': SessionFilesGateway.path,
            'expected_sha256': SessionFilesGateway.hash(markdownFixture),
            'content': edit,
          });
          expect(wire.text, other);
          expect(tester.widget<TextField>(_source).controller!.text, edit);
          expect(
            tester
                .widget<TextButton>(
                  _inside(find.widgetWithText(TextButton, 'Save')),
                )
                .onPressed,
            isNull,
          );
          await _tap(tester, review);
          await _wait(
            tester,
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text(other),
            ),
          );
          await _tap(tester, find.text('Keep draft against this version'));
          expect(
            wire.replacements,
            hasLength(1),
            reason: 'Review is not confirmation to write.',
          );
          expect(tester.widget<TextField>(_source).controller!.text, edit);
          await _tap(tester, _inside(find.text('Save')));
          await _tap(tester, find.widgetWithText(FilledButton, 'Save changes'));
          await _wait(
            tester,
            _inside(find.text('Saved and verified on the gateway.')),
          );
          expect(wire.replacements.map((p) => p['expected_sha256']), [
            SessionFilesGateway.hash(markdownFixture),
            SessionFilesGateway.hash(other),
          ]);
          expect(wire.text, edit);
          expect(
            wire.reads.last,
            edit,
            reason: 'A receipt alone does not verify the bytes.',
          );
          expect(
            _inside(find.text('My reconciled café notes', findRichText: true)),
            findsOneWidget,
          );
        });
      },
    );
    testWidgets(
      '${shell.name}: reloading a preflight conflict discards only the file draft without sending a write',
      (tester) async {
        await _withChat(tester, shell, (wire) async {
          await tester.enterText(_composer(shell), 'Separate chat draft');
          await _openFolder(tester);
          await _tap(tester, _file);
          await _tap(tester, _inside(find.text('Edit')));
          await tester.enterText(_source, 'Discard this file draft');
          wire.text = '# New host text before save';
          await _tap(tester, _inside(find.text('Save')));
          await _tap(tester, find.widgetWithText(FilledButton, 'Save changes'));
          final review = _inside(find.text('Review gateway version'));
          await _wait(tester, review);
          expect(wire.reads.last, wire.text);
          wire.text = '# Latest at review';
          await _tap(tester, review);
          await _wait(
            tester,
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text(wire.text),
            ),
          );
          await _tap(tester, find.text('Discard draft and reload'));
          expect(
            _inside(find.text('Latest at review', findRichText: true)),
            findsOneWidget,
          );
          expect(_source, findsNothing);
          await _tap(tester, find.byTooltip('Back to tree'));
          await _tap(tester, find.byTooltip('Close session files'));
          expect(
            tester.widget<TextField>(_composer(shell)).controller!.text,
            'Separate chat draft',
          );
          expect(wire.replacements, isEmpty);
        });
      },
    );
  }
}
