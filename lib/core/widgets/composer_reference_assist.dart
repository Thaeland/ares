import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../composer/emoji_completion.dart';
import '../composer/reference_completion.dart';
import '../composer/composer_commands.dart';

/// Chips for references already in the draft, plus @ / : / argument rows.
/// Suggestions come from [completePath] and [completeSlash]; a missing or
/// failed completer leaves the list empty rather than inventing entries.
class ComposerReferenceAssist extends StatefulWidget {
  const ComposerReferenceAssist({
    super.key,
    required this.controller,
    this.completePath,
    this.completeSlash,
  });

  final TextEditingController controller;
  final Future<List<ReferenceSuggestion>> Function(String query)? completePath;
  final Future<List<ArgumentHint>> Function(String text)? completeSlash;

  @override
  State<ComposerReferenceAssist> createState() =>
      _ComposerReferenceAssistState();
}

class _ComposerReferenceAssistState extends State<ComposerReferenceAssist> {
  List<ReferenceSuggestion> _references = const [];
  List<EmojiHit> _emoji = const [];
  List<ArgumentHint> _arguments = const [];
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _collect(notify: false);
  }

  @override
  void didUpdateWidget(covariant ComposerReferenceAssist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
      _refresh();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => _collect(notify: true);

  void _collect({required bool notify}) {
    final value = widget.controller.value;
    final caret = value.selection.isValid
        ? value.selection.extentOffset
        : value.text.length;
    final at = activeTrigger(value.text, caret, '@');
    final emoji = at == null ? activeTrigger(value.text, caret, ':') : null;
    final slash = _argumentQuery(value.text);
    final generation = ++_generation;
    final references = at == null
        ? const <ReferenceSuggestion>[]
        : starterSuggestions(at.query);
    final emojiHits = emoji == null
        ? const <EmojiHit>[]
        : emojiMatches(emoji.query);
    if (notify) {
      setState(() {
        _references = references;
        _emoji = emojiHits;
        if (slash == null) _arguments = const [];
      });
    } else {
      _references = references;
      _emoji = emojiHits;
      if (slash == null) _arguments = const [];
    }
    final complete = widget.completePath;
    if (at != null && complete != null) {
      complete(at.query).then(
        (rows) {
          if (!mounted || generation != _generation) return;
          setState(() {
            _references = rows.isEmpty ? starterSuggestions(at.query) : rows;
          });
        },
        onError: (_) {
          if (!mounted || generation != _generation) return;
          setState(() => _references = starterSuggestions(at.query));
        },
      );
    }
    final slashComplete = widget.completeSlash;
    if (slash != null && slashComplete != null) {
      slashComplete(slash).then(
        (rows) {
          if (!mounted || generation != _generation) return;
          setState(() => _arguments = rows);
        },
        onError: (_) {
          if (!mounted || generation != _generation) return;
          setState(() => _arguments = const []);
        },
      );
    }
  }

  void _apply(int start, int end, String insert) {
    final text = widget.controller.text;
    final next = applyInsert(text, start, end, insert);
    final added = next.length - (text.length - (end - start));
    widget.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: (start + added).clamp(0, next.length),
      ),
    );
  }

  String? _argumentQuery(String text) {
    final trimmed = text.trimLeft();
    if (!trimmed.startsWith('/') || !trimmed.contains(' ')) return null;
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.sharedL10n;
    final chips = referenceChips(widget.controller.text);
    if (chips.isEmpty &&
        _references.isEmpty &&
        _emoji.isEmpty &&
        _arguments.isEmpty) {
      return const SizedBox.shrink();
    }
    final value = widget.controller.value;
    final caret = value.selection.isValid
        ? value.selection.extentOffset
        : value.text.length;
    final at = activeTrigger(value.text, caret, '@');
    final emoji = at == null ? activeTrigger(value.text, caret, ':') : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (chips.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final chip in chips)
                InputChip(
                  label: Text(chip.raw, overflow: TextOverflow.ellipsis),
                  onPressed: () => _chipMenu(context, l10n, chip),
                  onDeleted: () => _remove(chip),
                ),
            ],
          ),
        if (_references.isNotEmpty && at != null)
          _rows(
            _references.map(
              (row) => (
                row.label,
                row.meta,
                () => _apply(at.start, at.end, row.insert),
              ),
            ),
          ),
        if (_emoji.isNotEmpty && emoji != null)
          _rows(
            _emoji.map(
              (row) => (
                '${row.character} :${row.code}',
                '',
                () => _apply(emoji.start, emoji.end, row.character),
              ),
            ),
          ),
        if (_arguments.isNotEmpty)
          _rows(
            _arguments.map(
              (row) => (row.label, row.text, () => _replaceArgument(row.text)),
            ),
          ),
      ],
    );
  }

  void _replaceArgument(String text) {
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _remove(ReferenceChip chip) {
    final next = removeChip(widget.controller.text, chip);
    widget.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  Future<void> _chipMenu(
    BuildContext context,
    AppLocalizations l10n,
    ReferenceChip chip,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.composerReferenceCopy),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
            ListTile(
              title: Text(l10n.composerReferenceRemove),
              onTap: () => Navigator.pop(context, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'copy') {
      await Clipboard.setData(ClipboardData(text: chip.value));
    } else if (action == 'remove') {
      _remove(chip);
    }
  }

  Widget _rows(Iterable<(String, String, VoidCallback)> rows) {
    return Column(
      children: [
        for (final row in rows.take(8))
          ListTile(
            dense: true,
            title: Text(row.$1),
            subtitle: row.$2.isEmpty ? null : Text(row.$2),
            onTap: row.$3,
          ),
      ],
    );
  }
}
