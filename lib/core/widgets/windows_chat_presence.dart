import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_prefs.dart';
import '../services/turn_notification_service.dart';
import '../services/ws_client.dart';

/// Page-level input evidence for `client.activity`, on every platform.
/// Never sample other apps or send keys, text, mouse coordinates, titles,
/// configured hosts or credentials. Off until the user opts in, and silent
/// unless this socket's gateway acknowledged `client_activity`.
class WindowsChatPresence extends StatefulWidget {
  const WindowsChatPresence({
    super.key,
    required this.target,
    required this.child,
  });
  final (WsClient, String)? Function() target;
  final Widget child;
  @override
  State<WindowsChatPresence> createState() => _PresenceState();
}

class _PresenceState extends State<WindowsChatPresence>
    with WidgetsBindingObserver {
  static final _claimants = Expando<Object>();
  final _clock = Stopwatch()..start();
  final _focus = FocusNode(skipTraversal: true, canRequestFocus: false);
  (WsClient, String)? _last, _inputTarget;
  Duration? _input, _sent;
  Timer? _tick;
  bool get _on => notificationPrefs.value.shareWindowActivity;
  bool get _visible =>
      mounted &&
      TickerMode.valuesOf(context).enabled &&
      ModalRoute.isCurrentOf(context) != false &&
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_key);
    notificationPrefs.addListener(_policy);
    _policy();
  }

  bool _key(KeyEvent event) {
    if (event is KeyDownEvent && _focus.hasFocus) _activity();
    return false;
  }

  void _policy() {
    _tick?.cancel();
    if (_on) {
      _tick = Timer.periodic(const Duration(seconds: 10), (_) => _report());
    } else {
      _withdraw();
      _input = null;
    }
  }

  void _activity() {
    if (!_on || !_visible) return;
    _inputTarget = widget.target();
    _input = _clock.elapsed;
    _report();
  }

  void _report() {
    final target = widget.target();
    final age = _input == null ? null : _clock.elapsed - _input!;
    if (!_on ||
        !_visible ||
        target == null ||
        target != _inputTarget ||
        !target.$1.acceptsWindowActivity ||
        age == null ||
        age.inSeconds >= 60) {
      _withdraw();
      return;
    }
    if (target == _last &&
        _sent != null &&
        (_clock.elapsed - _sent!).inSeconds < 45) {
      return;
    }
    if (_last != target) _withdraw();
    _last = target;
    _sent = _clock.elapsed;
    _claimants[target.$1] = this;
    target.$1.send('client.activity', {
      'sessions': [target.$2],
      'basis': 'page',
      'idle_seconds': age.inSeconds,
      'can_alert':
          notificationKindEnabled(HermesNotificationKind.turnDone) &&
          TurnNotificationService.shared.permissionGranted,
    }, includeProfile: false).ignore();
  }

  void _withdraw() {
    final socket = _last?.$1;
    _last = null;
    _sent = null;
    if (socket == null || _claimants[socket] != this) return;
    _claimants[socket] = null;
    if (socket.acceptsWindowActivity) {
      socket.send('client.activity', {
        'sessions': <String>[],
        'away': true,
        'basis': 'page',
        'idle_seconds': _input == null
            ? 60
            : (_clock.elapsed - _input!).inSeconds,
      }, includeProfile: false).ignore();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _input = null;
      _withdraw();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _withdraw();
    notificationPrefs.removeListener(_policy);
    HardwareKeyboard.instance.removeHandler(_key);
    WidgetsBinding.instance.removeObserver(this);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focus,
    child: Listener(
      onPointerDown: (_) => _activity(),
      onPointerSignal: (_) => _activity(),
      child: widget.child,
    ),
  );
}
