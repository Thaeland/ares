/// Desktop-parity rewind semantics for Classic and NextGen (see
/// apps/desktop/src/app/session/hooks/use-prompt-actions/rewind.ts).
///
/// Pure helpers and injectable RPC runner — no widget dependencies. This file
/// owns the exact wire shape of a truncating `prompt.submit`.
library;

/// Mirror of rewind.ts `isSyntheticRendererId`. Renderer-synthetic message ids
/// (`timestamp-index-role` from chat-messages/hydration.ts, `user-…` /
/// `assistant-…` shapes, Classic `_timeline_id`s and NextGen item keys) never
/// reach the gateway — only durable `row_id` or platform `message_id` values
/// may ride along as truncation targets.
bool isSyntheticRendererId(String? messageId) {
  if (messageId == null || messageId.isEmpty) return true;
  return messageId.startsWith('user-') ||
      messageId.startsWith('assistant-') ||
      messageId.startsWith('local-') ||
      messageId.startsWith('run:') ||
      messageId.startsWith('reasoning:') ||
      messageId.contains('-synthetic-') ||
      RegExp(r'^[uast]\d+$').hasMatch(messageId) ||
      RegExp(r'^\d+-\d+-(user|assistant|tools)\b').hasMatch(messageId);
}

/// Mirror of rewind.ts `truncateSubmitParams`.
///
/// `confirm_truncate` states that the submit really is a rewind/edit/regenerate:
/// the gateway drops history only for a submit that says so, so a leftover
/// ordinal riding along on an ordinary send cannot delete the transcript.
/// Emits `confirm_truncate` plus ONE durable target (`truncate_before_row_id`
/// preferred, else non-synthetic `truncate_before_message_id`, else
/// `truncate_before_user_ordinal`). Ordinal 0 additionally sets
/// `confirm_empty_truncate`. A cut that archives later user turns sets
/// `confirm_deep_truncate` only when [confirmDeepTruncate] is true.
Map<String, dynamic> truncateSubmitParams(
  int? truncateOrdinal,
  String? truncateMessageId,
  int? truncateRowId, {
  bool confirmDeepTruncate = false,
}) {
  final hasRowId = truncateRowId != null && truncateRowId > 0;
  final hasMessageId =
      truncateMessageId != null &&
      truncateMessageId.isNotEmpty &&
      !isSyntheticRendererId(truncateMessageId);
  final hasOrdinal = truncateOrdinal != null && truncateOrdinal >= 0;

  if (!hasRowId && !hasMessageId && !hasOrdinal) {
    return const {};
  }

  return <String, dynamic>{
    'confirm_truncate': true,
    if (hasRowId)
      'truncate_before_row_id': truncateRowId
    else if (hasMessageId)
      'truncate_before_message_id': truncateMessageId
    else if (hasOrdinal)
      'truncate_before_user_ordinal': truncateOrdinal,
    if (truncateOrdinal == 0) 'confirm_empty_truncate': true,
    if (confirmDeepTruncate) 'confirm_deep_truncate': true,
  };
}

typedef GatewayRpcCall =
    Future<Map<String, dynamic>?> Function(
      String method,
      Map<String, dynamic> params,
    );

/// Outcome of inspecting `session.history` for a durable `row_id`.
class DurableRowLookup {
  const DurableRowLookup({
    required this.rowId,
    required this.persistedHasRowIds,
  });

  final int? rowId;

  /// True when `session.history` returned persisted user rows carrying integer
  /// `row_id`s. When true and [rowId] is null, client/server ordinal spaces may
  /// diverge so the caller degrades to a plain resubmit rather than guessing.
  /// When false (legacy gateway without `row_id` or `session.history` absent),
  /// `truncate_before_user_ordinal` remains usable as the fallback target.
  final bool persistedHasRowIds;
}

int? _parsePositiveInt(Object? raw) {
  if (raw is int && raw > 0) return raw;
  if (raw is String) {
    final parsed = int.tryParse(raw);
    if (parsed != null && parsed > 0) return parsed;
  }
  return null;
}

/// Mirror of rewind.ts `resolveDurableRowId`. Resolves the durable `row_id` of
/// a user turn by exact trimmed content against `session.history`.
Future<int?> resolveDurableRowId(
  GatewayRpcCall requestGateway,
  String sessionId,
  String sourceText,
  int? expectedOrdinal,
) async {
  final lookup = await lookupDurableRowId(
    requestGateway,
    sessionId,
    sourceText,
    expectedOrdinal,
  );
  return lookup.rowId;
}

