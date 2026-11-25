// The gateway's slash-command catalogue, read only to highlight a typed
// `/command` in the NextGen composer and describe it on tap. NextGen still
// sends every draft as a prompt; nothing here dispatches a command.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/widgets/slash_command_highlight.dart';
import 'nextgen_gateway.dart';

/// A cached, scoped `commands.catalog` reader for one composer.
///
/// Answers are cached per gateway (one connection) and per profile and live
/// session, since the server binds skills to the session's profile and
/// workspace. One request is in flight per scope; a failure leaves the
/// composer working with no highlight and is retried no sooner than
/// [retryAfter], on the next typed slash. A reconnect marks cached answers
/// stale so a restarted gateway's new commands appear.
class NgSlashCatalog extends ChangeNotifier {
  NgSlashCatalog({this.retryAfter = const Duration(seconds: 30)});

  final Duration retryAfter;

  static final Expando<Map<String, _NgCatalogEntry>> _cache = Expando(
    'nextgen slash catalogue',
  );

  static final Expando<StreamSubscription<void>> _reconnects = Expando(
    'nextgen slash catalogue reconnects',
  );

  /// Forgets every cached answer for [gateway].
  @visibleForTesting
  static void clearCache(NextGenGateway gateway) => _cache[gateway] = null;

  /// The cache for [gateway]. A (re)connection may be a restarted gateway
  /// with new plugins or skills, so each one marks that gateway's answers
  /// stale: they keep highlighting until the next typed slash refetches.
  static Map<String, _NgCatalogEntry> _entriesFor(NextGenGateway gateway) {
    _reconnects[gateway] ??= gateway.reconnected.listen((_) {
      for (final entry
          in _cache[gateway]?.values ?? const <_NgCatalogEntry>[]) {
        entry
          ..stale = true
          ..failedAt = null;
      }
    });
    return _cache[gateway] ??= <String, _NgCatalogEntry>{};
  }

  NextGenGateway? _gateway;
  String? _sessionId;
  String _key = '';
  bool _disposed = false;

  /// The loaded lookup for the current scope, or null.
  SlashCommandLookup? get lookup => _entry?.lookup;

  _NgCatalogEntry? get _entry {
    final gateway = _gateway;
    return gateway == null ? null : _cache[gateway]?[_key];
  }

  /// Points this reader at [gateway] and the chat's live [sessionId].
  void scopeTo(NextGenGateway gateway, {String? sessionId}) {
    final key = '${gateway.profile ?? ''}\u0000${sessionId ?? ''}';
    if (identical(gateway, _gateway) && key == _key) return;
    final before = lookup;
    _gateway = gateway;
    _sessionId = sessionId;
    _key = key;
    if (!identical(before, lookup)) _notify();
  }

  /// Highlights only names the loaded catalogue knows (aliases included).
  SlashCommandTokenInfo? resolve(String name) => lookup?.resolve(name);

  /// Loads the catalogue for the current scope unless it is cached, loading,
  /// or failed recently.
  Future<void> ensureLoaded() {
    final gateway = _gateway;
    // Offline is not a failure: the next typed slash after connecting asks.
    if (gateway == null || _disposed || !gateway.state.isConnected) {
      return Future<void>.value();
    }
    final entry = _entriesFor(gateway)[_key] ??= _NgCatalogEntry();
    final flight = entry.flight;
    if (flight != null) return flight;
    final failedAt = entry.failedAt;
    if ((entry.lookup != null && !entry.stale) ||
        (failedAt != null &&
            DateTime.now().difference(failedAt) < retryAfter)) {
      return Future<void>.value();
    }
    final done = Completer<void>();
    entry.flight = done.future;
    unawaited(_load(gateway, entry, _sessionId, done));
    return done.future;
  }

  Future<void> _load(
    NextGenGateway gateway,
    _NgCatalogEntry entry,
    String? sessionId,
    Completer<void> done,
  ) async {
    try {
      // The socket adds the connection's profile to every call; a live
      // session also binds the server to its workspace's skills.
      final result = await gateway.call('commands.catalog', {
        'session_id': ?sessionId,
      });
      entry
        ..lookup = SlashCommandLookup.fromCatalogResult(result)
        ..stale = false
        ..failedAt = null;
    } catch (_) {
      entry.failedAt = DateTime.now();
    } finally {
      entry.flight = null;
      done.complete();
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _NgCatalogEntry {
  SlashCommandLookup? lookup;

  /// Loaded before the latest reconnect: still shown, refetched on demand.
  bool stale = false;
  Future<void>? flight;
  DateTime? failedAt;
}
