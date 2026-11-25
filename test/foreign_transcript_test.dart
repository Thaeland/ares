import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/history/foreign_file.dart';
import 'package:hermes_android/core/history/transcript_redaction.dart';

void main() {
  const secret = 'sk-ant-api03-SECRETVALUE12';

  test('redacts token shapes and leaves ordinary sentences', () {
    expect(redactSecrets('use $secret please'), 'use [redacted] please');
    expect(redactSecrets('api_key=abcdefghij'), 'api_key=[redacted]');
    expect(containsSecret(redactSecrets('ghp_ABCDEFGH12345678')), isFalse);
    expect(
      redactSecrets('the secret plan is ready'),
      'the secret plan is ready',
    );
  });

  test('previews Claude and Codex files without keeping the token', () {
    final claude = parseForeignFile(
      '{"type":"user","message":{"role":"user","content":"Hello $secret"}}\n'
      '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Hi"}]}}\n',
      sourceHint: 'claude',
    );
    expect(claude.source, 'claude');
    expect(claude.turns.first.text, isNot(contains(secret)));
    expect(claude.turns.last.text, 'Hi');
    expect(containsSecret(claude.title), isFalse);

    final codex = parseForeignFile(
      '{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"Ship it"}]}}\n'
      '{"type":"response_item","payload":{"type":"message","role":"assistant","content":[{"type":"output_text","text":"Done ghp_ABCDEFGH12345678"}]}}\n',
      sourceHint: 'codex',
    );
    expect(codex.source, 'codex');
    expect(codex.turns.last.text, isNot(contains('ghp_')));
    expect(
      codex.digest,
      foreignFileDigest(codex.source, codex.title, codex.turns),
    );
  });
}
