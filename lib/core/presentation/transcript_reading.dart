import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'presentation_label.dart';
import 'reading_controls.dart';

/// Chat face for prose. Missing scope keeps the surrounding theme.
TextStyle? chatTypeface(BuildContext context, TextStyle? style) {
  final family = ReadingControls.maybeOf(context)?.chatFont.family;
  if (family == null || style == null) return style;
  return style.copyWith(fontFamily: family);
}

/// Monospace face for code. Missing scope keeps the token face.
TextStyle terminalTypeface(BuildContext context, TextStyle style) {
  final family = ReadingControls.maybeOf(context)?.terminalFont.family;
  if (family == null) return style;
  return style.copyWith(fontFamily: family);
}

/// User bubbles fade toward the surface. Assistant bubbles stay opaque so
/// body text keeps the contrast the palette already measured.
Color userBubbleFill(BuildContext context, Color color) {
  final opacity = ReadingControls.maybeOf(context)?.bubbleOpacity;
  if (opacity == null || opacity >= 1) return color;
  return color.withValues(alpha: opacity);
}

/// Wraps a transcript when the reader has forced a direction.
Widget transcriptDirection(BuildContext context, Widget child) {
  final direction = ReadingControls.maybeOf(context)?.direction.textDirection;
  if (direction == null) return child;
  return Directionality(textDirection: direction, child: child);
}

/// Remote images stay as their alt text until embeds are opted in. Opting in
/// shows the host name and opens the https URL in the browser on tap. The
/// transcript still does not fetch the image itself.
Widget externalEmbed(
  BuildContext context, {
  required String? uri,
  required String? alt,
  required Widget blocked,
}) {
  final enabled = ReadingControls.maybeOf(context)?.externalEmbeds ?? false;
  if (!enabled) return blocked;
  final parsed = uri == null ? null : Uri.tryParse(uri);
  if (parsed == null ||
      parsed.scheme != 'https' ||
      parsed.host.isEmpty ||
      parsed.userInfo.isNotEmpty) {
    return blocked;
  }
  final label = (alt == null || alt.trim().isEmpty) ? parsed.host : alt.trim();
  return _EmbedCard(label: label, host: parsed.host, uri: parsed);
}

class _EmbedCard extends StatelessWidget {
  const _EmbedCard({
    required this.label,
    required this.host,
    required this.uri,
  });

  final String label;
  final String host;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final open = presentationLabel(
      context,
      'Open embed',
      'فتح الضمن',
      '開啟嵌入內容',
    );
    return Semantics(
      link: true,
      label: '$label, $host',
      child: OutlinedButton.icon(
        onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text('$open · $host', overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// One reaction from a fixed set. Stored only for a caller-supplied id that
/// already belongs to the message; otherwise it lasts for this visit.
class MessageReaction extends StatefulWidget {
  const MessageReaction({super.key, required this.messageId});

  final String? messageId;

  static const choices = <String>['👍', '👀', '✅'];

  @override
  State<MessageReaction> createState() => _MessageReactionState();
}

class _MessageReactionState extends State<MessageReaction> {
  static final _saved = <String, String>{};
  String? _local;

  String? get _selected =>
      widget.messageId == null ? _local : _saved[widget.messageId!];

  @override
  Widget build(BuildContext context) {
    if (!(ReadingControls.maybeOf(context)?.emojiReactions ?? false)) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 4,
      children: [
        for (final emoji in MessageReaction.choices)
          ChoiceChip(
            label: Text(emoji),
            selected: _selected == emoji,
            onSelected: (_) => setState(() {
              final next = _selected == emoji ? null : emoji;
              final id = widget.messageId;
              if (id == null) {
                _local = next;
              } else if (next == null) {
                _saved.remove(id);
              } else {
                _saved[id] = next;
              }
            }),
          ),
      ],
    );
  }
}

/// A short heart burst when a reply arrived and the reader opted in.
class CelebrationHearts extends StatefulWidget {
  const CelebrationHearts({super.key, required this.play});

  final bool play;

  @override
  State<CelebrationHearts> createState() => _CelebrationHeartsState();
}

class _CelebrationHeartsState extends State<CelebrationHearts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(CelebrationHearts oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final enabled =
        widget.play &&
        (ReadingControls.maybeOf(context)?.celebrationHearts ?? false);
    if (!enabled) {
      _clock.reset();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) return;
    if (!_clock.isAnimating && _clock.value == 0) {
      _clock.forward();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play ||
        !(ReadingControls.maybeOf(context)?.celebrationHearts ?? false)) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 28,
      height: 28,
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Icon(
          Icons.favorite,
          size: 16 + 8 * (1 - _clock.value),
          color: const Color(0xFFE25563).withValues(alpha: 1 - _clock.value),
        ),
      ),
    );
  }
}
