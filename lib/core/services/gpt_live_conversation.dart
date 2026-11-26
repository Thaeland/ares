import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'connection_manager.dart';

/// Which voice engine the active profile selected, and whether GPT-Live can
/// start. Never carries the project API key: the gateway performs session
/// creation and only returns a session id plus the SDP answer.
@immutable
class GptLiveStatus {
  const GptLiveStatus({
    required this.mode,
    required this.available,
    required this.reason,
    required this.model,
    required this.voice,
  });

  final String mode;
  final bool available;
  final String? reason;
  final String model;
  final String voice;
  bool get isLive => mode == 'gpt-live';

  @override
  String toString() => 'GptLiveStatus($mode, available: $available)';
}

@immutable
class GptLiveSession {
  const GptLiveSession({required this.id, required this.sdp});
  final String? id;
  final String sdp;
}

GptLiveStatus? parseGptLiveStatus(Object? body) {
  if (body is! Map || body['ok'] != true) return null;
  final mode = body['mode']?.toString() ?? 'chained';
  return GptLiveStatus(
    mode: mode == 'gpt-live' ? 'gpt-live' : 'chained',
    available: body['available'] == true,
    reason: body['reason']?.toString().trim().isEmpty ?? true
        ? null
        : body['reason']!.toString().trim(),
    model: body['model']?.toString().trim().isEmpty ?? true
        ? 'gpt-live-1'
        : body['model']!.toString().trim(),
    voice: body['voice']?.toString().trim().isEmpty ?? true
        ? 'marin'
        : body['voice']!.toString().trim(),
  );
}

GptLiveSession? parseGptLiveSession(Object? body) {
  if (body is! Map || body['ok'] != true) return null;
  final transport = body['transport'];
  if (transport is! Map) return null;
  final sdp = transport['sdp']?.toString() ?? '';
  if (sdp.trim().isEmpty) return null;
  final session = body['session'];
  final id = session is Map ? session['id']?.toString() : null;
  return GptLiveSession(sdp: sdp, id: id);
}

@immutable
class LiveFragment {
  const LiveFragment({
    required this.speaker,
    required this.text,
    this.startMs = 0,
    this.endMs = 0,
  });
  final String speaker;
  final String text;
  final int startMs;
  final int endMs;
}

/// Last user words become the persisted turn; the recent spoken exchange
/// rides along as model-input context, mirroring Desktop's `delegationPrompt`.
Map<String, String> delegationPrompt(List<LiveFragment> fragments) {
  final turns = <LiveFragment>[];
  for (final fragment in fragments) {
    if (turns.isNotEmpty && turns.last.speaker == fragment.speaker) {
      final previous = turns.removeLast();
      turns.add(
        LiveFragment(
          speaker: previous.speaker,
          text: previous.text + fragment.text,
          startMs: previous.startMs,
          endMs: fragment.endMs,
        ),
      );
    } else {
      turns.add(fragment);
    }
  }
  LiveFragment? lastUser;
  for (final turn in turns.reversed) {
    if (turn.speaker == 'user') {
      lastUser = turn;
      break;
    }
  }
  final prompt = (lastUser?.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  final context = turns
      .map(
        (turn) =>
            '${turn.speaker == 'user' ? 'User' : 'Voice assistant'}: '
            '${turn.text.replaceAll(RegExp(r'\s+'), ' ').trim()}',
      )
      .where((line) => !line.endsWith(': '))
      .join('\n');
  return {
    'prompt': prompt.isNotEmpty
        ? prompt
        : context.substring(0, context.length.clamp(0, 400)),
    'context': context,
  };
}

/// Vendor cap: 500 tokens per commentary append. Keep headroom.
List<String> chunkForCommentary(String text, {int limit = 1400}) {
  final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.isEmpty) return const [];
  if (clean.length <= limit) return [clean];
  final chunks = <String>[];
  var current = '';
  for (final sentence in clean.split(RegExp(r'(?<=[.!?])\s+'))) {
    if (sentence.length > limit) {
      if (current.isNotEmpty) {
        chunks.add(current);
        current = '';
      }
      for (var i = 0; i < sentence.length; i += limit) {
        chunks.add(
          sentence.substring(i, (i + limit).clamp(0, sentence.length)),
        );
      }
      continue;
    }
    final candidate = current.isEmpty ? sentence : '$current $sentence';
    if (candidate.length > limit) {
      chunks.add(current);
      current = sentence;
    } else {
      current = candidate;
    }
  }
  if (current.isNotEmpty) chunks.add(current);
  return chunks;
}

