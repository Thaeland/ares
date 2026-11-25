import 'package:flutter/foundation.dart';

import '../utils/media_tags.dart';

enum GeneratedArtifactKind { code, html, svg }

class GeneratedArtifact {
  const GeneratedArtifact({
    required this.kind,
    required this.language,
    required this.title,
  });

  final GeneratedArtifactKind kind;
  final String language;
  final String title;
}

const _htmlLanguages = {'html', 'htm', 'xhtml'};
const _nonArtifactLanguages = {
  '',
  'console',
  'diff',
  'listing',
  'log',
  'logs',
  'markdown',
  'md',
  'mermaid',
  'output',
  'patch',
  'plain',
  'plaintext',
  'shell-session',
  'stdout',
  'text',
  'txt',
};
const _commonCodeLanguages = {
  'bash',
  'c',
  'cpp',
  'cs',
  'css',
  'dart',
  'go',
  'html',
  'java',
  'javascript',
  'js',
  'json',
  'jsx',
  'kt',
  'php',
  'py',
  'python',
  'rb',
  'rs',
  'sh',
  'sql',
  'swift',
  'ts',
  'tsx',
  'typescript',
  'yaml',
  'yml',
};

final _languageTag = RegExp(r'^[a-z0-9][a-z0-9+#-]*$', caseSensitive: false);
final _htmlDocument = RegExp(
  r'<!doctype\s+html|<html[\s>]|<head[\s>]|<body[\s>]',
  caseSensitive: false,
);
final _htmlTag = RegExp(r'<[a-z][a-z0-9-]*(\s[^>]*)?>', caseSensitive: false);
final _codeDeclaration = RegExp(
  r'(?:^|\n)\s*(?:export\s+)?(?:default\s+)?(?:async\s+)?(?:function|class|struct|interface|enum|trait|impl|def|fn)\s+([A-Za-z_$][\w$]*)',
);
final _filenameComment = RegExp(
  r'^\s*(?://|#|--|<!--|/\*)\s*([\w./-]+\.[a-z0-9]{1,8})\b',
  caseSensitive: false,
);

const _htmlDocumentMinChars = 160;
const _htmlFragmentMinChars = 1200;
const _svgMinChars = 2000;
const _codeMinLines = 48;
const _codeMinChars = 3000;

String sanitizeLanguageTag(String? tag) {
  final first = (tag ?? '').trim().split(RegExp(r'\s')).first;
  if (first.isEmpty || first.length > 16 || !_languageTag.hasMatch(first)) {
    return '';
  }
  return first.toLowerCase();
}

bool isLikelyProseCodeBlock(String language, String code) {
  if (_commonCodeLanguages.contains(language)) return false;
  var prose = 0;
  var signals = 0;
  for (final line in code.split('\n')) {
    if (RegExp(
      r'[;{}]|\b(def|class|function|import|const|let|var|fn|struct)\b',
    ).hasMatch(line)) {
      signals++;
    } else if (line.trim().split(RegExp(r'\s+')).length > 8) {
      prose++;
    }
  }
  return prose >= 2 && signals <= 1;
}

String _stripTags(String value) =>
    value.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

String _titleFromTag(String content, String tag) {
  final match = RegExp(
    '<$tag[^>]*>([\\s\\S]*?)</$tag>',
    caseSensitive: false,
  ).firstMatch(content);
  if (match == null) return '';
  final text = _stripTags(match.group(1) ?? '');
  return text.length > 80 ? text.substring(0, 80) : text;
}

String _codeTitle(String language, String content) {
  final head = content.length > 2000 ? content.substring(0, 2000) : content;
  final fileName = _filenameComment.firstMatch(head)?.group(1);
  if (fileName != null && fileName.isNotEmpty) return fileName;
  final declaration = _codeDeclaration.firstMatch(head)?.group(1);
  if (declaration != null && declaration.isNotEmpty) return declaration;
  return language;
}

int _lineCount(String text) {
  var lines = 1;
  var index = text.indexOf('\n');
  while (index != -1) {
    lines++;
    index = text.indexOf('\n', index + 1);
  }
  return lines;
}

