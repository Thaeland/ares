import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../services/connection_mutation_barrier.dart';
import '../services/remote_workspace.dart';

/// The chat that supplied the entry owns the route. Refresh/reopen reads the
/// server, never drains or replays a local copy of the server's FIFO.
class GatewayQueueScreen extends StatefulWidget {
  const GatewayQueueScreen({
    super.key,
    required this.owner,
    required this.route,
    this.draft = '',
    this.onAdmitted,
  });
  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final String draft;
  final ValueChanged<String>? onAdmitted;

  static Future<void> open(
    BuildContext context,
    RemoteWorkspaceOwner owner,
    WorkspaceRoute route, {
    String draft = '',
    ValueChanged<String>? onAdmitted,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => GatewayQueueScreen(
        owner: owner,
        route: route,
        draft: draft,
        onAdmitted: onAdmitted,
      ),
    ),
  );

  @override
  State<GatewayQueueScreen> createState() => _GatewayQueueScreenState();
}

class _GatewayQueueScreenState extends State<GatewayQueueScreen> {
  late final _pane = widget.owner.pane();
  late final _editor = TextEditingController(text: widget.draft);
  late final _account = ConnectionMutationBarrier.capture(
    widget.route.connectionId,
  );
  WorkspaceTarget? _target;
  GatewayQueue? _queue;
  QueueAdmission? _editing;
  String _previous = '', _request = const Uuid().v4();
  bool _reading = false, _writing = false, _again = false, _closed = false;
  String? _message;
  void Function()? _stopWatch;
  bool get _alive => mounted && !_closed;

  @override
  void initState() {
    super.initState();
    ConnectionMutationBarrier.addListener(_accountChanged);
    unawaited(_read());
  }

  void _accountChanged() {
    if (!ConnectionMutationBarrier.isCurrent(
      widget.route.connectionId,
      _account,
    )) {
      _retire();
      if (mounted) {
        setState(() {
          _editor.clear();
          _previous = '';
          _editing = null;
          _queue = null;
          _message = 'This connection changed. Reopen its chat.';
        });
      }
    }
  }

  void _retire() {
    _closed = true;
    _pane.close();
    _stopWatch?.call();
    _stopWatch = null;
  }

  @override
  void dispose() {
    _retire();
    ConnectionMutationBarrier.removeListener(_accountChanged);
    _editor.dispose();
    super.dispose();
  }

  Future<void> _read() async {
    if (!_alive) return;
    if (_reading || _writing) {
      _again = true;
      return;
    }
    setState(() => _reading = true);
    try {
      do {
        _again = false;
        var t = _target;
        if (t == null || !t.isCurrent) {
          _stopWatch?.call();
          t = _target = await _pane.bind(widget.route);
          if (!_alive) return;
          if (!t.sessionAuthority) {
            throw const WorkspaceException(WorkspaceFailure.unsupported);
          }
          _stopWatch = t.watchQueue(() {
            if (!_alive) return;
            if (!t!.isCurrent) {
              // Wait for a human refresh after socket loss, never attach in the
              // background simply because an old operation lost its response.
              setState(() {
                _queue = null;
                _message = 'Disconnected. Reconnect the chat, then refresh.';
              });
            } else {
              unawaited(_read());
            }
          });
        }
        final value = await t.busyQueue();
        if (!_alive) return;
        t.checkCurrent();
        // A notification received during this physical read demands a fresh
        // trailing read, not publication of the held earlier snapshot.
        if (!_again) setState(() => _queue = value);
      } while (_again && _alive);
    } on WorkspaceException catch (e) {
      if (_alive) {
        setState(() {
          _queue = null;
          _message = 'Gateway queue unavailable: ${e.reason.name}.';
        });
      }
    } finally {
      if (_alive) setState(() => _reading = false);
    }
  }

  Future<bool> _perform(Future<void> Function() action, String success) async {
    if (!_alive || _writing || _reading) return false;
    setState(() => _writing = true);
    var ok = false;
    try {
      await action();
      if (!_alive) return false;
      _target!.checkCurrent();
      ok = true;
      setState(() => _message = success);
    } on WorkspaceException catch (e) {
      if (_alive) {
        setState(
          () => _message =
              'Not confirmed (${e.reason.name}). Nothing was resent.',
        );
      }
    } finally {
      if (_alive) {
        setState(() => _writing = false);
        await _read();
      }
    }
    return ok && _alive;
  }

