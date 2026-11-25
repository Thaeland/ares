import 'dart:math';

/// Provider, route and billing decisions that do not touch the network.
///
/// A route clamp is reported only when the gateway stamps both the picked
/// effort and a different wire effort. An empty wire means the route has not
/// said what it sends, so the pick is shown unchanged.
class ModelAdminException implements Exception {
  final String message;
  const ModelAdminException(this.message);

  @override
  String toString() => message;
}

const reasoningEffortLevels = <String>{
  'none',
  'minimal',
  'low',
  'medium',
  'high',
  'xhigh',
  'max',
  'ultra',
};

const customEndpointApiModes = <String>{
  '',
  'chat_completions',
  'codex_responses',
  'anthropic_messages',
};

class EffortClamp {
  final String picked;
  final String wire;
  const EffortClamp(this.picked, this.wire);
}

EffortClamp? reasoningEffortClamp(String? effort, String? wire) {
  final picked = (effort ?? '').trim().toLowerCase();
  final sent = (wire ?? '').trim().toLowerCase();
  if (sent.isEmpty || sent == picked) return null;
  if (!reasoningEffortLevels.contains(picked) ||
      !reasoningEffortLevels.contains(sent)) {
    return null;
  }
  return EffortClamp(picked, sent);
}

class ModelPreset {
  final String? effort;
  final bool? fast;
  const ModelPreset({this.effort, this.fast});

  bool get isEmpty => effort == null && fast == null;
}

abstract class ModelPresetStore {
  ModelPreset? read(String provider, String model);
  Future<void> save(String provider, String model, ModelPreset preset);
}

class MemoryModelPresetStore implements ModelPresetStore {
  final Map<String, ModelPreset> values = {};

  static String keyFor(String provider, String model) =>
      '${provider.trim()}::${model.trim()}';

  @override
  ModelPreset? read(String provider, String model) =>
      values[keyFor(provider, model)];

  @override
  Future<void> save(String provider, String model, ModelPreset preset) async {
    final key = keyFor(provider, model);
    if (provider.trim().isEmpty || model.trim().isEmpty) {
      throw const ModelAdminException('Choose a provider and a model.');
    }
    if (preset.effort != null &&
        !reasoningEffortLevels.contains(preset.effort)) {
      throw const ModelAdminException('Choose a known effort level.');
    }
    final previous = values[key] ?? const ModelPreset();
    values[key] = ModelPreset(
      effort: preset.effort ?? previous.effort,
      fast: preset.fast ?? previous.fast,
    );
  }
}

class ProviderKeyGroup {
  final String name;
  final String envKey;
  final String description;
  final bool saved;
  const ProviderKeyGroup({
    required this.name,
    required this.envKey,
    required this.description,
    required this.saved,
  });
}

bool _isKeyVar(String key, Map<String, dynamic> info) =>
    info['is_password'] == true ||
    RegExp(r'(?:_API_KEY|_TOKEN|_KEY)$').hasMatch(key);

List<ProviderKeyGroup> providerKeyGroups(Map<String, dynamic> env) {
  final buckets = <String, List<MapEntry<String, Map<String, dynamic>>>>{};
  for (final entry in env.entries) {
    final info = entry.value;
    if (info is! Map || info['category'] != 'provider') continue;
    final row = Map<String, dynamic>.from(info);
    final name =
        (row['provider_label'] ?? row['provider'])?.toString().trim() ?? '';
    if (name.isEmpty || name == 'Other') continue;
    if (!RegExp(r'^[A-Z][A-Z0-9_]{0,127}$').hasMatch(entry.key)) continue;
    buckets.putIfAbsent(name, () => []).add(MapEntry(entry.key, row));
  }
  final groups = <ProviderKeyGroup>[];
  for (final bucket in buckets.entries) {
    final entries = bucket.value;
    MapEntry<String, Map<String, dynamic>>? primary;
    for (final entry in entries) {
      if (entry.value['provider_primary'] == true &&
          _isKeyVar(entry.key, entry.value)) {
        primary = entry;
        break;
      }
    }
    if (primary == null) {
      for (final entry in entries) {
        if (entry.value['advanced'] != true &&
            _isKeyVar(entry.key, entry.value)) {
          primary = entry;
          break;
        }
      }
    }
    if (primary == null) {
      for (final entry in entries) {
        if (_isKeyVar(entry.key, entry.value)) {
          primary = entry;
          break;
        }
      }
    }
    if (primary == null) continue;
    groups.add(
      ProviderKeyGroup(
        name: bucket.key,
        envKey: primary.key,
        description: primary.value['description']?.toString() ?? '',
        saved: entries.any((entry) => entry.value['is_set'] == true),
      ),
    );
  }
  groups.sort((a, b) => a.name.compareTo(b.name));
  return groups;
}