/// Full lookup used by [RewindPlan.resolve] so callers distinguish an
/// unresolvable turn in a `row_id`-stamped transcript from a legacy gateway
/// that does not stamp `row_id`.
Future<DurableRowLookup> lookupDurableRowId(
  GatewayRpcCall requestGateway,
  String sessionId,
  String sourceText,
  int? expectedOrdinal,
) async {
  final wanted = sourceText.trim();
  if (wanted.isEmpty) {
    return const DurableRowLookup(rowId: null, persistedHasRowIds: false);
  }

  List<Map<String, dynamic>> messages;
  try {
    final result = await requestGateway('session.history', {
      'session_id': sessionId,
    });
    final raw = result?['messages'];
    if (raw is! List) {
      return const DurableRowLookup(rowId: null, persistedHasRowIds: false);
    }
    messages = [
      for (final entry in raw)
        if (entry is Map) Map<String, dynamic>.from(entry),
    ];
  } catch (_) {
    return const DurableRowLookup(rowId: null, persistedHasRowIds: false);
  }

  final visibleUsers = messages
      .where(
        (m) =>
            m['role'] == 'user' &&
            (m['display_kind'] == null || m['display_kind'] == ''),
      )
      .toList();
  final durableUsers = <({int rowId, String text})>[];
  for (final m in visibleUsers) {
    final rid = _parsePositiveInt(m['row_id']);
    if (rid == null) continue;
    final rawText = m['text'] ?? m['content'];
    if (rawText != null && rawText is! String) continue;
    durableUsers.add((rowId: rid, text: (rawText as String? ?? '').trim()));
  }

  if (durableUsers.isEmpty) {
    return const DurableRowLookup(rowId: null, persistedHasRowIds: false);
  }

  final matches = durableUsers.where((u) => u.text == wanted).toList();
  if (matches.length == 1) {
    return DurableRowLookup(
      rowId: matches.single.rowId,
      persistedHasRowIds: true,
    );
  }
  if (matches.length > 1 &&
      expectedOrdinal != null &&
      expectedOrdinal >= durableUsers.length - 1) {
    final last = matches.last;
    return DurableRowLookup(
      rowId: identical(durableUsers.last, last) ? last.rowId : null,
      persistedHasRowIds: true,
    );
  }
  return const DurableRowLookup(rowId: null, persistedHasRowIds: true);
}

