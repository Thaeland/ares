import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'artifact_library.dart';
import 'plugin_slots.dart';
import 'render_contract.dart';
import 'rich_blocks.dart';

/// Publishes localhost HTML and dev-server links for the composer strip.
/// A dismissal of this completion is not offered again.
class PreviewOfferHook extends StatefulWidget {
  const PreviewOfferHook({
    super.key,
    required this.sessionId,
    required this.text,
    this.child = const SizedBox.shrink(),
  });

  final String sessionId;
  final String text;
  final Widget child;

  @override
  State<PreviewOfferHook> createState() => _PreviewOfferHookState();
}

class _PreviewOfferHookState extends State<PreviewOfferHook> {
  @override
  void initState() {
    super.initState();
    _publish();
  }

  @override
  void didUpdateWidget(PreviewOfferHook oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.sessionId != widget.sessionId) {
      _publish();
    }
  }

  void _publish() {
    if (widget.sessionId.isEmpty) return;
    final completionId = artifactContentHash(widget.text);
    final targets = previewTargetsIn(widget.text);
    if (targets.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final target in targets) {
        previewSuggestions.record(
          sessionId: widget.sessionId,
          target: target.target,
          label: target.label,
          completionId: completionId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ComposerRenderExtras extends StatelessWidget {
  const ComposerRenderExtras({
    super.key,
    required this.sessionId,
    required this.controller,
  });

  final String sessionId;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([previewSuggestions, pluginGrants]),
      builder: (context, _) {
        final suggestions = previewSuggestions.visible(sessionId);
        final actions = pluginGrants.composerActions();
        if (suggestions.isEmpty && actions.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final action in actions)
                ActionChip(
                  label: Text(action.composerLabel!),
                  onPressed: () {
                    final snippet = '${action.command ?? ''} ';
                    final text = controller.text;
                    final next = text.trim().isEmpty
                        ? snippet.trimLeft()
                        : '$text$snippet';
                    controller.value = TextEditingValue(
                      text: next,
                      selection: TextSelection.collapsed(offset: next.length),
                    );
                  },
                ),
              for (final item in suggestions)
                InputChip(
                  key: Key('preview-suggestion-${item.target}'),
                  label: Text(item.label),
                  onDeleted: () =>
                      previewSuggestions.dismiss(sessionId, item.target),
                  deleteButtonTooltipMessage: 'Dismiss preview',
                  onPressed: () {},
                ),
            ],
          ),
        );
      },
    );
  }
}

List<Widget> richProseWidgets({
  required String text,
  required Widget Function(String text) markdown,
  Future<String?> Function(String path)? readHtml,
  Future<void> Function(String prompt)? onIntent,
}) {
  final pieces = splitRichProse(text);
  if (pieces.length == 1 && pieces.single is ProsePiece) {
    return [markdown(text)];
  }
  final widgets = <Widget>[];
  for (final piece in pieces) {
    if (piece is ProsePiece) {
      if (piece.text.trim().isEmpty) continue;
      widgets.add(markdown(piece.text));
    } else if (piece is RichPiece) {
      widgets.add(
        RichPieceView(
          value: piece.value,
          markdown: markdown,
          readHtml: readHtml,
          onIntent: onIntent,
        ),
      );
    }
  }
  if (widgets.isEmpty) return [markdown(text)];
  return widgets;
}

class RichFence extends StatelessWidget {
  const RichFence({
    super.key,
    required this.language,
    required this.code,
    required this.corpus,
    required this.fallback,
    this.readHtml,
    this.onIntent,
  });

  final String? language;
  final String code;
  final String corpus;
  final Widget fallback;
  final Future<String?> Function(String path)? readHtml;
  final Future<void> Function(String prompt)? onIntent;

  @override
  Widget build(BuildContext context) {
    final clean = sanitizeLanguageTag(language);
    final detection = detectArtifact(language, code);
    if (detection != null) {
      return ArtifactRevisionCard(
        corpus: corpus,
        code: code,
        detection: detection,
        fallback: fallback,
      );
    }
    if (clean == 'mermaid') {
      final model = parseMermaid(code);
      if (model != null) return DiagramView(model: model);
    }
    if (clean == 'svg') {
      final drawing = parseSafeSvg(code);
      if (drawing != null) return SafeSvgView(drawing: drawing);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [const Text('This SVG was not drawn.'), fallback],
      );
    }
    if (clean == 'listing') {
      final cards = parseListings(code);
      if (cards.isNotEmpty) return ListingSet(cards: cards);
    }
    return fallback;
  }
}

class RichPieceView extends StatelessWidget {
  const RichPieceView({
    super.key,
    required this.value,
    required this.markdown,
    this.readHtml,
    this.onIntent,
  });

