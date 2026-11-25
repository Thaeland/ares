import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/connection_mutation_barrier.dart';
import 'package:hermes_android/core/services/gateway_fleet.dart';
import 'package:hermes_android/core/services/remote_workspace.dart';
import 'package:hermes_android/nextgen/data/chat_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_origin_test.dart' show MemoryCredentials;
import 'support/fleet_fixture.dart';
import 'support/mtls_fixture.dart';

Future<void> until(bool Function() ready) async {
  final clock = Stopwatch()..start();
  while (!ready() && clock.elapsed < const Duration(seconds: 8)) {
    await Future<void>.delayed(const Duration(milliseconds: 8));
  }
  expect(ready(), isTrue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GatewayFleet fleet;
  late ConnectionManager manager;
  late FleetFixture a, b;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    manager = ConnectionManager(
      await SharedPreferences.getInstance(),
      credentialStore: MemoryCredentials(),
      nativePushSupported: false,
    );
    fleet = GatewayFleet(manager);
    a = await FleetFixture.start('A');
    b = await FleetFixture.start('B');
    for (final f in [a, b]) {
      final c = f.connection;
      await manager.saveConnection(
        c.label,
        c.host,
        c.port,
        '',
        dashboardPort: c.port,
        dashboardUsername: 'test',
        dashboardPassword: c.dashboardPassword,
        gatewayProfile: 'work',
        desktopGatewayUrl: c.desktopGatewayUrl,
      );
    }
  });
  tearDown(() async {
    fleet.dispose();
    await a.close();
    await b.close();
  });
  Future<FleetHost> attach(String name) => fleet.attach(
    manager.getConnections().singleWhere((c) => c.label == 'Gateway $name').id,
  );
  test(
    'two peers with colliding IDs keep separate transcripts and reconnect without resubmitting',
    () => withPlatformTrust(() async {
      final [ha, hb] = await Future.wait([attach('A'), attach('B')]);
      await until(() => ha.target != null && hb.target != null);
      final ta = ha.target!, tb = hb.target!;
      final ra = ha.sessions.single, rb = hb.sessions.single;
      await expectLater(
        ha.openSession(rb, tb),
        throwsA(isA<WorkspaceException>()),
      );
      final [ca, cb] = await Future.wait([
        ha.openSession(ra, ta),
        hb.openSession(rb, tb),
      ]);
      await until(() => ca.runtimeId == 'runtime' && cb.runtimeId == 'runtime');
      expect(
        await Future.wait([ha.send(ra, ca, 'alpha'), hb.send(rb, cb, 'beta')]),
        [true, true],
      );
      a.event('message.delta', {'text': 'one'});
      b.event('message.delta', {'text': 'two'});
      String output(NgChatController c) =>
          c.items.whereType<NgAssistantItem>().map((i) => i.text).join();
      await until(() => output(ca) == 'one' && output(cb) == 'two');
      await a.sockets.single.close();
      b.event('message.delta', {'text': '!'});
      await until(() => !ta.isCurrent && output(cb) == 'two!');
      await until(() => a.issued == 2 && ha.target != null);
      expect(hb.target, same(tb));
      expect(a.prompts, ['alpha']);
      expect(b.prompts, ['beta']);
      final lease = ConnectionMutationBarrier.begin([ha.gateway.connection.id]);
      lease.release();
      expect(ha.current, isFalse);
      expect(fleet.host(ha.gateway.connection.id), isNull);
      expect(hb.current, isTrue);
    }),
  );
  test(
    'Cloud organisation receipt, safe URL, registry primary and single-key PATCH use the serving owner',
    () => withPlatformTrust(() async {
      final host = await attach('A');
      await until(() => host.target != null);
      final t = host.target!;
      final org = (await t.discoverCloud()).choices.single;
      expect(org.name, 'Fixture team');
      expect(
        (await t.discoverCloud(orgId: org.id)).agents.single.address,
        Uri.parse('https://agent.invalid'),
      );
      a.orgEcho = 'elsewhere';
      await expectLater(
        t.discoverCloud(orgId: org.id),
        throwsA(isA<WorkspaceException>()),
      );
      a.orgEcho = 'team';
      a.agentUrl = 'https://agent.invalid/?ticket=example';
      await expectLater(
        t.discoverCloud(orgId: org.id),
        throwsA(isA<WorkspaceException>()),
      );
      final reg = await t.webappRegistry();
      expect(reg.toString(), isNot(contains('never-render')));
      final after = await t.setWebappPrimary(reg.entries.last);
      expect(after.primary, 'other');
      expect(after.lastUsed, 'local');
      expect(await t.webappDirection(), WebappDirection.auto);
      expect(
        await t.setWebappDirection(WebappDirection.rtl),
        WebappDirection.rtl,
      );
      expect(
        await t.setWebappDirection(WebappDirection.auto),
        WebappDirection.auto,
      );
      expect(a.writes.last.body, {
        'values': {'hermes.desktop.textDirection': null},
        'seed': false,
      });
      expect(a.writes.length, 3);
      expect(b.requests, isEmpty);
    }),
  );
}
