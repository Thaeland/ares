import 'package:flutter/material.dart';

import '../models/attachment_draft.dart';
import '../services/attachment_draft_service.dart';
import '../services/prepared_image_store.dart';

/// Read the journal only on a gesture. Choosing a row fills the composer;
/// neither opening the chooser nor restoring a row submits anything.
class PreparedImageRecovery extends StatefulWidget {
  const PreparedImageRecovery({
    super.key,
    required this.target,
    required this.revision,
    required this.install,
    this.store,
  });
  final PreparedImageTarget target;
  final Object? Function() revision;
  final void Function(String, List<AttachmentDraft>) install;
  final PreparedImageStore? store;
  @override
  State<PreparedImageRecovery> createState() => _PreparedImageRecoveryState();
}

class _PreparedImageRecoveryState extends State<PreparedImageRecovery> {
  bool busy = false;
  Future<void> open() async {
    if (busy) return;
    final revision = widget.revision();
    if (revision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for an empty draft before restoring.'),
        ),
      );
      return;
    }
    setState(() => busy = true);
    final target = widget.target;
    bool current() =>
        mounted &&
        widget.target.key == target.key &&
        widget.revision() == revision;
    final store = widget.store ?? PreparedImageStore.shared;
    try {
      final entries = await store.list(target);
      if (!mounted || !current()) return;
      if (entries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No unacknowledged image drafts in this chat.'),
          ),
        );
        return;
      }
      final choice =
          await showModalBottomSheet<
            ({PreparedImageEntry entry, bool discard})
          >(
            context: context,
            builder: (context) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListTile(
                    title: Text('Unacknowledged image drafts'),
                    subtitle: Text(
                      'The gateway may already have received these. Restore to review; nothing is sent.',
                    ),
                  ),
                  for (final entry in entries)
                    ListTile(
                      title: Text(
                        entry.text.isEmpty ? 'Image draft' : entry.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${entry.imageCount} image(s) · ${entry.created.toLocal()}${entry.copyOnly ? ' · Sending creates a new turn' : ''}',
                      ),
                      onTap: () => Navigator.pop(context, (
                        entry: entry,
                        discard: false,
                      )),
                      trailing: IconButton(
                        tooltip: 'Discard local copy',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => Navigator.pop(context, (
                          entry: entry,
                          discard: true,
                        )),
                      ),
                    ),
                ],
              ),
            ),
          );
      if (!mounted || !current() || choice == null) return;
      if (choice.discard) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard this local image draft?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (confirmed == true && current()) {
          await PreparedImageStore.retire(choice.entry);
        }
        return;
      }
      final drafts = await store.restore(choice.entry, current);
      if (drafts == null) return;
      if (!current()) {
        await AttachmentDraftService().removeAll(drafts);
        return;
      }
      widget.install(choice.entry.text, drafts);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image draft recovery is unavailable.')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: busy ? null : open,
    icon: const Icon(Icons.restore, size: 18),
    label: const Text('Recover image draft…'),
  );
}
