// Uses the repository's theme_app_integration_test RepaintBoundary capture
// convention. All data are generated locally; no gateway is connected.
import 'dart:io';
import 'dart:async';
import 'package:hermes_android/core/desktop/desktop_integration.dart';
import 'package:hermes_android/core/desktop/desktop_os.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/settings/settings_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/settings_fixture.dart';
import 'support/settings_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final mode in SettingsMode.values) {
    for (final brightness in Brightness.values) {
      for (final size in [const Size(390, 844), const Size(1280, 900)]) {
        final name =
            '${mode.name}-${brightness.name}-${size.width < 600 ? 'phone' : 'desktop'}';
        testWidgets(
          'real redesigned settings capture $name',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            SharedPreferences.setMockInitialValues({
              NextGenPreferences.enabledKey: mode == SettingsMode.nextgen,
              NextGenPreferences.themeModeKey: brightness.name,
              'theme_mode': brightness.name,
            });
            SettingsFixture.platforms();
            final fixture = SettingsFixture(
              await SharedPreferences.getInstance(),
            );
            DesktopIntegration? integration;
            if (size.width >= 600) {
              final messenger = TestDefaultBinaryMessengerBinding
                  .instance
                  .defaultBinaryMessenger;
              messenger.setMockMethodCallHandler(
                DesktopOsChannels.shell,
                (call) async =>
                    call.method == 'isTraySupported' ||
                    call.method == 'setTray',
              );
              messenger.setMockMethodCallHandler(
                DesktopOsChannels.hotkey,
                (call) async => call.method == 'isSupported' ? true : null,
              );
              integration = DesktopIntegration(preferences: fixture.prefs)
                ..start();
              addTearDown(() => unawaited(integration!.dispose()));
            }
            NextGenPreferences.load(fixture.prefs);
            addTearDown(fixture.dispose);
            await tester.runAsync(() async {
              final root =
                  Platform.environment['FLUTTER_ROOT'] ??
                  '/opt/homebrew/share/flutter';
              for (final font in {
                'Roboto':
                    '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
                'MaterialIcons':
                    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
                'Geist': 'assets/fonts/geist/Geist-Regular.ttf',
              }.entries) {
                final file = File(font.value);
                if (await file.exists()) {
                  await (FontLoader(font.key)..addFont(
                        Future.value(
                          ByteData.sublistView(await file.readAsBytes()),
                        ),
                      ))
                      .load();
                }
              }
            });
            await tester.pumpWidget(
              fixture.app(mode, brightness: brightness, realFonts: true),
            );
            await tester.pumpAndSettle();
            expect(
              find.byKey(const ValueKey('settings-category-appearance')),
              findsOneWidget,
            );
            Future<void> capture(String suffix) async {
              expect(tester.takeException(), isNull);
              final directory =
                  Platform.environment['HERMES_WORKSPACE_PREVIEW_DIR'];
              if (directory == null) return;
              final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(settingsCaptureKey),
              );
              await tester.runAsync(() async {
                await Directory(directory).create(recursive: true);
                final image = await boundary.toImage(pixelRatio: 1);
                final data = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                await File(
                  '$directory/$name-$suffix.png',
                ).writeAsBytes(data!.buffer.asUint8List());
                image.dispose();
              });
            }

            await capture('categories');
            await openSettingsCategory(tester, 'appearance');
            expect(
              find.byKey(const ValueKey('settings-control-text-size')),
              findsOneWidget,
            );
            await capture('appearance');
            await tester.pageBack();
            await tester.pumpAndSettle();
            await openSettingsCategory(tester, 'notifications');
            expect(
              find.byKey(const ValueKey('completion-sound')),
              findsOneWidget,
            );
            await capture('notifications');
            await tester.pageBack();
            await tester.pumpAndSettle();
            await openSettingsCategory(tester, 'device');
            expect(
              find.byKey(const ValueKey('settings-control-device.keep-awake')),
              findsOneWidget,
            );
            if (size.width >= 600) {
              expect(
                find.byKey(const Key('desktop-tray-switch')),
                findsOneWidget,
              );
              expect(find.text('Battery optimisation settings'), findsNothing);
            }
            await capture('device');
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          },
          variant: TargetPlatformVariant.only(
            size.width < 600 ? TargetPlatform.android : TargetPlatform.linux,
          ),
        );
      }
    }
  }
}
