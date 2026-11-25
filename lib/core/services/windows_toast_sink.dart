part of 'turn_notification_service.dart';

/// Captured by the producer, never parsed out of gateway event content or
/// inferred from whichever account happens to be on-screen later.
class WindowsToastTarget {
  const WindowsToastTarget(
    this.connectionId,
    this.sessionId,
    this.account,
    this.mutation,
  );
  final String connectionId, sessionId, account, mutation;
  static WindowsToastTarget? capture(
    SavedConnection? origin,
    String? id,
    String? session,
  ) {
    if (!isWindowsPlatform ||
        origin == null ||
        id != origin.id ||
        session == null ||
        session.isEmpty ||
        session.length > 512 ||
        session == '__new__' ||
        ConnectionMutationBarrier.isPending(origin.id)) {
      return null;
    }
    final scope = NotificationApprovalAuthority.origin(origin);
    return WindowsToastTarget(
      origin.id,
      session,
      scope['approvalAccount']!,
      scope['approvalMutation']!,
    );
  }

  bool matches(SavedConnection? connection) =>
      connection != null &&
      connection.id == connectionId &&
      NotificationApprovalAuthority.matchesOrigin(
        connection,
        account,
        mutation,
      );
  Map<String, String> toJson() => {
    'connection': connectionId,
    'session': sessionId,
    'account': account,
    'mutation': mutation,
  };
  static WindowsToastTarget? decode(Object? value) {
    if (value case {
      'connection': String id,
      'session': String session,
      'account': String account,
      'mutation': String mutation,
    }) {
      if (id.isNotEmpty &&
          session.isNotEmpty &&
          session != '__new__' &&
          session.length <= 512) {
        return WindowsToastTarget(id, session, account, mutation);
      }
    }
    return null;
  }
}

/// Windows can only navigate, never answer. Not an FLN action payload.
class WindowsToastResponse extends NotificationResponse {
  const WindowsToastResponse(this.target)
    : super(
        notificationResponseType: NotificationResponseType.selectedNotification,
      );
  final WindowsToastTarget target;
}

class WindowsToastSink implements TurnNotificationSink {
  static const channel = MethodChannel('ares/windows_toast');
  static const ledgerKey = 'windows_toast_tickets_v1';
  static final _ticket = RegExp(r'^[a-f0-9]{32}$');
  static const retention = Duration(days: 3);
  static const maxEntries = 256;
  Future<void> _tail = Future.value();
  Future<T> _serialized<T>(Future<T> Function() op) {
    final next = _tail.then((_) => op());
    _tail = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> checkPermission() async =>
      await channel.invokeMethod<bool>('permission') == true;
  // Windows has no runtime prompt: only the user can change OS settings.
  @override
  Future<bool> requestPermission() => checkPermission();

  Map<String, dynamic> _read(SharedPreferences prefs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final raw = prefs.getString(ledgerKey);
    if (raw == null) return {};
    final entries = jsonDecode(raw) as Map<String, dynamic>;
    entries.removeWhere(
      (_, row) =>
          row is! Map ||
          row['expires'] is! int ||
          (row['expires'] as int) <= now,
    );
    return entries;
  }

  Future<void> _save(
    SharedPreferences prefs,
    Map<String, dynamic> entries,
  ) async {
    if (!await prefs.setString(ledgerKey, jsonEncode(entries))) {
      throw StateError('Toast ticket storage unavailable');
    }
  }

  @override
  Future<void> show(TurnNotification n) => _serialized(() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _read(prefs)..removeWhere((_, e) => e['id'] == n.id);
    while (entries.length >= maxEntries) {
      entries.remove(entries.keys.first);
    }
    final token = const Uuid().v4().replaceAll('-', '');
    final kind = n.kind;
    final test = n.payload == 'test' && kind == null && !n.ongoing;
    if (!test &&
        (!notificationPrefs.value.enabled ||
            (kind != null && !notificationKindEnabled(kind)))) {
      throw StateError('Notification disabled');
    }
    // No gateway text, chat title, action buttons or raw event payload in OS history.
    final strings = lookupAppLocalizations(
      resolvePreferredLocale(
        PlatformDispatcher.instance.locales,
        AppLocalizations.supportedLocales,
      ),
    );
    final message = switch (kind) {
      HermesNotificationKind.turnDone => strings.response_complete,
      HermesNotificationKind.turnError => strings.turn_failed,
      HermesNotificationKind.approval => strings.approval_needed,
      HermesNotificationKind.input => strings.input_needed,
      HermesNotificationKind.backgroundDone =>
        strings.background_task_completed,
      HermesNotificationKind.plugin => strings.plugin_notifications,
      HermesNotificationKind.credits => strings.credit_notifications,
      null =>
        test
            ? strings.test_notification_body
            : strings.ongoing_chat_channel_name,
    };
    entries[token] = {
      'id': n.id,
      'expires': DateTime.now().add(retention).millisecondsSinceEpoch,
      'kind': kind?.name,
      'test': test,
      if (n.windowsTarget != null) 'target': n.windowsTarget!.toJson(),
    };
    await _save(prefs, entries);
    try {
      await channel.invokeMethod<void>('show', {
        'id': n.id,
        'ticket': token,
        'body': message,
        'quiet':
            n.onlyAlertOnce ||
            n.silent ||
            n.importance == TurnNotificationImportance.low,
        'sound': n.silent || n.onlyAlertOnce
            ? 'silent'
            : kind == HermesNotificationKind.turnDone || test
            ? notificationPrefs.value.completionSound.name
            : 'system',
      });
    } catch (_) {
      entries.remove(token);
      await _save(prefs, entries);
      rethrow;
    }
  });

  Future<WindowsToastResponse?> _consume(Object? token) async {
    if (token is! String || token.length != 32 || !_ticket.hasMatch(token)) {
      return null;
    }
    return _serialized(() async {
      final prefs = await SharedPreferences.getInstance();
      final entries = _read(prefs);
      final row = entries.remove(token);
      if (row is! Map) return null;
      await _save(
        prefs,
        entries,
      ); // one-shot, including across process restarts
      final kind = row['kind'];
      if (row['test'] != true &&
          (!notificationPrefs.value.enabled ||
              (kind != null &&
                  !HermesNotificationKind.values.any(
                    (k) => k.name == kind && notificationKindEnabled(k),
                  )))) {
        return null;
      }
      await channel.invokeMethod<void>('focus');
      final target = WindowsToastTarget.decode(row['target']);
      return target == null ? null : WindowsToastResponse(target);
    });
  }

  @override
  Future<NotificationResponse?> takeInitialLaunchResponse() async {
    channel.setMethodCallHandler((call) async {
      if (call.method != 'activate') return;
      final response = await _consume(call.arguments);
      if (response != null) notificationResponseHandler?.call(response);
    });
    return _consume(await channel.invokeMethod<String>('listen'));
  }

  @override
  Future<void> cancel(int id) => _serialized(() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = _read(prefs)..removeWhere((_, e) => e['id'] == id);
    await _save(prefs, entries);
    await channel.invokeMethod<void>('cancel', id);
  });
  @override
  Future<void> cancelAll() => _serialized(() async {
    final prefs = await SharedPreferences.getInstance();
    await _save(prefs, {});
    await channel.invokeMethod<void>('cancelAll');
  });
}
