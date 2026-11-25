import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/connection_manager.dart';
import '../services/model_admin.dart';
import '../services/remote_model_admin.dart';

enum ModelAdminSection {
  keys,
  endpoints,
  accounts,
  presets,
  delegation,
  mixture,
  billing,
}

const _modeLabels = {
  '': 'Auto',
  'chat_completions': 'Chat Completions',
  'codex_responses': 'Codex Responses',
  'anthropic_messages': 'Anthropic Messages',
};

class PreferencesModelPresetStore implements ModelPresetStore {
  PreferencesModelPresetStore(this.prefs);
  final SharedPreferences prefs;
  static const storageKey = 'hermes.model-presets';

  Map<String, dynamic> _all() {
    final raw = prefs.getString(storageKey);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return {};
    }
    return {};
  }

  @override
  ModelPreset? read(String provider, String model) {
    final row = _all()[MemoryModelPresetStore.keyFor(provider, model)];
    if (row is! Map) return null;
    final effort = row['effort']?.toString();
    return ModelPreset(
      effort: reasoningEffortLevels.contains(effort) ? effort : null,
      fast: row['fast'] is bool ? row['fast'] as bool : null,
    );
  }

  @override
  Future<void> save(String provider, String model, ModelPreset preset) async {
    final memory = MemoryModelPresetStore()
      ..values.addAll({
        for (final entry in _all().entries)
          if (entry.value is Map)
            entry.key: ModelPreset(
              effort: reasoningEffortLevels.contains(entry.value['effort'])
                  ? entry.value['effort'] as String
                  : null,
              fast: entry.value['fast'] is bool
                  ? entry.value['fast'] as bool
                  : null,
            ),
      });
    await memory.save(provider, model, preset);
    final stored =
        memory.values[MemoryModelPresetStore.keyFor(provider, model)];
    final next = _all();
    next[MemoryModelPresetStore.keyFor(provider, model)] = {
      if (stored?.effort != null) 'effort': stored!.effort,
      if (stored?.fast != null) 'fast': stored!.fast,
    };
    await prefs.setString(storageKey, jsonEncode(next));
  }
}

class _SlotFields {
  _SlotFields({String provider = '', String model = ''})
    : provider = TextEditingController(text: provider),
      model = TextEditingController(text: model);
  final TextEditingController provider;
  final TextEditingController model;
  void dispose() {
    provider.dispose();
    model.dispose();
  }

  Map<String, dynamic> toSlot({Map<String, dynamic>? base}) => {
    ...?base,
    'provider': provider.text.trim(),
    'model': model.text.trim(),
    'enabled': base?['enabled'] ?? true,
  };
}

/// Provider keys, named endpoints, delegation, mixtures and consented billing.
class ModelAdminScreen extends StatefulWidget {
  final SavedConnection connection;
  final DashboardClient? dashboard;
  final Future<Map<String, dynamic>> Function(
    String method,
    Map<String, dynamic> params,
  )?
  rpc;
  final ModelPresetStore? presets;
  final ModelAdminSection initialSection;

  const ModelAdminScreen({
    required this.connection,
    this.dashboard,
    this.rpc,
    this.presets,
    this.initialSection = ModelAdminSection.keys,
    super.key,
  });

  @override
  State<ModelAdminScreen> createState() => _ModelAdminScreenState();
}

class _ModelAdminScreenState extends State<ModelAdminScreen> {
  late final DashboardClient _client =
      widget.dashboard ?? DashboardClient.fromConnection(widget.connection);
  late final RemoteModelAdmin _admin = RemoteModelAdmin(
    _client,
    rpc: widget.rpc,
  );
  late ModelPresetStore _presets = widget.presets ?? MemoryModelPresetStore();
  late ModelAdminSection _section = widget.initialSection;
  final _keyValue = TextEditingController();
  final _endpointName = TextEditingController();
  final _endpointUrl = TextEditingController();
  final _endpointModel = TextEditingController();
  final _endpointKey = TextEditingController();
  final _iterations = TextEditingController();
  final _children = TextEditingController();
  final _timeout = TextEditingController();
  final _routeName = TextEditingController();
  final _routeProvider = TextEditingController();
  final _routeModel = TextEditingController();
  final _presetProvider = TextEditingController();
  final _presetModel = TextEditingController();
  final _sessionId = TextEditingController();
  final _aggregator = _SlotFields();
  bool _busy = false;
  String? _error;
  String? _notice;
  List<ProviderKeyGroup> _keys = const [];
  String? _selectedKey;
  List<NamedEndpoint> _endpoints = const [];
  String _endpointId = '';
  String _apiMode = '';
  String? _testResult;
  List<ProviderAccountRow> _accounts = const [];
  String? _blocked;
  List<Map<String, dynamic>> _backends = const [];
  String? _backend;
  List<Map<String, dynamic>> _routes = const [];
  String? _defaultRoute;
  List<String> _hostProfiles = const [];
  List<Map<String, dynamic>> _profileRoutes = const [];
  String? _defaultProfile;
  String? _limitEffort;
  String _routeEffort = '';
  Map<String, dynamic>? _mixture;
  bool _mixtureEnabled = false;
  String _policy = 'loud';
  List<_SlotFields> _references = [];
  String _presetEffort = 'medium';
  bool _presetFast = false;
  String? _clamp;
  Map<String, dynamic>? _billing;
  Map<String, dynamic>? _subscription;
  String? _amount;
  String? _previewEffect;
  String? _previewTier;

