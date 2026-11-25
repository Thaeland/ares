import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether replies are read aloud automatically after a turn completes.
///
/// Opt-in, off by default: reading a reply aloud out loud is a visible side
/// effect, so it is never on until the user asks for it. Stored in
/// [SharedPreferences] so it survives restarts and never leaves the device.
/// Separate from the per-chat in-chat "Spoken replies" toggle, which still
/// governs hands-free/voice-turn playback.
final ValueNotifier<bool> autoSpeakRepliesEnabled = ValueNotifier(false);

/// Loads and persists [autoSpeakRepliesEnabled] on this device.
abstract final class AutoSpeakRepliesStore {
  static const storageKey = 'hermes_auto_speak_replies';

  /// Reads the persisted value into [autoSpeakRepliesEnabled]. Safe to call on
  /// every startup; a failed read keeps the default instead of blocking
  /// startup.
  static Future<void> load() async {
    try {
      final store = await SharedPreferences.getInstance();
      final value = store.getBool(storageKey);
      if (value != null) autoSpeakRepliesEnabled.value = value;
    } catch (_) {
      // A failed read must never block startup; the default stays in place.
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    autoSpeakRepliesEnabled.value = enabled;
    try {
      final store = await SharedPreferences.getInstance();
      await store.setBool(storageKey, enabled);
    } catch (_) {
      // The live value already changed; persistence can retry on a later write.
    }
  }
}
