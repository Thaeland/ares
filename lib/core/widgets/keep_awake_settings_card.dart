/// Shared "Keep computer awake" settings card for Classic and NextGen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/keep_awake.dart';

class KeepAwakeSettingsCard extends StatefulWidget {
  const KeepAwakeSettingsCard({
    required this.preferences,
    this.powerChannel = MethodChannelKeepAwakeAdapter.channel,
    super.key,
  });

  final SharedPreferences preferences;
  final MethodChannel powerChannel;

  @override
  State<KeepAwakeSettingsCard> createState() => _KeepAwakeSettingsCardState();
}

class _KeepAwakeSettingsCardState extends State<KeepAwakeSettingsCard> {
  bool? _runnerSupported;

  @override
  void initState() {
    super.initState();
    _probeRunner();
  }

  Future<void> _probeRunner() async {
    final supported = await isKeepAwakeChannelSupported(widget.powerChannel);
    if (mounted) {
      setState(() => _runnerSupported = supported);
    }
  }

  static String _modeLabel(KeepAwakeMode mode) => switch (mode) {
    KeepAwakeMode.off => 'Off',
    KeepAwakeMode.whileWorking => 'While working',
    KeepAwakeMode.always => 'Always',
  };

  static String _modeDescription(KeepAwakeMode mode) => switch (mode) {
    KeepAwakeMode.off =>
      'Never block system sleep (default, opt-in power policy).',
    KeepAwakeMode.whileWorking =>
      'Prevent idle sleep only while an agent turn is actively running.',
    KeepAwakeMode.always =>
      'Prevent idle sleep while Ares remains open on this device.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = KeepAwakePolicyStore(widget.preferences);
    return Card(
      key: const Key('keep-awake-settings-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<int>(
          valueListenable: keepAwakePolicyChanges,
          builder: (context, _, _) {
            final selected = store.read();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep computer awake',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _modeDescription(selected),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in KeepAwakeMode.values)
                      ChoiceChip(
                        key: Key('keep-awake-mode-${mode.name}'),
                        label: Text(_modeLabel(mode)),
                        selected: selected == mode,
                        onSelected: (_) => store.write(mode),
                      ),
                  ],
                ),
                if (_runnerSupported == false) ...[
                  const SizedBox(height: 10),
                  Text(
                    'OS sleep inhibition is not active on this platform runner yet; your preference is saved on this device.',
                    key: const Key('keep-awake-capability-note'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