  @override
  void initState() {
    super.initState();
    if (widget.presets == null) {
      SharedPreferences.getInstance().then((prefs) {
        if (!mounted || widget.presets != null) return;
        setState(() => _presets = PreferencesModelPresetStore(prefs));
      }, onError: (_) {});
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    if (widget.dashboard == null) _client.close();
    for (final controller in [
      _keyValue,
      _endpointName,
      _endpointUrl,
      _endpointModel,
      _endpointKey,
      _iterations,
      _children,
      _timeout,
      _routeName,
      _routeProvider,
      _routeModel,
      _presetProvider,
      _presetModel,
      _sessionId,
    ]) {
      controller.dispose();
    }
    _aggregator.dispose();
    for (final row in _references) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _run(() async {
      switch (_section) {
        case ModelAdminSection.keys:
          final keys = await _admin.keys();
          if (!mounted) return;
          setState(() {
            _keys = keys;
            _selectedKey = keys.any((key) => key.envKey == _selectedKey)
                ? _selectedKey
                : keys.firstOrNull?.envKey;
          });
        case ModelAdminSection.endpoints:
          final endpoints = await _admin.endpoints();
          if (!mounted) return;
          setState(() => _endpoints = endpoints);
        case ModelAdminSection.accounts:
          final accounts = await _admin.accounts();
          if (!mounted) return;
          setState(() => _accounts = accounts);
        case ModelAdminSection.presets:
          break;
        case ModelAdminSection.delegation:
          final routing = await _admin.delegation();
          final limits = await _admin.limits();
          if (!mounted) return;
          _applyRouting(routing, limits);
        case ModelAdminSection.mixture:
          final mixture = await _admin.mixture();
          if (!mounted) return;
          _applyMixture(mixture);
        case ModelAdminSection.billing:
          if (widget.rpc == null) {
            throw const ModelAdminException(
              'Connect the live gateway session before reading billing. Nothing is charged from this page.',
            );
          }
          final state = await _admin.billingState();
          final subscription = await _admin.subscriptionState();
          if (!mounted) return;
          setState(() {
            _billing = state;
            _subscription = subscription;
            _previewEffect = null;
            _previewTier = null;
            final presets = _amounts(state);
            _amount = presets.contains(_amount) ? _amount : presets.firstOrNull;
          });
      }
    });
  }

  void _applyRouting(Map<String, dynamic> routing, DelegationLimits limits) {
    final backends = [
      for (final row
          in routing['backends'] is List
              ? routing['backends'] as List
              : const [])
        if (row is Map) Map<String, dynamic>.from(row),
    ];
    final modelMap = routing['model_map'] is Map
        ? Map<String, dynamic>.from(routing['model_map'] as Map)
        : const <String, dynamic>{};
    final routes = [
      for (final row
          in modelMap['options'] is List
              ? modelMap['options'] as List
              : const [])
        if (row is Map) Map<String, dynamic>.from(row),
    ];
    final profileRoutes = routing['profile_routes'] is Map
        ? Map<String, dynamic>.from(routing['profile_routes'] as Map)
        : const <String, dynamic>{};
    final selectedProfiles = [
      for (final row
          in profileRoutes['profiles'] is List
              ? profileRoutes['profiles'] as List
              : const [])
        if (row is Map) Map<String, dynamic>.from(row),
    ];
    setState(() {
      _backends = backends;
      _blocked = routing['blocked_reason']?.toString();
      _backend = routing['configured']?.toString();
      _routes = routes;
      _defaultRoute = modelMap['default']?.toString();
      _hostProfiles = [
        for (final name
            in routing['profiles'] is List
                ? routing['profiles'] as List
                : const [])
          if (name is String) name,
      ];
      _profileRoutes = selectedProfiles;
      _defaultProfile = profileRoutes['default']?.toString();
      _iterations.text = limits.maxIterations?.toString() ?? '';
      _children.text = limits.maxConcurrentChildren?.toString() ?? '';
      _timeout.text = limits.childTimeoutSeconds?.toString() ?? '';
      _limitEffort = limits.reasoningEffort;
    });
  }

  void _applyMixture(Map<String, dynamic> mixture) {
    final presets = mixture['presets'];
    final active = mixture['active_preset']?.toString();
    final preset = presets is Map && active != null && presets[active] is Map
        ? Map<String, dynamic>.from(presets[active] as Map)
        : mixture;
    final aggregator = preset['aggregator'] is Map
        ? Map<String, dynamic>.from(preset['aggregator'] as Map)
        : const <String, dynamic>{};
    for (final row in _references) {
      row.dispose();
    }
    setState(() {
      _mixture = mixture;
      _mixtureEnabled = preset['enabled'] == true;
      _policy = preset['degraded_reference_policy'] == 'silent'
          ? 'silent'
          : 'loud';
      _aggregator.provider.text = aggregator['provider']?.toString() ?? '';
      _aggregator.model.text = aggregator['model']?.toString() ?? '';
      _references = [
        for (final row
            in preset['reference_models'] is List
                ? preset['reference_models'] as List
                : const [])
          if (row is Map)
            _SlotFields(
              provider: row['provider']?.toString() ?? '',
              model: row['model']?.toString() ?? '',
            ),
      ];
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      await action();
    } on ModelAdminException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not complete that request.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('admin-confirm'),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('admin-confirm-yes'),
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return agreed == true && mounted;
  }

  EndpointDraft _draft({bool makeDefault = false}) => EndpointDraft(
    id: _endpointId.isEmpty ? null : _endpointId,
    name: _endpointName.text,
    baseUrl: _endpointUrl.text,
    model: _endpointModel.text,
    apiMode: _apiMode,
    apiKey: _endpointKey.text,
    makeDefault: makeDefault,
  );

  List<String> _amounts(Map<String, dynamic>? state) => [
    for (final amount
        in state?['charge_presets'] is List
            ? state!['charge_presets'] as List
            : const [])
      if (amount is String && amount.isNotEmpty) amount,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers and billing'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<ModelAdminSection>(
            key: const Key('model-admin-section'),
            isExpanded: true,
            value: _section,
            items: const [
              DropdownMenuItem(
                value: ModelAdminSection.keys,
                child: Text('API keys'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.endpoints,
                child: Text('Custom endpoints'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.accounts,
                child: Text('Provider accounts'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.presets,
                child: Text('Effort and speed presets'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.delegation,
                child: Text('Delegation'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.mixture,
                child: Text('Mixture of agents'),
              ),
              DropdownMenuItem(
                value: ModelAdminSection.billing,
                child: Text('Credits and plans'),
              ),
            ],
            onChanged: _busy
                ? null
                : (section) {
                    if (section == null) return;
                    setState(() => _section = section);
                    _load();
                  },
          ),
          if (_error != null) Text(_error!, key: const Key('admin-error')),
          if (_notice != null) Text(_notice!, key: const Key('admin-notice')),
          const SizedBox(height: 12),
          ...switch (_section) {
            ModelAdminSection.keys => _keySection(),
            ModelAdminSection.endpoints => _endpointSection(),
            ModelAdminSection.accounts => _accountSection(),
            ModelAdminSection.presets => _presetSection(),
            ModelAdminSection.delegation => _delegationSection(),
            ModelAdminSection.mixture => _mixtureSection(),
            ModelAdminSection.billing => _billingSection(),
          },
        ],
      ),
    );
  }

  List<Widget> _keySection() => [
    if (_keys.isEmpty)
      const Text('No provider keys were reported for this profile.'),
    if (_keys.isNotEmpty)
      DropdownButton<String>(
        key: const Key('provider-key'),
        isExpanded: true,
        value: _selectedKey,
        items: [
          for (final key in _keys)
            DropdownMenuItem(
              value: key.envKey,
              child: Text(
                '${key.name} · ${key.envKey} · ${key.saved ? 'Saved' : 'Not saved'}',
              ),
            ),
        ],
        onChanged: (value) => setState(() => _selectedKey = value),
      ),
    TextField(
      key: const Key('provider-key-value'),
      controller: _keyValue,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: const InputDecoration(labelText: 'New key value'),
    ),
    FilledButton(
      key: const Key('provider-key-save'),
      onPressed: _busy || _selectedKey == null
          ? null
          : () => _run(() async {
              await _admin.saveKey(_selectedKey!, _keyValue.text);
              _keyValue.clear();
              if (mounted) setState(() => _notice = 'Provider key saved.');
              final keys = await _admin.keys();
              if (mounted) setState(() => _keys = keys);
            }),
      child: const Text('Save key'),
    ),
    TextButton(
      key: const Key('provider-key-clear'),
      onPressed: _busy || _selectedKey == null
          ? null
          : () => _run(() async {
              final key = _selectedKey!;
              final agreed = await _confirm(
                'Clear provider key',
                'Remove the saved $key value from this profile?',
              );
              if (!agreed) return;
              await _admin.clearKey(key);
              if (mounted) setState(() => _notice = 'Provider key cleared.');
              final keys = await _admin.keys();
              if (mounted) setState(() => _keys = keys);
            }),
      child: const Text('Clear key'),
    ),
  ];

  List<Widget> _endpointSection() => [
    DropdownButton<String>(
      key: const Key('endpoint-existing'),
      isExpanded: true,
      value: _endpointId,
      items: [
        const DropdownMenuItem(value: '', child: Text('New endpoint')),
        for (final endpoint in _endpoints)
          DropdownMenuItem(
            value: endpoint.id,
            child: Text(
              '${endpoint.name}${endpoint.current ? ' · current' : ''}',
            ),
          ),
      ],
      onChanged: (value) {
        final endpoint = _endpoints.where((row) => row.id == value).firstOrNull;
        setState(() {
          _endpointId = value ?? '';
          _testResult = null;
          if (endpoint != null) {
            _endpointName.text = endpoint.name;
            _endpointUrl.text = endpoint.baseUrl;
            _endpointModel.text = endpoint.model;
            _apiMode = endpoint.apiMode;
            _endpointKey.clear();
          }
        });
      },
    ),
    TextField(
      key: const Key('endpoint-name'),
      controller: _endpointName,
      decoration: const InputDecoration(labelText: 'Name'),
    ),
    TextField(
      key: const Key('endpoint-url'),
      controller: _endpointUrl,
      decoration: const InputDecoration(labelText: 'Base URL'),
    ),
    TextField(
      key: const Key('endpoint-model'),
      controller: _endpointModel,
      decoration: const InputDecoration(labelText: 'Model'),
    ),
    DropdownButton<String>(
      key: const Key('endpoint-mode'),
      isExpanded: true,
      value: _apiMode,
      items: [
        for (final mode in customEndpointApiModes)
          DropdownMenuItem(value: mode, child: Text(_modeLabels[mode]!)),
      ],
      onChanged: (value) => setState(() => _apiMode = value ?? ''),
    ),
    TextField(
      controller: _endpointKey,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'API key',
        helperText: 'Leave blank to keep a key this endpoint already has.',
      ),
    ),
    FilledButton(
      key: const Key('endpoint-test'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              final result = await _admin.testEndpoint(_draft());
              if (!mounted) return;
              final transport = result.transport.isEmpty
                  ? 'auto'
                  : result.transport;
              setState(() {
                _testResult =
                    '${result.reachable ? 'Reachable' : 'Unreachable'} · $transport · ${result.models.length} models. ${result.message}';
              });
            }),
      child: const Text('Test endpoint'),
    ),
    if (_testResult != null)
      Text(_testResult!, key: const Key('endpoint-test-result')),
    FilledButton(
      key: const Key('endpoint-save'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              await _admin.saveEndpoint(_draft());
              _endpointKey.clear();
              if (mounted) setState(() => _notice = 'Endpoint saved.');
              final endpoints = await _admin.endpoints();
              if (mounted) setState(() => _endpoints = endpoints);
            }),
      child: const Text('Save endpoint'),
    ),
    TextButton(
      key: const Key('endpoint-activate'),
      onPressed: _busy || _endpointId.isEmpty
          ? null
          : () => _run(() async {
              final agreed = await _confirm(
                'Use this endpoint',
                'Make this named endpoint the current model for this profile?',
              );
              if (!agreed) return;
              await _admin.activateEndpoint(_endpointId);
              if (mounted) setState(() => _notice = 'Endpoint is now current.');
            }),
      child: const Text('Use endpoint'),
    ),
    TextButton(
      key: const Key('endpoint-delete'),
      onPressed: _busy || _endpointId.isEmpty
          ? null
          : () => _run(() async {
              final agreed = await _confirm(
                'Delete endpoint',
                'Delete this named endpoint from the profile?',
              );
              if (!agreed) return;
              await _admin.deleteEndpoint(_endpointId);
              if (mounted) {
                setState(() {
                  _endpointId = '';
                  _notice = 'Endpoint deleted.';
                });
              }
              final endpoints = await _admin.endpoints();
              if (mounted) setState(() => _endpoints = endpoints);
            }),
      child: const Text('Delete endpoint'),
    ),
  ];

