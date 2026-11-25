/// Desktop-parity rewind semantics for Classic and NextGen (see
/// apps/desktop/src/app/session/hooks/use-prompt-actions/rewind.ts).
///
/// Pure helpers only — no UI, no I/O except the injectable [requestGateway].
/// Callers decide when to interrupt a live turn and which transport to use;
/// this file owns the exact wire shape of a truncating `prompt.submit`.
library;

/// Mirror of rewind.ts isSyntheticRendererId. Renderer-synthetic message ids
/// (`timestamp-index-role` from chat-messages/hydration.ts, plus older
/// `user-…` / `assistant-…` shapes) never reach the gateway — only durable
/// row ids / platform message ids may ride along as truncation targets.
bool isSyntheticRendererId(String? messageId) {
  if (messageId == null) return true;
  return messageId.startsWith('user-') ||
      messageId.startsWith('assistant-') ||
      messageId.contains('-synthetic-') ||
      RegExp(r'^\d+-\d+-(user|assistant|tools)\b').hasMatch(messageId);
}

/// Mirror of rewind.ts truncateSubmitParams. `confirm_truncate` states that
/// the submit really is a rewind/edit/regenerate: the gateway drops history
/// only for a submit that says so, so a leftover ordinal riding along on an
/// ordinary send cannot delete the transcript. Ordinal 0 additionally
/// truncates to an empty transcript, which the gateway gates behind
/// `confirm_empty_truncate` on top of that. A cut that archives later user
/// turns (restore/edit an older turn, confirmed deep regenerate) also needs
/// `confirm_deep_truncate`.
Map<String, dynamic> truncateSubmitParams(
  int? truncateOrdinal,
  String? truncateMessageId,
  int? truncateRowId, {
  bool confirmDeepTruncate = false,
}) {
  final hasOrdinal = truncateOrdinal != null && truncateOrdinal >= 0;
  final hasRowId = truncateRowId != null;
  final hasMessageId =
      truncateMessageId != null &&
      truncateMessageId.isNotEmpty &&
      !isSyntheticRendererId(truncateMessageId);

  if (!hasOrdinal && !hasMessageId && !hasRowId) {
    return const {};
  }

  return {
    'confirm_truncate': true,
    if (hasOrdinal) 'truncate_before_user_ordinal': truncateOrdinal,
    if (hasMessageId) 'truncate_before_message_id': truncateMessageId,
    if (hasRowId) 'truncate_before_row_id': truncateRowId,
    if (truncateOrdinal == 0) 'confirm_empty_truncate': true,
    if (confirmDeepTruncate) 'confirm_deep_truncate': true,
  };
}

/// Mirror of rewind.ts resolveDurableRowId. Resolves the durable row id of a
/// user turn by CONTENT against the gateway's stamped transcript
/// (`session.history` ships `row_id` per persisted row).
///
/// Content matching is exact-or-nothing: a unique text match wins; ambiguity
/// prefers the LAST match only when [expectedOrdinal] says the target is the
/// latest persisted turn (the edit-after-interrupt shape — the just-sent
/// message is by definition the newest). Anything else returns undefined and
/// the caller degrades to a plain resubmit, never a guessed cut.
Future<int?> resolveDurableRowId(
  Future<Map<String, dynamic>?> Function(
    String method,
    Map<String, dynamic> params,
  )
  requestGateway,
  String sessionId,
  String sourceText,
  int? expectedOrdinal,
) async {
  final wanted = sourceText.trim();
  if (wanted.isEmpty) return null;

  List<Map<String, dynamic>> messages;
  try {
    final result = await requestGateway('session.history', {
      'session_id': sessionId,
    });
    final raw = result?['messages'];
    messages = raw is List
        ? raw.whereType<Map<String, dynamic>>().toList()
        : [];
  } catch (_) {
    return null;
  }

  final durableUsers = messages
      .where(
        (m) =>
            m['role'] == 'user' &&
            m['display_kind'] == null &&
            m['row_id'] is int &&
            (m['text'] == null || m['text'] is String),
      )
      .toList();

  final matches = durableUsers
      .where((m) => (m['text'] as String?)?.trim() == wanted)
      .toList();

  if (matches.length == 1) {
    return matches.first['row_id'] as int;
  }

  if (matches.length > 1 &&
      expectedOrdinal != null &&
      expectedOrdinal >= durableUsers.length - 1) {
    final last = matches.last;
    // Latest match wins only when the target is the newest persisted turn.
    return durableUsers.last == last ? last['row_id'] as int : null;
  }

  return null;
}