List<Map<String, dynamic>> toLiveHistory(
  List<({String role, String text})> turns, {
  int maxMessages = 24,
  int maxChars = 6000,
}) {
  final history = <Map<String, dynamic>>[];
  var budget = maxChars;
  for (final turn in turns.reversed) {
    final text = turn.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isEmpty) continue;
    if (history.length >= maxMessages || budget < text.length) break;
    budget -= text.length;
    history.insert(0, {
      'role': turn.role,
      'content': [
        {
          'type': turn.role == 'assistant' ? 'output_text' : 'input_text',
          'text': text,
        },
      ],
    });
  }
  return history;
}

/// Gateway transport for the two non-secret GPT-Live endpoints. The project
/// key never travels through these calls: session creation happens on the host.
abstract interface class GptLiveTransport {
  Future<Object?> status();
  Future<Object?> createSession({
    required String sdp,
    List<Map<String, dynamic>>? history,
  });
  void dispose();
}

class GptLiveGatewayTransport implements GptLiveTransport {
  GptLiveGatewayTransport(SavedConnection connection, {this.profile})
    : _dashboard = DashboardClient.fromConnection(connection),
      ownsDashboard = true;

  GptLiveGatewayTransport.fromDashboard(
    DashboardClient dashboard, {
    this.profile,
    this.ownsDashboard = false,
  }) : _dashboard = dashboard;

  final String? profile;
  final DashboardClient _dashboard;
  final bool ownsDashboard;

  Map<String, String> get _query {
    final scope = profile;
    return {'profile': ?scope};
  }

