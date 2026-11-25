/// Heuristic echo guard for barge-in: a transcript that closely matches the
/// text being read aloud is the engine's own voice bleeding back into the mic,
/// not the user talking. This is intentionally lighter than Hermes Desktop's
/// difflib-based guard — it never blocks a genuine interjection (most words
/// differ), and only suppresses close matches.
library;

String _normalize(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

/// Character bigram overlap ratio, in [0, 1].
double _bigramRatio(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final aSet = <String>{};
  final bSet = <String>{};
  for (var i = 0; i < a.length - 1; i++) {
    aSet.add(a.substring(i, i + 2));
  }
  for (var i = 0; i < b.length - 1; i++) {
    bSet.add(b.substring(i, i + 2));
  }
  if (aSet.isEmpty && bSet.isEmpty) {
    // Short strings: fall back to exact-character containment.
    return a == b ? 1.0 : 0.0;
  }
  final overlap = aSet.intersection(bSet).length;
  final union = aSet.union(bSet).length;
  return union == 0 ? 0.0 : overlap / union;
}

/// True when [transcript] looks like the engine speaking (echo) rather than a
/// user interjection. A genuine one-word barge ("no", "stop") never matches
/// long reply text, so short transcripts only compare against short spoken
/// text.
bool isLikelyEcho(String transcript, String spoken) {
  final a = _normalize(transcript);
  final b = _normalize(spoken);
  if (a.isEmpty || b.isEmpty) return false;
  if (_bigramRatio(a, b) >= 0.5) return true;
  // Sliding window over the spoken text for short transcripts: a fragment of
  // a long reply can look like echo without matching the whole reply.
  if (a.length < b.length && a.length >= 10) {
    for (var start = 0; start <= b.length - a.length; start++) {
      if (_bigramRatio(a, b.substring(start, start + a.length)) >= 0.5) {
        return true;
      }
    }
  }
  return false;
}