/// Resolved target for ONE truncating `prompt.submit`.
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

  bool get truncates =>
      truncateRowId != null ||
      truncateMessageId != null ||
      truncateOrdinal != null;

  /// Target priority: `truncate_before_row_id` preferred (direct or resolved
  /// from `session.history`), else non-synthetic `truncate_before_message_id`,
  /// else `truncate_before_user_ordinal` (only when `session.history` does not
  /// stamp `row_id`s).
  static Future<RewindPlan> resolve({
    required GatewayRpcCall requestGateway,
    required String sessionId,
    required int? truncateOrdinal,
    required String? truncateMessageId,
    required int? truncateRowId,
    required String sourceText,
  }) async {
    final hasRowId = truncateRowId != null && truncateRowId > 0;
    final hasMessageId =
        truncateMessageId != null &&
        truncateMessageId.isNotEmpty &&
        !isSyntheticRendererId(truncateMessageId);
    final hasOrdinal = truncateOrdinal != null && truncateOrdinal >= 0;

    if (!hasRowId && !hasMessageId && !hasOrdinal) {
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: null,
        truncateRowId: null,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    if (hasRowId) {
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: null,
        truncateRowId: truncateRowId,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    final lookup = sourceText.trim().isEmpty
        ? const DurableRowLookup(rowId: null, persistedHasRowIds: false)
        : await lookupDurableRowId(
            requestGateway,
            sessionId,
            sourceText,
            truncateOrdinal,
          );
    if (lookup.rowId != null) {
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: null,
        truncateRowId: lookup.rowId,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    if (hasMessageId) {
      return RewindPlan._(
        truncateOrdinal: null,
        truncateMessageId: truncateMessageId,
        truncateRowId: null,
        sourceText: sourceText,
        originalOrdinal: truncateOrdinal,
      );
    }

    return RewindPlan._(
      truncateOrdinal: (!lookup.persistedHasRowIds && hasOrdinal)
          ? truncateOrdinal
          : null,
      truncateMessageId: null,
      truncateRowId: null,
      sourceText: sourceText,
      originalOrdinal: truncateOrdinal,
    );
  }

  @override
  String toString() =>
      'RewindPlan(rowId: $truncateRowId, messageId: $truncateMessageId, ordinal: $truncateOrdinal)';
}

/// Builds the truncation params for ONE `prompt.submit`.
Map<String, dynamic> buildRewindParams(
  RewindPlan plan, {
  required bool confirmDeepTruncate,
  Iterable<int>? rebindSurvivorRowIds,
}) {
  final params = <String, dynamic>{
    ...truncateSubmitParams(
      plan.truncateOrdinal,
      plan.truncateMessageId,
      plan.truncateRowId,
      confirmDeepTruncate: confirmDeepTruncate,
    ),
  };
  if (params.isEmpty) return const {};
  if (plan.truncateOrdinal == null &&
      (plan.truncateRowId != null || plan.originalOrdinal == 0)) {
    params['confirm_empty_truncate'] = true;
  }
  if (rebindSurvivorRowIds != null) {
    final ids = {
      for (final id in rebindSurvivorRowIds)
        if (id > 0) id,
    }.toList(growable: false);
    if (ids.isNotEmpty) {
      params['rebind_survivor_row_ids'] = ids;
    }
  }
  return params;
}

/// Exact match of rewind.ts lines 382-386: backends predating `#133716` reject
/// `confirm_deep_truncate` at contract admission (`4000`, handler never runs).
/// Only that field may be stripped on the single compatibility retry.
bool isRejectedDeepTruncatePayload({
  required int? code,
  required String message,
  required Map<String, dynamic> sentParams,
}) =>
    code == 4000 &&
    sentParams.containsKey('confirm_deep_truncate') &&
    message.contains(
      'invalid params for prompt.submit: confirm_deep_truncate:',
    );

/// Returns a copy of [params] with ONLY `confirm_deep_truncate` removed.
Map<String, dynamic> stripRejectedDeepTruncate(Map<String, dynamic> params) =>
    Map<String, dynamic>.of(params)..remove('confirm_deep_truncate');

bool isSessionBusyPayload({required int? code, required String message}) {
  if (code == 4002) return true;
  final lower = message.toLowerCase();
  return lower.contains('session is busy') || lower.contains('session_busy');
}

/// Post-rewrite durable row identity returned by a truncating `prompt.submit`.
class SurvivorRowIds {
  const SurvivorRowIds._({this.byOldRowId, this.byUserOrdinal});

  final Map<int, int?>? byOldRowId;
  final List<int?>? byUserOrdinal;

  static SurvivorRowIds? fromSubmitResult(Object? rawResult) {
    if (rawResult is! Map) return null;
    final rawMap = rawResult['survivor_row_id_map'];
    if (rawMap is Map) {
      final parsed = <int, int?>{};
      for (final entry in rawMap.entries) {
        final previous = int.tryParse('${entry.key}');
        if (previous == null) continue;
        final val = entry.value;
        if (val == null) {
          parsed[previous] = null;
        } else if (val is int) {
          parsed[previous] = val;
        }
      }
      return SurvivorRowIds._(byOldRowId: parsed);
    }
    final rawList = rawResult['survivor_user_row_ids'];
    if (rawList is List) {
      return SurvivorRowIds._(
        byUserOrdinal: [
          for (final entry in rawList) entry is int ? entry : null,
        ],
      );
    }
    return null;
  }
}

/// Exception interface accepted by [runRewindSubmit] for RPC error inspection.
class RewindRpcException implements Exception {
  const RewindRpcException({required this.code, required this.message});
  final int? code;
  final String message;
  @override
  String toString() => 'RewindRpcException($code): $message';
}

/// Mirror of rewind.ts `runRewindSubmit`: resolves the durable address, sends
/// `session.interrupt` first when [interruptFirst] is true (and on a raced
/// session-busy error), submits ONE truncating `prompt.submit`, and retries
/// once without `confirm_deep_truncate` when an older backend rejects that
/// parameter with 4000.
Future<SurvivorRowIds?> runRewindSubmit({
  required GatewayRpcCall requestGateway,
  required String sessionId,
  required String text,
  int? truncateOrdinal,
  String? truncateMessageId,
  int? truncateRowId,
  String? sourceText,
  Iterable<int>? rebindRowIds,
  bool interruptFirst = false,
  bool confirmDeepTruncate = false,
  int? Function(Object error)? errorCodeOf,
  String Function(Object error)? errorMessageOf,
}) async {
  int? codeOf(Object err) {
    if (errorCodeOf != null) return errorCodeOf(err);
    if (err is RewindRpcException) return err.code;
    return null;
  }

  String messageOf(Object err) {
    if (errorMessageOf != null) return errorMessageOf(err);
    if (err is RewindRpcException) return err.message;
    return err.toString();
  }

  final plan = await RewindPlan.resolve(
    requestGateway: requestGateway,
    sessionId: sessionId,
    truncateOrdinal: truncateOrdinal,
    truncateMessageId: truncateMessageId,
    truncateRowId: truncateRowId,
    sourceText: sourceText ?? '',
  );

  Future<void> interrupt() async {
    try {
      await requestGateway('session.interrupt', {'session_id': sessionId});
    } catch (_) {
      // Best-effort; submit still gates on gateway state.
    }
  }

  var deepConfirmUnsupported = false;

  Future<Map<String, dynamic>?> submitOnce() async {
    final params = <String, dynamic>{
      'session_id': sessionId,
      'text': text,
      ...buildRewindParams(
        plan,
        confirmDeepTruncate: confirmDeepTruncate && !deepConfirmUnsupported,
        rebindSurvivorRowIds: rebindRowIds,
      ),
    };
    try {
      return await requestGateway('prompt.submit', params);
    } catch (error) {
      if (!isRejectedDeepTruncatePayload(
        code: codeOf(error),
        message: messageOf(error),
        sentParams: params,
      )) {
        rethrow;
      }
      deepConfirmUnsupported = true;
      return requestGateway('prompt.submit', stripRejectedDeepTruncate(params));
    }
  }

  if (interruptFirst) {
    await interrupt();
  }

  Map<String, dynamic>? result;
  try {
    result = await submitOnce();
  } catch (error) {
    if (!isSessionBusyPayload(code: codeOf(error), message: messageOf(error))) {
      rethrow;
    }
    await interrupt();
    result = await submitOnce();
  }
  return SurvivorRowIds.fromSubmitResult(result);
}
