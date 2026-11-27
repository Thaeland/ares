import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/utils/delivered_files.dart';

List<String> _paths(String text) =>
    extractMarkdownFileRefs(text).map((ref) => ref.path).toList();

void main() {
  for (final depth in [8, 20000]) {
    test('empty quote depth $depth preserves surrounding file links', () {
      expect(
        _paths(
          '[before](/tmp/before-$depth.md)\n\n${'>' * depth}\n'
          '[after](/tmp/after-$depth.md)\n',
        ),
        ['/tmp/before-$depth.md', '/tmp/after-$depth.md'],
      );
    });
  }

  test('a pathological trailing quote still preserves the preceding file', () {
    expect(_paths('[before](/tmp/trailing-before.md)\n\n${'>' * 20000}\n'), [
      '/tmp/trailing-before.md',
    ]);
  });

  test('spaced empty quotes preserve CRLF and following quote exclusion', () {
    expect(
      _paths(
        '[before](/tmp/crlf-before.md)\r\n\r\n${'> ' * 10000}\r\n'
        '> actual quotation\r\n[hidden](/tmp/quoted-lazy.md)\r\n\r\n'
        '[after](/tmp/crlf-after.md)\r\n',
      ),
      ['/tmp/crlf-before.md', '/tmp/crlf-after.md'],
    );
  });

  test('empty quote markers inside fenced or indented code stay excluded', () {
    expect(
      _paths(
        '```text\n${'>' * 20000}\n[hidden](/tmp/fenced.md)\n```\n\n'
        '    ${'>' * 20000}\n    [hidden](/tmp/indented.md)\n\n'
        '[outside](/tmp/outside-code.md)\n',
      ),
      ['/tmp/outside-code.md'],
    );
  });

  for (final spaces in [1, 5]) {
    test('deep quoted reference definition retains $spaces body spaces', () {
      final expected = spaces == 1 ? ['/tmp/deep-reference.md'] : <String>[];
      expect(
        _paths(
          '[outside][ref-$spaces]\n\n${'>' * 20000}${' ' * spaces}'
          '[ref-$spaces]: /tmp/deep-reference.md\n',
        ),
        expected,
      );
    });
  }

  test('a nonempty long quoted line keeps its body and lazy continuation', () {
    expect(
      _paths(
        '[before](/tmp/body-before.md)\n\n'
        '${'>' * 128} ${'q' * 3000} [hidden](/tmp/quoted-body.md)\n'
        '[hidden](/tmp/body-lazy.md)\n\n'
        '[after](/tmp/body-after.md)\n',
      ),
      ['/tmp/body-before.md', '/tmp/body-after.md'],
    );
  });
}