/// Mirror of rewind.ts runRewindSubmit. Resolves the durable address for the
/// rewind, sends the interrupt first when [interruptFirst], and returns the
/// params for ONE truncating submit — never a guessed cut.
///
/// [sourceText] is the ORIGINAL user text (pre-edit). It is used only to
/// resolve the durable row id when the target has no known row id; when the
/// target has a durable row id, it wins and the ordinal/message id are left
/// out (the rendered ordinal space can diverge from the gateway's).
class RewindPlan {
  const RewindPlan._({
    required this.truncateOrdinal,
    required this.truncateMessageId,
    required this.truncateRowId,
    required this.sourceText,
    required this.originalOrdinal,
  });

  final int? truncateOrdinal;
  final String? truncateMessageId;
  final int? truncateRowId;
  final String sourceText;
  final int? originalOrdinal;

  /// The durable address: row id when known, else the platform message id,
  /// else content-resolved row id. Never a synthetic renderer id.
  static Future<RewindPlan> resolve({
    required Future<Map<String, dynamic>?> Function(
      String method,
      Map<String, dynamic> params,
    )
    requestGateway,
    required String sessionId,
    required int? truncateOrdinal,
    required String? truncateMessageId,
    required int? truncateRowId,
    required String sourceText,
  }) async {
    final hasOrdinal = truncateOrdinal != null && truncateOrdinal >= 0;
    final hasRowId = truncateRowId != null;
    final hasMessageId =
        truncateMessageId != null &&
        truncateMessageId.isNotEmpty &&
        !isSyntheticRendererId(truncateMessageId);
    final wantsTruncation = hasOrdinal || hasRowId || hasMessageId;
    final hasDurableAddress = hasRowId || hasMessageId;

    if (!wantsTruncation) {
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: null,
        truncateRowId: null,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    if (hasDurableAddress) {
      // A durable row or platform-message id is globally stable, while the
      // rendered ordinal can be relative to a paged transcript tail. Do not
      // cross-check those different spaces.
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: hasRowId ? null : truncateMessageId,
        truncateRowId: hasRowId ? truncateRowId : null,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    // No durable address: resolve the row id by content; unresolvable degrades
    // to a plain resubmit (no truncation), never a guessed cut.
    final resolvedRowId = sourceText.trim().isEmpty
        ? null
        : await resolveDurableRowId(
            requestGateway,
            sessionId,
            sourceText,
            truncateOrdinal,
          );
    return RewindPlan._(
      truncateOrdinal: null,
      truncateMessageId: null,
      truncateRowId: resolvedRowId,
      sourceText: sourceText,
      originalOrdinal: truncateOrdinal,
    );
  }

  @override
  String toString() =>
      'RewindPlan(rowId: $truncateRowId, ordinal: $truncateOrdinal, messageId: $truncateMessageId)';
}

/// Builds the params for the ONE truncating submit of a rewind.
///
/// [confirmDeepTruncate] is only set after the user explicitly confirms that
/// later user turns will be archived (see the confirm-deep-truncate flow).
/// It is intentionally omitted on tail-regenerate, which must never be
/// deep-confirmed.
Map<String, dynamic> buildRewindParams(
  RewindPlan plan, {
  required bool confirmDeepTruncate,
}) {
  final params = truncateSubmitParams(
    plan.truncateOrdinal,
    plan.truncateMessageId,
    plan.truncateRowId,
    confirmDeepTruncate: confirmDeepTruncate,
  );
  // A first-turn rewind resolves to an empty transcript, which the gateway
  // additionally gates behind confirm_empty_truncate. In resolved-row-id
  // mode the tail-local ordinal was dropped — the durable target is
  // authoritative, so explicitly allow a first-active-tip cut; the gateway
  // ignores this when the prefix is non-empty.
  if (plan.truncateOrdinal == null &&
      (plan.truncateRowId != null || plan.originalOrdinal == 0)) {
    params['confirm_empty_truncate'] = true;
  }
  return params;
}
