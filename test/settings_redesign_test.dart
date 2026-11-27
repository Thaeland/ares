import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/notification_prefs.dart';
import 'package:hermes_android/core/services/text_size_preference.dart';
import 'package:hermes_android/core/settings/settings_browser.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'support/settings_fixture.dart';
import 'support/settings_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SettingsFixture.platforms();
    nextGenEnabled.value = false;
    notificationPrefs.value = NotificationPrefs.defaults;
  });

  test('baseline inventory IDs and intended scope cannot disappear', () {
    final baseline =
        jsonDecode(
              File('test/fixtures/settings_inventory.json').readAsStringSync(),
            )
            as List;
    final lines = File('docs/settings-inventory.md').readAsLinesSync().where(
      (line) =>
          line.startsWith('| ') &&
          !line.startsWith('| Stable') &&
          !line.startsWith('| ---'),
    );
    final actual = {
      for (final line in lines)
        line.split('|')[1].trim(): line
            .split('|')
            .map((s) => s.trim())
            .toList(),
    };
    expect(actual.length, lines.length, reason: 'Unique stable IDs');
    expect(actual.keys.toSet(), baseline.map((e) => e['id']).toSet());
    for (final entry in baseline) {
      final row = actual[entry['id']]!;
      expect(row[3], entry['category'], reason: entry['id']);
      expect(row[4], entry['scope'], reason: entry['id']);
      expect(row[5], isNotEmpty);
    }
  });

  for (final mode in SettingsMode.values) {
    testWidgets(
      '${mode.name} search catalog has correct scope; browsing never switches mode',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();
        final fixture = SettingsFixture(prefs);
        addTearDown(fixture.dispose);
        await tester.pumpWidget(fixture.app(mode));
        await tester.pumpAndSettle();
        final browser = tester.widget<SettingsBrowser>(
          find.byType(SettingsBrowser),
        );
        final items = browser.items.where((e) => e.visibleIn(mode));
        expect(items.map((e) => e.id).toSet().length, items.length);
        expect(
          items
              .where((e) => e.scope != SettingsScope.shared)
              .every((e) => e.scope.name == mode.name),
          isTrue,
        );
        expect(
          items.any((e) => e.id == 'classic.chat.density'),
          mode == SettingsMode.classic,
        );
        expect(
          items.any((e) => e.id == 'ng.theme'),
          mode == SettingsMode.nextgen,
        );
        await openSettingsCategory(tester, 'chat');
        if (mode == SettingsMode.nextgen) {
          await tester.tap(find.byKey(const ValueKey('ng-reopen-chat')));
          await tester.pumpAndSettle();
          expect(prefs.getBool(NextGenPreferences.reopenKey), isFalse);
          expect(prefs.getString('verbose_mode'), isNull);
        } else {
          expect(find.byKey(const ValueKey('ng-reopen-chat')), findsNothing);
        }
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('settings-search')),
          'terminal font',
        );
        await tester.pumpAndSettle();
        final result = find.byKey(
          const ValueKey('settings-result-presentation.font.terminal'),
        );
        await tester.ensureVisible(result);
        await tester.tap(result);
        await tester.pumpAndSettle();
        expect(
          find
              .byKey(const ValueKey('presentation-terminal-font'))
              .hitTestable(),
          findsOneWidget,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(result, findsOneWidget, reason: 'Back retains search');
        expect(nextGenEnabled.value, isFalse);
        expect(prefs.getBool(NextGenPreferences.enabledKey), isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'shared nested text size and notification changes survive reopening other experience',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final fixture = SettingsFixture(prefs);
      addTearDown(fixture.dispose);
      await tester.pumpWidget(fixture.app(SettingsMode.classic));
      await tester.pumpAndSettle();
      await openSettingsCategory(tester, 'appearance');
      final textSize = find.byKey(const ValueKey('settings-control-text-size'));
      await tester.ensureVisible(textSize);
      await tester.tap(
        find.descendant(of: textSize, matching: find.byType(ListTile)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Large').last);
      await tester.tap(find.text('Large').last);
      await tester.pumpAndSettle();
      expect(TextSizePreferenceStore(prefs).read(), TextSizePreference.large);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        fixture.app(
          SettingsMode.nextgen,
          category: SettingsCategory.appearance,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Large'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openSettingsCategory(tester, 'notifications');
      final mute = find.byKey(const ValueKey('mute-app-sounds'));
      await tester.ensureVisible(mute);
      await tester.tap(mute);
      await tester.pumpAndSettle();
      expect(notificationPrefs.value.muteAppSounds, isTrue);
      expect(
        prefs.getString(NotificationPrefsStore.storageKey),
        contains('muteAppSounds'),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        fixture.app(
          SettingsMode.classic,
          category: SettingsCategory.notifications,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(mute).value, isTrue);
      expect(prefs.getKeys().where((k) => k.contains('notification')), {
        NotificationPrefsStore.storageKey,
      });
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'explicit mode action alone writes layout; appearance writes correct mode store',
    (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final fixture = SettingsFixture(prefs);
      addTearDown(fixture.dispose);
      await tester.pumpWidget(
        fixture.app(
          SettingsMode.nextgen,
          category: SettingsCategory.appearance,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pure black'));
      await tester.pumpAndSettle();
      expect(prefs.getBool(NextGenPreferences.pureBlackKey), isTrue);
      expect(prefs.getString('theme_mode'), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openSettingsCategory(tester, 'general');
      await tester.tap(find.byKey(const ValueKey('nextgen-toggle')));
      await tester.pumpAndSettle();
      expect(prefs.getBool(NextGenPreferences.enabledKey), isTrue);
      expect(nextGenEnabled.value, isTrue);
    },
  );

  testWidgets('gateway owner change ignores delayed signed-in identity', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final held = Completer<http.Response>();
    final old = SettingsFixture(
      prefs,
      id: 'old',
      reply: (request) => request.url.path.endsWith('auth/me')
          ? held.future
          : Future.value(http.Response('{}', 503)),
    );
    final current = SettingsFixture(prefs, id: 'current');
    addTearDown(old.dispose);
    addTearDown(current.dispose);
    await tester.pumpWidget(
      old.app(SettingsMode.nextgen, category: SettingsCategory.connections),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      current.app(SettingsMode.nextgen, category: SettingsCategory.connections),
    );
    await tester.pumpAndSettle();
    held.complete(
      http.Response(
        '{"username":"stale-person","display_name":"Stale owner"}',
        200,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Stale owner'), findsNothing);
    expect(find.textContaining('stale-person'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final mode in SettingsMode.values) {
    for (final category in [
      SettingsCategory.general,
      SettingsCategory.appearance,
      SettingsCategory.notifications,
      SettingsCategory.security,
    ]) {
      testWidgets('${mode.name} ${category.name} at 320px, large text, RTL', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final fixture = SettingsFixture(await SharedPreferences.getInstance());
        addTearDown(fixture.dispose);
        await tester.pumpWidget(
          fixture.app(
            mode,
            category: category,
            locale: const Locale('ar'),
            scale: 1.6,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
