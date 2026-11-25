import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'client_direct_voice.dart';
import '../controllers/hands_free_conversation_controller.dart';
import 'hands_free_speech.dart';

/// Playback boundary for provider-synthesised MP3 bytes. Kept injectable so a
/// test can prove start/stop/cancel without a platform audio device.
abstract interface class DirectVoiceAudioSink {
  Future<HandsFreeSpeechOutcome> play(Uint8List bytes);
  Future<void> stop();
}

class FlutterDirectVoiceAudioSink implements DirectVoiceAudioSink {
  FlutterDirectVoiceAudioSink({AudioPlayer? player})
    : _player = player ?? AudioPlayer(playerId: 'ares-direct-voice');

  final AudioPlayer _player;
  Completer<HandsFreeSpeechOutcome>? _active;
  StreamSubscription<void>? _subscription;

  @override
  Future<HandsFreeSpeechOutcome> play(Uint8List bytes) async {
    await stop();
    final completer = Completer<HandsFreeSpeechOutcome>();
    _active = completer;
    _subscription = _player.onPlayerComplete.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(HandsFreeSpeechOutcome.completed);
      }
    });
    await _player.play(BytesSource(bytes, mimeType: 'audio/mpeg'));
    return completer.future;
  }

  @override
  Future<void> stop() async {
    final active = _active;
    _active = null;
    await _subscription?.cancel();
    _subscription = null;
    await _player.stop();
    if (active != null && !active.isCompleted) {
      active.complete(HandsFreeSpeechOutcome.canceled);
    }
  }
}

/// Uses the profile's client-direct TTS wire when the gateway reports one,
/// otherwise delegates to the existing flutter_tts relay speaker. Provider
/// rejections throw to the caller; they are never silently replayed through
/// the gateway with a different provider.
class ClientDirectVoiceReplySpeaker implements VoiceReplySpeaker {
  ClientDirectVoiceReplySpeaker({
    required this.store,
    required this.scopeKey,
    required this.fallback,
    DirectVoiceAudioSink? sink,
  }) : _sink = sink ?? FlutterDirectVoiceAudioSink();

  final VoiceClientConfigStore store;
  final String scopeKey;
  final VoiceReplySpeaker fallback;
  final DirectVoiceAudioSink _sink;

  @override
  Future<bool> prepare() => fallback.prepare();

  @override
  Future<HandsFreeSpeechOutcome> speak(
    String text, {
    required bool Function() isCurrent,
  }) async {
    final voice = (await store.configFor(scopeKey))?.tts;
    if (voice == null) {
      return fallback.speak(text, isCurrent: isCurrent);
    }
    final bytes = await store.synthesize(text);
    if (bytes == null || bytes.isEmpty) {
      return fallback.speak(text, isCurrent: isCurrent);
    }
    if (!isCurrent()) {
      return HandsFreeSpeechOutcome.canceled;
    }
    try {
      return await _sink.play(bytes);
    } catch (_) {
      return HandsFreeSpeechOutcome.failed;
    }
  }

  @override
  Future<void> stop() async {
    await _sink.stop();
    await fallback.stop();
  }
}
