import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/screens/workspace_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/connection_mutation_barrier.dart';
import 'package:hermes_android/core/services/gateway_turn_application_controller.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_l10n.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/chat_view.dart';
import 'package:hermes_android/nextgen/ui/more_page.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_voice_composer_adapter.dart';
import 'support/mtls_fixture.dart';
import 'support/workspace_worker_peer.dart';

Future<void> visible(WidgetTester tester, Finder finder) async {
  final elapsed = Stopwatch()..start();
  while (finder.evaluate().isEmpty &&
      elapsed.elapsed < const Duration(seconds: 6)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(finder, findsWidgets);
}

void main() {
  for (final entry in [
    'Classic More',
    'NextGen More',
    'Classic parent chat',
    'NextGen parent chat',
  ]) {
    testWidgets(
      '$entry: use the displayed owner, not a transcript or active chat',
      (tester) async {
        final classic = !entry.startsWith('NextGen');
        final parentChat = entry.endsWith('chat');
        SharedPreferences.setMockInitialValues({});
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(420, 950);
        addTearDown(tester.view.reset);
        const picker = MethodChannel('plugins.flutter.io/image_picker');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          picker,
          (_) async => null,
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            picker,
            null,
          ),
        );
        final peer = (await tester.runAsync(WorkerPeer.start))!;
        final c = peer.connection;
        final prefs = await SharedPreferences.getInstance();
        NextGenGateway? ng;
        NgChatController? ngChat;
        final controller = GatewayTurnApplicationController();
        await withPlatformTrust(() async {
          try {
            if (!classic) {
              ng = NextGenGateway(c);
              await tester.runAsync(() async {
                await ng!.connected();
                if (parentChat) {
                  ngChat = NgChatController(ng!, sessionId: 'stored-A');
                  await ngChat!.open();
                  return;
                }
                await ng!.call('session.resume', {
                  'session_id': 'stored-A',
                  'omit_messages': true,
                });
              });
            }
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
                home: ngChat != null
                    ? NgChatView(
                        chat: ngChat!,
                        onOpenSidebar: () {},
                        onNewChat: () {},
                      )
                    : parentChat
                    ? ChatScreen(
                        connection: c,
                        session: const Session(
                          id: 'stored-A',
                          title: 'Parent',
                          model: 'fixture',
                          source: 'test',
                          messageCount: 1,
                          isActive: false,
                          preview: '',
                          startedAt: 1,
                        ),
                        turnApplicationController: controller,
                        testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
                      )
                    : classic
                    ? WorkspaceScreen(
                        connection: c,
                        sessionsLoader: () async => [],
                      )
                    : NgMorePage(onOpenSession: (_) {}),
              ),
            );
            await tester.pump();
            if (parentChat) {
              await visible(tester, find.byTooltip('Live workers'));
              await tester.tap(find.byTooltip('Live workers'));
            } else {
              if (classic) {
                await tester.tap(find.text('More').last);
                await tester.pumpAndSettle();
              }
              await tester.ensureVisible(find.text('Live workers'));
              await tester.tap(find.text('Live workers'));
              await visible(tester, find.text('Stored session: stored-B'));
              expect(
                find.textContaining('Background process: 3'),
                findsWidgets,
              );
              expect(peer.calls('subagent.roster'), [
                {'profile': 'work'},
              ]);
              expect(peer.calls('subagent.list'), isEmpty);
              if (classic) {
                expect(peer.calls('session.resume'), isEmpty);
                expect(find.textContaining('Counts only.'), findsNWidgets(2));
                peer.backgroundB = 7;
                await tester.tap(find.byTooltip('Refresh'));
                await visible(
                  tester,
                  find.textContaining('Background process: 7'),
                );
                expect(peer.calls('subagent.roster'), hasLength(2));
              } else {
                await tester.tap(find.text('Stored session: stored-A'));
              }
            }
            if (parentChat || !classic) {
              await visible(tester, find.text('Task second'));
              expect(find.text('not live'), findsNothing);
              await tester.tap(find.text('Task second'));
              await tester.pump();
              final draft = find.byWidgetPredicate(
                (w) =>
                    w is TextField &&
                    w.decoration?.labelText == 'Steer · second',
              );
              await tester.enterText(draft, 'second worker only');
              await tester.pump();
              peer.receipt = 'rejected';
              await tester.tap(find.widgetWithText(FilledButton, 'Steer'));
              await visible(
                tester,
                find.text("the running turn didn't accept it"),
              );
              expect(
                tester.widget<TextField>(draft).controller!.text,
                'second worker only',
              );
              peer.receipt = 'queued';
              await tester.tap(find.widgetWithText(FilledButton, 'Steer'));
              await visible(tester, find.text('Queued'));
              expect(tester.widget<TextField>(draft).controller!.text, isEmpty);
              expect(peer.calls('subagent.steer'), [
                for (var i = 0; i < 2; i++)
                  {
                    'session_id': 'runtime-A',
                    'subagent_id': 'second',
                    'text': 'second worker only',
                    'profile': 'work',
                  },
              ]);
              expect(peer.calls('session.steer'), isEmpty);
              expect(peer.calls('prompt.submit'), isEmpty);
            }
            ConnectionMutationBarrier.begin([c.id]).release();
            await visible(
              tester,
              find.text('The gateway connection dropped. Try again.'),
            );
            expect(find.text('Task second'), findsNothing);
          } finally {
            await tester.pumpWidget(const SizedBox());
            ngChat?.dispose();
            ng?.dispose();
            await tester.runAsync(() async {
              await controller.close();
              await peer.close();
            });
            await tester.pump(const Duration(seconds: 35));
          }
        });
      },
    );
  }
}
