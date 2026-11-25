import 'package:flutter/material.dart';

import 'petdex.dart';
import 'presentation_scope.dart';
import 'radio.dart';
import 'transcript_reading.dart';

/// Status-bar companion and radio. Both stay absent until the reader opts in,
/// so existing chrome is unchanged for a fresh install.
class PresentationChrome extends StatelessWidget {
  const PresentationChrome({
    super.key,
    this.activity = PetActivity.idle,
    this.unread = false,
    this.onCompose,
  });

  final PetActivity activity;
  final bool unread;
  final VoidCallback? onCompose;

  @override
  Widget build(BuildContext context) {
    final host = PresentationScope.maybeOf(context);
    if (host == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: Listenable.merge([host.pet, host.radio, host.reading]),
      builder: (context, _) {
        final pet = host.pet.enabled;
        final radio = host.radio.enabled;
        if (!pet && !radio) return const SizedBox.shrink();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (radio) AresRadioBar(radio: host.radio),
            if (pet)
              PetCompanion.compact(
                controller: host.pet,
                activity: activity,
                anyUnread: unread,
                onCompose: onCompose,
              ),
            if (pet) CelebrationHearts(play: unread),
          ],
        );
      },
    );
  }
}
