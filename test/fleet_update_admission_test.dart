import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/services/fleet_ssh.dart';
import 'package:hermes_android/core/services/gateway_fleet.dart';
import 'package:hermes_android/core/services/hermes_sign_in.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:hermes_android/nextgen/nextgen_home.dart';
import 'package:hermes_android/nextgen/nextgen_preferences.dart';
import 'package:hermes_android/nextgen/theme/nextgen_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_origin_test.dart' show MemoryCredentials;
import 'support/fleet_fixture.dart';
import 'support/mtls_fixture.dart';
import 'support/parallel_workspace_fixture.dart';

Future<void> _until(bool Function() predicate) async {
  final w = Stopwatch()..start();
  while (!predicate() && w.elapsed < const Duration(seconds: 5)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(predicate(), true);
}

int _updatePosts(FleetFixture f) => f.requests
    .where((r) => r.method == 'POST' && r.uri.path == '/api/hermes/update')
    .length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HermesSignInVault.resetForTesting();
  });

  test(
    'a chat that starts while eligibility is rechecked holds the update POST',
    () => withPlatformTrust(() async {
      final manager = ConnectionManager(
        await SharedPreferences.getInstance(),
        credentialStore: MemoryCredentials(),
        nativePushSupported: false,
      );
      final fleet = GatewayFleet(manager);
      final a = await FleetFixture.start('A');
      try {
        final c = a.connection;
        final saved = await manager.saveSingleLoginConnection(
          url: GatewayUrl.parse(c.desktopGatewayUrl!),
          signInMethod: 'password',
          username: 'test',
          password: c.dashboardPassword,
          profile: 'work',
          fleetKind: 'direct',
        );
        final h = await fleet.attach(saved.id);
        await _until(() => h.target != null);
        h.attachProfile('studio', h.target!);
        final s = h.attachedProfiles.single;
        await _until(() => s.target != null);
        final row = s.sessions.single;
        final chat = await s.openSession(row, s.target!);
        await _until(() => chat.runtimeId != null);
        final update = (await fleet.checkUpdates()).single;
        expect(update.canStart, true);
        final release = a.holdCheck = Completer<void>();
        final started = update.start();
        try {
          await a.enteredCheck.future.timeout(const Duration(seconds: 4));
          expect(await s.send(row, chat, 'fixture-only', s.target!), true);
          expect(h.busyInstallation, true);
        } finally {
          release.complete();
        }
        await started;
        expect(_updatePosts(a), 0);
        expect(update.state, 'Skipped: a chat on this installation is running');
        expect(update.hasReceipt, false);
      } finally {
        fleet.dispose();
        await a.close();
      }
    }),
  );

  test(
    'a busy chat through another saved address for the same installation blocks the update',
    () => withPlatformTrust(() async {
      final manager = ConnectionManager(
        await SharedPreferences.getInstance(),
        credentialStore: MemoryCredentials(),
        nativePushSupported: false,
      );
      final fleet = GatewayFleet(manager);
      final a = await FleetFixture.start('A');
      try {
        Future<FleetHost> direct(String host, String profile) async {
          final saved = await manager.saveSingleLoginConnection(
            url: GatewayUrl.parse('http://$host:${a.server.port}'),
            signInMethod: 'password',
            username: 'test',
            password: 'fixture-A',
            profile: profile,
            fleetKind: 'direct',
          );
          return fleet.attach(saved.id);
        }

        final idle = await direct('127.0.0.1', 'work');
        final busy = await direct('localhost', 'studio');
        expect(idle.gateway.connection.id, isNot(busy.gateway.connection.id));
        await _until(() => idle.target != null && busy.target != null);
        expect(idle.installId, isNotNull);
        expect(busy.installId, idle.installId);
        final row = busy.sessions.single;
        final chat = await busy.openSession(row, busy.target!);
        await _until(() => chat.runtimeId != null);
        expect(await busy.send(row, chat, 'fixture-only', busy.target!), true);
        expect(busy.busyInstallation, true);
        expect(idle.busyInstallation, false);
        final plan = await fleet.checkUpdates();
        expect(plan.where((r) => r.canStart), isEmpty);
        for (final r in plan) {
          await r.start();
        }
        expect(_updatePosts(a), 0);
      } finally {
        fleet.dispose();
        await a.close();
      }
    }),
  );

  testWidgets('NextGen primary startup does not replace last-used routing', (
    t,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final manager = ConnectionManager(
      prefs,
      credentialStore: MemoryCredentials(),
      nativePushSupported: false,
    );
    final c = ParallelFixture(dashboard: true);
    final a = c.connection;
    final b = SavedConnection(
      id: 'last-used-B',
      label: 'B',
      host: '127.0.0.1',
      port: 2,
      apiKey: '',
    );
    await manager.importConnections([a, b], replaceExisting: true);
    await prefs.setString(
      'ares.fleet.primary.v1',
      sha256.convert(utf8.encode(jsonEncode(a.toMap()))).toString(),
    );
    await NextGenPreferences.setCurrentConnectionId(prefs, b.id);
    String? selectedId;
    await t.pumpWidget(
      MaterialApp(
        theme: nextGenTheme(Brightness.dark, NextGenLook.instance),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NextGenHome(
          connManager: manager,
          testGatewayFactory: (picked) {
            selectedId = picked.id;
            return ParallelFixtureGateway(c);
          },
        ),
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 350));
    final last = NextGenPreferences.currentConnectionId(prefs);
    await t.pumpWidget(const SizedBox.shrink());
    expect(selectedId, a.id);
    expect(last, b.id);
  });

  test(
    'an interrupted, empty host-key pin can be completed but never replaced',
    () async {
      final work = await Directory.systemTemp.createTemp('fleet-pin-');
      try {
        Future<SshPublicKey> key(String name) async {
          final path = File.fromUri(work.uri.resolve(name)).path;
          final gen = await Process.run('/usr/bin/ssh-keygen', [
            '-q',
            '-t',
            'ed25519',
            '-N',
            '',
            '-f',
            path,
          ]);
          expect(gen.exitCode, 0);
          final pub = (await File(
            '$path.pub',
          ).readAsString()).trim().split(' ');
          return SshPublicKey.parse('${pub[0]} ${pub[1]}');
        }

        final first = await key('k1'), second = await key('k2');
        final ssh = FleetSsh(Directory.fromUri(work.uri.resolve('pins/')));
        final d = SshDestination('127.0.0.1', 2222, 'fixture');
        // Simulate a crash between exclusive creation and the write.
        await ssh.enroll(d, first);
        final pin = Directory.fromUri(
          work.uri.resolve('pins/'),
        ).listSync(recursive: true).whereType<File>().single;
        await pin.writeAsString('');
        expect(await ssh.enrolled(d), isNull);
        await ssh.enroll(d, second);
        expect((await ssh.enrolled(d))?.encoded, second.encoded);
        await expectLater(
          ssh.enroll(d, first),
          throwsA(isA<FleetSshException>()),
        );
        expect((await ssh.enrolled(d))?.encoded, second.encoded);
      } finally {
        await work.delete(recursive: true);
      }
    },
  );
}