  final Object value;
  final Widget Function(String text) markdown;
  final Future<String?> Function(String path)? readHtml;
  final Future<void> Function(String prompt)? onIntent;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value is AlertPiece) return AlertBanner(alert: value);
    if (value is MathPiece) return MathBlock(piece: value);
    if (value is TablePiece) return ResizableMarkdownTable(table: value);
    if (value is EmbedPiece) return ConsentEmbed(embed: value);
    if (value is DirectivePiece) {
      if (value.name == 'preview') {
        return SandboxPreviewCard(
          file: value.attrs['file'] ?? '',
          readHtml: readHtml,
          onIntent: onIntent,
        );
      }
      return ListenableBuilder(
        listenable: pluginGrants,
        builder: (context, _) {
          if (!pluginGrants.showsDirective(value.name)) {
            return Text(value.raw);
          }
          return _GrantedDirective(directive: value);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class _GrantedDirective extends StatelessWidget {
  const _GrantedDirective({required this.directive});

  final DirectivePiece directive;

  @override
  Widget build(BuildContext context) {
    final text = directive.attrs['text'] ?? directive.attrs.values.join(' ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const Text('Notes directive'), Text(text)],
        ),
      ),
    );
  }
}

class AlertBanner extends StatelessWidget {
  const AlertBanner({super.key, required this.alert});

  final AlertPiece alert;

  static const _labels = {
    'note': 'Note',
    'tip': 'Tip',
    'important': 'Important',
    'warning': 'Warning',
    'caution': 'Caution',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: Key('alert-${alert.type}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
        color: scheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _labels[alert.type] ?? alert.type,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(alert.body),
        ],
      ),
    );
  }
}

class MathBlock extends StatelessWidget {
  const MathBlock({super.key, required this.piece});

  final MathPiece piece;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: piece.display
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(piece.display ? 'Math' : 'Inline math'),
          Text(piece.source, key: const Key('math-expression')),
        ],
      ),
    );
  }
}

class ResizableMarkdownTable extends StatefulWidget {
  const ResizableMarkdownTable({super.key, required this.table});

  final TablePiece table;

  @override
  State<ResizableMarkdownTable> createState() => _ResizableMarkdownTableState();
}

class _ResizableMarkdownTableState extends State<ResizableMarkdownTable> {
  late final List<double> _widths;

  @override
  void initState() {
    super.initState();
    _widths = [for (final _ in widget.table.headers) 96];
  }

  @override
  Widget build(BuildContext context) {
    final headers = widget.table.headers;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < headers.length; i++)
                _cell(
                  i,
                  headers[i],
                  header: true,
                  resize: i < headers.length - 1,
                ),
            ],
          ),
          for (final row in widget.table.rows)
            Row(
              children: [
                for (var i = 0; i < headers.length; i++)
                  _cell(i, i < row.length ? row[i] : ''),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(
    int index,
    String text, {
    bool header = false,
    bool resize = false,
  }) {
    return SizedBox(
      key: header ? Key('table-col-$index') : null,
      width: _widths[index],
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: header
                  ? const TextStyle(fontWeight: FontWeight.w700)
                  : null,
            ),
          ),
          if (resize)
            GestureDetector(
              key: Key('table-resize-$index'),
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _widths[index] = (_widths[index] + details.delta.dx).clamp(
                    48,
                    320,
                  );
                });
              },
              child: const SizedBox(width: 12, height: 24),
            ),
        ],
      ),
    );
  }
}

class ConsentEmbed extends StatelessWidget {
  const ConsentEmbed({super.key, required this.embed});

  final EmbedPiece embed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: embedConsent,
      builder: (context, _) {
        if (embedConsent.mode == EmbedMode.off) {
          return Text(embed.url);
        }
        if (!embedConsent.fetches(embed)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(embed.url),
              Text('Load this ${embed.provider} card?'),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => embedConsent.loadOnce(embed),
                    child: const Text('Load once'),
                  ),
                  TextButton(
                    onPressed: () => embedConsent.allowProvider(embed.provider),
                    child: Text('Always allow ${embed.provider}'),
                  ),
                ],
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${embed.provider} ${embed.externalId}'),
            const Text(
              'This card stays inside Ares and does not load the provider page.',
            ),
          ],
        );
      },
    );
  }
}

class DiagramView extends StatelessWidget {
  const DiagramView({super.key, required this.model});

  final DiagramModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.kind == 'sequence' ? 'Sequence' : 'Diagram'),
          for (final node in model.nodes)
            Text(node.label, key: Key('diagram-${node.id}')),
          for (final edge in model.edges)
            Text(
              '${edge.from} → ${edge.to}${edge.label == null ? '' : ' ${edge.label}'}',
            ),
        ],
      ),
    );
  }
}

class SafeSvgView extends StatelessWidget {
  const SafeSvgView({super.key, required this.drawing});

