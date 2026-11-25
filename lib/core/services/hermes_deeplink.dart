/// Validated `hermes://` deep-link router.
///
/// The rules mirror the Electron Desktop client
/// (`desktop/apps/desktop/src/lib/deeplink-routes.ts` and
/// `hermes-open-target.ts`) so a URL that is accepted by Desktop is accepted by
/// Ares. This is deliberately narrow:
///
///  - only documented routes are recognized; anything else is ignored;
///  - ids are schema-validated, never echoed as executable input;
///  - a deep link can prefill a draft and navigate, but it NEVER sends a
///    message, installs a plugin, or executes a command on open;
///  - everything is validated before any UI is touched — the router performs
///    no I/O and no side effects.
library;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/services.dart';

/// Allowlisted deep-link routes.
enum HermesDeepLinkKind { launch, open, settings, session, ignore }

/// Result of parsing a `hermes://` URL. `kind == ignore` means the URL was
/// rejected and must not be acted on.
class HermesDeepLink {
  const HermesDeepLink._({
    required this.kind,
    this.path,
    this.prefill,
    this.params = const {},
    this.sessionId,
  });

  const HermesDeepLink.launch() : this._(kind: HermesDeepLinkKind.launch);
  const HermesDeepLink.open(
    String path, {
    String? prefill,
    Map<String, String>? params,
  }) : this._(
         kind: HermesDeepLinkKind.open,
         path: path,
         prefill: prefill,
         params: params ?? const {},
       );
  const HermesDeepLink.settings(String tab)
    : this._(kind: HermesDeepLinkKind.settings, path: '/settings/$tab');
  const HermesDeepLink.session(String id, {String? prefill})
    : this._(kind: HermesDeepLinkKind.session, sessionId: id, prefill: prefill);
  const HermesDeepLink.ignore() : this._(kind: HermesDeepLinkKind.ignore);

  final HermesDeepLinkKind kind;

  /// In-app route (e.g. `/settings/appearance`) — never a raw external URL.
  final String? path;

  /// Text to prefill into the composer. Never sent automatically.
  final String? prefill;

  /// Allowlisted query parameters (e.g. `tab`), never for arbitrary payloads.
  final Map<String, String> params;

  /// Validated session id — never sent, never a raw `sessionId` to a command.
  final String? sessionId;

  bool get isIgnored => kind == HermesDeepLinkKind.ignore;
}

/// A route component: `/`, `[a-z0-9-]`, bounded length — no query, no `..`.
final RegExp _routeComponentRe = RegExp(r'^[a-z0-9][a-z0-9-]{0,63}$');

/// A session/chat/object id: conservative charset, bounded length.
final RegExp _idRe = RegExp(r'^[A-Za-z0-9._-]{1,128}$');

/// Settings tabs this build understands. Any other tab is rejected.
const _knownSettingsTabs = {
  'appearance',
  'gateway',
  'notifications',
  'shortcuts',
  'connection',
};

/// Route params this build understands and allows through after validation.
const _knownOpenParams = {'prefill', 'session', 'archived', 'pinned'};

/// Validates a path segment, returning it unchanged or null.
String? _safeRouteSegment(String segment) {
  if (!_routeComponentRe.hasMatch(segment)) return null;
  return segment;
}

/// Validates a `/`-joined path. Returns null when any segment is invalid or
/// the path would escape the app (`..`, backslash, colon).
String? _safePath(String path) {
  if (path.isEmpty || path.length > 256) return null;
  if (path.startsWith('/') && !path.contains('//')) {
    final segments = path.split('/').where((s) => s.isNotEmpty);
    final parts = <String>[];
    for (final segment in segments) {
      final safe = _safeRouteSegment(segment);
      if (safe == null) return null;
      parts.add(safe);
    }
    if (parts.isEmpty) return null;
    final joined = parts.join('/');
    if (joined.contains('..')) return null;
    return '/$joined';
  }
  return null;
}

/// Sanitizes a prefill string: strips control characters except newline and
/// tab, and bounds the length. Returns null when nothing usable survives.
String? _sanitizePrefill(String? text) {
  if (text == null) return null;
  final stripped = text
      .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]'), '')
      .trim();
  if (stripped.isEmpty) return null;
  return stripped.length > 4000 ? stripped.substring(0, 4000) : stripped;
}

