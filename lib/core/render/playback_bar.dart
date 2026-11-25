import 'package:flutter/material.dart';

import 'artifact_library.dart';

/// Position and speed for one transcript attachment. Remounting the same
/// media id reads the last values; nothing is fetched from the network.
class TranscriptPlaybackBar extends StatefulWidget {
  const TranscriptPlaybackBar({super.key, required this.mediaId});

  final String mediaId;

  @override
  State<TranscriptPlaybackBar> createState() => _TranscriptPlaybackBarState();
}

class _TranscriptPlaybackBarState extends State<TranscriptPlaybackBar> {
  static const _speeds = <double>[1, 1.5, 2];

  @override
  Widget build(BuildContext context) {
    final position = mediaPlayback.positionOf(widget.mediaId);
    final speed = mediaPlayback.speedOf(widget.mediaId);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, size: 16),
              const SizedBox(width: 8),
              const Expanded(child: Text('Playback in this transcript')),
              for (final choice in _speeds)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: TextButton(
                    key: Key(
                      'playback-speed-${choice == choice.roundToDouble() ? choice.toStringAsFixed(0) : choice}-'
                      '${speed == choice ? 'on' : 'off'}',
                    ),
                    onPressed: () {
                      mediaPlayback.remember(widget.mediaId, speed: choice);
                      setState(() {});
                    },
                    child: Text(
                      '${choice == choice.roundToDouble() ? choice.toStringAsFixed(0) : choice}x',
                      style: TextStyle(
                        fontWeight: speed == choice
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: speed == choice
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Slider(
            key: Key('playback-position-${widget.mediaId}'),
            value: position.clamp(0, 1).toDouble(),
            onChanged: (value) {
              mediaPlayback.remember(widget.mediaId, position: value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
