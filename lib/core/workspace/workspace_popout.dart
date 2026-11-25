import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../nextgen/nextgen_preferences.dart';
import '../screens/parallel_workspace_entry.dart';
import '../services/connection_mutation_barrier.dart';
import '../services/hermes_sign_in.dart';
import '../services/notification_prefs.dart';
import 'popout_owner.dart';
import 'popout_protocol.dart';

bool get supportsWorkspacePopout =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };

final _openTargets = <String>{};

/// Tells a launched pop-out whenever sharing chat activity is off, so an
/// opt-out reaches open windows at once. Returns the remover. The child copied
/// the preference at launch; this line can only take authority away.
@visibleForTesting
VoidCallback forwardActivityOptOut(IOSink stdin) {
  var told = false;
  void sync() {
    if (notificationPrefs.value.shareWindowActivity) {
      told = false;
      return;
    }
    if (told) return;
    told = true;
    try {
      stdin.writeln(workspacePopoutStopActivity);
    } on Object {
      // The child has exited; its reports ended with it.
    }
  }

  notificationPrefs.addListener(sync);
  sync();
  return () => notificationPrefs.removeListener(sync);
}

/// Opens only from the keyed workspace entry. A launched child has no root
/// navigator, connection chooser or durable app-state writer. No shell, URI
/// handler, or separate installed executable participates in the hand-off.
Future<void> openWorkspacePopout(
  BuildContext context, {
  required String sessionId,
  required String connectionId,
  required String profile,
  required bool nextGen,
}) async {
  try {
    if (!supportsWorkspacePopout) throw UnsupportedError('Desktop only');
    final target = PopoutTarget(
      sessionId: sessionId,
      connectionId: connectionId,
      profile: profile,
      nextGen: nextGen,
    );
    final owner = ParallelWorkspaceEntryHost.popoutOwner(context);
    if (owner == null) throw StateError('No workspace owner');
    final connection = owner.connection;
    final nonce = const Uuid().v4();
    final proof = popoutOwnerProof(nonce, connection);
    bool current() =>
        owner.current() &&
        nextGenEnabled.value == nextGen &&
        matchesPopoutOwner(target, connection);
    if (!current()) throw StateError('Owner changed');
    if (!_openTargets.add(target.key)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('This chat already has a pop-out window.'),
        ),
      );
      return;
    }
    await _openNative(
      target,
      nonce,
      proof,
      current,
      () => popoutOwnerProof(nonce, connection) == proof,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open this saved chat. Check the connection and try again.',
          ),
        ),
      );
    }
  }
}

Future<void> _openNative(
  PopoutTarget target,
  String nonce,
  String proof,
  bool Function() current,
  bool Function() credentialsCurrent,
) async {
  Directory? directory;
  Process? child;
  var retired = false;
  var listening = true;
  VoidCallback? stopForwarding;
  final ready = Completer<bool>();
  void retire() {
    retired = true;
    child?.kill(
      Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sigkill,
    );
    if (!ready.isCompleted) ready.complete(false);
  }

  void check() {
    try {
      if (!current()) retire();
    } catch (_) {
      retire();
    }
  }

  void afterFrame(Duration _) {
    if (!listening || retired) return;
    // Route/gateway replacement and app-root disposal are visible after the
    // current frame. This callback watches frames; it never schedules one.
    check();
    if (!retired) WidgetsBinding.instance.addPostFrameCallback(afterFrame);
  }

  void checkCredentials() {
    try {
      if (!credentialsCurrent()) retire();
    } catch (_) {
      retire();
    }
  }

  void detach() {
    listening = false;
    stopForwarding?.call();
    stopForwarding = null;
    _openTargets.remove(target.key);
    ConnectionMutationBarrier.removeListener(check);
    HermesSignInVault.instance.removeListener(checkCredentials);
    nextGenEnabled.removeListener(check);
  }

  Future<void> clean() async {
    try {
      await directory?.delete(recursive: true);
    } on FileSystemException {
      // OS cache collection remains possible, e.g. after a machine crash.
    }
  }

  ConnectionMutationBarrier.addListener(check);
  HermesSignInVault.instance.addListener(checkCredentials);
  nextGenEnabled.addListener(check);
  WidgetsBinding.instance.addPostFrameCallback(afterFrame);
  try {
    final cache = await getTemporaryDirectory();
    await cache.create(recursive: true);
    directory = await cache.createTemp('ares-chat-');
    check();
    if (retired) throw StateError('Revoked');
    final process = child = await Process.start(
      Platform.resolvedExecutable,
      const [workspacePopoutMarker],
      workingDirectory: directory.path,
    );
    // Register exit cleanup before any other operation which might fail.
    process.stdin.done.ignore();
    unawaited(
      process.exitCode.then((_) async {
        if (!ready.isCompleted) ready.complete(false);
        detach();
        try {
          await process.stdin.close();
        } on IOException {
          // The reader has already exited.
        }
        await clean();
      }),
    );
    unawaited(process.stderr.drain<void>());
    process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .listen((line) {
          if (ready.isCompleted) return;
          if (line == workspacePopoutReady) ready.complete(true);
          if (line == workspacePopoutFailed) ready.complete(false);
        }, onError: (Object _) => retire());
    check();
    if (retired) {
      retire();
      throw StateError('Revoked');
    }
    process.stdin.writeln(
      jsonEncode({'target': target.toJson(), 'nonce': nonce, 'proof': proof}),
    );
    await process.stdin.flush(); // Keep the pipe open until exit.
    if (listening) stopForwarding = forwardActivityOptOut(process.stdin);
    final ok = await ready.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () => false,
    );
    check();
    if (!ok || retired) throw StateError('Unavailable');
  } catch (_) {
    retire();
    if (child == null) {
      detach();
      await clean();
    }
    rethrow;
  }
}
