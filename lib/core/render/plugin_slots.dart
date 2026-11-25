import 'package:flutter/foundation.dart';

import 'artifact_library.dart';
import 'rich_blocks.dart';

enum PluginSlot {
  pane,
  page,
  composerAction,
  command,
  directive,
  toolMedia,
}

/// A contribution compiled into the client. Chat text and downloaded packages
/// cannot add one of these.
class PluginDescriptor {
  const PluginDescriptor({
    required this.id,
    required this.title,
    required this.slots,
    this.directive,
    this.toolName,
    this.paneLabel,
    this.command,
    this.composerLabel,
  });

  final String id;
  final String title;
  final Set<PluginSlot> slots;
  final String? directive;
  final String? toolName;
  final String? paneLabel;
  final String? command;
  final String? composerLabel;
}

const reviewedPlugins = <PluginDescriptor>[
  PluginDescriptor(
    id: 'notes',
    title: 'Notes',
    slots: {
      PluginSlot.pane,
      PluginSlot.page,
      PluginSlot.composerAction,
      PluginSlot.command,
      PluginSlot.directive,
      PluginSlot.toolMedia,
    },
    directive: 'notes',
    toolName: 'notes.attach',
    paneLabel: 'Notes',
    command: '/notes',
    composerLabel: 'Insert note',
  ),
];

PluginDescriptor? reviewedPlugin(String id) {
  for (final plugin in reviewedPlugins) {
    if (plugin.id == id) return plugin;
  }
  return null;
}

class PluginGrants extends ChangeNotifier {
  final _granted = <String>{};

  bool granted(String id) => _granted.contains(id);

  /// Only a reviewed descriptor can receive a grant. Revocation is immediate.
  bool grant(String id) {
    if (reviewedPlugin(id) == null) return false;
    final added = _granted.add(id);
    if (added) notifyListeners();
    return true;
  }

  void revoke(String id) {
    if (_granted.remove(id)) notifyListeners();
  }

  bool showsDirective(String name) {
    for (final plugin in reviewedPlugins) {
      if (plugin.directive == name &&
          plugin.slots.contains(PluginSlot.directive) &&
          _granted.contains(plugin.id)) {
        return true;
      }
    }
    return false;
  }

  PluginDescriptor? mediaPlayerFor(String toolName) {
    for (final plugin in reviewedPlugins) {
      if (plugin.toolName == toolName &&
          plugin.slots.contains(PluginSlot.toolMedia) &&
          _granted.contains(plugin.id)) {
        return plugin;
      }
    }
    return null;
  }

  List<PluginDescriptor> composerActions() => [
    for (final plugin in reviewedPlugins)
      if (_granted.contains(plugin.id) &&
          plugin.slots.contains(PluginSlot.composerAction) &&
          plugin.composerLabel != null)
        plugin,
  ];

  void reset() {
    _granted.clear();
    notifyListeners();
  }
}

final pluginGrants = PluginGrants();

enum PreviewScriptChoice { undecided, denied, allowed }

class PreviewScriptConsent extends ChangeNotifier {
  final _choices = <String, PreviewScriptChoice>{};

  String _key(String pluginId, String origin) => '$pluginId|$origin';

  PreviewScriptChoice choice(String pluginId, String origin) =>
      _choices[_key(pluginId, origin)] ?? PreviewScriptChoice.undecided;

  void decide(String pluginId, String origin, PreviewScriptChoice choice) {
    _choices[_key(pluginId, origin)] = choice;
    notifyListeners();
  }

  void revoke(String pluginId, String origin) =>
      decide(pluginId, origin, PreviewScriptChoice.denied);

  void reset() {
    _choices.clear();
    notifyListeners();
  }
}

final previewScriptConsent = PreviewScriptConsent();

/// Allowing a site names the plugin and origin. It does not execute page script.
bool pluginMaySeePreview({
  required String pluginId,
  required String origin,
}) {
  if (!pluginGrants.granted(pluginId)) return false;
  return previewScriptConsent.choice(pluginId, origin) ==
      PreviewScriptChoice.allowed;
}

enum CatalogOutcome { offered, installed, skipped, refused }

class CatalogDecision {
  const CatalogDecision(this.outcome, {this.reason});

  final CatalogOutcome outcome;
  final String? reason;
}

class CatalogDecisions extends ChangeNotifier {
  final byId = <String, CatalogDecision>{};

  CatalogDecision stateFor(String id) =>
      byId[id] ?? const CatalogDecision(CatalogOutcome.offered);

  CatalogDecision install(String id) {
    final plugin = reviewedPlugin(id);
    final decision = plugin == null
        ? const CatalogDecision(
            CatalogOutcome.refused,
            reason:
                'This package is not a reviewed client contribution. Ares will not run it inside the app.',
          )
        : (pluginGrants.grant(id)
              ? CatalogDecision(
                  CatalogOutcome.installed,
                  reason: '${plugin.title} can use its granted slots.',
                )
              : const CatalogDecision(
                  CatalogOutcome.refused,
                  reason: 'The contribution could not be granted.',
                ));
    byId[id] = decision;
    notifyListeners();
    return decision;
  }

  CatalogDecision skip(String id) {
    const decision = CatalogDecision(CatalogOutcome.skipped);
    byId[id] = decision;
    notifyListeners();
    return decision;
  }

  CatalogDecision retry(String id) => install(id);

  void reset() {
    byId.clear();
    notifyListeners();
  }
}

final catalogDecisions = CatalogDecisions();

class SetupAnswers extends ChangeNotifier {
  final settled = <String, String>{};

  void settle(String callId, String label) {
    settled[callId] = label;
    notifyListeners();
  }

  void reset() {
    settled.clear();
    notifyListeners();
  }
}

final setupAnswers = SetupAnswers();

void resetSandboxedRenderer() {
  previewSuggestions.reset();
  embedConsent.reset();
  pluginGrants.reset();
  previewScriptConsent.reset();
  catalogDecisions.reset();
  setupAnswers.reset();
  mediaPlayback.reset();
}
