import 'package:flutter/material.dart';

import 'plugin_slots.dart';

/// Reviewed client contributions. Granting a slot does not download code or
/// run a page script. An id that is not in [reviewedPlugins] cannot be granted.
class ContributionsPage extends StatefulWidget {
  const ContributionsPage({super.key});

  @override
  State<ContributionsPage> createState() => _ContributionsPageState();
}

class _ContributionsPageState extends State<ContributionsPage> {
  static const _origin = 'https://example.test';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          pluginGrants,
          previewScriptConsent,
          catalogDecisions,
        ]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Only contributions compiled into Ares can add a pane, a composer action, a command, a transcript directive or a tool player. Chat text cannot register one.',
              ),
              const SizedBox(height: 12),
              for (final plugin in reviewedPlugins) ...[
                Text(
                  plugin.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  plugin.grantedSlotsLabel,
                  key: Key('plugin-slots-${plugin.id}'),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    if (!pluginGrants.granted(plugin.id))
                      FilledButton(
                        onPressed: () => pluginGrants.grant(plugin.id),
                        child: Text('Grant ${plugin.title}'),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => pluginGrants.revoke(plugin.id),
                        child: Text('Revoke ${plugin.title}'),
                      ),
                  ],
                ),
                if (pluginGrants.granted(plugin.id) &&
                    plugin.slots.contains(PluginSlot.pane)) ...[
                  const SizedBox(height: 8),
                  Text('${plugin.paneLabel} pane'),
                  TextField(
                    key: Key('plugin-pane-${plugin.id}'),
                    controller: _note,
                    decoration: const InputDecoration(
                      labelText: 'Note kept in this pane',
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text('Preview for ${plugin.title}'),
                Text(_origin),
                const Text(
                  'Allowing a site does not run page script. The reader stays text-only.',
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => previewScriptConsent.decide(
                        plugin.id,
                        _origin,
                        PreviewScriptChoice.allowed,
                      ),
                      child: const Text('Allow this site'),
                    ),
                    OutlinedButton(
                      onPressed: () => previewScriptConsent.revoke(
                        plugin.id,
                        _origin,
                      ),
                      child: const Text('Deny this site'),
                    ),
                  ],
                ),
                Text(
                  pluginMaySeePreview(pluginId: plugin.id, origin: _origin)
                      ? '${plugin.title} may read $_origin'
                      : '${plugin.title} cannot read $_origin',
                  key: Key('preview-grant-${plugin.id}'),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Unreviewed package'),
              FilledButton(
                onPressed: () => catalogDecisions.install('remote.example'),
                child: const Text('Install remote.example'),
              ),
              Text(
                catalogDecisions.stateFor('remote.example').reason ??
                    'Not installed.',
                key: const Key('unreviewed-install'),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension PluginDescriptorLabels on PluginDescriptor {
  String get grantedSlotsLabel {
    final names = [
      if (slots.contains(PluginSlot.pane)) 'pane',
      if (slots.contains(PluginSlot.page)) 'page',
      if (slots.contains(PluginSlot.composerAction)) 'composer',
      if (slots.contains(PluginSlot.command)) command ?? 'command',
      if (slots.contains(PluginSlot.directive)) 'directive',
      if (slots.contains(PluginSlot.toolMedia)) 'tool player',
    ];
    return names.join(', ');
  }
}
