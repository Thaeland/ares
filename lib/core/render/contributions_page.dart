import 'package:flutter/material.dart';

import 'plugin_slots.dart';

/// Reviewed client contributions for one connection. Granting a slot does
/// not download code or run a page script. An id that is not in
/// [reviewedPlugins] cannot be granted.
class ContributionsPage extends StatelessWidget {
  const ContributionsPage({super.key, required this.scope});

  /// The render connection key the grants apply to.
  final String scope;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributions')),
      body: ListenableBuilder(
        listenable: pluginGrants,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Only contributions compiled into Ares can add to a reply. '
                'Chat text cannot register one, and a grant applies to this '
                'connection only.',
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
                    if (!pluginGrants.granted(scope, plugin.id))
                      FilledButton(
                        onPressed: () => pluginGrants.grant(scope, plugin.id),
                        child: Text('Grant ${plugin.title}'),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => pluginGrants.revoke(scope, plugin.id),
                        child: Text('Revoke ${plugin.title}'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
    );
  }
}

extension PluginDescriptorLabels on PluginDescriptor {
  String get grantedSlotsLabel => 'reply cards for ::$directive';
}
