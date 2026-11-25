/// Prompts this client has not admitted yet.
///
/// Desktop 0.23.4 keeps this list in the composer and parks it on Stop or
/// Esc. A healthy gateway FIFO is a different queue: nothing here holds,
/// releases or reorders it. The park is memory-only, so a new process starts
/// unparked.
final class ClientHeldPrompt {
  ClientHeldPrompt(this.id, this.text);

  final String id;
  final String text;
}

final class ClientHeldQueue {
  final List<ClientHeldPrompt> entries = [];
  bool parked = false;
  var _sequence = 0;

  bool get isEmpty => entries.isEmpty;

  /// A newly typed prompt is fresh intent, so it lifts a park from an earlier
  /// Stop. It does not itself send.
  void enqueue(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    entries.add(ClientHeldPrompt('held-$_sequence', trimmed));
    _sequence += 1;
    parked = false;
  }

  /// Stop or Esc. An empty list cannot be parked, or a later prompt would
  /// inherit a stale hold.
  bool park() {
    if (entries.isEmpty) return false;
    parked = true;
    return true;
  }

  void unpark() => parked = false;

  bool promote(String id) {
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    if (index == 0) return true;
    entries.insert(0, entries.removeAt(index));
    return true;
  }

  /// [manual] is Resume, Enter or a row send: it lifts the park. An automatic
  /// drain leaves a park in place and takes nothing.
  ClientHeldPrompt? takeHead({required bool manual}) {
    if (entries.isEmpty) return null;
    if (!manual && parked) return null;
    final head = entries.removeAt(0);
    if (manual || entries.isEmpty) parked = false;
    return head;
  }

  bool remove(String id) {
    final before = entries.length;
    entries.removeWhere((entry) => entry.id == id);
    if (entries.isEmpty) parked = false;
    return entries.length != before;
  }

  bool edit(String id, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index < 0) return false;
    entries[index] = ClientHeldPrompt(id, trimmed);
    return true;
  }
}

String clientHeldQueueLabel({required int count, required bool parked}) =>
    parked ? '$count queued — paused' : '$count queued';
