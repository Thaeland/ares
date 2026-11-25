import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

class DiagramNode {
  const DiagramNode(this.id, this.label, this.shape);

  final String id;
  final String label;
  final String shape;
}

class DiagramEdge {
  const DiagramEdge(this.from, this.to, [this.label]);

  final String from;
  final String to;
  final String? label;
}

class DiagramModel {
  const DiagramModel({
    required this.kind,
    required this.direction,
    required this.nodes,
    required this.edges,
  });

  final String kind;
  final String direction;
  final List<DiagramNode> nodes;
  final List<DiagramEdge> edges;
}

final _nodeShape = RegExp(
  r'^([A-Za-z0-9_]+)(?:\[([^\]]+)\]|\{([^}]+)\]|\(([^)]+)\))?$',
);

DiagramNode? _node(String raw) {
  final match = _nodeShape.firstMatch(raw.trim());
  if (match == null) return null;
  final id = match.group(1)!;
  final label = match.group(2) ?? match.group(3) ?? match.group(4) ?? id;
  final shape = match.group(2) != null
      ? 'rect'
      : match.group(3) != null
      ? 'diamond'
      : 'round';
  return DiagramNode(id, label, shape);
}

/// A bounded flowchart or sequence diagram. Anything else stays a code fence.
DiagramModel? parseMermaid(String source) {
  final lines = source
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty && !line.startsWith('%%'))
      .toList();
  if (lines.isEmpty) return null;
  final header = lines.first.toLowerCase();
  if (header.startsWith('sequencediagram')) {
    final nodes = <String, DiagramNode>{};
    final edges = <DiagramEdge>[];
    final arrow = RegExp(r'^(\S+?)\s*(-{1,2}>>|->>|->)\s*(\S+?)\s*:\s*(.+)');
    for (final line in lines.skip(1)) {
      final match = arrow.firstMatch(line);
      if (match == null) continue;
      final from = match.group(1)!;
      final to = match.group(3)!;
      nodes.putIfAbsent(from, () => DiagramNode(from, from, 'actor'));
      nodes.putIfAbsent(to, () => DiagramNode(to, to, 'actor'));
      edges.add(DiagramEdge(from, to, match.group(4)));
    }
    if (edges.isEmpty) return null;
    return DiagramModel(
      kind: 'sequence',
      direction: 'TD',
      nodes: nodes.values.toList(),
      edges: edges,
    );
  }
  if (!header.startsWith('flowchart') && !header.startsWith('graph')) {
    return null;
  }
  final direction = header.split(RegExp(r'\s+')).length > 1
      ? header.split(RegExp(r'\s+'))[1].toUpperCase()
      : 'TD';
  final nodes = <String, DiagramNode>{};
  final edges = <DiagramEdge>[];
  final link = RegExp(
    r'^(.+?)\s+-->(?:\|([^|]+)\|)?\s+(.+)\s*'
    r'|^(.+?)\s+---\s+(.+)\s*',
  );
  for (final line in lines.skip(1)) {
    final match = link.firstMatch(line);
    if (match == null) {
      final lone = _node(line);
      if (lone != null) nodes.putIfAbsent(lone.id, () => lone);
      continue;
    }
    final fromRaw = match.group(1) ?? match.group(4)!;
    final toRaw = match.group(3) ?? match.group(5)!;
    final from = _node(fromRaw);
    final to = _node(toRaw);
    if (from == null || to == null) continue;
    nodes[from.id] = from;
    nodes[to.id] = to;
    edges.add(DiagramEdge(from.id, to.id, match.group(2)));
  }
  if (nodes.isEmpty) return null;
  return DiagramModel(
    kind: 'flowchart',
    direction: direction == 'LR' || direction == 'RL' ? direction : 'TD',
    nodes: nodes.values.toList(),
    edges: edges,
  );
}

class SvgOp {
  const SvgOp(this.name, this.attrs);

  final String name;
  final Map<String, String> attrs;
}

class SvgDrawing {
  const SvgDrawing(this.viewBox, this.ops);

  final String viewBox;
  final List<SvgOp> ops;
}

const _svgAllowed = {
  'svg',
  'g',
  'rect',
  'circle',
  'ellipse',
  'line',
  'polyline',
  'polygon',
  'text',
  'title',
};