class NamedEndpoint {
  final String id;
  final String name;
  final String baseUrl;
  final String model;
  final String apiMode;
  final bool current;
  final bool hasKey;
  const NamedEndpoint({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.model,
    required this.apiMode,
    required this.current,
    required this.hasKey,
  });
}

class EndpointDraft {
  final String? id;
  final String name;
  final String baseUrl;
  final String model;
  final String apiMode;
  final String? apiKey;
  final bool discoverModels;
  final bool makeDefault;
  const EndpointDraft({
    required this.name,
    required this.baseUrl,
    required this.model,
    required this.apiMode,
    this.id,
    this.apiKey,
    this.discoverModels = true,
    this.makeDefault = false,
  });
}

void validateEndpointDraft(EndpointDraft draft) {
  final name = draft.name.trim();
  final model = draft.model.trim();
  if (name.isEmpty || name.length > 128 || name.contains(RegExp(r'[\r\n]'))) {
    throw const ModelAdminException('Enter a name for this endpoint.');
  }
  if (model.isEmpty || model.length > 256) {
    throw const ModelAdminException('Enter the model this endpoint serves.');
  }
  if (!customEndpointApiModes.contains(draft.apiMode)) {
    throw const ModelAdminException('Choose Auto or a known API mode.');
  }
  if (draft.id != null &&
      !RegExp(r'^[A-Za-z0-9_.:-]{1,128}$').hasMatch(draft.id!)) {
    throw const ModelAdminException('This endpoint identifier is not usable.');
  }
  final uri = Uri.tryParse(draft.baseUrl.trim());
  final host = uri?.host.toLowerCase() ?? '';
  final loopback = host == 'localhost' || host == '127.0.0.1' || host == '::1';
  if (uri == null ||
      !uri.hasScheme ||
      host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      (uri.scheme != 'https' && !(uri.scheme == 'http' && loopback))) {
    throw const ModelAdminException(
      'Use HTTPS for a remote endpoint, or HTTP on localhost.',
    );
  }
  final key = draft.apiKey?.trim();
  if (key != null &&
      key.isNotEmpty &&
      (key.length > 4096 || key.contains('\n'))) {
    throw const ModelAdminException('That API key cannot be saved.');
  }
}

Map<String, dynamic> endpointRequestBody(EndpointDraft draft) {
  validateEndpointDraft(draft);
  final key = draft.apiKey?.trim();
  return {
    if (draft.id != null) 'id': draft.id,
    'name': draft.name.trim(),
    'base_url': draft.baseUrl.trim(),
    'model': draft.model.trim(),
    'api_mode': draft.apiMode,
    'discover_models': draft.discoverModels,
    'make_default': draft.makeDefault,
    if (key != null && key.isNotEmpty) 'api_key': key,
  };
}

List<NamedEndpoint> namedEndpoints(Map<String, dynamic> body) {
  final rows = body['endpoints'];
  if (rows is! List) {
    throw const ModelAdminException(
      'The gateway response did not match the expected shape.',
    );
  }
  return [
    for (final row in rows)
      if (row is Map &&
          row['id'] is String &&
          row['name'] is String &&
          row['base_url'] is String &&
          row['model'] is String)
        NamedEndpoint(
          id: row['id'] as String,
          name: row['name'] as String,
          baseUrl: row['base_url'] as String,
          model: row['model'] as String,
          apiMode: customEndpointApiModes.contains(row['api_mode'])
              ? row['api_mode'] as String
              : '',
          current: row['is_current'] == true,
          hasKey: row['has_api_key'] == true,
        ),
  ];
}

class EndpointTestResult {
  final bool reachable;
  final String message;
  final String transport;
  final List<String> models;
  const EndpointTestResult({
    required this.reachable,
    required this.message,
    required this.transport,
    required this.models,
  });
}