/// Promotes a substantial HTML, SVG or code fence. Small snippets stay inline.
GeneratedArtifact? detectArtifact(String? language, String? code) {
  final trimmed = (code ?? '').trim();
  if (trimmed.isEmpty) return null;
  final clean = sanitizeLanguageTag(language);
  if (_htmlLanguages.contains(clean)) {
    final document = _htmlDocument.hasMatch(trimmed);
    final substantial =
        (document && trimmed.length >= _htmlDocumentMinChars) ||
        (!document &&
            trimmed.length >= _htmlFragmentMinChars &&
            _htmlTag.hasMatch(trimmed));
    if (!substantial) return null;
    final title = _titleFromTag(trimmed, 'title');
    return GeneratedArtifact(
      kind: GeneratedArtifactKind.html,
      language: clean,
      title: title.isNotEmpty
          ? title
          : (_titleFromTag(trimmed, 'h1').isNotEmpty
                ? _titleFromTag(trimmed, 'h1')
                : 'HTML'),
    );
  }
  if (clean == 'svg') {
    if (trimmed.length >= _svgMinChars &&
        RegExp(r'<svg[\s>]', caseSensitive: false).hasMatch(trimmed)) {
      final title = _titleFromTag(trimmed, 'title');
      return GeneratedArtifact(
        kind: GeneratedArtifactKind.svg,
        language: clean,
        title: title.isEmpty ? 'SVG' : title,
      );
    }
    return null;
  }
  if (_nonArtifactLanguages.contains(clean)) return null;
  if (trimmed.length < _codeMinChars && _lineCount(trimmed) < _codeMinLines) {
    return null;
  }
  if (isLikelyProseCodeBlock(clean, trimmed)) return null;
  return GeneratedArtifact(
    kind: GeneratedArtifactKind.code,
    language: clean,
    title: _codeTitle(clean, trimmed),
  );
}

String artifactSlug(GeneratedArtifact detection) {
  final title = detection.title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final trimmed = title.length > 48 ? title.substring(0, 48) : title;
  return '${detection.kind.name}:${detection.language}:${trimmed.isEmpty ? 'untitled' : trimmed}';
}

