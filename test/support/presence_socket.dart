import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/ws_client.dart';

/// A socket that records each `client.activity` with the real time it was
/// sent. Presence ages input on a real clock, so tests advance it with
/// [waitRealSeconds].
class PresenceSocket implements WsClient {
  PresenceSocket({this.capable = false});
  bool capable;
  final clock = Stopwatch()..start();
  final reports = <Map<String, dynamic>>[];
  final at = <Duration>[];

  /// Other requests, when a chat view also uses this socket.
  final other = <String>[];

  @override
  bool get acceptsWindowActivity => capable;

  @override
  bool get isConnected => capable;

  @override
  int get socketEpoch => 1;

  @override
  Future<Map<String, dynamic>> send(
    String method,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
    void Function()? onSent,
    bool includeProfile = true,
  }) async {
    // A report names no profile (gateway/session_presence.py): one that does
    // is not counted. No expect() here: reports also go out during pump().
    if (method != 'client.activity' || includeProfile) {
      other.add(method);
      return {};
    }
    reports.add(params);
    at.add(clock.elapsed);
    return {};
  }

  String log() => [
    for (var i = 0; i < reports.length; i++)
      't=${at[i].inSeconds}s ${reports[i]}',
  ].join('\n');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Real seconds for the presence clock, with the same fake time for its
/// 10 s ticker, one second at a time.
Future<void> waitRealSeconds(WidgetTester tester, int seconds) async {
  for (var i = 0; i < seconds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 1)),
    );
    await tester.pump(const Duration(seconds: 1));
  }
}

/// The review probe's oracle, after input in [older] at t=0, in [newer] at
/// t=3 and a wait past 60 s: the socket claimed [older] once, then only
/// [newer]; the 45 s refresh re-claimed [newer] with its real idle time; and
/// nothing withdrew or claimed `away` while [newer] was in view.
void expectNewestPaneOnly(
  PresenceSocket socket, {
  required String older,
  required String newer,
}) {
  final log = socket.log();
  final claims = socket.reports.where(
    (r) => (r['sessions'] as List).isNotEmpty,
  );
  expect(claims.first['sessions'], [older], reason: log);
  final after = socket.reports.skip(socket.reports.indexOf(claims.first) + 1);
  expect(after, isNotEmpty, reason: log);
  for (final report in after) {
    expect(report['sessions'], [newer], reason: '$older is older:\n$log');
    expect(report.containsKey('away'), isFalse, reason: log);
  }
  final refreshed = after.where((r) => (r['idle_seconds'] as int) >= 40);
  expect(refreshed, isNotEmpty, reason: log);
  expect(refreshed.first['idle_seconds'], lessThan(60), reason: log);
}
