import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hermes_android/core/services/keep_awake.dart';
import 'package:hermes_android/core/widgets/keep_awake_settings_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The card probes the native power channel on mount; without a mock the
  // call never resolves and the test waits on a pending future forever.
  // Default: unsupported runner.
  late TestDefaultBinaryMessenger messenger;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.hermesagent.ares/power'),
      (_) async => false,
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.hermesagent.ares/power'),
      null,
    );
  });

  testWidgets('renders the three modes and the current default (off)', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: KeepAwakeSettingsCard(preferences: prefs)),
      ),
    );
    expect(find.text('Keep computer awake'), findsOneWidget);
    expect(find.byKey(const Key('keep-awake-mode-off')), findsOneWidget);
    expect(find.byKey(const Key('keep-awake-mode-whileWorking')), findsOneWidget);
    expect(find.byKey(const Key('keep-awake-mode-always')), findsOneWidget);
    expect(find.byKey(const Key('keep-awake-mode-off')), findsOneWidget);

    // Default mode: Off. (Both chips exist; the off chip is selected.)
    final offChip = tester.widget<ChoiceChip>(
      find.byKey(const Key('keep-awake-mode-off')),
    );
    expect(offChip.selected, isTrue);
  });

  testWidgets('selecting a mode writes the policy store', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: KeepAwakeSettingsCard(preferences: prefs)),
      ),
    );
    await tester.tap(find.byKey(const Key('keep-awake-mode-always')));
    await tester.pumpAndSettle();
    final store = KeepAwakePolicyStore(prefs);
    expect(store.read(), KeepAwakeMode.always);
  });

  testWidgets('shows the opt-in note when the power channel is absent', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: KeepAwakeSettingsCard(preferences: prefs)),
      ),
    );
    await tester.pumpAndSettle();
    // No native runner on the test platform: the card must say so honestly.
    expect(
      find.byKey(const Key('keep-awake-capability-note')),
      findsOneWidget,
    );
    expect(
      find.textContaining('not active on this platform runner'),
      findsOneWidget,
    );
  });
}