/// Paints a small SVG subset. Scripts, foreign objects and external URLs are
/// dropped rather than loaded.
SvgDrawing? parseSafeSvg(String source) {
  XmlDocument document;
  try {
    document = XmlDocument.parse(source);
  } on XmlException {
    return null;
  }
  final root = document.rootElement;
  if (root.name.local.toLowerCase() != 'svg') return null;
  final ops = <SvgOp>[];
  var refused = false;
  void walk(XmlElement element) {
    final name = element.name.local.toLowerCase();
    if (name == 'script' ||
        name == 'foreignobject' ||
        name == 'iframe' ||
        name == 'image' ||
        name == 'use') {
      refused = true;
      return;
    }
    for (final attribute in element.attributes) {
      final key = attribute.name.local.toLowerCase();
      final value = attribute.value.trim().toLowerCase();
      if (key.startsWith('on') ||
          value.startsWith('javascript:') ||
          (key == 'href' && value.contains('://'))) {
        refused = true;
        return;
      }
    }
    if (_svgAllowed.contains(name) && name != 'svg' && name != 'g') {
      ops.add(
        SvgOp(name, {
          for (final attribute in element.attributes)
            attribute.name.local: attribute.value,
          if (name == 'text') 'text': element.innerText,
        }),
      );
    }
    for (final child in element.childElements) {
      walk(child);
    }
  }

  walk(root);
  if (refused) return null;
  return SvgDrawing(root.getAttribute('viewBox') ?? '', ops);
}

class MathPiece {
  const MathPiece(this.source, {required this.display});

  final String source;
  final bool display;
}

class AlertPiece {
  const AlertPiece(this.type, this.body);

  final String type;
  final String body;
}

class TablePiece {
  const TablePiece(this.headers, this.rows);

  final List<String> headers;
  final List<List<String>> rows;
}

class EmbedPiece {
  const EmbedPiece(this.url, this.provider, this.externalId);

  final String url;
  final String provider;
  final String externalId;
}

class DirectivePiece {
  const DirectivePiece(this.name, this.attrs, this.raw);

  final String name;
  final Map<String, String> attrs;
  final String raw;
}

class ListingCard {
  const ListingCard({
    required this.address,
    this.price,
    this.beds,
    this.baths,
    this.size,
    this.note,
    this.facts = const [],
    this.catches = const [],
  });

  final String address;
  final String? price;
  final double? beds;
  final double? baths;
  final String? size;
  final String? note;
  final List<String> facts;
  final List<String> catches;
}

class SandboxControl {
  const SandboxControl(this.prompt, this.label);

  final String prompt;
  final String label;
}

class SandboxDocument {
  const SandboxDocument({
    required this.text,
    required this.controls,
    required this.droppedActiveContent,
  });

  final String text;
  final List<SandboxControl> controls;
  final bool droppedActiveContent;
}

const _droppedTags = {
  'script',
  'iframe',
  'object',
  'embed',
  'link',
  'meta',
  'base',
  'style',
};

/// Reads agent HTML as a document. No script, handler or external frame runs.
SandboxDocument? parseSandboxedHtml(String source) {
  if (!RegExp(r'<[a-z]', caseSensitive: false).hasMatch(source)) return null;
  final document = html_parser.parse(source);
  var dropped = false;
  final controls = <SandboxControl>[];
  final text = StringBuffer();

  void walk(dom.Node node) {
    if (node is dom.Element) {
      final name = node.localName?.toLowerCase() ?? '';
      if (_droppedTags.contains(name)) {
        dropped = true;
        return;
      }
      final attrs = node.attributes;
      for (final entry in attrs.entries.toList()) {
        final key = entry.key.toString().toLowerCase();
        final value = entry.value.trim().toLowerCase();
        if (key.startsWith('on') ||
            value.startsWith('javascript:') ||
            (key == 'src' && value.contains('://')) ||
            (key == 'href' && value.startsWith('javascript:'))) {
          dropped = true;
          attrs.remove(entry.key);
        }
      }
      final send = attrs['data-hermes-send'];
      if (send != null && send.trim().isNotEmpty) {
        controls.add(SandboxControl(send.trim(), node.text.trim()));
        return;
      }
      for (final child in node.nodes) {
        walk(child);
      }
      if (name == 'p' ||
          name == 'div' ||
          name == 'br' ||
          name.startsWith('h')) {
        text.write('\n');
      }
      return;
    }
    if (node is dom.Text) {
      text.write(node.text);
    }
  }

  final body = document.body;
  if (body != null) walk(body);
  return SandboxDocument(
    text: text.toString().replaceAll(RegExp(r'\n{3,}'), '\n\n').trim(),
    controls: controls,
    droppedActiveContent: dropped,
  );
}

