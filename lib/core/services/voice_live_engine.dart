import 'package:flutter/foundation.dart';

import 'gpt_live_conversation.dart';
import '../utils/speech_text.dart';

/// Live conversation state, surfaced by the composer UI.
enum VoiceLiveState { idle, listening, thinking, speaking }

/// Chat-scoped GPT-Live conversation. Owns one [LiveConversation] (WebRTC
/// peer + data channel) per chat and tracks the host-declared status
/// (chained vs gpt-live). The vendor key stays on the gateway host; this
/// class only talks to the two gateway endpoints.
///
/// Every surface that finishes a turn (chat switch, connection/profile
/// change, app background, sign-out, dispose) must call [stop] or
/// [dispose]. All callbacks and events refuse to fire after teardown so a
/// late session event can never land in a stale composer.
class VoiceLiveEngine extends ChangeNotifier {
  VoiceLiveEngine({required this.transport, LiveConversation? session})
    : super() {
    _conversation = session ?? GptLiveConversation(transport: transport);
    _wireCallbacks();
  }

  /// Gateway transport (status + session creation). Not closed by the
  /// engine — the owner controls the lifecycle.
  final GptLiveTransport transport;

  late final LiveConversation _conversation;

  GptLiveStatus? _status;
  VoiceLiveState _state = VoiceLiveState.idle;
  bool _muted = false;
  bool _disposing = false;
  bool _stopped = false;

  String? _delegationId;
  String _spokenRaw = '';
  String _spokenText = '';
  int _spokenCursor = 0;
  String _lastToolLabel = '';

  LiveConversation get conversation => _conversation;

  GptLiveStatus? get status => _status;
  bool get isLive => _status?.isLive == true;
  bool get available => _status?.available == true;
  bool get startable => isLive && available;
  VoiceLiveState get state => _state;
  bool get active => _conversation.active;
  bool get muted => _muted;
  bool get liveOwningMic => startable && active;
  String? get delegationId => _delegationId;

  /// Last spoken reply text the engine has sent to the model.
  String get spokenText => _spokenText;

  /// The host's reason the live engine cannot start, if any.
  String? get reason {
    final status = _status;
    if (status == null) return null;
    if (!status.available && status.reason != null) return status.reason;
    if (status.available && !status.isLive) {
      return 'GPT-Live is not enabled for this profile.';
    }
    return null;
  }

  // callbacks (set by the composer after the engine is created)
  void Function(String id, Map<String, String> prompt)? onDelegation;
  void Function(String message)? onError;
  void Function(String reason)? onClosed;

  void _wireCallbacks() {
    _conversation.onDelegation = _handleDelegation;
    _conversation.onError = _handleError;
    _conversation.onClosed = _handleClosed;
  }

  // --- lifecycle ---

  Future<GptLiveStatus?> _refreshOnce() async {
    final status = parseGptLiveStatus(await transport.status());
    if (!_disposing) {
      _status = status;
      notifyListeners();
    }
    return _status;
  }

  /// Fetch the host-declared status. Returns null when the gateway did not
  /// answer (caller still falls back to chained).
  Future<GptLiveStatus?> refresh() async {
    if (_disposing || _stopped) return null;
    try {
      return await _refreshOnce();
    } catch (_) {
      return null;
    }
  }

  /// Start the live conversation. Returns false — without throwing — when
  /// the host refuses (chained mode, unavailable, no mic). The caller
  /// decides whether to fall through to the chained composer.
  Future<bool> start({List<Map<String, dynamic>>? history}) async {
    if (_disposing) return false;
    await refresh();
    if (_disposing) return false;
    if (!startable) {
      onError?.call(reason ?? 'GPT-Live is not available');
      return false;
    }
    if (_conversation.active) return false;
    _stopped = false;
    final started = await _conversation.start(history: history);
    if (_disposing) {
      await _conversation.forceClose('disposed');
      return false;
    }
    if (started) {
      _state = VoiceLiveState.listening;
      _muted = false;
      _delegationId = null;
      _spokenRaw = '';
      _spokenText = '';
      _spokenCursor = 0;
      _lastToolLabel = '';
      notifyListeners();
      return true;
    }
    _state = VoiceLiveState.idle;
    notifyListeners();
    return false;
  }