  final SvgDrawing drawing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: CustomPaint(
        painter: _SvgPainter(drawing, Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _SvgPainter extends CustomPainter {
  _SvgPainter(this.drawing, this.color);

  final SvgDrawing drawing;
  final Color color;

  double? _n(String? value) => value == null ? null : double.tryParse(value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final op in drawing.ops) {
      final attrs = op.attrs;
      switch (op.name) {
        case 'rect':
          final rect = Rect.fromLTWH(
            _n(attrs['x']) ?? 0,
            _n(attrs['y']) ?? 0,
            _n(attrs['width']) ?? 0,
            _n(attrs['height']) ?? 0,
          );
          canvas.drawRect(rect, paint);
        case 'circle':
          canvas.drawCircle(
            Offset(_n(attrs['cx']) ?? 0, _n(attrs['cy']) ?? 0),
            _n(attrs['r']) ?? 0,
            paint,
          );
        case 'line':
          canvas.drawLine(
            Offset(_n(attrs['x1']) ?? 0, _n(attrs['y1']) ?? 0),
            Offset(_n(attrs['x2']) ?? 0, _n(attrs['y2']) ?? 0),
            paint,
          );
        case 'text':
          final painter = TextPainter(
            text: TextSpan(
              text: attrs['text'] ?? '',
              style: TextStyle(color: color, fontSize: 12),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          painter.paint(
            canvas,
            Offset(_n(attrs['x']) ?? 0, _n(attrs['y']) ?? 0),
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter oldDelegate) =>
      oldDelegate.drawing != drawing || oldDelegate.color != color;
}

class ListingSet extends StatelessWidget {
  const ListingSet({super.key, required this.cards});

  final List<ListingCard> cards;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final card in cards)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.address),
                  if (card.price != null) Text(card.price!),
                  if (card.note != null) Text(card.note!),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ArtifactRevisionCard extends StatefulWidget {
  const ArtifactRevisionCard({
    super.key,
    required this.corpus,
    required this.code,
    required this.detection,
    required this.fallback,
  });

  final String corpus;
  final String code;
  final GeneratedArtifact detection;
  final Widget fallback;

  @override
  State<ArtifactRevisionCard> createState() => _ArtifactRevisionCardState();
}

class _ArtifactRevisionCardState extends State<ArtifactRevisionCard> {
  late final List<ArtifactRevision> _revisions = _load();
  late int _index = _initial();
  var _source = false;

  List<ArtifactRevision> _load() {
    final slug = artifactSlug(widget.detection);
    for (final artifact in artifactHistoryFromText(widget.corpus)) {
      if (artifact.slug == slug) return artifact.revisions;
    }
    return [
      ArtifactRevision(
        index: 1,
        hash: artifactContentHash(widget.code.trim()),
        content: widget.code.trim(),
        detection: widget.detection,
      ),
    ];
  }

  int _initial() {
    final hash = artifactContentHash(widget.code.trim());
    final match = _revisions.indexWhere((revision) => revision.hash == hash);
    return match < 0 ? _revisions.length - 1 : match;
  }

  @override
  Widget build(BuildContext context) {
    final revision = _revisions[_index];
    final html = revision.detection.kind == GeneratedArtifactKind.html
        ? parseSandboxedHtml(revision.content)
        : null;
    final svg = revision.detection.kind == GeneratedArtifactKind.svg
        ? parseSafeSvg(revision.content)
        : null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(revision.detection.title),
            Text('Revision ${revision.index} of ${_revisions.length}'),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index -= 1),
                  child: const Text('Previous revision'),
                ),
                TextButton(
                  onPressed: _index == _revisions.length - 1
                      ? null
                      : () => setState(() => _index += 1),
                  child: const Text('Next revision'),
                ),
                TextButton(
                  onPressed: () => setState(() => _source = !_source),
                  child: Text(_source ? 'Rendered' : 'Source'),
                ),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: revision.content),
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied ${revision.downloadName}'),
                      ),
                    );
                  },
                  child: Text('Copy ${revision.downloadName}'),
                ),
              ],
            ),
            if (_source || (html == null && svg == null))
              widget.fallback
            else if (html != null)
              _HtmlBody(document: html)
            else if (svg != null)
              SafeSvgView(drawing: svg),
          ],
        ),
      ),
    );
  }
}

class _HtmlBody extends StatelessWidget {
  const _HtmlBody({required this.document});

  final SandboxDocument document;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (document.droppedActiveContent)
          const Text('Scripts, frames and external addresses were removed.'),
        Text(document.text),
      ],
    );
  }
}

class SandboxPreviewCard extends StatefulWidget {
  const SandboxPreviewCard({
    super.key,
    required this.file,
    this.readHtml,
    this.onIntent,
  });

