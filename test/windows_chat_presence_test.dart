import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/ws_client.dart';
import 'package:hermes_android/core/services/notification_prefs.dart';
import 'package:hermes_android/core/widgets/windows_chat_presence.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Socket implements WsClient {
  bool capable = false;
  final reports = <Map<String, dynamic>>[];
  @override
  bool get acceptsWindowActivity => capable;
  @override
  Future<Map<String, dynamic>> send(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
    void Function()? onSent,
    bool includeProfile = true,
  }) async {
    expect(method, 'client.activity');
    expect(includeProfile, isFalse);
    reports.add(params);
    return {};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'presence needs opt-in, a capable session and actual chat input; blur withdraws once',
    (t) async {
      SharedPreferences.setMockInitialValues({});
      notificationPrefs.value = NotificationPrefs.defaults;
      final a = _Socket(), b = _Socket()..capable = true;
      var target = (a, 'one');
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pumpWidget(
        MaterialApp(
          home: WindowsChatPresence(
            target: () => target,
            child: const ColoredBox(key: Key('chat'), color: Colors.black),
          ),
        ),
      );
      Future<void> touch() async {
        await t.tap(find.byKey(const Key('chat')));
        await t.pump();
      }

      await touch();
      expect(a.reports, isEmpty);
      await NotificationPrefsStore.setShareWindowActivity(true);
      await touch();
      expect(a.reports, isEmpty);
      a.capable = true;
      await touch();
      await touch();
      expect(a.reports.single, {
        'sessions': ['one'],
        'basis': 'page',
        'idle_seconds': 0,
        'can_alert': true,
      });
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await t.pump();
      expect(a.reports.last['away'], true);
      expect(a.reports.last['sessions'], isEmpty);
      target = (b, 'two');
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await t.pump(const Duration(seconds: 11));
      expect(b.reports, isEmpty);
      await touch();
      expect(b.reports.single['sessions'], ['two']);
      await NotificationPrefsStore.setShareWindowActivity(false);
      expect(b.reports.last['away'], true);
      await touch();
      expect(b.reports.length, 2);
      notificationPrefs.value = NotificationPrefs.defaults;
      await t.pumpWidget(const SizedBox());
    },
  );
}
