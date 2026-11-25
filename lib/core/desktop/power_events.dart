/// Suspend/resume and lock/unlock events from the desktop runners.
///
/// The runners call `onPowerEvent` on `com.hermesagent.ares/power` with
/// `suspend`, `resume`, `lock` or `unlock`. The events feed
/// [SystemSleepGate], which pauses the gateway sockets until the computer
/// is awake and unlocked again. The same channel carries the keep-awake
/// requests (`keep_awake.dart`), which run while a turn is active if the
/// user chose that.
library;

import 'package:flutter/services.dart';

import '../services/system_sleep_gate.dart';
import 'desktop_os.dart';

class PowerEventsListener {
  PowerEventsListener({
    this._channel = DesktopOsChannels.power,
    SystemSleepGate? gate,
  }) : _gate = gate ?? SystemSleepGate.instance;

  final MethodChannel _channel;
  final SystemSleepGate _gate;
  bool _started = false;
  bool _disposed = false;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    _channel.setMethodCallHandler(_onCall);
  }

  Future<Object?> _onCall(MethodCall call) async {
    if (_disposed || call.method != 'onPowerEvent') return null;
    final event = PowerEvent.fromWire(call.arguments);
    if (event != null) _gate.apply(event);
    return null;
  }

  /// Stops listening and lifts any pause, so sockets never stay paused
  /// without a runner to report the wake.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    if (_started) _channel.setMethodCallHandler(null);
    _gate.clear();
  }
}
