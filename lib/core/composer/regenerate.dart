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
/// regenerate and the row id is the cut. Only a cut at the first user turn
/// ([ordinal] 0) leaves an empty transcript, so only that one carries
/// `confirm_empty_truncate`. The ordinal itself is not sent: in row-id mode
/// Desktop drops it, as a client-side ordinal can disagree with the
/// gateway's and trip its cross-check.
Map<String, Object> regenerateSubmitParams(int rowId, {int? ordinal}) => {
  'confirm_truncate': true,
  'truncate_before_row_id': rowId,
  if (ordinal == 0) 'confirm_empty_truncate': true,
};

/// The turn to regenerate: its durable row id and its place among the
/// session's durable user rows (0 = the first turn).
typedef RegenerateTarget = ({int rowId, int ordinal});

/// The turn to regenerate: the newest persisted user row of [sessionId]
/// (`session.history` stamps `row_id` on each), and only when its text is
/// [text]. Anything else (a failed read, an unpersisted turn, an older
/// identical prompt) is null: the caller must not guess a cut and must not
/// fall back to a plain resend.
///
/// A history that starts mid-transcript can only call a later turn the
/// first, never the first turn a later one: at worst
/// `confirm_empty_truncate` goes out where the gateway ignores it (a
/// non-empty prefix).
Future<RegenerateTarget?> resolveRegenerateTarget({
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
  var ordinal = -1;
  for (final row in messages) {
    if (row is! Map || row['role'] != 'user') continue;
    if (row['display_kind'] != null) continue;
    if (row['row_id'] is! int) continue;
    newest = row;
    ordinal++;
  }
  if (newest == null) return null;
  final body = (newest['text'] ?? newest['content'])?.toString().trim() ?? '';
  if (body != wanted) return null;
  return (rowId: newest['row_id'] as int, ordinal: ordinal);
}

/// [resolveRegenerateTarget]'s row id alone.
Future<int?> resolveRegenerateRow({
  required GatewayRpc rpc,
  required String sessionId,
  required String text,
}) async => (await resolveRegenerateTarget(
  rpc: rpc,
  sessionId: sessionId,
  text: text,
))?.rowId;
