/// Opt-in "keep the computer awake" policy.
///
/// The policy is device-local, off by default, and documented as opt-in by
/// the user in Settings. The current release keeps the Dart-side policy and
/// the adapter seam; native runners are expected to implement the
/// `com.hermesagent.ares/power` MethodChannel contract documented here. A
/// runner that does not implement the channel degrades to a no-op — the
/// policy is still read and stored, and the UI explains that wake control is
/// unavailable on this platform.
library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How long the computer is kept awake while Ares is working.
enum KeepAwakeMode {
  /// Never keep the computer awake.
  off,

  /// Keep awake only during an active turn (a turn in progress).
  whileWorking,

  /// Keep awake for as long as Ares is running.
  always,
}

/// Device-local policy store. Values round-trip as stable strings so a future
/// store can share a single preferences file.
class KeepAwakePolicyStore {
  KeepAwakePolicyStore(this._prefs);

  /// Preference key — stable and never reused for anything else.
  static const preferenceKey = 'keep_awake_mode';

  final SharedPreferences _prefs;

  KeepAwakeMode read() {
    final raw = _prefs.getString(preferenceKey);
    for (final mode in KeepAwakeMode.values) {
      if (raw == mode.name) return mode;
    }
    return KeepAwakeMode.off;
  }

  Future<void> write(KeepAwakeMode mode) async {
    await _prefs.setString(preferenceKey, mode.name);
  }
}

/// The native seam. A runner that implements the channel receives one
/// `setAwake` call with `{owner, enabled}` per state change; a runner that
/// does not implement it is a no-op.
abstract class KeepAwakeAdapter {
  /// Idempotent request: the channel may be absent (headless test or a
  /// platform without a runner implementation). Never throws.
  void setAwake({required String owner, required bool enabled});
}

/// Default adapter using a MethodChannel. Implements the documented
/// `com.hermesagent.ares/power` contract when a native runner provides it.
class MethodChannelKeepAwakeAdapter implements KeepAwakeAdapter {
  const MethodChannelKeepAwakeAdapter();

  /// Channel contract: `setAwake {owner, enabled}` → void.
  static const channel = MethodChannel('com.hermesagent.ares/power');

  @override
  void setAwake({required String owner, required bool enabled}) {
    unawaited(_send(owner, enabled));
  }

  Future<void> _send(String owner, bool enabled) async {
    try {
      await channel.invokeMethod<void>('setAwake', {
        'owner': owner,
        'enabled': enabled,
      });
    } on MissingPluginException {
      // No native implementation — a wake request is not an error.
    } on PlatformException {
      // Same reasoning.
    } on Exception {
      // Never throw into a turn.
    }
  }
}

/// Applies the policy for the active session. A single controller owns the
/// OS-level wake flag: closing an old chat cannot release a newer chat's flag.
class KeepAwakeController {
  KeepAwakeController({
    required this._adapter,
    required this._store,
  }) {
    final mode = _store?.read() ?? KeepAwakeMode.off;
    _apply(mode, working: false);
  }

  final KeepAwakeAdapter _adapter;
  final KeepAwakePolicyStore? _store;
  final String _owner = 'keep-awake-${DateTime.now().microsecondsSinceEpoch}';
  bool _awake = false;
  bool _busy = false;

  /// Current policy, mirroring the store.
  KeepAwakeMode get mode => _store?.read() ?? KeepAwakeMode.off;

  /// Whether the OS is currently told to stay awake.
  bool get isAwake => _awake;

  /// Begin/end a turn. A turn in flight keeps the computer awake when the
  /// policy is `whileWorking` or `always`.
  void setWorking(bool working) {
    if (_busy == working) return;
    _busy = working;
    _apply(_store?.read() ?? KeepAwakeMode.off, working: working);
  }

  /// Re-read the policy and re-apply it (call after a preference change).
  void refresh() {
    _apply(_store?.read() ?? KeepAwakeMode.off, working: _busy);
  }

  /// Refreshes the policy from the store — safe to call when the store is
  /// absent (headless test or an unsupported platform).
  void refreshFromStore() {
    _apply(_store?.read() ?? KeepAwakeMode.off, working: _busy);
  }

  void _apply(KeepAwakeMode mode, {required bool working}) {
    final shouldAwake = switch (mode) {
      KeepAwakeMode.off => false,
      KeepAwakeMode.whileWorking => working,
      KeepAwakeMode.always => true,
    };
    if (_awake == shouldAwake) return;
    _awake = shouldAwake;
    _adapter.setAwake(owner: _owner, enabled: shouldAwake);
  }

  /// Clean up: release the wake flag without touching the stored policy.
  void dispose() {
    _apply(KeepAwakeMode.off, working: false);
  }
}