EndpointTestResult endpointTestResult(Map<String, dynamic> body) {
  final models = body['models'];
  return EndpointTestResult(
    reachable: body['reachable'] == true && body['ok'] != false,
    message: body['message']?.toString().trim().isNotEmpty == true
        ? body['message'].toString()
        : (body['reachable'] == true
              ? 'The endpoint answered.'
              : 'The endpoint did not answer.'),
    transport: customEndpointApiModes.contains(body['transport_checked'])
        ? body['transport_checked'] as String
        : '',
    models: models is List
        ? [
            for (final model in models)
              if (model is String) model,
          ]
        : const [],
  );
}

class ProviderAccountRow {
  final String id;
  final String name;
  final bool loggedIn;
  final bool disconnectable;
  const ProviderAccountRow({
    required this.id,
    required this.name,
    required this.loggedIn,
    required this.disconnectable,
  });
}

List<ProviderAccountRow> providerAccounts(Map<String, dynamic> body) {
  final rows = body['providers'];
  if (rows is! List) {
    throw const ModelAdminException(
      'The gateway response did not match the expected shape.',
    );
  }
  return [
    for (final row in rows)
      if (row is Map &&
          row['id'] is String &&
          RegExp(r'^[a-zA-Z0-9_-]{1,128}$').hasMatch(row['id'] as String) &&
          row['name'] is String)
        ProviderAccountRow(
          id: row['id'] as String,
          name: row['name'] as String,
          loggedIn: row['status'] is Map && row['status']['logged_in'] == true,
          disconnectable: row['disconnectable'] == true,
        ),
  ];
}

class DelegationLimits {
  final int? maxIterations;
  final int? maxConcurrentChildren;
  final int? childTimeoutSeconds;
  final String? reasoningEffort;
  const DelegationLimits({
    this.maxIterations,
    this.maxConcurrentChildren,
    this.childTimeoutSeconds,
    this.reasoningEffort,
  });
}

int? _boundedInt(Object? value, int max) {
  final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed < 1 || parsed > max) return null;
  return parsed;
}

DelegationLimits delegationLimitsFromConfig(Map<String, dynamic> body) {
  final root = body['config'] is Map
      ? Map<String, dynamic>.from(body['config'] as Map)
      : body;
  final delegation = root['delegation'];
  if (delegation is! Map) return const DelegationLimits();
  final effort = delegation['reasoning_effort']
      ?.toString()
      .trim()
      .toLowerCase();
  return DelegationLimits(
    maxIterations: _boundedInt(delegation['max_iterations'], 10000),
    maxConcurrentChildren: _boundedInt(
      delegation['max_concurrent_children'],
      10000,
    ),
    childTimeoutSeconds: _boundedInt(
      delegation['child_timeout_seconds'],
      86400,
    ),
    reasoningEffort: effort != null && reasoningEffortLevels.contains(effort)
        ? effort
        : null,
  );
}

Map<String, dynamic> delegationLimitsPatch(DelegationLimits limits) {
  final iterations = limits.maxIterations;
  final children = limits.maxConcurrentChildren;
  final timeout = limits.childTimeoutSeconds;
  if (iterations == null || children == null || timeout == null) {
    throw const ModelAdminException(
      'Enter iteration, concurrency and timeout limits before saving.',
    );
  }
  if (limits.reasoningEffort != null &&
      !reasoningEffortLevels.contains(limits.reasoningEffort)) {
    throw const ModelAdminException('Choose a known effort level.');
  }
  return {
    'max_iterations': iterations,
    'max_concurrent_children': children,
    'child_timeout_seconds': timeout,
    if (limits.reasoningEffort != null)
      'reasoning_effort': limits.reasoningEffort,
  };
}