bool htmlFilePath(String path) {
  final name = path.split('?').first.split('/').last.toLowerCase();
  return name.endsWith('.html') ||
      name.endsWith('.htm') ||
      name.endsWith('.xhtml');
}

Map<String, String> _directiveAttrs(String raw) {
  final attrs = <String, String>{};
  final pattern = RegExp('(\\w+)\\s*=\\s*(?:"([^"]*)"|\'([^"]*)\')');
  for (final match in pattern.allMatches(raw)) {
    attrs[match.group(1)!] = match.group(2) ?? match.group(3) ?? '';
  }
  return attrs;
}

final _directive = RegExp(r'::([a-z][a-z0-9-]*)\{([^{}]*)\}');
final _alert = RegExp(
  r'(?:^|\n)(?:>\s*)+\[!(note|tip|important|warning|caution)\]\s*\n((?:>.*(?:\n|$))*)',
  caseSensitive: false,
);
final _displayMath = RegExp(r'\$\$([^$]+)\$\$');
final _inlineMath = RegExp(r'(?<!\$)\$([^$\n]+)\$(?!\$)');

bool _mathLike(String body) =>
    body.contains(r'\') || body.contains('^') || body.contains('_');

List<String> _cells(String line) => line
    .trim()
    .replaceAll(RegExp(r'^\|'), '')
    .replaceAll(RegExp(r'\|$'), '')
    .split('|')
    .map((cell) => cell.trim())
    .toList();

bool _separator(String line) =>
    RegExp(r'^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)+\|?\s*$').hasMatch(line);

EmbedPiece? detectProviderEmbed(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  final host = uri.host.toLowerCase().replaceFirst(RegExp(r'^www\.'), '');
  String? provider;
  String id = uri.path;
  if (host == 'youtu.be') {
    provider = 'youtube';
    id = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
  } else if (host == 'youtube.com' || host == 'm.youtube.com') {
    provider = 'youtube';
    id = uri.queryParameters['v'] ?? uri.pathSegments.lastOrNull ?? '';
  } else if (host == 'vimeo.com') {
    provider = 'vimeo';
    id = uri.pathSegments.lastOrNull ?? '';
  } else if (host == 'instagram.com') {
    provider = 'instagram';
  } else if (host == 'pinterest.com' || host.endsWith('.pinterest.com')) {
    provider = 'pinterest';
  } else if (host.endsWith('tiktok.com')) {
    provider = 'tiktok';
  } else if (host == 'twitter.com' || host == 'x.com') {
    provider = 'twitter';
  } else if (host == 'open.spotify.com') {
    provider = 'spotify';
  } else if (host == 'google.com' && uri.path.startsWith('/maps') ||
      host.startsWith('maps.google.') ||
      host == 'maps.app.goo.gl') {
    provider = 'maps';
  }
  if (provider == null || id.isEmpty) return null;
  return EmbedPiece(raw.trim(), provider, id);
}

List<ListingCard> parseListings(String code) {
  Object? data;
  try {
    data = jsonDecode(code);
  } on FormatException {
    return const [];
  }
  final entries = data is List
      ? data
      : data is Map && data['listings'] is List
      ? data['listings'] as List
      : [data];
  final cards = <ListingCard>[];
  for (final entry in entries.take(12)) {
    if (entry is! Map) continue;
    final address = (entry['address'] ?? entry['title'] ?? '')
        .toString()
        .trim();
    if (address.isEmpty) continue;
    double? count(Object? value) {
      final parsed = value is num
          ? value.toDouble()
          : value is String
          ? double.tryParse(value.trim())
          : null;
      if (parsed == null || parsed <= 0 || parsed > 99) return null;
      return (parsed * 10).round() / 10;
    }

    List<String> strings(Object? value) => value is List
        ? [
            for (final item in value.take(8))
              if (item.toString().trim().isNotEmpty) item.toString().trim(),
          ]
        : const [];
    cards.add(
      ListingCard(
        address: address,
        price: entry['price']?.toString(),
        beds: count(entry['beds']),
        baths: count(entry['baths']),
        size: (entry['size'] ?? entry['sqft'])?.toString(),
        note: entry['note']?.toString(),
        facts: strings(entry['facts']),
        catches: strings(entry['catches']),
      ),
    );
  }
  return cards;
}

sealed class TranscriptPiece {
  const TranscriptPiece();
}

class ProsePiece extends TranscriptPiece {
  const ProsePiece(this.text);

  final String text;
}

class RichPiece extends TranscriptPiece {
  const RichPiece(this.value);

  final Object value;
}

List<TranscriptPiece> _piecesFromProse(String text) {
  if (text.isEmpty) return const [];
  final matches = <_Hit>[];
  void take(RegExp pattern, Object? Function(RegExpMatch match) build) {
    for (final match in pattern.allMatches(text)) {
      final value = build(match);
      if (value != null) {
        matches.add(_Hit(match.start, match.end, value));
      }
    }
  }

  take(_directive, (match) {
    return DirectivePiece(
      match.group(1)!,
      _directiveAttrs(match.group(2) ?? ''),
      match.group(0)!,
    );
  });
  take(_alert, (match) {
    final body = (match.group(2) ?? '')
        .split('\n')
        .map((line) => line.replaceFirst(RegExp(r'^>\s?'), ''))
        .join('\n')
        .trim();
    return AlertPiece(match.group(1)!.toLowerCase(), body);
  });
  take(_displayMath, (match) {
    final body = match.group(1)!.trim();
    return _mathLike(body) ? MathPiece(body, display: true) : null;
  });
  take(_inlineMath, (match) {
    final body = match.group(1)!.trim();
    return _mathLike(body) ? MathPiece(body, display: false) : null;
  });

  final lines = text.split('\n');
  var offset = 0;
  var row = 0;
  while (row < lines.length) {
    final lineStart = offset;
    if (lines[row].trimLeft().startsWith('|') &&
        row + 1 < lines.length &&
        _separator(lines[row + 1])) {
      final headers = _cells(lines[row]);
      final rows = <List<String>>[];
      var end = offset + lines[row].length + 1 + lines[row + 1].length;
      var next = row + 2;
      while (next < lines.length && lines[next].trimLeft().startsWith('|')) {
        rows.add(_cells(lines[next]));
        end += 1 + lines[next].length;
        next++;
      }
      if (end <= text.length) {
        matches.add(_Hit(lineStart, end, TablePiece(headers, rows)));
      }
      row = next;
      offset = end + 1;
      continue;
    }
    final trimmed = lines[row].trim();
    final embed = detectProviderEmbed(trimmed);
    if (embed != null &&
        trimmed == lines[row].trim() &&
        !trimmed.contains('](')) {
      final start = text.indexOf(trimmed, offset);
      if (start >= 0) {
        matches.add(_Hit(start, start + trimmed.length, embed));
      }
    }
    offset += lines[row].length + 1;
    row++;
  }

  if (matches.isEmpty) return [ProsePiece(text)];
  matches.sort((a, b) => a.start.compareTo(b.start));
  final kept = <_Hit>[];
  var cursor = 0;
  for (final hit in matches) {
    if (hit.start < cursor || hit.end > text.length) continue;
    kept.add(hit);
    cursor = hit.end;
  }
  final pieces = <TranscriptPiece>[];
  cursor = 0;
  for (final hit in kept) {
    if (hit.start > cursor) {
      pieces.add(ProsePiece(text.substring(cursor, hit.start)));
    }
    pieces.add(RichPiece(hit.value));
    cursor = hit.end;
  }
  if (cursor < text.length) pieces.add(ProsePiece(text.substring(cursor)));
  return pieces.where((piece) {
    return piece is! ProsePiece || piece.text.trim().isNotEmpty;
  }).toList();
}

class _Hit {
  const _Hit(this.start, this.end, this.value);

  final int start;
  final int end;
  final Object value;
}

List<TranscriptPiece> splitRichProse(String text) => _piecesFromProse(text);

enum EmbedMode { always, ask, off }

class EmbedConsent extends ChangeNotifier {
  EmbedMode mode = EmbedMode.ask;
  final allowedProviders = <String>{};
  final loadedOnce = <String>{};

  bool fetches(EmbedPiece embed) {
    if (mode == EmbedMode.off) return false;
    if (mode == EmbedMode.always || allowedProviders.contains(embed.provider)) {
      return true;
    }
    return loadedOnce.contains(embed.url);
  }

  void loadOnce(EmbedPiece embed) {
    loadedOnce.add(embed.url);
    notifyListeners();
  }

  void allowProvider(String provider) {
    allowedProviders.add(provider);
    notifyListeners();
  }

  void setMode(EmbedMode value) {
    mode = value;
    notifyListeners();
  }

  void reset() {
    mode = EmbedMode.ask;
    allowedProviders.clear();
    loadedOnce.clear();
    notifyListeners();
  }
}

final embedConsent = EmbedConsent();