/// Parses and validates a `hermes://` URL. Returns `HermesDeepLink.ignore()`
/// for anything that does not match a recognized route — it must never be
/// acted on.
HermesDeepLink? parseHermesDeepLink(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const HermesDeepLink.ignore();
  final text = raw.trim();

  // Parse scheme — never trust a host-absolute URL with an unexpected scheme.
  final schemeMatch = RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*)://').firstMatch(text);
  if (schemeMatch == null) return const HermesDeepLink.ignore();
  if (schemeMatch.group(1)!.toLowerCase() != 'hermes') {
    return const HermesDeepLink.ignore();
  }
  final afterScheme = text.substring(schemeMatch.end);

  // host part (up to the first '/'), lower-cased
  final slashIndex = afterScheme.indexOf('/');
  final hostPart =
      (slashIndex < 0 ? afterScheme : afterScheme.substring(0, slashIndex))
          .split('?')
          .first
          .toLowerCase();
  final rawPath = (slashIndex < 0 ? '' : afterScheme.substring(slashIndex + 1))
      .split('?')
      .first;
  // Normalize so the path validator can always work with a leading slash.
  final normalizedPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
  final query = afterScheme.contains('?')
      ? afterScheme.substring(afterScheme.indexOf('?') + 1)
      : '';

  Map<String, String> queryParams() {
    final params = <String, String>{};
    if (query.isEmpty) return params;
    for (final pair in query.split('&')) {
      if (pair.isEmpty) continue;
      final eq = pair.indexOf('=');
      final key = eq < 0 ? pair : pair.substring(0, eq);
      final value = eq < 0 ? '' : pair.substring(eq + 1);
      if (key.isEmpty) continue;
      params[Uri.decodeComponent(key)] = Uri.decodeComponent(value);
    }
    return params;
  }

  // hermes://launch — focus/open only; never prefill, never navigate.
  if (hostPart == 'launch' && rawPath.isEmpty) {
    return const HermesDeepLink.launch();
  }

  if (hostPart == 'open') {
    final params = queryParams();
    final prefill = _sanitizePrefill(params['prefill']);
    final session = params['session'];
    if (session != null && !_idRe.hasMatch(session)) {
      return const HermesDeepLink.ignore();
    }
    // path is either an explicit rawRoute or an implicit session-scoped one.
    final path = _safePath(normalizedPath);
    if (path == null) return const HermesDeepLink.ignore();
    final allowlisted = <String, String>{};
    for (final entry in params.entries) {
      if (_knownOpenParams.contains(entry.key)) {
        allowlisted[entry.key] = entry.value;
      }
    }
    return HermesDeepLink.open(path, prefill: prefill, params: allowlisted);
  }

  if (hostPart == 'settings' || hostPart == 'settings/') {
    final params = queryParams();
    final tab = rawPath.isNotEmpty ? rawPath : params['tab'];
    if (tab == null || tab.isEmpty) return const HermesDeepLink.ignore();
    if (!_knownSettingsTabs.contains(tab)) return const HermesDeepLink.ignore();
    return HermesDeepLink.settings(tab);
  }

  if (hostPart == 'session') {
    final segments = rawPath.split('/').where((s) => s.isNotEmpty);
    final id = segments.join('/');
    if (!_idRe.hasMatch(id)) return const HermesDeepLink.ignore();
    final params = queryParams();
    final prefill = _sanitizePrefill(params['prefill']);
    return HermesDeepLink.session(id, prefill: prefill);
  }

  return const HermesDeepLink.ignore();
}

/// Formats a parsed link for a human-readable diagnostics line — never a log
/// of the raw URL (a deep link can contain a session id, which must not be
/// written into logs).
String describeHermesDeepLink(HermesDeepLink link) {
  switch (link.kind) {
    case HermesDeepLinkKind.launch:
      return 'launch';
    case HermesDeepLinkKind.open:
      return 'open /${link.path?.substring(1)}';
    case HermesDeepLinkKind.settings:
      return 'settings /${link.path?.substring(1)}';
    case HermesDeepLinkKind.session:
      return 'session';
    case HermesDeepLinkKind.ignore:
      return 'ignored';
  }
}

/// Primary-window `hermes://` deep-link bridge.
///
/// Only the primary application shell owns this service (pop-out child windows
/// exit before constructing the app root). Incoming URLs from either the
/// `com.hermesagent.ares/deeplink` channel or Flutter's platform route observer
/// are validated with [parseHermesDeepLink] before any UI state changes:
///  - invalid or non-`hermes://` links are dropped;
///  - `hermes://launch` focuses/opens only (never navigates or prefills);
///  - `open`, `settings` and `session` links publish to [pendingLink] for the
///    active Classic or NextGen shell to navigate and prefill without sending.
class HermesDeepLinkService {
  HermesDeepLinkService({MethodChannel? channel})
    : _channel = channel ?? defaultChannel;

  static const defaultChannel = MethodChannel('com.hermesagent.ares/deeplink');

  /// Shared instance owned by the primary [HermesApp], or replaced in tests.
  static HermesDeepLinkService shared = HermesDeepLinkService();

  final MethodChannel _channel;
  final ValueNotifier<HermesDeepLink?> pendingLink = ValueNotifier(null);
  String? _lastDiagnostic;
  int _launchCount = 0;
  bool _initialized = false;

  /// Safe diagnostic string from [describeHermesDeepLink]; never raw URLs/IDs.
  String? get lastDiagnostic => _lastDiagnostic;

  /// Number of `hermes://launch` focus-only links accepted in this session.
  int get launchCount => _launchCount;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    try {
      final initial = await _channel.invokeMethod<String>('getInitialLink');
      if (initial != null && initial.isNotEmpty) {
        handleRawLink(initial);
      }
    } on MissingPluginException {
      // Runner does not implement the custom deep-link channel yet.
    } on PlatformException {
      // Never block startup on a deep-link channel error.
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onDeepLink' && call.method != 'deepLink') return;
    final raw = switch (call.arguments) {
      final String s => s,
      final Map<Object?, Object?> m => m['url'] as String?,
      _ => null,
    };
    handleRawLink(raw);
  }

  /// Validates [raw] and publishes only allowlisted navigation/prefill links.
  /// Returns `true` when [raw] was recognized as a valid `hermes://` link
  /// (including `launch`), `false` when ignored.
  bool handleRawLink(String? raw) {
    final parsed = parseHermesDeepLink(raw);
    if (parsed == null || parsed.isIgnored) {
      _lastDiagnostic = 'ignored';
      return false;
    }
    _lastDiagnostic = describeHermesDeepLink(parsed);
    if (parsed.kind == HermesDeepLinkKind.launch) {
      _launchCount++;
      return true;
    }
    pendingLink.value = parsed;
    return true;
  }

  HermesDeepLink? takePendingLink() {
    final link = pendingLink.value;
    if (link != null) pendingLink.value = null;
    return link;
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    pendingLink.dispose();
  }
}
