// Uses the repository's theme_app_integration_test RepaintBoundary capture
// convention. All data are generated locally; no gateway is connected.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
        testWidgets('real redesigned settings capture $name', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({});
          SettingsFixture.platforms();
          final fixture = SettingsFixture(
            await SharedPreferences.getInstance(),
          );
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
          await tester.pumpWidget(fixture.app(mode, brightness: brightness));
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
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        });
      }
    }
  }
}
