import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'transcript_redaction.dart';

/// A Claude Code or Codex log the user picked, after secrets are removed.
///
/// The raw file and any filesystem path are not retained.
class ForeignFilePreview {
  const ForeignFilePreview({
    required this.source,
    required this.title,
    required this.turns,
    required this.digest,
    required this.truncated,
  });

  final String source;
  final String title;
  final List<ForeignTurn> turns;
  final String digest;
  final bool truncated;

  /// Turns the page shows. Import still sends every retained turn.
  List<ForeignTurn> get previewTurns {
    if (turns.length <= 40) return turns;
    return turns.sublist(turns.length - 40);
  }
}

class ForeignTurn {
  const ForeignTurn({required this.role, required this.text});

  final String role;
  final String text;
}

const foreignFileTurnLimit = 500;
const foreignFileByteLimit = 2 * 1024 * 1024;

/// Parses a Claude Code JSONL log or a Codex rollout JSONL log.
///
/// [sourceHint] is `claude` or `codex` when the user already chose. Secrets
/// are replaced before a turn is stored.
ForeignFilePreview parseForeignFile(String raw, {String? sourceHint}) {
  if (raw.length > foreignFileByteLimit) {
    throw const FormatException('This log is larger than 2 MB');
  }
  final hint = sourceHint?.trim();
  if (hint != null && hint != 'claude' && hint != 'codex') {
    throw const FormatException('Choose Claude Code or Codex');
  }
  final claude = <ForeignTurn>[];
  final codex = <ForeignTurn>[];
  final codexEvents = <ForeignTurn>[];
  var sawClaude = false;
  var sawCodex = false;
  var truncated = false;
  for (final line in const LineSplitter().convert(raw)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException {
      continue;
    }
    if (decoded is! Map) continue;
    final row = decoded;
    final type = row['type'];
    if (row['sessionId'] is String || type == 'user' || type == 'assistant') {
      sawClaude = true;
    }
    if (type == 'session_meta' ||
        type == 'response_item' ||
        type == 'event_msg') {
      sawCodex = true;
    }
    final message = row['message'];
    if (message is Map && (type == 'user' || type == 'assistant')) {
      final turn = _turn(message['role'], message['content']);
      if (turn != null) _add(claude, turn, () => truncated = true);
    }
    final payload = row['payload'];
    if (payload is! Map) continue;
    if (type == 'response_item' && payload['type'] == 'message') {
      final turn = _turn(payload['role'], payload['content']);
      if (turn != null) _add(codex, turn, () => truncated = true);
    } else if (type == 'event_msg' && payload['type'] == 'user_message') {
      final turn = _turn('user', payload['message']);
      if (turn != null) _add(codexEvents, turn, () => truncated = true);
    }
  }
  final source =
      hint ??
      (sawCodex && !sawClaude
          ? 'codex'
          : sawClaude && !sawCodex
          ? 'claude'
          : null);
  if (source == null) {
    throw const FormatException('Choose Claude Code or Codex');
  }
  final turns = source == 'codex'
      ? (codex.isNotEmpty ? codex : codexEvents)
      : claude;
  if (turns.isEmpty) {
    throw const FormatException('This file has no conversation to preview');
  }
  final title = _title(turns, source);
  return ForeignFilePreview(
    source: source,
    title: title,
    turns: turns,
    digest: foreignFileDigest(source, title, turns),
    truncated: truncated,
  );
}

String foreignFileDigest(String source, String title, List<ForeignTurn> turns) {
  final buffer = StringBuffer('$source\n$title\n');
  for (final turn in turns) {
    buffer.writeln('${turn.role}\t${turn.text}');
  }
  return sha256.convert(utf8.encode(buffer.toString())).toString();
}

void _add(List<ForeignTurn> turns, ForeignTurn turn, void Function() overflow) {
  if (turns.length >= foreignFileTurnLimit) {
    overflow();
    return;
  }
  turns.add(turn);
}

ForeignTurn? _turn(Object? role, Object? content) {
  if (role is! String || (role != 'user' && role != 'assistant')) return null;
  final text = _text(content);
  if (text == null) return null;
  return ForeignTurn(role: role, text: text);
}

String? _text(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return redactSecrets(trimmed);
  }
  if (value is Map) {
    return _text(value['text'] ?? value['content']);
  }
  if (value is List) {
    final parts = <String>[];
    for (final item in value) {
      final piece = _text(item);
      if (piece != null) parts.add(piece);
    }
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }
  return null;
}

String _title(List<ForeignTurn> turns, String source) {
  String? first;
  for (final turn in turns) {
    if (turn.role == 'user') {
      first = turn.text;
      break;
    }
  }
  final line = (first ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  final label = source == 'codex' ? 'Codex' : 'Claude Code';
  if (line.isEmpty) return 'Imported from $label';
  final clipped = line.length > 180 ? line.substring(0, 179) : line;
  return 'Imported from $label: $clipped';
}
