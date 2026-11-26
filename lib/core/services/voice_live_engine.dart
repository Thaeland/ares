import 'dart:async';

import 'package:flutter/foundation.dart';

import '../utils/speech_text.dart';
import '../utils/voice_stop_word.dart';
import 'connection_mutation_barrier.dart';
import 'gpt_live_conversation.dart';

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
  VoiceLiveEngine({
    required this.transport,
    LiveConversation? session,
    this.connectionId,
    this.utteranceSettleDuration = const Duration(milliseconds: 1500),
  }) : super() {
    _conversation = session ?? GptLiveConversation(transport: transport);
    _wireCallbacks();
    if (connectionId != null) {
      _accountEpoch = ConnectionMutationBarrier.capture(connectionId!);
      ConnectionMutationBarrier.addListener(_onAccountBarrier);
    }
  }

  /// Gateway transport (status + session creation). Not closed by the
  /// engine — the owner controls the lifecycle.
  final GptLiveTransport transport;

  /// Optional connection id for automatic teardown on sign-out / mutation.
  final String? connectionId;

  /// Quiet window after user transcript deltas before checking stop phrases.
  final Duration utteranceSettleDuration;

  late final LiveConversation _conversation;

  Object? _accountEpoch;
  GptLiveStatus? _status;
  VoiceLiveState _state = VoiceLiveState.idle;
  bool _muted = false;
  bool _disposing = false;
  bool _stopped = false;
  int _startEpoch = 0;

  String? _delegationId;
  String _spokenRaw = '';
  String _spokenText = '';
  int _spokenCursor = 0;
  String _lastToolLabel = '';
  String _pendingUserUtterance = '';
  Timer? _utteranceSettleTimer;

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
  int get startEpoch => _startEpoch;
  int get spokenCursor => _spokenCursor;

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
  void Function()? onStopWord;

  void _wireCallbacks() {
    _conversation.onDelegation = _handleDelegation;
    _conversation.onTranscript = _handleTranscript;
    _conversation.onError = _handleError;
    _conversation.onClosed = _handleClosed;
  }

  void _onAccountBarrier() {
    final id = connectionId;
    if (_disposing || id == null) return;
    if (!ConnectionMutationBarrier.isCurrent(id, _accountEpoch)) {
      _accountEpoch = ConnectionMutationBarrier.capture(id);
      if (_conversation.active || _state != VoiceLiveState.idle) {
        unawaited(stop());
      }
    }
  }

  void _clearUtteranceTimer() {
    _utteranceSettleTimer?.cancel();
    _utteranceSettleTimer = null;
    _pendingUserUtterance = '';
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
    if (_disposing) return null;
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
    final epoch = ++_startEpoch;
    await refresh();
    if (_disposing || epoch != _startEpoch) return false;
    if (!startable) {
      onError?.call(reason ?? 'GPT-Live is not available');
      return false;
    }
    if (_conversation.active) return false;
    _stopped = false;
    _clearUtteranceTimer();
    final started = await _conversation.start(history: history);
    if (_disposing || _stopped || epoch != _startEpoch) {
      await _conversation.forceClose('cancelled');
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
    _startEpoch++;
    _stopped = true;
    _clearUtteranceTimer();
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

  /// Nudges the full-duplex voice model to answer now (Desktop's `stopTurn`).
  void stopTurn() {
    instruct('The user has finished speaking. Respond now to what they said.');
  }

  // --- reply feed ---

  static int _lastSentenceBoundary(String text) {
    var best = -1;
    for (final marker in const ['. ', '! ', '? ']) {
      final idx = text.lastIndexOf(marker, text.length - 2);
      if (idx > best) best = idx;
    }
    return best;
  }

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
    } else if (sanitized.length >= 2) {
      // Append only completed sentences while streaming; the tail lands on settle.
      final boundary = _lastSentenceBoundary(sanitized);
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

  void _handleTranscript(LiveFragment fragment) {
    if (_disposing || _stopped || !_conversation.active) return;
    if (fragment.speaker == 'assistant') {
      if (fragment.text.trim().isNotEmpty &&
          _state != VoiceLiveState.speaking) {
        _state = VoiceLiveState.speaking;
        notifyListeners();
      }
      return;
    }
    if (fragment.speaker != 'user') return;
    _pendingUserUtterance += fragment.text;
    _utteranceSettleTimer?.cancel();
    final epoch = _startEpoch;
    _utteranceSettleTimer = Timer(utteranceSettleDuration, () {
      _utteranceSettleTimer = null;
      final utterance = _pendingUserUtterance;
      _pendingUserUtterance = '';
      if (_disposing ||
          _stopped ||
          !_conversation.active ||
          epoch != _startEpoch) {
        return;
      }
      if (isVoiceStopCommand(utterance)) {
        unawaited(stop());
        onStopWord?.call();
      }
    });
  }

  void _handleDelegation(String id, Map<String, String> prompt) {
    if (_disposing || _stopped) return;
    _clearUtteranceTimer();
    final utterance = (prompt['prompt'] ?? '').trim();
    if (utterance.isNotEmpty && isVoiceStopCommand(utterance)) {
      unawaited(stop());
      onStopWord?.call();
      return;
    }
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
    _clearUtteranceTimer();
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
    _startEpoch++;
    _clearUtteranceTimer();
    if (connectionId != null) {
      ConnectionMutationBarrier.removeListener(_onAccountBarrier);
    }
    _conversation.dispose();
    super.dispose();
  }
}
