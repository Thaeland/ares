import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/composer/composer_commands.dart';
import 'package:hermes_android/core/composer/composer_drag.dart';
import 'package:hermes_android/core/composer/composer_intake.dart';
import 'package:hermes_android/core/composer/context_status.dart';
import 'package:hermes_android/core/composer/emoji_completion.dart';
import 'package:hermes_android/core/composer/failure_recovery.dart';
import 'package:hermes_android/core/composer/prompt_snippets.dart';
import 'package:hermes_android/core/composer/reference_completion.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/core/widgets/failure_recovery_card.dart';
import 'package:hermes_android/core/widgets/prompt_snippet_sheet.dart';
import 'package:hermes_android/core/widgets/resume_session_picker.dart';
import 'package:hermes_android/l10n/app_localizations.dart';

void main() {
  test(
    'at starters do not invent paths, and a bare kind asks for that listing',
    () {
      expect(starterSuggestions(''), isNotEmpty);
      expect(pathCompletionWord('file'), '@file:');
      expect(pathCompletionWord('src/main'), '@src/main');
      expect(parseReferenceCompletions(const {'items': []}), isEmpty);
      final rows = parseReferenceCompletions({
        'items': [
          {'text': '@file:lib/main.dart', 'display': 'main.dart'},
        ],
      });
      expect(rows.single.insert, '@file:lib/main.dart');
      expect(rows.single.kind, 'file');
    },
  );

  test('chips copy the path and can be removed', () {
    const text = 'see @file:lib/main.dart and @diff';
    final chips = referenceChips(text);
    expect(chips.map((chip) => chip.kind), ['file', 'diff']);
    expect(chips.first.value, 'lib/main.dart');
    expect(
      removeChip(text, chips.first),
      isNot(contains('@file:lib/main.dart')),
    );
  });

  test('emoji completion ignores clock times and inserts the character', () {
    expect(activeTrigger('12:30', 5, ':'), isNull);
    final token = activeTrigger('hi :jo', 6, ':');
    expect(token?.query, 'jo');
    expect(emojiMatches('jo').single.character, kComposerEmoji['joy']);
    expect(applyInsert('hi :jo', token!.start, token.end, 'x'), 'hi x');
  });

  test('status labels stay blank when the gateway omitted the figure', () {
    expect(cacheHitLabel(null), isEmpty);
    expect(cacheHitLabel(87), '87%');
    expect(tokensPerSecondLabel(null), isEmpty);
    expect(tokensPerSecondLabel(0), isEmpty);
    expect(tokensPerSecondLabel(41.6), '42 t/s');
    final omitted = parseUsageReading({'input_tokens': 3});
    expect(omitted.cacheHitPct, isNull);
    expect(omitted.avgTps, isNull);
    expect(
      parseContextBreakdown({'context_max': 0, 'categories': []}).usable,
      isFalse,
    );
    final layout = StatusBarLayout.defaults();
    expect(layout.visible('cache-hit-rate'), isFalse);
    expect(
      layout.setVisible('cache-hit-rate', true).visible('cache-hit-rate'),
      isTrue,
    );
  });

  test('failure actions follow the failure and drop account-only buttons', () {
    final now = DateTime.utc(2026, 1, 1).millisecondsSinceEpoch;
    final overflow = FailureSurface(
      layer: 'provider',
      code: 'context_overflow',
      retryable: false,
    );
    expect(actionsFor(overflow, nowMs: now).primary, RecoveryAction.compress);
    final presented = presentRecovery(
      FailureSurface(
        layer: 'billing',
        code: 'usage_window',
        retryable: false,
        usageLimit: UsageLimitInfo(
          suggestions: [ModelSuggestion(model: 'm', label: 'M', provider: 'p')],
        ),
      ),
      nowMs: now,
    );
    expect(presented.primary, RecoveryAction.switchToModel);
    expect(presented.secondary, isNull);
    expect(presented.omittedExternal, isTrue);
    expect(
      actionsFor(
        const FailureSurface(
          layer: 'gateway',
          code: 'SESSION_OWNER_UNCONFIRMED',
          retryable: false,
        ),
        nowMs: now,
      ).primary,
      isNull,
    );
    final resetsAt = (now ~/ 1000) + 30;
    expect(
      scheduledRetryDelayMs(resetsAt, now),
      inInclusiveRange(29000, 30000),
    );
    expect(scheduledRetryDelayMs((now ~/ 1000) + 100000000, now), isNull);
    final details = formatErrorDiagnostics(
      errorText: 'nope',
      surface: const FailureSurface(
        layer: 'provider',
        code: 'timeout',
        retryable: true,
      ),
    );
    expect(details, contains('code: timeout'));
    expect(details, isNot(contains('provider:')));
    expect(FailureSurface.parse({'message': 'plain'}), isNull);
  });

  test('side question, background and handoff use their RPCs', () async {
    final usage = planDedicated(name: 'btw', arg: '  ', sessionId: 's');
    expect(usage.consumed, isTrue);
    expect(usage.request, isNull);
    final missing = await runDedicatedCommand(
      name: 'bg',
      arg: 'look',
      sessionId: 's',
      rpc: (method, params) async {
        throw JsonRpcError(method, 'missing', code: -32601);
      },
    );
    expect(missing!.answer!.fallbackToExec, isTrue);
    final started = await runDedicatedCommand(
      name: 'background',
      arg: 'look',
      sessionId: 's',
      rpc: (_, _) async => {'task_id': 't1'},
    );
    expect(started!.answer!.notice, contains('t1'));
    expect(
      readHandoffPhase(state: 'pending', nowMs: 10, deadlineMs: 5),
      HandoffPhase.timedOut,
    );
    expect(
      readHandoffPhase(state: 'completed', nowMs: 10, deadlineMs: 5),
      HandoffPhase.completed,
    );
    expect(
      filterResume(const [
        ResumeCandidate(id: 'abc', title: 'Alpha', preview: ''),
        ResumeCandidate(id: 'zzz', title: 'Beta', preview: ''),
      ], 'alp').single.id,
      'abc',
    );
  });

  test('a handoff that handoff.fail reports completed is completed', () async {
    final calls = <String>[];
    var clock = 0;
    final outcome = await watchHandoff(
      rpc: (method, params) async {
        calls.add(method);
        clock += 30000;
        return method == 'handoff.fail'
            ? {'state': 'completed'}
            : {'state': 'pending'};
      },
      sessionId: 's',
      timeoutMessage: 'timed out',
      alive: () => true,
      interval: Duration.zero,
      clock: () => clock,
    );
    expect(outcome.phase, HandoffPhase.completed);
    expect(calls.last, 'handoff.fail');
    final failed = await watchHandoff(
      rpc: (method, params) async => {'state': 'failed', 'error': 'no bot'},
      sessionId: 's',
      timeoutMessage: 'timed out',
      alive: () => true,
      interval: Duration.zero,
    );
    expect(failed.phase, HandoffPhase.failed);
    expect(failed.error, 'no bot');
  });

  test('side answers carry Desktop headers and drop empty events', () {
    final btw = SideAnswer.fromEvent('btw.complete', const {
      'task_id': 'b1',
      'question': 'why',
      'text': 'because',
    })!;
    expect(btw.header, 'btw "why" (b1)');
    final bg = SideAnswer.fromEvent('background.complete', const {
      'task_id': 'g1',
      'text': 'done',
    })!;
    expect(bg.header, 'bg g1');
    expect(SideAnswer.fromEvent('btw.complete', const {'text': '  '}), isNull);
    expect(SideAnswer.fromEvent('review.summary', const {'text': 'x'}), isNull);
  });

  test('drops and pastes do not attach a path that is not on the device', () {
    expect(
      classifyDrag(
        const ComposerDrag(
          path: '/gw/a.dart',
          directory: false,
          onGateway: true,
        ),
      ).kind,
      LocalIntake.reference,
    );
    expect(
      classifyPaste(
        '/tmp/missing.png',
        pathExists: false,
        directory: false,
      ).kind,
      LocalIntake.leaveText,
    );
    expect(
      classifyPaste('/tmp/pic.png', pathExists: true, directory: false).kind,
      LocalIntake.imageFile,
    );
    expect(
      classifyPaste('x' * 3001, pathExists: false, directory: false).kind,
      LocalIntake.pastedText,
    );
    expect(
      insertSnippet(
        'hello',
        const TextSelection.collapsed(offset: 5),
        ' there',
      ),
      'hello there',
    );
  });

  testWidgets(
    'failure card offers compress and copies only reported diagnostics',
    (tester) async {
      var compressed = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FailureRecoveryCard(
              message: 'Context full',
              recovery: presentRecovery(
                const FailureSurface(
                  layer: 'provider',
                  code: 'context_overflow',
                  retryable: false,
                ),
                nowMs: 0,
              ),
              diagnosticsText: 'error: Context full',
              onCompress: () async => compressed = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Compress'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Compress'),
        ),
      );
      await tester.pump();
      expect(compressed, isTrue);
      expect(find.text('Open billing'), findsNothing);
    },
  );

  testWidgets('snippet sheet inserts the starter and resume search filters', (
    tester,
  ) async {
    final editor = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showPromptSnippets(context: context, editor: editor),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Code review'));
    await tester.pumpAndSettle();
    expect(editor.text, contains('missing tests'));

    ResumeCandidate? picked;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showResumePicker(
                context: context,
                initialQuery: '',
                listAvailable: true,
                load: (_) async => const [
                  ResumeCandidate(id: '1', title: 'Alpha', preview: ''),
                  ResumeCandidate(id: '2', title: 'Beta', preview: ''),
                ],
              );
            },
            child: const Text('resume'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('resume'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('resume-search')), 'bet');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Alpha'), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(picked?.id, '2');
  });
}