  List<Widget> _accountSection() => [
    const Text(
      'Signing in stays on the provider sign-in screen. Disconnect only runs when this gateway says the account can be removed.',
    ),
    for (final account in _accounts)
      ListTile(
        title: Text(account.name),
        subtitle: Text(account.loggedIn ? 'Signed in' : 'Not signed in'),
        trailing: account.disconnectable && account.loggedIn
            ? TextButton(
                key: Key('disconnect-${account.id}'),
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final agreed = await _confirm(
                          'Disconnect ${account.name}',
                          'Disconnect this provider account on the gateway?',
                        );
                        if (!agreed) return;
                        await _admin.disconnectAccount(account.id);
                        final accounts = await _admin.accounts();
                        if (mounted) {
                          setState(() {
                            _accounts = accounts;
                            _notice = 'Provider account disconnected.';
                          });
                        }
                      }),
                child: const Text('Disconnect'),
              )
            : const Text('Not disconnectable'),
      ),
  ];

  List<Widget> _presetSection() => [
    TextField(
      controller: _presetProvider,
      decoration: const InputDecoration(labelText: 'Provider'),
    ),
    TextField(
      key: const Key('preset-model'),
      controller: _presetModel,
      decoration: const InputDecoration(labelText: 'Model'),
    ),
    DropdownButton<String>(
      key: const Key('preset-effort'),
      isExpanded: true,
      value: _presetEffort,
      items: [
        for (final effort in reasoningEffortLevels)
          DropdownMenuItem(value: effort, child: Text(effort)),
      ],
      onChanged: (value) => setState(() => _presetEffort = value ?? 'medium'),
    ),
    SwitchListTile(
      key: const Key('preset-fast'),
      title: const Text('Fast'),
      value: _presetFast,
      onChanged: (value) => setState(() => _presetFast = value),
    ),
    FilledButton(
      key: const Key('preset-save'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              await _presets.save(
                _presetProvider.text,
                _presetModel.text,
                ModelPreset(effort: _presetEffort, fast: _presetFast),
              );
              if (mounted) {
                setState(() => _notice = 'Preset saved for this model.');
              }
            }),
      child: const Text('Save preset'),
    ),
    TextField(
      key: const Key('preset-session'),
      controller: _sessionId,
      decoration: const InputDecoration(labelText: 'Chat id'),
    ),
    FilledButton(
      key: const Key('preset-apply'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              final preset = _presets.read(
                _presetProvider.text,
                _presetModel.text,
              );
              if (preset == null || preset.isEmpty) {
                throw const ModelAdminException(
                  'Save a preset before applying it.',
                );
              }
              final agreed = await _confirm(
                'Apply preset',
                'Set this chat\'s effort and speed from the saved preset?',
              );
              if (!agreed) return;
              await _admin.applyPreset(
                sessionId: _sessionId.text,
                preset: preset,
              );
              if (mounted) {
                setState(() => _notice = 'Preset applied to this chat.');
              }
            }),
      child: const Text('Apply to this chat'),
    ),
    TextButton(
      key: const Key('route-clamp'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              final clamp = await _admin.routeClamp(_sessionId.text);
              if (!mounted) return;
              setState(() {
                _clamp = clamp == null
                    ? 'This route sends the picked effort unchanged.'
                    : '${clamp.picked}→${clamp.wire}';
              });
            }),
      child: const Text('Show route clamp'),
    ),
    if (_clamp != null) Text(_clamp!, key: const Key('route-clamp-label')),
  ];

  List<Widget> _delegationSection() => [
    if (_blocked != null && _blocked!.isNotEmpty)
      Text(
        'Delegation is blocked: $_blocked',
        key: const Key('delegation-blocked'),
      ),
    DropdownButton<String>(
      key: const Key('delegation-backend'),
      isExpanded: true,
      value: _backends.any((row) => row['name'] == _backend) ? _backend : null,
      hint: const Text('Delegation backend'),
      items: [
        for (final backend in _backends)
          DropdownMenuItem(
            value: backend['name']?.toString(),
            enabled: backend['available'] == true,
            child: Text(
              '${backend['label'] ?? backend['name']}${backend['available'] == true ? '' : ' · unavailable'}',
            ),
          ),
      ],
      onChanged: (value) => setState(() => _backend = value),
    ),
    FilledButton(
      key: const Key('delegation-backend-save'),
      onPressed: _busy || _backend == null
          ? null
          : () => _run(() async {
              await _admin.selectDelegationBackend(_backend!, [
                for (final backend in _backends)
                  if (backend['available'] == true && backend['name'] is String)
                    backend['name'] as String,
              ]);
              if (mounted) {
                setState(() => _notice = 'Delegation backend saved.');
              }
            }),
      child: const Text('Save backend'),
    ),
    TextField(
      controller: _iterations,
      decoration: const InputDecoration(labelText: 'Max iterations'),
      keyboardType: TextInputType.number,
    ),
    TextField(
      controller: _children,
      decoration: const InputDecoration(labelText: 'Max concurrent children'),
      keyboardType: TextInputType.number,
    ),
    TextField(
      controller: _timeout,
      decoration: const InputDecoration(labelText: 'Child timeout seconds'),
      keyboardType: TextInputType.number,
    ),
    DropdownButton<String>(
      key: const Key('delegation-effort'),
      isExpanded: true,
      value: _limitEffort,
      hint: const Text('Delegation effort, leave unchanged'),
      items: [
        for (final effort in reasoningEffortLevels)
          DropdownMenuItem(value: effort, child: Text(effort)),
      ],
      onChanged: (value) => setState(() => _limitEffort = value),
    ),
    FilledButton(
      key: const Key('delegation-limits-save'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              await _admin.saveLimits(
                DelegationLimits(
                  maxIterations: int.tryParse(_iterations.text.trim()),
                  maxConcurrentChildren: int.tryParse(_children.text.trim()),
                  childTimeoutSeconds: int.tryParse(_timeout.text.trim()),
                  reasoningEffort: _limitEffort,
                ),
              );
              if (mounted) setState(() => _notice = 'Delegation limits saved.');
            }),
      child: const Text('Save limits'),
    ),
    for (final route in _routes)
      ListTile(
        title: Text(
          '${route['name']} · ${route['provider'] ?? ''} · ${route['model']}',
        ),
        trailing: IconButton(
          tooltip: 'Remove route',
          onPressed: () => setState(() {
            _routes = [
              for (final item in _routes)
                if (item['name'] != route['name']) item,
            ];
            if (_defaultRoute == route['name']) _defaultRoute = null;
          }),
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    TextField(
      controller: _routeName,
      decoration: const InputDecoration(labelText: 'Route name'),
    ),
    TextField(
      controller: _routeProvider,
      decoration: const InputDecoration(labelText: 'Route provider'),
    ),
    TextField(
      controller: _routeModel,
      decoration: const InputDecoration(labelText: 'Route model'),
    ),
    DropdownButton<String>(
      isExpanded: true,
      value: _routeEffort,
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('Route effort unchanged'),
        ),
        for (final effort in reasoningEffortLevels)
          DropdownMenuItem(value: effort, child: Text(effort)),
      ],
      onChanged: (value) => setState(() => _routeEffort = value ?? ''),
    ),
    TextButton(
      key: const Key('delegation-route-add'),
      onPressed: () => setState(() {
        _routes = [
          ..._routes,
          {
            'name': _routeName.text.trim(),
            'provider': _routeProvider.text.trim(),
            'model': _routeModel.text.trim(),
            'description': '',
            if (_routeEffort.isNotEmpty) 'reasoning_effort': _routeEffort,
          },
        ];
      }),
      child: const Text('Add route'),
    ),
    DropdownButton<String>(
      key: const Key('delegation-default'),
      isExpanded: true,
      value: _routes.any((route) => route['name'] == _defaultRoute)
          ? _defaultRoute
          : null,
      hint: const Text('Default route'),
      items: [
        for (final route in _routes)
          if (route['name'] is String)
            DropdownMenuItem(
              value: route['name'] as String,
              child: Text(route['name'] as String),
            ),
      ],
      onChanged: (value) => setState(() => _defaultRoute = value),
    ),
    FilledButton(
      key: const Key('delegation-routes-save'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              await _admin.saveModelRoutes(
                routes: _routes,
                defaultRoute: _defaultRoute,
              );
              if (mounted) setState(() => _notice = 'Delegation routes saved.');
            }),
      child: const Text('Save routes'),
    ),
    for (final name in _hostProfiles)
      CheckboxListTile(
        key: Key('profile-route-$name'),
        title: Text(name),
        value: _profileRoutes.any((route) => route['name'] == name),
        onChanged: (checked) => setState(() {
          _profileRoutes = [
            for (final route in _profileRoutes)
              if (route['name'] != name) route,
            if (checked == true)
              _profileRoutes
                      .where((route) => route['name'] == name)
                      .firstOrNull ??
                  {'name': name, 'description': ''},
          ];
        }),
      ),
    FilledButton(
      key: const Key('profile-routes-save'),
      onPressed: _busy
          ? null
          : () => _run(() async {
              await _admin.saveProfileRoutes(
                profiles: _profileRoutes,
                defaultProfile:
                    _profileRoutes.any(
                      (route) => route['name'] == _defaultProfile,
                    )
                    ? _defaultProfile
                    : null,
              );
              if (mounted) setState(() => _notice = 'Profile routes saved.');
            }),
      child: const Text('Save profile routes'),
    ),
  ];

  List<Widget> _mixtureSection() => [
    if (_mixture == null) const Text('No mixture is loaded.'),
    SwitchListTile(
      key: const Key('moa-enabled'),
      title: const Text('Mixture enabled'),
      value: _mixtureEnabled,
      onChanged: (value) => setState(() => _mixtureEnabled = value),
    ),
    DropdownButton<String>(
      key: const Key('moa-policy'),
      isExpanded: true,
      value: _policy,
      items: const [
        DropdownMenuItem(
          value: 'loud',
          child: Text('Loud degraded references'),
        ),
        DropdownMenuItem(
          value: 'silent',
          child: Text('Silent degraded references'),
        ),
      ],
      onChanged: (value) => setState(() => _policy = value ?? 'loud'),
    ),
    Text('Aggregator', style: Theme.of(context).textTheme.titleSmall),
    TextField(
      controller: _aggregator.provider,
      decoration: const InputDecoration(labelText: 'Aggregator provider'),
    ),
    TextField(
      key: const Key('moa-aggregator-model'),
      controller: _aggregator.model,
      decoration: const InputDecoration(labelText: 'Aggregator model'),
    ),
    for (var index = 0; index < _references.length; index++) ...[
      Text('Reference ${index + 1}'),
      TextField(
        controller: _references[index].provider,
        decoration: const InputDecoration(labelText: 'Reference provider'),
      ),
      TextField(
        controller: _references[index].model,
        decoration: const InputDecoration(labelText: 'Reference model'),
      ),
    ],
    TextButton(
      onPressed: () =>
          setState(() => _references = [..._references, _SlotFields()]),
      child: const Text('Add reference model'),
    ),
    FilledButton(
      key: const Key('moa-save'),
      onPressed: _busy || _mixture == null
          ? null
          : () => _run(() async {
              final source = Map<String, dynamic>.from(_mixture!);
              final preset =
                  source['presets'] is Map && source['active_preset'] is String
                  ? (source['presets'] as Map)[source['active_preset']]
                  : null;
              final baseReferences =
                  preset is Map && preset['reference_models'] is List
                  ? preset['reference_models'] as List
                  : const [];
              final edited = editActiveMixture(
                source,
                enabled: _mixtureEnabled,
                policy: _policy,
                aggregator: _aggregator.toSlot(
                  base: preset is Map && preset['aggregator'] is Map
                      ? Map<String, dynamic>.from(preset['aggregator'] as Map)
                      : null,
                ),
                references: [
                  for (var index = 0; index < _references.length; index++)
                    _references[index].toSlot(
                      base:
                          index < baseReferences.length &&
                              baseReferences[index] is Map
                          ? Map<String, dynamic>.from(
                              baseReferences[index] as Map,
                            )
                          : null,
                    ),
                ],
              );
              await _admin.saveMixture(edited);
              if (mounted) setState(() => _notice = 'Mixture saved.');
            }),
      child: const Text('Save mixture'),
    ),
  ];

  List<Widget> _billingSection() {
    final billing = _billing;
    final subscription = _subscription;
    final tiers = [
      for (final tier
          in subscription?['tiers'] is List
              ? subscription!['tiers'] as List
              : const [])
        if (tier is Map) Map<String, dynamic>.from(tier),
    ];
    final reload = billing?['auto_reload'];
    final keepGoing = billing?['keep_going_on_credits'];
    return [
      const Text(
        'Credit and plan changes wait for confirmation. A plan that would charge immediately is shown and not confirmed here.',
      ),
      if (billing != null) Text('Balance ${billing['balance_display'] ?? '—'}'),
      if (billing != null && creditsPurchasable(billing)) ...[
        DropdownButton<String>(
          key: const Key('billing-amount'),
          isExpanded: true,
          value: _amount,
          items: [
            for (final amount in _amounts(billing))
              DropdownMenuItem(value: amount, child: Text('\$$amount')),
          ],
          onChanged: (value) => setState(() => _amount = value),
        ),
        FilledButton(
          key: const Key('billing-buy'),
          onPressed: _busy || _amount == null
              ? null
              : () => _run(() async {
                  final amount = _amount!;
                  final agreed = await _confirm(
                    'Buy credits',
                    'Charge \$$amount to the payment method on this Nous account. This spends real money.',
                  );
                  if (!agreed) return;
                  final result = await _admin.buyCredits(amount);
                  if (!mounted) return;
                  setState(() {
                    _notice = result['ok'] == true
                        ? 'Credit purchase submitted.'
                        : safeBillingMessage(
                            result['message'] ?? result['error'],
                          );
                  });
                }),
          child: const Text('Buy credits'),
        ),
      ] else if (billing != null)
        const Text(
          'Credit purchases are not available for this account.',
          key: Key('billing-unavailable'),
        ),
      if (reload is Map &&
          reload['threshold_usd'] is String &&
          reload['reload_to_usd'] is String)
        SwitchListTile(
          key: const Key('billing-auto-reload'),
          title: const Text('Auto-reload'),
          value: reload['enabled'] == true,
          onChanged: _busy
              ? null
              : (enabled) => _run(() async {
                  final agreed = await _confirm(
                    'Auto-reload',
                    enabled
                        ? 'Turn on auto-reload using the amounts already on this account?'
                        : 'Turn off auto-reload for this account?',
                  );
                  if (!agreed) return;
                  final result = await _admin.setAutoReload(
                    enabled: enabled,
                    thresholdUsd: reload['threshold_usd'] as String,
                    reloadToUsd: reload['reload_to_usd'] as String,
                  );
                  if (!mounted) return;
                  setState(() {
                    _notice = result['ok'] == true
                        ? 'Auto-reload updated.'
                        : safeBillingMessage(
                            result['message'] ?? result['error'],
                          );
                  });
                }),
        ),
      if (keepGoing is bool)
        SwitchListTile(
          key: const Key('billing-keep-going'),
          title: const Text('Keep going on credits'),
          value: keepGoing,
          onChanged: _busy
              ? null
              : (enabled) => _run(() async {
                  final agreed = await _confirm(
                    'Keep going on credits',
                    enabled
                        ? 'Continue on credits when the plan window is used up?'
                        : 'Stop continuing on credits when the plan window is used up?',
                  );
                  if (!agreed) return;
                  final result = await _admin.setKeepGoing(enabled);
                  if (!mounted) return;
                  setState(() {
                    _notice = result['ok'] == true
                        ? 'Credit continuation updated.'
                        : safeBillingMessage(
                            result['message'] ?? result['error'],
                          );
                  });
                }),
        ),
      if (subscription?['can_change_plan'] == true)
        for (final tier in tiers)
          if (tier['is_enabled'] == true &&
              tier['is_current'] != true &&
              tier['tier_id'] is String)
            ListTile(
              title: Text(
                tier['name']?.toString() ?? tier['tier_id'] as String,
              ),
              trailing: TextButton(
                key: Key('plan-${tier['tier_id']}'),
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final id = tier['tier_id'] as String;
                        final preview = await _admin.previewPlan(id);
                        if (!mounted) return;
                        setState(() {
                          _previewTier = id;
                          _previewEffect = preview['effect']?.toString();
                          _notice = preview['ok'] == true
                              ? (planChangeCanCommit(_previewEffect)
                                    ? 'This change is scheduled. Confirm to apply it.'
                                    : 'This plan change is not confirmed from Ares.')
                              : safeBillingMessage(
                                  preview['message'] ?? preview['error'],
                                );
                        });
                      }),
                child: const Text('Preview plan'),
              ),
            ),
      if (planChangeCanCommit(_previewEffect) && _previewTier != null)
        FilledButton(
          key: const Key('plan-confirm'),
          onPressed: _busy
              ? null
              : () => _run(() async {
                  final agreed = await _confirm(
                    'Schedule plan change',
                    'Schedule this plan change for the end of the current period?',
                  );
                  if (!agreed) return;
                  final result = await _admin.schedulePlan(
                    _previewTier!,
                    _previewEffect,
                  );
                  if (!mounted) return;
                  setState(() {
                    _previewEffect = null;
                    _notice = result['ok'] == true
                        ? 'Plan change scheduled.'
                        : safeBillingMessage(
                            result['message'] ?? result['error'],
                          );
                  });
                }),
          child: const Text('Confirm scheduled plan change'),
        ),
    ];
  }
}
