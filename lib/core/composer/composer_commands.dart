import '../services/ws_client.dart';

/// Commands the composer runs itself, the way Desktop does, instead of
/// sending them as an ordinary prompt.
enum DedicatedSlash { sideQuestion, background, handoff, resume }

DedicatedSlash? dedicatedSlash(String name) {
  return switch (name.toLowerCase()) {
    'btw' => DedicatedSlash.sideQuestion,
    'bg' || 'background' => DedicatedSlash.background,
    'handoff' => DedicatedSlash.handoff,
    'resume' || 'sessions' || 'switch' => DedicatedSlash.resume,
    _ => null,
  };
}

class CommandRequest {
  const CommandRequest(this.method, this.params);

  final String method;
  final Map<String, dynamic> params;
}

class CommandPlan {
  const CommandPlan({
    this.consumed = false,
    this.openResume = false,
    this.resumeQuery = '',
    this.notice,
    this.request,
  });

  /// The line was handled. Do not also send it as a prompt.
  final bool consumed;
  final bool openResume;
  final String resumeQuery;
  final String? notice;
  final CommandRequest? request;
}

/// What to do before any RPC. [notice] is the usage or missing-session line.
CommandPlan planDedicated({
  required String name,
  required String arg,
  required String? sessionId,
}) {
  final kind = dedicatedSlash(name);
  if (kind == null) return const CommandPlan();
  final trimmed = arg.trim();
  if (kind == DedicatedSlash.resume) {
    return CommandPlan(consumed: true, openResume: true, resumeQuery: trimmed);
  }
  if (trimmed.isEmpty) {
    return CommandPlan(
      consumed: true,
      notice: switch (kind) {
        DedicatedSlash.sideQuestion =>
          'Usage: /btw <question> \u2014 answered from a snapshot of this conversation without interrupting it.',
        DedicatedSlash.background =>
          'Usage: /background <prompt> \u2014 the task runs separately and the result comes back here.',
        DedicatedSlash.handoff =>
          'Usage: /handoff <platform> \u2014 transfer this chat to that messaging platform.',
        DedicatedSlash.resume => '',
      },
    );
  }
  final session = sessionId?.trim() ?? '';
  if (session.isEmpty) {
    return const CommandPlan(
      consumed: true,
      notice: 'This command needs an open chat.',
    );
  }
  final method = switch (kind) {
    DedicatedSlash.sideQuestion => 'prompt.btw',
    DedicatedSlash.background => 'prompt.background',
    DedicatedSlash.handoff => 'handoff.request',
    DedicatedSlash.resume => '',
  };
  final params = switch (kind) {
    DedicatedSlash.handoff => {'session_id': session, 'platform': trimmed},
    _ => {'session_id': session, 'text': trimmed},
  };
  return CommandPlan(consumed: true, request: CommandRequest(method, params));
}

class CommandAnswer {
  const CommandAnswer({
    required this.fallbackToExec,
    this.notice = '',
    this.watchHandoff = false,
  });

  /// The gateway has no dedicated method. The existing slash.exec path runs.
  final bool fallbackToExec;
  final String notice;
  final bool watchHandoff;
}

bool missingRpcMethod(Object error) =>
    error is JsonRpcError && error.code == -32601;

CommandAnswer interpretCommandResult({
  required DedicatedSlash kind,
  required String arg,
  required Map<String, dynamic> result,
}) {
  final id = result['task_id']?.toString().trim() ?? '';
  return switch (kind) {
    DedicatedSlash.sideQuestion => CommandAnswer(
      fallbackToExec: false,
      notice: id.isEmpty
          ? 'btw \u2014 answering from a conversation snapshot'
          : 'btw $id \u2014 answering from a conversation snapshot',
    ),
    DedicatedSlash.background => CommandAnswer(
      fallbackToExec: false,
      notice: id.isEmpty
          ? 'Background task started. You can keep chatting. The result will appear here.'
          : 'Background task $id started. You can keep chatting. The result will appear here.',
    ),
    DedicatedSlash.handoff => CommandAnswer(
      fallbackToExec: false,
      watchHandoff: true,
      notice: 'Handoff to ${arg.trim()} requested.',
    ),
    DedicatedSlash.resume => const CommandAnswer(fallbackToExec: false),
  };
}

