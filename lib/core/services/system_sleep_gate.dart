/// App-wide "the computer is asleep or the session is locked" signal.
///
/// The desktop runners report suspend/resume and lock/unlock on
/// `com.hermesagent.ares/power` (see `lib/core/desktop/power_events.dart`).
/// While [value] is true, gateway clients close their live sockets and stop
/// reconnecting; when it turns false they reconnect and re-bind stored
/// sessions with `session.resume`. Nothing is replayed: a prompt whose
/// submission was in flight is reconciled from history by the existing
/// recovery journal, never sent again.
library;

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

class SystemSleepGate extends ChangeNotifier implements ValueListenable<bool> {
  SystemSleepGate._();

  static final SystemSleepGate instance = SystemSleepGate._();

  bool _suspended = false;
  bool _locked = false;

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
        // Waking does not unlock a session that locked on the way down.
        _suspended = false;
      case PowerEvent.lock:
        _locked = true;
      case PowerEvent.unlock:
        _locked = false;
    }
    if (value != before) notifyListeners();
  }

  /// Clears both flags (listener shutdown, tests).
  void clear() {
    final before = value;
    _suspended = false;
    _locked = false;
    if (before) notifyListeners();
  }
}
