// The Desktop integration card is reachable from both navigation trees on
// desktop (Classic Settings, NextGen Settings) and absent on phones.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/desktop/desktop_integration.dart';
import 'package:hermes_android/core/desktop/desktop_os.dart';
import 'package:hermes_android/core/screens/settings_screen.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/main.dart';
import 'package:hermes_android/nextgen/data/nextgen_gateway.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:hermes_android/nextgen/ui/nextgen_scope.dart';
import 'package:hermes_android/nextgen/ui/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _card = Key('desktop-integration-card');

class _Ng extends NextGenGateway {
  _Ng(super.connection);
  @override
  NgConnectionState get state =>
      const NgConnectionState(NgConnectionPhase.connected);
  @override
  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async => {};
}

Future<void> _pumpClassic(WidgetTester tester) async {
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(HermesApp(connManager: ConnectionManager(prefs)));
  await tester.pumpAndSettle();
  unawaited(
    Navigator.of(tester.element(find.byType(HomeScreen))).push<void>(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          connection: SavedConnection(
            id: 'desktop-settings',
            label: 'Offline',
            host: 'offline.test',
            port: 8642,
            apiKey: 'test-key',
          ),
          dashboardClient: DashboardClient(
            host: 'offline.test',
            port: 9119,
            httpClient: MockClient((_) async => http.Response('offline', 503)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<_Ng> _pumpNextGen(WidgetTester tester) async {
  final g = _Ng(
    SavedConnection(
      id: 'desktop-settings-ng',
      label: 'Offline',
      host: '127.0.0.1',
      port: 9,
      apiKey: '',
      dashboardProxied: true,
      dashboardPortOverride: 9,
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: nextGenTheme(Brightness.dark, NextGenLook.instance),
      home: NgScope(
        connManager: ConnectionManager(await SharedPreferences.getInstance()),
        gateway: g,
        connections: [g.connection],
        switchTo: (_) async {},
        addGateway: () async {},
        signOut: (_) async {},
        reload: () async {},
        signInAgain: () async {},
        child: const Scaffold(body: NgSettingsPage()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  return g;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Ares',
      packageName: 'com.hermesagent.hermes_android',
      version: '5.0.0-test',
      buildNumber: '5000',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (_) async => <Object>[],
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  testWidgets(
    'Classic Settings shows the card and the app root runs the integration',
    (tester) async {
      await _pumpClassic(tester);
      expect(DesktopIntegration.current, isNotNull);
      await tester.scrollUntilVisible(
        find.byKey(_card),
        300,
        scrollable: find
            .descendant(
              of: find.byType(SettingsScreen),
              matching: find.byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              ),
            )
            .first,
      );
      expect(find.byKey(_card), findsOneWidget);
      // The switch writes the device-local preference the root applies.
      tester
          .widget<SwitchListTile>(find.byKey(const Key('desktop-tray-switch')))
          .onChanged!(true);
      await tester.pump();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(DesktopOsPrefs.trayKey), isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(DesktopIntegration.current, isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'NextGen Settings shows the card on desktop',
    (tester) async {
      final g = await _pumpNextGen(tester);
      await tester.scrollUntilVisible(
        find.byKey(_card),
        300,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first,
      );
      expect(find.byKey(_card), findsOneWidget);
      expect(find.text('Quick entry shortcut'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      g.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'phones never show the card',
    (tester) async {
      final g = await _pumpNextGen(tester);
      for (var i = 0; i < 20; i++) {
        await tester.drag(
          find
              .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              )
              .first,
          const Offset(0, -400),
        );
        await tester.pump();
        expect(find.byKey(_card), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
      g.dispose();
      await tester.pump(const Duration(seconds: 1));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