CommandAnswer interpretCommandError(Object error) {
  if (missingRpcMethod(error)) {
    return const CommandAnswer(fallbackToExec: true);
  }
  final message = error is JsonRpcError ? error.message : error.toString();
  return CommandAnswer(fallbackToExec: false, notice: message);
}

class DedicatedRun {
  const DedicatedRun(this.plan, this.answer);

  final CommandPlan plan;
  final CommandAnswer? answer;
}

/// Plans the command and, when it has an RPC, runs that RPC. Resume and
/// usage lines do not call the gateway. A missing method asks the caller to
/// use its existing slash.exec path.
Future<DedicatedRun?> runDedicatedCommand({
  required String name,
  required String arg,
  required String? sessionId,
  Future<Map<String, dynamic>> Function(
    String method,
    Map<String, dynamic> params,
  )?
  rpc,
}) async {
  if (dedicatedSlash(name) == null) return null;
  final plan = planDedicated(name: name, arg: arg, sessionId: sessionId);
  final request = plan.request;
  if (request == null) return DedicatedRun(plan, null);
  if (rpc == null) {
    return DedicatedRun(plan, const CommandAnswer(fallbackToExec: true));
  }
  try {
    final result = await rpc(request.method, request.params);
    return DedicatedRun(
      plan,
      interpretCommandResult(
        kind: dedicatedSlash(name)!,
        arg: arg,
        result: result,
      ),
    );
  } catch (error) {
    return DedicatedRun(plan, interpretCommandError(error));
  }
}

enum HandoffPhase { pending, completed, failed, timedOut }

/// One `handoff.state` reading. A clock past [deadlineMs] is a timeout even
/// when the gateway is still pending. Completed wins over the clock.
HandoffPhase readHandoffPhase({
  required Object? state,
  required int nowMs,
  required int deadlineMs,
}) {
  if (state == 'completed') return HandoffPhase.completed;
  if (state == 'failed') return HandoffPhase.failed;
  if (nowMs >= deadlineMs) return HandoffPhase.timedOut;
  return HandoffPhase.pending;
}

Map<String, dynamic> handoffStateParams(String sessionId) => {
  'session_id': sessionId,
};

Map<String, dynamic> handoffFailParams(String sessionId, String error) => {
  'session_id': sessionId,
  'error': error,
};

class ResumeCandidate {
  const ResumeCandidate({
    required this.id,
    required this.title,
    this.preview = '',
  });

  final String id;
  final String title;
  final String preview;
}

List<ResumeCandidate> filterResume(
  Iterable<ResumeCandidate> rows,
  String query,
) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return rows.toList();
  return [
    for (final row in rows)
      if (row.id.toLowerCase().contains(needle) ||
          row.title.toLowerCase().contains(needle) ||
          row.preview.toLowerCase().contains(needle))
        row,
  ];
}

class ArgumentHint {
  const ArgumentHint(this.text, this.label);

  final String text;
  final String label;
}

/// Rows from `complete.slash`. An empty or unrecognised payload is no hints,
/// not a locally invented argument list.
List<ArgumentHint> parseArgumentHints(Object? result) {
  if (result is! Map) return const [];
  final items = result['items'] ?? result['completions'];
  if (items is! List) return const [];
  final hints = <ArgumentHint>[];
  for (final item in items) {
    if (item is String && item.trim().isNotEmpty) {
      hints.add(ArgumentHint(item.trim(), item.trim()));
      continue;
    }
    if (item is! Map) continue;
    final text = item['text'] ?? item['insert'] ?? item['value'];
    if (text is! String || text.trim().isEmpty) continue;
    final display = item['display'];
    hints.add(
      ArgumentHint(
        text.trim(),
        display is String && display.isNotEmpty ? display : text.trim(),
      ),
    );
  }
  return hints;
}