String artifactContentHash(String content) {
  var hash = 0x811c9dc5;
  for (final unit in content.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(36);
}

const _downloadExtensions = {
  'bash': '.sh',
  'c': '.c',
  'cpp': '.cpp',
  'css': '.css',
  'dart': '.dart',
  'go': '.go',
  'htm': '.html',
  'html': '.html',
  'java': '.java',
  'javascript': '.js',
  'js': '.js',
  'json': '.json',
  'jsx': '.jsx',
  'php': '.php',
  'py': '.py',
  'python': '.py',
  'rb': '.rb',
  'rs': '.rs',
  'sh': '.sh',
  'sql': '.sql',
  'svg': '.svg',
  'swift': '.swift',
  'ts': '.ts',
  'tsx': '.tsx',
  'typescript': '.ts',
  'xhtml': '.html',
  'yaml': '.yaml',
  'yml': '.yaml',
};

String artifactDownloadName(GeneratedArtifact detection) {
  final base =
      detection.title
          .replaceAll(RegExp(r'[^A-Za-z0-9._ -]+'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
  final clipped = (base.isEmpty
          ? 'artifact'
          : (base.length > 60 ? base.substring(0, 60) : base))
      .replaceAll(RegExp(r'[ .]+$'), '');
  if (RegExp(r'\.[a-z0-9]{1,8}$', caseSensitive: false).hasMatch(clipped)) {
    return clipped;
  }
  final extension = switch (detection.kind) {
    GeneratedArtifactKind.html => '.html',
    GeneratedArtifactKind.svg => '.svg',
    GeneratedArtifactKind.code =>
      _downloadExtensions[detection.language] ?? '.txt',
  };
  return '$clipped$extension';
}

class ArtifactRevision {
  const ArtifactRevision({
    required this.index,
    required this.hash,
    required this.content,
    required this.detection,
  });

  final int index;
  final String hash;
  final String content;
  final GeneratedArtifact detection;

  String get downloadName => artifactDownloadName(detection);
}

class VersionedArtifact {
  const VersionedArtifact({
    required this.slug,
    required this.revisions,
  });

  final String slug;
  final List<ArtifactRevision> revisions;
}

final _fence = RegExp(r'```([^\n`]*)\n([\s\S]*?)```');

/// Rebuilds versioned artifacts from assistant text. The same title in one
/// corpus is one artifact; a changed body is the next revision. No file is
/// required.
List<VersionedArtifact> artifactHistoryFromText(String corpus) {
  final grouped = <String, List<ArtifactRevision>>{};
  final order = <String>[];
  for (final match in _fence.allMatches(corpus)) {
    final language = match.group(1);
    final body = match.group(2) ?? '';
    final detection = detectArtifact(language, body);
    if (detection == null) continue;
    final slug = artifactSlug(detection);
    final hash = artifactContentHash(body.trim());
    final revisions = grouped.putIfAbsent(slug, () {
      order.add(slug);
      return <ArtifactRevision>[];
    });
    if (revisions.isNotEmpty && revisions.last.hash == hash) continue;
    revisions.add(
      ArtifactRevision(
        index: revisions.length + 1,
        hash: hash,
        content: body.trim(),
        detection: detection,
      ),
    );
  }
  return [
    for (final slug in order)
      VersionedArtifact(slug: slug, revisions: grouped[slug]!),
  ];
}

enum IndexedArtifactKind { image, file, link }

class IndexedArtifact {
  const IndexedArtifact({
    required this.id,
    required this.kind,
    required this.value,
    required this.label,
    required this.sessionId,
    required this.sessionTitle,
    required this.timestamp,
  });

  final String id;
  final IndexedArtifactKind kind;
  final String value;
  final String label;
  final String sessionId;
  final String sessionTitle;
  final double timestamp;
}

final _markdownImage = RegExp(r'!\[([^\]]*)\]\(([^)\s]+)\)');
final _markdownLink = RegExp(r'\[([^\]]+)\]\(([^)\s]+)\)');
final _bareUrl = RegExp(r'''https?://[^\s<>"'`)]+''');
final _unixPath = RegExp(
  r'''(^|[\s("'`)])((?:/|~/|\.\.?/)[^\s"'`<>]+)''',
);
final _imageExt = RegExp(
  r'\.(?:png|jpe?g|gif|webp|svg|bmp)(?:\?.*)?$',
  caseSensitive: false,
);
final _fileExt = RegExp(
  r'\.(?:png|jpe?g|gif|webp|svg|bmp|pdf|txt|json|md|csv|xlsx?|docx?|pptx?|html?|zip|tar|gz|avi|flac|m4a|mkv|mp3|ogg|opus|wav|webm|mp4|mov)(?:\?.*)?$',
  caseSensitive: false,
);
final _producerTool = RegExp(
  r'(?:^|_)(?:creat(?:e|ion)|download|export|generat(?:e|ion)|render|save|speech|tts|write)(?:_|$)',
  caseSensitive: false,
);
final _wheel = RegExp(r'\.whl(?:\.metadata)?$', caseSensitive: false);
final _pipCache = RegExp(
  r'/(?:\.cache/pip|library/caches/pip|appdata/local/pip/cache)/',
  caseSensitive: false,
);

bool _packageDownload(String value) {
  final path = value.replaceAll('\\', '/').toLowerCase();
  return _pipCache.hasMatch(path) || _wheel.hasMatch(path);
}

String _cleanArtifactValue(String value) {
  var trimmed = value.trim();
  for (var i = 0; i < 3; i++) {
    if (trimmed.length >= 2 &&
        '"\'`'.contains(trimmed[0]) &&
        trimmed[0] == trimmed[trimmed.length - 1]) {
      trimmed = trimmed.substring(1, trimmed.length - 1).trim();
      continue;
    }
    break;
  }
  return trimmed.replaceAll(RegExp(r'[`*]+$'), '').replaceAll(
    RegExp(r'[),.;]+$'),
    '',
  );
}

IndexedArtifactKind? _kindFor(String value, {required bool explicit}) {
  if (!explicit && _packageDownload(value)) return null;
  if (value.startsWith('https://') || value.startsWith('http://')) {
    return _fileExt.hasMatch(value)
        ? (_imageExt.hasMatch(value)
              ? IndexedArtifactKind.image
              : IndexedArtifactKind.file)
        : IndexedArtifactKind.link;
  }
  if (explicit || _fileExt.hasMatch(value)) {
    return _imageExt.hasMatch(value)
        ? IndexedArtifactKind.image
        : IndexedArtifactKind.file;
  }
  return null;
}

void _pushIndexed(
  Map<String, IndexedArtifact> into,
  String raw, {
  required String sessionId,
  required String sessionTitle,
  required double timestamp,
  bool explicit = false,
}) {
  final value = _cleanArtifactValue(raw);
  if (value.isEmpty) return;
  final kind = _kindFor(value, explicit: explicit);
  if (kind == null) return;
  final id = '$sessionId|$value';
  final label = value.split('/').last.split('?').first;
  into[id] = IndexedArtifact(
    id: id,
    kind: kind,
    value: value,
    label: label.isEmpty ? value : label,
    sessionId: sessionId,
    sessionTitle: sessionTitle,
    timestamp: timestamp,
  );
}

void _fromProse(
  Map<String, IndexedArtifact> into,
  String text, {
  required String sessionId,
  required String sessionTitle,
  required double timestamp,
}) {
  for (final ref in extractMediaTagRefs(text)) {
    _pushIndexed(
      into,
      ref.path,
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      timestamp: timestamp,
      explicit: true,
    );
  }
  for (final match in _markdownImage.allMatches(text)) {
    _pushIndexed(
      into,
      match.group(2) ?? '',
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      timestamp: timestamp,
    );
  }
  for (final match in _markdownLink.allMatches(text)) {
    final start = match.start;
    if (start > 0 && text[start - 1] == '!') continue;
    _pushIndexed(
      into,
      match.group(2) ?? '',
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      timestamp: timestamp,
    );
  }
  for (final match in _bareUrl.allMatches(text)) {
    _pushIndexed(
      into,
      match.group(0) ?? '',
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      timestamp: timestamp,
    );
  }
  for (final match in _unixPath.allMatches(text)) {
    _pushIndexed(
      into,
      match.group(2) ?? '',
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      timestamp: timestamp,
    );
  }
}

double _timestampOf(Map<String, dynamic> message) {
  final raw = message['timestamp'];
  final parsed = raw is num
      ? raw.toDouble()
      : raw is String
      ? double.tryParse(raw)
      : null;
  return parsed != null && parsed.isFinite ? parsed : 0;
}

/// Indexes ordinary links, recognised paths and selected tool output.
/// Explicit deliveries stay eligible even when a heuristic would skip them.
List<IndexedArtifact> indexArtifactsFromMessages({
  required String sessionId,
  required String sessionTitle,
  required List<Map<String, dynamic>> messages,
}) {
  final found = <String, IndexedArtifact>{};
  for (final message in messages) {
    final role = message['role']?.toString() ?? '';
    final text = message['content']?.toString() ?? '';
    final timestamp = _timestampOf(message);
    if (role == 'assistant' || role == 'agent') {
      if (text.isNotEmpty) {
        _fromProse(
          found,
          text,
          sessionId: sessionId,
          sessionTitle: sessionTitle,
          timestamp: timestamp,
        );
      }
      continue;
    }
    if (role != 'tool') continue;
    final name = (message['tool_name'] ?? message['name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    final producer = _producerTool.hasMatch(name) || name.startsWith('bfl_flux3_');
    final terminal = name == 'terminal';
    if (text.isNotEmpty && (producer || terminal)) {
      _fromProse(
        found,
        text,
        sessionId: sessionId,
        sessionTitle: sessionTitle,
        timestamp: timestamp,
      );
    }
    if (name == 'browser_vision' || name == 'vision_analyze') {
      for (final match in RegExp(
        r'Screenshot path:\s*([^\r\n<>]+)',
        caseSensitive: false,
      ).allMatches(text)) {
        _pushIndexed(
          found,
          match.group(1) ?? '',
          sessionId: sessionId,
          sessionTitle: sessionTitle,
          timestamp: timestamp,
          explicit: true,
        );
      }
    }
  }
  final values = found.values.toList()
    ..sort((a, b) {
      final byTime = b.timestamp.compareTo(a.timestamp);
      return byTime == 0 ? a.id.compareTo(b.id) : byTime;
    });
  return values;
}

class PreviewSuggestion {
  const PreviewSuggestion({
    required this.sessionId,
    required this.target,
    required this.label,
    required this.completionId,
  });

  final String sessionId;
  final String target;
  final String label;
  final String completionId;
}

/// Dismissals survive a replay of the same completion. A later successful
/// completion of the same target may offer it again.
class PreviewSuggestionStore extends ChangeNotifier {
  final _visible = <String, List<PreviewSuggestion>>{};
  final _dismissedCompletion = <String, Map<String, String>>{};

  List<PreviewSuggestion> visible(String sessionId) =>
      List.unmodifiable(_visible[sessionId] ?? const []);

  void record({
    required String sessionId,
    required String target,
    required String label,
    required String completionId,
  }) {
    final dismissed = _dismissedCompletion.putIfAbsent(sessionId, () => {});
    if (dismissed[target] == completionId) return;
    if (dismissed.containsKey(target)) dismissed.remove(target);
    final list = _visible.putIfAbsent(sessionId, () => []);
    for (final item in list) {
      if (item.target == target && item.completionId == completionId) {
        return;
      }
    }
    list.removeWhere((item) => item.target == target);
    list.insert(
      0,
      PreviewSuggestion(
        sessionId: sessionId,
        target: target,
        label: label,
        completionId: completionId,
      ),
    );
    if (list.length > 4) list.removeRange(4, list.length);
    notifyListeners();
  }

  void dismiss(String sessionId, String target) {
    final list = _visible[sessionId];
    if (list == null) return;
    final match = list.where((item) => item.target == target).toList();
    if (match.isEmpty) return;
    list.removeWhere((item) => item.target == target);
    _dismissedCompletion.putIfAbsent(
      sessionId,
      () => {},
    )[target] = match.first.completionId;
    notifyListeners();
  }

  void reset() {
    _visible.clear();
    _dismissedCompletion.clear();
    notifyListeners();
  }
}

final previewSuggestions = PreviewSuggestionStore();

final _previewTarget = RegExp(
  r'''(?:https?://(?:localhost|127\.0\.0\.1)(?::\d+)?[^\s<>"'`]*|(?:/|\./|~/)[^\s<>"'`]+\.html?)''',
);

List<({String target, String label})> previewTargetsIn(String text) {
  final found = <({String target, String label})>[];
  final seen = <String>{};
  for (final match in _previewTarget.allMatches(text)) {
    final target = (match.group(0) ?? '').trim();
    if (target.isEmpty || !seen.add(target)) continue;
    final label = target.split('/').last;
    found.add((target: target, label: label.isEmpty ? target : label));
  }
  return found;
}

class MediaPlaybackMemory {
  final positions = <String, double>{};
  final speeds = <String, double>{};

  double positionOf(String id) => positions[id] ?? 0;

  double speedOf(String id) => speeds[id] ?? 1;

  void remember(String id, {double? position, double? speed}) {
    if (position != null) {
      positions[id] = position.clamp(0, 1).toDouble();
    }
    if (speed != null && speed > 0) speeds[id] = speed;
  }

  void reset() {
    positions.clear();
    speeds.clear();
  }
}

final mediaPlayback = MediaPlaybackMemory();
