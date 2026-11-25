import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connection_manager.dart';
import '../services/remote_workspace.dart';

/// Timeline of learned skills and memories, with edits on the bound profile.
class MemoryGraphScreen extends StatefulWidget {
  const MemoryGraphScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.connection,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;

  @override
  State<MemoryGraphScreen> createState() => _MemoryGraphScreenState();
}

class _MemoryGraphScreenState extends State<MemoryGraphScreen> {
  WorkspacePane? _pane;
  WorkspaceTarget? _target;
  MemoryGraph? _graph;
  MemoryLayerStatus? _layers;
  MemoryProviderConfig? _provider;
  var _layout = const MemoryLayout(
    zoom: 1,
    playback: 1000,
    kind: 'all',
    pinnedOnly: false,
  );
  final _filter = TextEditingController();
  final _code = TextEditingController();
  final _providerValues = <String, TextEditingController>{};
  var _busy = false;
  String? _error;
  Timer? _play;

  @override
  void initState() {
    super.initState();
    _code.text = _layout.encode();
    _open();
  }

  @override
  void dispose() {
    _play?.cancel();
    _filter.dispose();
    _code.dispose();
    for (final controller in _providerValues.values) {
      controller.dispose();
    }
    _pane?.close();
    super.dispose();
  }

  Future<WorkspaceTarget> _bound() async {
    final current = _target;
    if (current != null && current.isCurrent) return current;
    _pane?.close();
    final pane = _pane = widget.owner.pane();
    final target = await pane.bind(widget.route);
    _target = target;
    return target;
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final target = await _bound();
      final graph = await target.memoryGraph();
      final layers = await target.memoryLayers();
      if (!mounted) return;
      setState(() {
        _graph = graph;
        _layers = layers;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<MemoryGraphNode> get _visible {
    final graph = _graph;
    if (graph == null) return const [];
    final stamps = [
      for (final node in graph.nodes)
        if (node.timestamp != null) node.timestamp!,
    ];
    final min = stamps.isEmpty ? 0 : stamps.reduce((a, b) => a < b ? a : b);
    final max = stamps.isEmpty ? 0 : stamps.reduce((a, b) => a > b ? a : b);
    final cutoff = min + ((max - min) * _layout.playback / 1000).round();
    final query = _filter.text.trim().toLowerCase();
    return [
      for (final node in graph.nodes)
        if ((_layout.kind == 'all' || node.kind == _layout.kind) &&
            (!_layout.pinnedOnly || node.pinned) &&
            (node.timestamp == null || node.timestamp! <= cutoff) &&
            (query.isEmpty ||
                node.label.toLowerCase().contains(query) ||
                node.category.toLowerCase().contains(query)))
          node,
    ];
  }

  void _setLayout(MemoryLayout layout) {
    setState(() {
      _layout = layout;
      _code.text = layout.encode();
    });
  }

  void _playTimeline() {
    _play?.cancel();
    _play = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted || _layout.playback >= 1000) {
        timer.cancel();
        return;
      }
      _setLayout(
        MemoryLayout(
          zoom: _layout.zoom,
          playback: (_layout.playback + 50).clamp(0, 1000),
          kind: _layout.kind,
          pinnedOnly: _layout.pinnedOnly,
        ),
      );
    });
  }

  Future<void> _edit(MemoryGraphNode node) async {
    final target = _target;
    if (target == null) return;
    final detail = await target.memoryNode(node.id);
    if (!mounted) return;
    final controller = TextEditingController(text: detail.content);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${detail.label}'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final content = controller.text;
    controller.dispose();
    if (save != true || !mounted) return;
    await _guard(() async {
      await (await _bound()).saveMemoryNode(node.id, content);
      await _open();
    });
  }

