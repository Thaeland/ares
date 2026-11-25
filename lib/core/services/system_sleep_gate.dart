/// App-wide "the computer is asleep or the session is locked" signal.
///
/// The desktop runners report suspend/resume and lock/unlock on
/// `com.hermesagent.ares/power` (see `lib/core/desktop/power_events.dart`).
/// While [value] is true, gateway clients close their live sockets and stop
/// reconnecting; when it turns false they reconnect and re-bind stored
/// sessions with `session.resume`. Nothing is replayed: a prompt whose
/// submission was in flight is reconciled from history by the existing
/// recovery journal, never sent again.
///
/// The gate fails safe: a lock with no matching unlock (a locker that
/// unlocks without telling the session manager) never keeps the sockets
/// paused while the user is visibly using the app. Focus, pointer or key
/// input in the app lifts the pause ([noteUserActivity]), and a resume
/// re-reads the lock state from the runner ([lockProbe]).
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

enum PowerEvent {
  suspend,
  resume,
  lock,
  unlock;

  static PowerEvent? fromWire(Object? name) {
    for (final event in values) {
      if (event.name == name) return event;
    }
    return null;
  }
}

/// Asks the runner whether the session is locked right now: true or false,
/// or null when it cannot tell.
typedef LockStateProbe = Future<bool?> Function();

class SystemSleepGate extends ChangeNotifier implements ValueListenable<bool> {
  SystemSleepGate._();

  static final SystemSleepGate instance = SystemSleepGate._();

  bool _suspended = false;
  bool _locked = false;

  /// Set by the power listener of the primary window; null without a
  /// runner that can answer.
  LockStateProbe? lockProbe;

  /// True while sockets should stay paused.
  @override
  bool get value => _suspended || _locked;

  bool get suspended => _suspended;
  bool get locked => _locked;

  void apply(PowerEvent event) {
    final before = value;
    switch (event) {
      case PowerEvent.suspend:
        _suspended = true;
      case PowerEvent.resume:
        // Waking does not unlock a session that locked on the way down, but
        // the lock state is read again: a lock whose unlock was never
        // reported must not outlive the wake.
        _suspended = false;
      case PowerEvent.lock:
        _locked = true;
      case PowerEvent.unlock:
        _locked = false;
    }
    if (value != before) notifyListeners();
    if (event == PowerEvent.resume) unawaited(recheckLock());
  }

  /// The user is visibly using the app (it regained focus, or got pointer or
  /// key input): the computer is awake and the session unlocked, whatever
  /// the last event said.
  void noteUserActivity() {
    if (!value) return;
    _suspended = false;
    _locked = false;
    notifyListeners();
  }

  /// Re-reads the lock state from the runner. An unlocked answer lifts the
  /// lock; an unknown answer keeps it until the user is back in the app.
  Future<void> recheckLock() async {
    final probe = lockProbe;
    if (probe == null || !_locked) return;
    bool? locked;
    try {
      locked = await probe();
    } catch (_) {
      locked = null;
    }
    if (locked == false && _locked) apply(PowerEvent.unlock);
  }

  /// Clears both flags (listener shutdown, tests).
  void clear() {
    final before = value;
    _suspended = false;
    _locked = false;
    if (before) notifyListeners();
  }
}
