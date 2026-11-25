/// Removes credential-shaped text before a transcript is shown or sent.
///
/// Ordinary sentences stay intact. Only token shapes and assigned secrets
/// are replaced, so a preview cannot leak a key that rode along in a log.
final _token = RegExp(
  'sk-[A-Za-z0-9_-]{8,}'
  '|ghp_[A-Za-z0-9]{8,}'
  '|github_pat_[A-Za-z0-9_]{8,}'
  '|xox[baprs]-[A-Za-z0-9-]{8,}'
  '|AKIA[0-9A-Z]{16}'
  '|Bearer\\s+[A-Za-z0-9._-]{8,}',
);

final _assigned = RegExp(
  '(api[-_]?key|access[-_]?token|secret|authorization)'
  '(\\s*[:=]\\s*)'
  '\\S{8,}',
  caseSensitive: false,
);

String redactSecrets(String input) {
  final stripped = input.replaceAll(_token, '[redacted]');
  return stripped.replaceAllMapped(_assigned, (match) {
    return '${match[1]}${match[2]}[redacted]';
  });
}

bool containsSecret(String input) =>
    _token.hasMatch(input) || _assigned.hasMatch(input);