  Future<void> _remove(MemoryGraphNode node) async {
    final verb = node.kind == 'skill' ? 'Archive skill' : 'Delete memory';
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(verb),
        content: Text(
          node.kind == 'skill'
              ? 'Archive ${node.label} on ${widget.route.profile}? It can be restored on the host with the Curator.'
              : 'Delete ${node.label} from ${widget.route.profile}? This removes that memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(verb),
          ),
        ],
      ),
    );
    if (agreed != true) return;
    await _guard(() async {
      await (await _bound()).removeMemoryNode(node.id);
      await _open();
    });
  }

  Future<void> _loadProvider(String name) async {
    await _guard(() async {
      final config = await (await _bound()).memoryProviderConfig(name);
      for (final controller in _providerValues.values) {
        controller.dispose();
      }
      _providerValues.clear();
      for (final field in config.fields) {
        _providerValues[field.key] = TextEditingController();
      }
      _provider = config;
    });
  }

  Future<void> _saveProvider() async {
    final config = _provider;
    if (config == null) return;
    final values = <String, String>{};
    for (final field in config.fields) {
      final text = _providerValues[field.key]?.text ?? '';
      if (field.kind == 'secret' && text.isEmpty) continue;
      if (text.isEmpty && !field.isSet) continue;
      values[field.key] = text;
    }
    await _guard(() async {
      await (await _bound()).saveMemoryProvider(config.name, values);
    });
  }

  Future<void> _guard(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on WorkspaceException catch (error) {
      _error = '$error';
    } on FormatException catch (error) {
      _error = error.message;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final layers = _layers;
    return Scaffold(
      appBar: AppBar(title: const Text('Memory graph')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Profile ${widget.route.profile ?? 'gateway'} on ${widget.connection.label}. The share code stores zoom, time and filters only.',
          ),
          if (_error != null) Text(_error!, key: const Key('memory-error')),
          if (layers != null)
            Text(
              'Built-in memory ${layers.memoryBytes} bytes, user ${layers.userBytes} bytes. Active provider ${layers.active.isEmpty ? 'built-in' : layers.active}.',
              key: const Key('memory-layers'),
            ),
          TextField(
            key: const Key('memory-filter'),
            controller: _filter,
            decoration: const InputDecoration(labelText: 'Filter'),
            onChanged: (_) => setState(() {}),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final kind in ['all', 'skill', 'memory'])
                ChoiceChip(
                  label: Text(kind),
                  selected: _layout.kind == kind,
                  onSelected: (_) => _setLayout(
                    MemoryLayout(
                      zoom: _layout.zoom,
                      playback: _layout.playback,
                      kind: kind,
                      pinnedOnly: _layout.pinnedOnly,
                    ),
                  ),
                ),
              FilterChip(
                label: const Text('Pinned'),
                selected: _layout.pinnedOnly,
                onSelected: (value) => _setLayout(
                  MemoryLayout(
                    zoom: _layout.zoom,
                    playback: _layout.playback,
                    kind: _layout.kind,
                    pinnedOnly: value,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            key: const Key('memory-time'),
            value: _layout.playback.toDouble(),
            max: 1000,
            label: 'Timeline',
            onChanged: (value) => _setLayout(
              MemoryLayout(
                zoom: _layout.zoom,
                playback: value.round(),
                kind: _layout.kind,
                pinnedOnly: _layout.pinnedOnly,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                key: const Key('memory-play'),
                onPressed: _playTimeline,
                child: const Text('Play timeline'),
              ),
              for (final zoom in MemoryLayout.zooms)
                ChoiceChip(
                  label: Text('${zoom}x'),
                  selected: _layout.zoom == zoom,
                  onSelected: (_) => _setLayout(
                    MemoryLayout(
                      zoom: zoom,
                      playback: _layout.playback,
                      kind: _layout.kind,
                      pinnedOnly: _layout.pinnedOnly,
                    ),
                  ),
                ),
            ],
          ),
          TextField(
            key: const Key('memory-layout-code'),
            controller: _code,
            decoration: const InputDecoration(labelText: 'Layout code'),
            onSubmitted: (value) {
              try {
                _setLayout(MemoryLayout.decode(value.trim()));
              } on FormatException catch (error) {
                setState(() => _error = error.message);
              }
            },
          ),
          Transform.scale(
            scale: _layout.zoom,
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final node in visible)
                  ListTile(
                    key: Key('memory-node-${node.id}'),
                    title: Text(node.label),
                    subtitle: Text('${node.kind} · ${node.category}'),
                    onTap: _busy ? null : () => _edit(node),
                    trailing: IconButton(
                      key: Key('memory-remove-${node.id}'),
                      tooltip: node.kind == 'skill'
                          ? 'Archive skill'
                          : 'Delete memory',
                      onPressed: _busy ? null : () => _remove(node),
                      icon: Icon(
                        node.kind == 'skill'
                            ? Icons.archive_outlined
                            : Icons.delete_outline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('External memory providers'),
          Wrap(
            spacing: 8,
            children: [
              for (final provider
                  in layers?.providers ?? const <MemoryProviderSummary>[])
                ActionChip(
                  label: Text('${provider.name} (${provider.status})'),
                  onPressed: _busy ? null : () => _loadProvider(provider.name),
                ),
            ],
          ),
          if (_provider != null) ...[
            Text(_provider!.label),
            for (final field in _provider!.fields)
              TextField(
                key: Key('provider-field-${field.key}'),
                controller: _providerValues[field.key],
                obscureText: field.kind == 'secret',
                decoration: InputDecoration(
                  labelText: field.label,
                  helperText: field.kind == 'secret' && field.isSet
                      ? 'A value is stored. Leave blank to keep it.'
                      : field.kind,
                ),
              ),
            FilledButton(
              key: const Key('provider-save'),
              onPressed: _busy ? null : _saveProvider,
              child: const Text('Save provider'),
            ),
          ],
        ],
      ),
    );
  }
}
