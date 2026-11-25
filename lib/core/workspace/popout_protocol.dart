import 'dart:convert';

/// The OS command line contains this marker only. No deep links or account
/// data are accepted there. Identity and the parent's lifetime use stdin.
const workspacePopoutMarker = '--ares-workspace-chat-v1';
const workspacePopoutReady = 'ARES_WORKSPACE_CHAT_READY_V1';
const workspacePopoutFailed = 'ARES_WORKSPACE_CHAT_FAILED_V1';

class PopoutTarget {
  final String connectionId;
  final String profile;
  final String sessionId;
  final bool nextGen;

  PopoutTarget({
    required this.connectionId,
    required this.profile,
    required this.sessionId,
    required this.nextGen,
  }) {
    if (!_id(connectionId) ||
        !_id(sessionId) ||
        (profile.isNotEmpty && !_id(profile))) {
      throw const FormatException('Invalid chat identity.');
    }
  }

  // Fail closed on unsupported IDs instead of interpreting paths, URLs,
  // switches, free text or an empty string as a stored session.
  static bool _id(String value) =>
      value.length <= 200 &&
      RegExp(r'^[A-Za-z0-9_][A-Za-z0-9_.-]*$').stringMatch(value) == value;

  Map<String, Object> toJson() => {
    'connectionId': connectionId,
    'sessionId': sessionId,
    'profile': profile,
    'nextGen': nextGen,
  };

  static PopoutTarget decode(Object? map) {
    if (map case {
      'connectionId': final String c,
      'sessionId': final String s,
      'profile': final String p,
      'nextGen': final bool n,
    } when map.length == 4) {
      return PopoutTarget(
        connectionId: c,
        sessionId: s,
        profile: p,
        nextGen: n,
      );
    }
    throw const FormatException('Invalid chat identity.');
  }

  String get key => jsonEncode(toJson());
}

/// The only line a parent may send after the launch frame: the user turned
/// off sharing chat activity. It can only take authority away.
const workspacePopoutStopActivity = '{"share_activity":false}';

/// Read precisely one small JSON frame. EOF (including parent crash), errors,
/// and attempted renegotiation permanently revoke this child. Never rebind.
/// After the launch frame only [workspacePopoutStopActivity] lines are
/// accepted (each calls [onStopActivity]); any other byte revokes at once.
Future<void> watchPopoutPipe(
  Stream<List<int>> pipe, {
  required void Function(Map<String, dynamic>) onLaunch,
  required void Function() onRevoked,
  void Function()? onStopActivity,
}) async {
  final bytes = <int>[];
  final stop = utf8.encode(workspacePopoutStopActivity);
  var received = false;
  try {
    await for (final chunk in pipe) {
      for (final b in chunk) {
        if (!received) {
          if (bytes.length >= 2048) return;
          if (b == 10) {
            received = true;
            onLaunch(jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>);
            bytes.clear();
          } else {
            bytes.add(b);
          }
        } else if (onStopActivity == null) {
          return;
        } else if (b == 10 && bytes.length == stop.length) {
          bytes.clear();
          onStopActivity();
        } else if (bytes.length < stop.length && b == stop[bytes.length]) {
          bytes.add(b);
        } else {
          return;
        }
      }
    }
  } catch (_) {
    // A malformed frame or a broken pipe has no authority.
  } finally {
    onRevoked();
  }
}