  void _edit(QueueAdmission row) {
    setState(() {
      _previous = _editor.text;
      _editing = row;
      _editor.text = row.text;
      _request = const Uuid().v4();
    });
  }

  void _finishEdit() {
    _editor.text = _previous;
    _previous = '';
    _editing = null;
    _request = const Uuid().v4();
  }

  Future<void> _save() async {
    final q = _queue, row = _editing;
    final text = _editor.text;
    if (q == null || text.trim().isEmpty) return;
    final request = _request;
    final ok = await _perform(
      () => row == null ? q.enqueue(text, request) : row.replace(text, request),
      row == null
          ? 'Gateway confirmed admission.'
          : 'Edited entry admitted at the end of the queue.',
    );
    if (!ok || _request != request) return;
    if (row == null) widget.onAdmitted?.call(text);
    setState(() {
      if (row != null) {
        _finishEdit();
      } else {
        _editor.clear();
        _request = const Uuid().v4();
      }
    });
  }

  Future<void> _confirm(QueueAdmission row) async {
    final discard = row.unknown;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          discard ? 'Discard unknown outcome?' : 'Remove this entry?',
        ),
        content: Text(
          discard
              ? 'The lost turn will not be retried. Waiting turns may now run.'
              : 'If the gateway has just started this entry, removing it can stop that turn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(discard ? 'Discard and resume' : 'Remove entry'),
          ),
        ],
      ),
    );
    if (yes == true && _alive) {
      await _perform(
        discard ? row.discardUnknown : row.remove,
        discard
            ? 'Lost admission resolved; it was not resent.'
            : 'Gateway acknowledged removal.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _queue;
    final busy = _reading || _writing || _closed;
    return PopScope<void>(
      onPopInvokedWithResult: (popped, _) {
        if (popped) _retire();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gateway queue'),
          actions: [
            IconButton(
              tooltip: 'Refresh queue',
              onPressed: busy
                  ? null
                  : () {
                      setState(() => _message = null);
                      _read();
                    },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                [
                  widget.route.connectionId,
                  ?widget.route.profile,
                  ?widget.route.storedSessionId,
                ].join(' · '),
              ),
              if (_reading) const LinearProgressIndicator(),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(_message!),
                ),
              if (q != null) ...[
                if (q.paused)
                  const ListTile(
                    leading: Icon(Icons.pause_circle_outline),
                    title: Text('Queue paused: unknown outcome'),
                    subtitle: Text(
                      'Review the lost admission before resuming. Nothing is sent again.',
                    ),
                  ),
                if (q.entries.isEmpty)
                  const ListTile(title: Text('No pending admissions')),
                for (final row in q.entries)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.text,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('#${row.sequence} · ${row.state}'),
                          Wrap(
                            children: [
                              if (row.unknown)
                                TextButton(
                                  onPressed: busy ? null : () => _confirm(row),
                                  child: const Text('Discard…'),
                                ),
                              if (row.queued) ...[
                                if (row.controls.contains('replace'))
                                  TextButton(
                                    onPressed: busy || _editing != null
                                        ? null
                                        : () => _edit(row),
                                    child: const Text('Edit'),
                                  ),
                                if (row.controls.contains('steer'))
                                  TextButton(
                                    onPressed: busy
                                        ? null
                                        : () => _perform(
                                            row.steer,
                                            'Gateway acknowledged the steering request.',
                                          ),
                                    child: const Text('Steer running turn'),
                                  ),
                                TextButton(
                                  onPressed: busy ? null : () => _confirm(row),
                                  child: const Text('Remove…'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              if (!_closed) ...[
                TextField(
                  controller: _editor,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (_) => _request = const Uuid().v4(),
                  decoration: InputDecoration(
                    labelText: _editing == null
                        ? 'Next prompt'
                        : 'Edit queued prompt',
                  ),
                ),
                Wrap(
                  children: [
                    FilledButton(
                      onPressed: busy || q == null ? null : _save,
                      child: Text(
                        _editing == null
                            ? 'Submit to gateway queue'
                            : 'Save at queue end',
                      ),
                    ),
                    if (_editing != null)
                      TextButton(
                        onPressed: _writing
                            ? null
                            : () => setState(_finishEdit),
                        child: const Text('Cancel edit'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
