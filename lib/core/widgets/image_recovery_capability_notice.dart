import 'package:flutter/material.dart';

/// Why this composer cannot restore an image together with its text.
///
/// Stock canonical sends keep a frozen receipt. These two transports do not,
/// and the composer says so instead of offering a control that cannot work.
enum ImageRecoveryGap { restSse, recoveryV2 }

class ImageRecoveryCapabilityNotice extends StatelessWidget {
  const ImageRecoveryCapabilityNotice({super.key, required this.gap});

  final ImageRecoveryGap gap;

  static const restExplanation =
      'Image and text recovery is not available on Classic REST/SSE. '
      'An unacknowledged image send cannot be restored on this connection, '
      'and nothing is sent again automatically.';

  static const recoveryExplanation =
      'Image and text recovery is not available on companion recovery. '
      'An unacknowledged image send cannot be restored on this connection, '
      'and nothing is sent again automatically.';

  @override
  Widget build(BuildContext context) {
    final text = switch (gap) {
      ImageRecoveryGap.restSse => restExplanation,
      ImageRecoveryGap.recoveryV2 => recoveryExplanation,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Text(
        text,
        key: ValueKey('image-recovery-gap-${gap.name}'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
