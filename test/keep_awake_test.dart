import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/keep_awake.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('KeepAwakePolicyStore', () {
    test('defaults to off when unset', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = KeepAwakePolicyStore(prefs);
      expect(store.read(), KeepAwakeMode.off);
    });

    test('round-trips every mode', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = KeepAwakePolicyStore(prefs);
      for (final mode in KeepAwakeMode.values) {
        await store.write(mode);
        expect(prefs.getString(KeepAwakePolicyStore.preferenceKey), mode.name);
        expect(store.read(), mode);
      }
    });

    test('unknown values fall back to off without erasing storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(KeepAwakePolicyStore.preferenceKey, 'forever');
      final store = KeepAwakePolicyStore(prefs);
      expect(store.read(), KeepAwakeMode.off);
    });
  });

  group('KeepAwakeController', () {
    Future<KeepAwakePolicyStore> storeWith(KeepAwakeMode mode) async {
      final prefs = await SharedPreferences.getInstance();
      final store = KeepAwakePolicyStore(prefs);
      await store.write(mode);
      return store;
    }

    test('stays off when mode is off', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.off),
      );
      controller.setWorking(true);
      expect(calls, isEmpty);
      controller.dispose();
      expect(calls, isEmpty);
    });

    test('whileWorking awakes only during a turn', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.whileWorking),
      );
      controller.setWorking(true);
      controller.setWorking(false);
      expect(calls, [true, false]);
    });

    test('always awakes on refresh regardless of working flag', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.always),
      );
      controller.setWorking(false);
      expect(calls.length, 1);
      expect(calls.last, isTrue);
    });

    test(
      'dispose releases the wake flag without touching the stored policy',
      () async {
        final calls = <bool>[];
        final policy = await storeWith(KeepAwakeMode.always);
        final controller = KeepAwakeController(
          adapter: _RecordingAdapter(calls),
          store: policy,
        );
        controller.dispose();
        expect(calls.isNotEmpty, isTrue);
        expect(calls.last, isFalse);
        expect(policy.read(), KeepAwakeMode.always);
      },
    );

    test('every way a turn ends releases whileWorking: finished, failed, '
        'cancelled', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.whileWorking),
      );
      // The app root reports "no active turn" however the turn settled.
      for (final _ in ['finished', 'failed', 'cancelled']) {
        controller.setWorking(true);
        expect(controller.isAwake, isTrue);
        controller.setWorking(false);
        expect(controller.isAwake, isFalse);
      }
      expect(calls, [true, false, true, false, true, false]);
      controller.dispose();
    });

    test(
      'background releases and resume re-takes only while still wanted',
      () async {
        final calls = <bool>[];
        final controller = KeepAwakeController(
          adapter: _RecordingAdapter(calls),
          store: await storeWith(KeepAwakeMode.whileWorking),
        );
        controller.setWorking(true);
        controller.setBackground(true);
        expect(controller.isAwake, isFalse);
        controller.setBackground(false);
        expect(controller.isAwake, isTrue);
        // The turn ends while backgrounded: resume must not take it again.
        controller.setBackground(true);
        controller.setWorking(false);
        controller.setBackground(false);
        expect(controller.isAwake, isFalse);
        expect(calls, [true, false, true, false]);
        controller.dispose();
      },
    );

    test('always is released in the background too', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.always),
      );
      controller.setBackground(true);
      controller.setBackground(false);
      expect(calls, [true, false, true]);
      controller.dispose();
    });

    test('a controller created in the background takes nothing', () async {
      final calls = <bool>[];
      final controller = KeepAwakeController(
        adapter: _RecordingAdapter(calls),
        store: await storeWith(KeepAwakeMode.always),
        background: true,
      );
      expect(calls, isEmpty);
      controller.setBackground(false);
      expect(calls, [true]);
      controller.dispose();
    });
  });
}

class _RecordingAdapter implements KeepAwakeAdapter {
  _RecordingAdapter(this.calls);

  final List<bool> calls;

  @override
  void setAwake({required String owner, required bool enabled}) {
    calls.add(enabled);
  }
}