  final String file;
  final Future<String?> Function(String path)? readHtml;
  final Future<void> Function(String prompt)? onIntent;

  @override
  State<SandboxPreviewCard> createState() => _SandboxPreviewCardState();
}

class _SandboxPreviewCardState extends State<SandboxPreviewCard> {
  final _token = DateTime.now().microsecondsSinceEpoch.toString();
  SandboxDocument? _document;
  var _loaded = false;
  var _missing = false;
  String? _status;
  var _lastAcceptedAt = 0;

  Future<void> _load() async {
    final reader = widget.readHtml;
    if (reader == null || !htmlFilePath(widget.file)) {
      setState(() {
        _loaded = true;
        _missing = true;
      });
      return;
    }
    final source = await reader(widget.file);
    if (!mounted) return;
    final document = source == null ? null : parseSandboxedHtml(source);
    setState(() {
      _loaded = true;
      _document = document;
      _missing = document == null;
    });
  }

  Future<void> _send(String prompt) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final decision = evaluateWidgetIntent(
      data: {
        'type': intentMessageType,
        'token': _token,
        'id': 1,
        'prompt': prompt,
      },
      token: _token,
      nowMs: now,
      lastAcceptedAtMs: _lastAcceptedAt,
      userGesture: true,
      origin: opaqueWidgetOrigin(widget.file),
      expectedOrigin: opaqueWidgetOrigin(widget.file),
    );
    if (decision is! IntentAccepted) {
      final reason = decision is IntentRejected ? decision.error : 'invalid';
      setState(() => _status = reason);
      return;
    }
    final deliver = widget.onIntent;
    if (deliver == null) {
      setState(() => _status = 'undelivered');
      return;
    }
    try {
      await deliver(decision.prompt);
      _lastAcceptedAt = now;
      if (mounted) setState(() => _status = 'Sent to this chat');
    } catch (_) {
      if (mounted) setState(() => _status = 'undelivered');
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Widget ${widget.file}'),
            const Text(
              'Runs as text in this chat. Scripts and external frames are removed.',
            ),
            if (!_loaded)
              TextButton(onPressed: _load, child: const Text('Load widget'))
            else if (_missing)
              const Text('This file is not an HTML widget.')
            else if (document != null) ...[
              if (document.droppedActiveContent)
                const Text(
                  'Scripts, frames and external addresses were removed.',
                ),
              Text(document.text),
              for (final control in document.controls)
                TextButton(
                  onPressed: () => unawaited(_send(control.prompt)),
                  child: Text(
                    control.label.isEmpty ? control.prompt : control.label,
                  ),
                ),
            ],
            if (_status != null) Text(_status!),
          ],
        ),
      ),
    );
  }
}

class InspectedImageTile extends StatelessWidget {
  const InspectedImageTile({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final path = inspectedImagePath(source);
    if (path == null) return const SizedBox.shrink();
    final name = path.split('/').last;
    return ListTile(
      key: Key('inspected-image-$name'),
      leading: const Icon(Icons.image_search),
      title: const Text('Inspected image'),
      subtitle: Text(name),
    );
  }
}

final _imagePath = RegExp(
  r'''(?:Screenshot path:\s*)?(\S+\.(?:png|jpe?g|gif|webp))''',
  caseSensitive: false,
);

String? inspectedImagePath(String text) {
  final match = _imagePath.firstMatch(text);
  final path = match?.group(1);
  if (path == null || path.contains('://')) return null;
  return path;
}

class InteractiveToolCard extends StatelessWidget {
  const InteractiveToolCard({
    super.key,
    required this.toolName,
    required this.callId,
    required this.output,
  });

  final String toolName;
  final String callId;
  final String output;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([catalogDecisions, setupAnswers]),
      builder: (context, _) {
        if (toolName == 'catalog_install') {
          final notes = catalogDecisions.stateFor('notes');
          final foreign = catalogDecisions.stateFor('remote.example');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Install a reviewed contribution?'),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => catalogDecisions.install('notes'),
                    child: const Text('Install notes'),
                  ),
                  OutlinedButton(
                    onPressed: () => catalogDecisions.skip('notes'),
                    child: const Text('Skip install'),
                  ),
                  TextButton(
                    onPressed: () => catalogDecisions.install('remote.example'),
                    child: const Text('Install remote.example'),
                  ),
                ],
              ),
              Text(notes.reason ?? 'Notes is not installed.'),
              Text(foreign.reason ?? '', key: const Key('catalog-foreign')),
            ],
          );
        }
        final settled = setupAnswers.settled[callId];
        if (settled != null) {
          return Text('Setup choice: $settled');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Setup'),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () =>
                      setupAnswers.settle(callId, 'Named the agent'),
                  child: const Text('Name the agent'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      setupAnswers.settle(callId, 'Kept the default'),
                  child: const Text('Keep the default'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
