/// Retry of a turn the gateway already accepted, as Desktop's regenerate
/// (`runReload` in use-prompt-actions/index.ts): the same prompt again with
/// a durable truncation target, so the failed turn is replaced rather than
/// repeated. A plain second `prompt.submit` would append a duplicate turn.
library;

typedef GatewayRpc =
    Future<Map<String, dynamic>> Function(
      String method,
      Map<String, dynamic> params,
    );

/// Desktop's `truncateSubmitParams` for a resolved durable row
/// (rewind.ts): `confirm_truncate` states that this submit really is a
/// regenerate, the row id is the cut, and a row-id cut may leave an empty
/// transcript when it is the first turn (`confirm_empty_truncate`).
Map<String, Object> regenerateSubmitParams(int rowId) => {
  'confirm_truncate': true,
  'truncate_before_row_id': rowId,
  'confirm_empty_truncate': true,
};

/// The durable row id of the turn to regenerate: the newest persisted user
/// row of [sessionId] (`session.history` stamps `row_id` on each), and only
/// when its text is [text]. Anything else (a failed read, an unpersisted
/// turn, an older identical prompt) is null: the caller must not guess a cut
/// and must not fall back to a plain resend.
Future<int?> resolveRegenerateRow({
  required GatewayRpc rpc,
  required String sessionId,
  required String text,
}) async {
  final wanted = text.trim();
  if (wanted.isEmpty) return null;
  Map<String, dynamic> reply;
  try {
    reply = await rpc('session.history', {'session_id': sessionId});
  } catch (_) {
    return null;
  }
  final messages = reply['messages'];
  if (messages is! List) return null;
  Map<dynamic, dynamic>? newest;
  for (final row in messages) {
    if (row is! Map || row['role'] != 'user') continue;
    if (row['display_kind'] != null) continue;
    if (row['row_id'] is! int) continue;
    newest = row;
  }
  if (newest == null) return null;
  final body = (newest['text'] ?? newest['content'])?.toString().trim() ?? '';
  return body == wanted ? newest['row_id'] as int : null;
}