  /// Stop the live session (user-initiated or internal).
  Future<void> stop() async {
    if (_disposing) return;
    _stopped = true;
    _delegationId = null;
    _spokenRaw = '';
    _spokenText = '';
    _spokenCursor = 0;
    _lastToolLabel = '';
    try {
      await _conversation.close();
    } catch (_) {
      await _conversation.forceClose('stopped');
    }
    if (_disposing) return;
    _state = VoiceLiveState.idle;
    _muted = false;
    notifyListeners();
  }

  void setMuted(bool muted) {
    if (_disposing || _stopped) return;
    _muted = muted;
    _conversation.setMuted(muted);
    notifyListeners();
  }

  // --- reply feed ---

  /// Append the pending reply to the live model. Only the new part of the
  /// text is sent — completed sentences while streaming, everything left on
  /// [flush]. The caller passes the whole pending reply each call; the engine
  /// tracks which of it has already been sent.
  void speak(String text, {String? delegationId, bool flush = false}) {
    if (_disposing || _stopped || !_conversation.active) return;
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return;
    if (_spokenRaw.isNotEmpty && !clean.startsWith(_spokenRaw)) {
      // The reply changed under us (new turn, re-read). Start over.
      _spokenRaw = '';
      _spokenText = '';
      _spokenCursor = 0;
    }
    _spokenRaw = clean;
    final sanitized = sanitizeTextForSpeech(clean);
    if (sanitized.isEmpty) return;
    _spokenText = sanitized;
    if (flush) {
      if (sanitized.length > _spokenCursor) {
        _conversation.speak(
          sanitized.substring(_spokenCursor),
          delegationId: delegationId ?? _delegationId,
        );
        _spokenCursor = sanitized.length;
      }
    } else {
      // Append only completed sentences while streaming; the tail lands on settle.
      final boundary = sanitized.lastIndexOf('. ', sanitized.length - 2);
      final cut = boundary > _spokenCursor ? boundary + 1 : _spokenCursor;
      if (cut > _spokenCursor) {
        _conversation.speak(
          sanitized.substring(_spokenCursor, cut),
          delegationId: delegationId ?? _delegationId,
        );
        _spokenCursor = cut;
      }
    }
    if (_state == VoiceLiveState.thinking ||
        _state == VoiceLiveState.listening) {
      _state = VoiceLiveState.speaking;
      notifyListeners();
    }
  }

  /// Flush the held tail (turn settled or chat switched away).
  void flushSpoken({String? delegationId}) {
    speak(_spokenRaw, delegationId: delegationId, flush: true);
  }

  /// Surface tool progress to the voice model.
  void think(String text, {String? delegationId}) {
    if (_disposing || _stopped || !_conversation.active) return;
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty || clean == _lastToolLabel) return;
    _lastToolLabel = clean;
    _conversation.think(clean, delegationId: delegationId ?? _delegationId);
  }

  /// Instruction to the model (e.g. "finish and respond now").
  void instruct(String text) {
    if (_disposing || _stopped || !_conversation.active) return;
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return;
    _conversation.instruct(clean);
  }

  /// Turn settled (the composer stopped streaming replies). Back to listening.
  void settle() {
    if (_disposing || _stopped) return;
    flushSpoken();
    if (_state == VoiceLiveState.thinking ||
        _state == VoiceLiveState.speaking) {
      _state = VoiceLiveState.listening;
      notifyListeners();
    }
    _delegationId = null;
    _spokenRaw = '';
    _spokenText = '';
    _spokenCursor = 0;
    _lastToolLabel = '';
  }

  // --- internal event wiring ---

  void _handleDelegation(String id, Map<String, String> prompt) {
    if (_disposing || _stopped) return;
    _delegationId = id;
    _state = VoiceLiveState.thinking;
    _spokenRaw = '';
    _spokenText = '';
    _spokenCursor = 0;
    _lastToolLabel = '';
    notifyListeners();
    onDelegation?.call(id, prompt);
  }

  void _handleError(String message, bool fatal) {
    if (_disposing || _stopped) return;
    onError?.call(message);
  }

  void _handleClosed(String reason, int? usageSeconds) {
    if (_disposing || _stopped) return;
    _state = VoiceLiveState.idle;
    _delegationId = null;
    _spokenText = '';
    notifyListeners();
    onClosed?.call(reason);
  }

  @override
  void dispose() {
    _disposing = true;
    _stopped = true;
    _conversation.dispose();
    super.dispose();
  }
}