  @override
  Future<Object?> status() async {
    final response = await _dashboard.apiRequest(
      'GET',
      'audio/voice-live/status',
      queryParameters: _query,
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  @override
  Future<Object?> createSession({
    required String sdp,
    List<Map<String, dynamic>>? history,
  }) async {
    final response = await _dashboard.apiRequest(
      'POST',
      'audio/voice-live/session',
      queryParameters: _query,
      body: <String, dynamic>{'sdp': sdp}
        ..addAll(history == null ? <String, dynamic>{} : {'history': history}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : null;
  }

  @override
  void dispose() {
    if (ownsDashboard) _dashboard.close();
  }
}

/// Minimal interface over the live conversation so callers can inject fakes in
/// tests without a real WebRTC peer.
abstract class LiveConversation {
  bool get active;
  String? get sessionId;
  String? get delegationId;

  Future<bool> start({List<Map<String, dynamic>>? history});
  void speak(String text, {String? delegationId});
  void think(String text, {String? delegationId});
  void instruct(String text);
  void setMuted(bool muted);
  Future<void> close();
  Future<void> forceClose(String reason, [int? usageSeconds]);
  void dispose();

  set onDelegation(
    void Function(String id, Map<String, String> prompt)? callback,
  );
  set onError(void Function(String message, bool fatal)? callback);
  set onClosed(void Function(String reason, int? usageSeconds)? callback);
}

/// Full-duplex GPT-Live conversation. Owns the WebRTC media session and the
/// `oai-events` data channel; a delegation is handed to the caller as a prompt
/// plus spoken context, and the caller streams Hermes' answer back with
/// [speak]. The vendor key stays on the gateway host.
class GptLiveConversation extends ChangeNotifier implements LiveConversation {
  GptLiveConversation({
    required this.transport,
    this.onDelegation,
    this.onTranscript,
    this.onError,
    this.onClosed,
    this.peerConnectionFactory,
    this.microphoneFactory,
  });

  final GptLiveTransport transport;
  final Future<RTCPeerConnection> Function()? peerConnectionFactory;
  final Future<MediaStream> Function()? microphoneFactory;

  /// LiveConversation-facing callbacks (plain fields; auto-getters/setters).
  void Function(String id, Map<String, String> prompt)? onDelegation;
  void Function(String message, bool fatal)? onError;
  void Function(String reason, int? usageSeconds)? onClosed;

  /// Deltas, user or assistant.
  void Function(LiveFragment fragment)? onTranscript;

  /// Fires when the vendor pauses the audio stream without closing.
  void Function()? onGap;

  RTCPeerConnection? _peer;
  RTCDataChannel? _events;
  MediaStream? _microphone;
  final List<LiveFragment> _transcript = [];
  bool _active = false;
  int _eventId = 0;
  String? _delegationId;
  String? _sessionId;
  bool _closed = false;

  @override
  bool get active => _active;
  @override
  String? get sessionId => _sessionId;
  @override
  String? get delegationId => _delegationId;
  List<LiveFragment> get transcript => List.unmodifiable(_transcript);

  Future<GptLiveStatus?> refreshStatus() async {
    final status = parseGptLiveStatus(await transport.status());
    notifyListeners();
    return status;
  }

  @override
  Future<bool> start({
    List<Map<String, dynamic>>? history,
    Duration iceTimeout = const Duration(seconds: 10),
  }) async {
    if (_active) return false;
    final status = await refreshStatus();
    if (status == null || !status.isLive || !status.available) return false;
    try {
      final peer = await (peerConnectionFactory ?? _createPeer)();
      _peer = peer;
      final microphone = await (microphoneFactory ?? _defaultGetUserMedia)();
      _microphone = microphone;
      for (final track in microphone.getAudioTracks()) {
        peer.addTrack(track, microphone);
      }
      final events = await peer.createDataChannel(
        'oai-events',
        RTCDataChannelInit(),
      );
      _events = events;
      events.onMessage = (message) => handleEvent(message.text);
      final offer = await peer.createOffer();
      await peer.setLocalDescription(offer);
      await _waitForIce(peer, iceTimeout);
      final sdp = (await peer.getLocalDescription())?.sdp ?? '';
      if (sdp.trim().isEmpty) {
        throw StateError('Missing local SDP offer');
      }
      final result = parseGptLiveSession(
        await transport.createSession(sdp: sdp, history: history),
      );
      if (result == null) throw StateError('GPT-Live session creation failed');
      _sessionId = result.id;
      await peer.setRemoteDescription(
        RTCSessionDescription(result.sdp, 'answer'),
      );
      _active = true;
      _closed = false;
      notifyListeners();
      return true;
    } catch (error) {
      onError?.call('GPT-Live could not start: $error', true);
      await forceClose('start_failed');
      return false;
    }
  }

  Future<RTCPeerConnection> _createPeer() =>
      createPeerConnection(<String, dynamic>{}, <String, dynamic>{});

  Future<MediaStream> _defaultGetUserMedia() =>
      RTCFactoryNative.instance.navigator.mediaDevices.getUserMedia({
        'audio': {
          'autoGainControl': true,
          'echoCancellation': true,
          'noiseSuppression': true,
        },
      });

  Future<void> _waitForIce(RTCPeerConnection peer, Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    while (peer.iceGatheringState !=
            RTCIceGatheringState.RTCIceGatheringStateComplete &&
        DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Visible for tests: maps a vendor data-channel event to app callbacks.
  @visibleForTesting
  void handleEvent(String raw) {
    Map<String, dynamic> event;
    try {
      event = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return;
    }
    switch (event['type']) {
      case 'session.started':
        final session = event['session'];
        if (session is Map) {
          _sessionId = session['id']?.toString() ?? _sessionId;
        }
        notifyListeners();
      case 'session.input_transcript.delta':
      case 'session.output_transcript.delta':
        final fragment = LiveFragment(
          speaker: event['type'] == 'session.input_transcript.delta'
              ? 'user'
              : 'assistant',
          text: event['delta']?.toString() ?? '',
          startMs: (event['start_ms'] as num?)?.toInt() ?? 0,
          endMs: (event['end_ms'] as num?)?.toInt() ?? 0,
        );
        _transcript.add(fragment);
        if (_transcript.length > 2000) {
          _transcript.removeRange(0, _transcript.length - 1500);
        }
        onTranscript?.call(fragment);
      case 'session.delegation.created':
        final delegation = event['delegation'];
        if (delegation is Map && delegation['id'] != null) {
          _delegationId = delegation['id'].toString();
          final contextWindow = _transcript.where(
            (fragment) =>
                fragment.endMs == 0 ||
                fragment.endMs >=
                    DateTime.now().millisecondsSinceEpoch - 300000,
          );
          onDelegation?.call(
            _delegationId!,
            delegationPrompt(contextWindow.toList()),
          );
        }
      case 'error':
        final error = event['error'];
        final code = error is Map ? error['code']?.toString() ?? '' : '';
        // Late appends after our own close are expected vendor noise.
        if (code != 'context_injection_incomplete') {
          final message = error is Map
              ? error['message']?.toString() ?? 'GPT-Live error'
              : 'GPT-Live error';
          onError?.call(message, false);
        }
      case 'gap':
        // Vendor pauses the stream without closing the session. Surface it so
        // the caller can keep the conversation alive.
        onGap?.call();
      case 'session.closed':
        final usage = event['usage'];
        forceClose(
          event['reason']?.toString() ?? 'closed',
          usage is Map ? (usage['seconds'] as num?)?.toInt() : null,
        );
    }
  }

  String _nextEventId(String kind) => '$kind-${++_eventId}';

  bool _send(Map<String, dynamic> payload) {
    final channel = _events;
    if (channel == null) return false;
    try {
      channel.send(RTCDataChannelMessage(jsonEncode(payload)));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  /// Streams an Hermes answer back to the voice model for paraphrasing.
  void speak(String text, {String? delegationId}) {
    final id = delegationId ?? _delegationId;
    for (final chunk in chunkForCommentary(text)) {
      _send({
        'type': 'session.commentary.append',
        'content': chunk,
        'delegation_id': id,
        'event_id': _nextEventId('say'),
      });
    }
  }

  @override
  void think(String text, {String? delegationId}) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return;
    _send({
      'type': 'session.thinking.append',
      'content': clean.substring(0, clean.length.clamp(0, 1400)),
      'delegation_id': delegationId ?? _delegationId,
      'event_id': _nextEventId('think'),
    });
  }

  @override
  /// Instruction back to the model (e.g. "finish and respond now").
  void instruct(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return;
    _send({
      'type': 'session.instruct',
      'text': clean,
      'event_id': _nextEventId('instruct'),
    });
  }

  @override
  void setMuted(bool muted) {
    for (final track in _microphone?.getAudioTracks() ?? const []) {
      track.enabled = !muted;
    }
    _send({
      'type': muted ? 'session.input_audio.mute' : 'session.input_audio.unmute',
      'event_id': _nextEventId(muted ? 'mute' : 'unmute'),
    });
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    if (!_send({'type': 'session.close'})) {
      await forceClose('close_requested');
    }
  }

  @override
  Future<void> forceClose(String reason, [int? usageSeconds]) async {
    if (_closed) return;
    _closed = true;
    _active = false;
    final channel = _events;
    _events = null;
    try {
      channel?.close();
      await _peer?.close();
      for (final track in _microphone?.getAudioTracks() ?? const []) {
        await track.stop();
      }
    } catch (_) {}
    _peer = null;
    _microphone = null;
    notifyListeners();
    onClosed?.call(reason, usageSeconds);
  }

  @override
  void dispose() {
    unawaited(forceClose('disposed'));
    super.dispose();
  }
}
