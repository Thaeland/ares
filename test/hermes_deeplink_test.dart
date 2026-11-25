import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/hermes_deeplink.dart';

void main() {
  group('parseHermesDeepLink', () {
    test('launch route is accepted and does not navigate', () {
      final link = parseHermesDeepLink('hermes://launch')!;
      expect(link.kind, HermesDeepLinkKind.launch);
      expect(link.isIgnored, isFalse);
    });

    test('open route with a safe path', () {
      final link = parseHermesDeepLink('hermes://open/settings/appearance')!;
      expect(link.kind, HermesDeepLinkKind.open);
      expect(link.path, '/settings/appearance');
    });

    test('open route rejects traversal, backslashes, and colons', () {
      for (final url in [
        'hermes://open/../etc/passwd',
        'hermes://open/a\\b',
        'hermes://open/a:b',
        'hermes://open/',
      ]) {
        expect(parseHermesDeepLink(url)!.isIgnored, isTrue, reason: url);
      }
    });

    test('open route rejects unknown params but keeps allowlisted ones', () {
      final link = parseHermesDeepLink(
        'hermes://open/settings?session=abc123&prefill=hello&arbitrary=nope',
      )!;
      expect(link.kind, HermesDeepLinkKind.open);
      expect(link.prefill, 'hello');
      expect(link.params.containsKey('session'), isTrue);
      expect(link.params.containsKey('arbitrary'), isFalse);
    });

    test('settings route requires a known tab', () {
      final ok = parseHermesDeepLink('hermes://settings/appearance')!;
      expect(ok.kind, HermesDeepLinkKind.settings);

      final bad = parseHermesDeepLink('hermes://settings/unknown-tab')!;
      expect(bad.isIgnored, isTrue);
    });

    test('session route validates the id', () {
      final ok = parseHermesDeepLink('hermes://session/abc-123_xyz.1')!;
      expect(ok.kind, HermesDeepLinkKind.session);
      expect(ok.sessionId, 'abc-123_xyz.1');

      final bad = parseHermesDeepLink('hermes://session/not valid!')!;
      expect(bad.isIgnored, isTrue);
    });

    test('session prefill is sanitized', () {
      final link = parseHermesDeepLink(
        'hermes://session/abc?prefill=hello%3Ctag%3E',
      )!;
      expect(link.sessionId, 'abc');
      // The prefill is sanitized, never executed.
      expect(link.prefill, contains('hello'));
    });

    test('non-hermes schemes are ignored', () {
      for (final url in [
        'https://evil.com/open/settings',
        'file:///etc/passwd',
        'HTTP://example.com',
        'settings/appearance',
        '',
        'hermes://',
      ]) {
        expect(parseHermesDeepLink(url)!.isIgnored, isTrue, reason: url);
      }
    });

    test('describeHermesDeepLink never echoes a session id', () {
      final link = parseHermesDeepLink('hermes://session/abc-123')!;
      final desc = describeHermesDeepLink(link);
      expect(desc, isNot(contains('abc-123')));
    });
  });
}