Map<String, dynamic> modelRouteBody({
  required List<Map<String, dynamic>> routes,
  required String? defaultRoute,
}) {
  final names = <String>{};
  final options = <Map<String, dynamic>>[];
  for (final route in routes) {
    final copy = Map<String, dynamic>.from(route);
    final name = copy['name']?.toString().trim() ?? '';
    final model = copy['model']?.toString().trim() ?? '';
    if (!RegExp(r'^[A-Za-z0-9_.:-]{1,64}$').hasMatch(name) || model.isEmpty) {
      throw const ModelAdminException(
        'Each route needs a name and a model before it can be saved.',
      );
    }
    if (!names.add(name)) {
      throw const ModelAdminException('Route names must be unique.');
    }
    copy['name'] = name;
    copy['model'] = model;
    final effort = copy['reasoning_effort']?.toString().trim().toLowerCase();
    if (effort == null || effort.isEmpty) {
      copy.remove('reasoning_effort');
    } else if (!reasoningEffortLevels.contains(effort)) {
      throw const ModelAdminException('Choose a known effort level.');
    } else {
      copy['reasoning_effort'] = effort;
    }
    options.add(copy);
  }
  if (defaultRoute != null && !names.contains(defaultRoute)) {
    throw const ModelAdminException(
      'The default route has to be one of the saved routes.',
    );
  }
  return {'options': options, 'default': defaultRoute};
}

Map<String, dynamic> editActiveMixture(
  Map<String, dynamic> source, {
  required bool enabled,
  required String policy,
  required Map<String, dynamic> aggregator,
  required List<Map<String, dynamic>> references,
}) {
  if (policy != 'loud' && policy != 'silent') {
    throw const ModelAdminException(
      'Choose a loud or silent degraded-reference policy.',
    );
  }
  final copy = _jsonMap(source);
  final presets = copy['presets'];
  final active = copy['active_preset']?.toString() ?? '';
  if (presets is! Map || active.isEmpty || presets[active] is! Map) {
    throw const ModelAdminException(
      'The gateway did not return an active mixture.',
    );
  }
  bool complete(Map slot) {
    final provider = slot['provider']?.toString().trim() ?? '';
    final model = slot['model']?.toString().trim() ?? '';
    return provider.isNotEmpty && model.isNotEmpty;
  }

  final preset = Map<String, dynamic>.from(presets[active] as Map);
  final nextAggregator = Map<String, dynamic>.from(aggregator);
  final nextReferences = [
    for (final reference in references) Map<String, dynamic>.from(reference),
  ];
  if (!complete(nextAggregator) ||
      nextReferences.isEmpty ||
      nextReferences.any((slot) => !complete(slot))) {
    throw const ModelAdminException(
      'Name a provider and model for the aggregator and every reference.',
    );
  }
  preset['enabled'] = enabled;
  preset['degraded_reference_policy'] = policy;
  preset['aggregator'] = nextAggregator;
  preset['reference_models'] = nextReferences;
  presets[active] = preset;
  copy['enabled'] = enabled;
  copy['degraded_reference_policy'] = policy;
  copy['aggregator'] = nextAggregator;
  copy['reference_models'] = nextReferences;
  return copy;
}

Map<String, dynamic> _jsonMap(Map<String, dynamic> source) {
  final copy = <String, dynamic>{};
  for (final entry in source.entries) {
    copy[entry.key] = _jsonValue(entry.value);
  }
  return copy;
}

Object? _jsonValue(Object? value) {
  if (value is Map) {
    return {
      for (final entry in value.entries)
        entry.key.toString(): _jsonValue(entry.value),
    };
  }
  if (value is List) return [for (final item in value) _jsonValue(item)];
  return value;
}

bool creditsPurchasable(Map<String, dynamic> state) {
  if (state['ok'] != true ||
      state['logged_in'] != true ||
      state['can_charge'] != true ||
      state['cli_billing_enabled'] != true) {
    return false;
  }
  final hasMethod = state['payment_method'] is Map || state['card'] is Map;
  final presets = state['charge_presets'];
  return hasMethod &&
      presets is List &&
      presets.any((amount) => amount is String && amount.isNotEmpty);
}

bool planChangeCanCommit(String? effect) => effect == 'scheduled';

String safeBillingMessage(Object? message) {
  final text = message?.toString().trim() ?? '';
  if (text.isEmpty || text.contains('http') || text.length > 240) {
    return 'The gateway refused this billing request.';
  }
  return text;
}

String newIdempotencyKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

String checkedSessionId(String value) {
  final id = value.trim();
  if (id.isEmpty || id.length > 256 || id.contains(RegExp(r'\s'))) {
    throw const ModelAdminException(
      'Enter the chat id this change applies to.',
    );
  }
  return id;
}
