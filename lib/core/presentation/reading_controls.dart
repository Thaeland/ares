import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Faces shipped with Ares. The chooser does not enumerate fonts installed
/// elsewhere on the computer: Flutter has no portable catalogue of those.
enum AresTypeface {
  platform,
  geist,
  geistMono,
  cinzel;

  String? get family => switch (this) {
    AresTypeface.platform => null,
    AresTypeface.geist => 'Geist',
    AresTypeface.geistMono => 'GeistMono',
    AresTypeface.cinzel => 'Cinzel',
  };

  static const chatChoices = <AresTypeface>[
    AresTypeface.platform,
    AresTypeface.geist,
    AresTypeface.cinzel,
  ];

  static const terminalChoices = <AresTypeface>[
    AresTypeface.platform,
    AresTypeface.geistMono,
  ];

  static AresTypeface? named(Object? value) => values.asNameMap()[value];
}

/// Forces the transcript only. Automatic follows the locale's direction.
enum TranscriptDirection {
  automatic,
  leftToRight,
  rightToLeft;

  TextDirection? get textDirection => switch (this) {
    TranscriptDirection.automatic => null,
    TranscriptDirection.leftToRight => TextDirection.ltr,
    TranscriptDirection.rightToLeft => TextDirection.rtl,
  };

  static TranscriptDirection? named(Object? value) => values.asNameMap()[value];
}

/// Device-local reading preferences. One JSON value, written in order.
class ReadingControls extends ChangeNotifier {
  ReadingControls(this._preferences)
    : _state = _ReadingState.decode(_preferences.get(preferenceKey));

  static const preferenceKey = 'presentation.reading.v1';

  /// Lowest user-bubble fill that still keeps the accent recognisable.
  static const minBubbleOpacity = 0.7;

  final SharedPreferences _preferences;
  _ReadingState _state;
  Future<void> _tail = Future<void>.value();
  var _disposed = false;

  AresTypeface get chatFont => _state.chatFont;
  AresTypeface get terminalFont => _state.terminalFont;
  TranscriptDirection get direction => _state.direction;
  double get bubbleOpacity => _state.bubbleOpacity;
  bool get externalEmbeds => _state.externalEmbeds;
  bool get emojiReactions => _state.emojiReactions;
  bool get celebrationHearts => _state.celebrationHearts;

  static ReadingControls? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ReadingScope>();
    return scope?.controls;
  }

  Future<void> setChatFont(AresTypeface value) =>
      _change((state) => state.copy(chatFont: value));

  Future<void> setTerminalFont(AresTypeface value) =>
      _change((state) => state.copy(terminalFont: value));

  Future<void> setDirection(TranscriptDirection value) =>
      _change((state) => state.copy(direction: value));

  Future<void> setBubbleOpacity(double value) {
    if (!value.isFinite) return Future<void>.value();
    final opacity = value.clamp(minBubbleOpacity, 1.0).toDouble();
    return _change((state) => state.copy(bubbleOpacity: opacity));
  }

  Future<void> setExternalEmbeds(bool value) =>
      _change((state) => state.copy(externalEmbeds: value));

  Future<void> setEmojiReactions(bool value) =>
      _change((state) => state.copy(emojiReactions: value));

  Future<void> setCelebrationHearts(bool value) =>
      _change((state) => state.copy(celebrationHearts: value));

  Future<void> _change(_ReadingState Function(_ReadingState state) change) {
    final result = _tail.then((_) async {
      final next = change(_state);
      final encoded = jsonEncode(next.encode());
      final previous = _preferences.get(preferenceKey);
      if (previous == encoded) {
        _state = next;
        return;
      }
      try {
        if (!await _preferences.setString(preferenceKey, encoded)) {
          throw StateError('Could not save reading settings.');
        }
      } catch (_) {
        try {
          if (previous is String) {
            await _preferences.setString(preferenceKey, previous);
          } else {
            await _preferences.remove(preferenceKey);
          }
        } catch (_) {}
        rethrow;
      }
      _state = next;
      if (!_disposed) notifyListeners();
    });
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class _ReadingScope extends InheritedNotifier<ReadingControls> {
  const _ReadingScope({
    required ReadingControls controls,
    required super.child,
  }) : super(notifier: controls);

  ReadingControls get controls => notifier!;
}

/// Publishes [ReadingControls] without owning their lifetime.
class ReadingScope extends StatelessWidget {
  const ReadingScope({super.key, required this.controls, required this.child});

  final ReadingControls controls;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _ReadingScope(controls: controls, child: child);
}

final class _ReadingState {
  const _ReadingState({
    this.chatFont = AresTypeface.platform,
    this.terminalFont = AresTypeface.geistMono,
    this.direction = TranscriptDirection.automatic,
    this.bubbleOpacity = 1,
    this.externalEmbeds = false,
    this.emojiReactions = false,
    this.celebrationHearts = false,
  });

  final AresTypeface chatFont;
  final AresTypeface terminalFont;
  final TranscriptDirection direction;
  final double bubbleOpacity;
  final bool externalEmbeds;
  final bool emojiReactions;
  final bool celebrationHearts;

  _ReadingState copy({
    AresTypeface? chatFont,
    AresTypeface? terminalFont,
    TranscriptDirection? direction,
    double? bubbleOpacity,
    bool? externalEmbeds,
    bool? emojiReactions,
    bool? celebrationHearts,
  }) => _ReadingState(
    chatFont: chatFont ?? this.chatFont,
    terminalFont: terminalFont ?? this.terminalFont,
    direction: direction ?? this.direction,
    bubbleOpacity: bubbleOpacity ?? this.bubbleOpacity,
    externalEmbeds: externalEmbeds ?? this.externalEmbeds,
    emojiReactions: emojiReactions ?? this.emojiReactions,
    celebrationHearts: celebrationHearts ?? this.celebrationHearts,
  );

  Map<String, Object> encode() => {
    'chatFont': chatFont.name,
    'terminalFont': terminalFont.name,
    'direction': direction.name,
    'bubbleOpacity': bubbleOpacity,
    'externalEmbeds': externalEmbeds,
    'emojiReactions': emojiReactions,
    'celebrationHearts': celebrationHearts,
  };

  static _ReadingState decode(Object? raw) {
    const fallback = _ReadingState();
    if (raw is! String || raw.length > 1024) return fallback;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return fallback;
      final opacity = map['bubbleOpacity'];
      if (opacity is! num || !opacity.isFinite) return fallback;
      final chat = AresTypeface.named(map['chatFont']);
      final terminal = AresTypeface.named(map['terminalFont']);
      final direction = TranscriptDirection.named(map['direction']);
      if (chat == null ||
          terminal == null ||
          direction == null ||
          map['externalEmbeds'] is! bool ||
          map['emojiReactions'] is! bool ||
          map['celebrationHearts'] is! bool) {
        return fallback;
      }
      if (!AresTypeface.chatChoices.contains(chat) ||
          !AresTypeface.terminalChoices.contains(terminal)) {
        return fallback;
      }
      return _ReadingState(
        chatFont: chat,
        terminalFont: terminal,
        direction: direction,
        bubbleOpacity: opacity.toDouble().clamp(
          ReadingControls.minBubbleOpacity,
          1.0,
        ),
        externalEmbeds: map['externalEmbeds'] as bool,
        emojiReactions: map['emojiReactions'] as bool,
        celebrationHearts: map['celebrationHearts'] as bool,
      );
    } on FormatException {
      return fallback;
    }
  }
}
