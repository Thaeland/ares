import 'package:flutter/material.dart';

import 'capability_admin.dart';

/// Pushes [page] and runs [release] when the route is gone.
///
/// A Classic capability page opened without a shared gateway owns a REST
/// dashboard client. That client is [release]d here, including when the push
/// fails, and a shared gateway client is left open by passing null.
Future<void> pushAndRelease(
  BuildContext context,
  Widget page,
  void Function()? release,
) {
  return Navigator.of(
    context,
  ).push<void>(MaterialPageRoute<void>(builder: (_) => page)).whenComplete(() {
    release?.call();
  });
}

class CapabilityAdminScreen extends StatefulWidget {
  const CapabilityAdminScreen({required this.admin, super.key});

  final CapabilityAdmin admin;

  @override
  State<CapabilityAdminScreen> createState() => _CapabilityAdminScreenState();
}

class _CapabilityAdminScreenState extends State<CapabilityAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capabilities'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Skills'),
              Tab(text: 'Plugins'),
              Tab(text: 'Connectors'),
              Tab(text: 'Backends'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SkillsTab(admin: widget.admin),
            _PluginsTab(admin: widget.admin),
            _ConnectorsTab(admin: widget.admin),
            _BackendsTab(admin: widget.admin),
          ],
        ),
      ),
    );
  }
}

class BrowserVaultScreen extends StatefulWidget {
  const BrowserVaultScreen({required this.admin, super.key});

  final CapabilityAdmin admin;

  @override
  State<BrowserVaultScreen> createState() => _BrowserVaultScreenState();
}

class AgentPolicyScreen extends StatefulWidget {
  const AgentPolicyScreen({required this.admin, super.key});

  final CapabilityAdmin admin;

  @override
  State<AgentPolicyScreen> createState() => _AgentPolicyScreenState();
}

class _SkillsTab extends StatefulWidget {
  const _SkillsTab({required this.admin});

  final CapabilityAdmin admin;

  @override
  State<_SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<_SkillsTab> {
  final _identifier = TextEditingController();
  List<SkillRecord> _skills = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _identifier.addListener(_onIdentifier);
    _load();
  }

  void _onIdentifier() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _identifier.removeListener(_onIdentifier);
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final skills = await widget.admin.skills();
      if (!mounted) return;
      setState(() {
        _skills = skills;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = '$error';
        _loading = false;
      });
    }
  }

  Future<void> _run(Future<void> action) async {
    try {
      await action;
      if (mounted) await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  String? _cautionFor;

  Future<void> _install({required bool force, String? identifier}) async {
    final requested = (identifier ?? _identifier.text).trim();
    try {
      final result = await widget.admin.installHubSkill(
        requested,
        force: force,
      );
      if (!mounted) return;
      if (!result.installed) {
        final verdict = result.scan.verdict;
        final detail = result.scan.findings.join('; ');
        setState(() {
          _cautionFor = result.scan.caution ? requested : null;
          _error = result.scan.blocked
              ? 'Install blocked ($verdict): $detail'
              : result.scan.caution
              ? 'Scan verdict: $verdict. Confirm $requested before installing.'
              : 'The gateway has not confirmed that $requested is installed.';
        });
        return;
      }
      _identifier.clear();
      setState(() {
        _cautionFor = null;
        _error = null;
      });
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  Future<void> _edit(SkillRecord skill) async {
    final content = await widget.admin.learningContent(skill.name);
    if (!mounted) return;
    final controller = TextEditingController(text: content);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${skill.name}'),
        content: TextField(
          controller: controller,
          key: const Key('skill-editor'),
          maxLines: 8,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save skill'),
          ),
        ],
      ),
    );
    final next = controller.text;
    controller.dispose();
    if (saved == true) {
      await _run(widget.admin.saveLearningContent(skill.name, next));
    }
  }

  Future<void> _archive(SkillRecord skill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Archive ${skill.name}?'),
        content: const Text(
          'The skill is archived and can be restored with hermes curator restore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-archive'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(widget.admin.archiveSkill(skill.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) Text(_error!, key: const Key('capability-error')),
        TextField(
          key: const Key('hub-identifier'),
          controller: _identifier,
          decoration: const InputDecoration(labelText: 'Hub identifier'),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              key: const Key('hub-install'),
              onPressed: () => _install(force: false),
              child: const Text('Install'),
            ),
            if (_cautionFor != null && _identifier.text.trim() == _cautionFor)
              TextButton(
                key: const Key('hub-force'),
                onPressed: () => _install(force: true, identifier: _cautionFor),
                child: Text('Install $_cautionFor anyway'),
              ),
            TextButton(
              key: const Key('skill-update-all'),
              onPressed: () => _run(widget.admin.updateHubSkills()),
              child: const Text('Update all'),
            ),
          ],
        ),
        if (_loading) const LinearProgressIndicator(),
        for (final skill in _skills)
          ListTile(
            title: Text(skill.name),
            subtitle: Text(skill.description),
            trailing: Wrap(
              spacing: 4,
              children: [
                Switch(
                  key: Key('skill-enable-${skill.name}'),
                  value: skill.enabled,
                  onChanged: (enabled) =>
                      _run(widget.admin.setSkillEnabled(skill.name, enabled)),
                ),
                IconButton(
                  key: Key('skill-lock-${skill.name}'),
                  tooltip: skill.locked ? 'Unlock' : 'Lock',
                  onPressed: () => _run(
                    widget.admin.setSkillLocked(skill.name, !skill.locked),
                  ),
                  icon: Icon(skill.locked ? Icons.lock : Icons.lock_open),
                ),
                if (skill.editable) ...[
                  IconButton(
                    key: Key('skill-edit-${skill.name}'),
                    tooltip: 'Edit',
                    onPressed: () => _edit(skill),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    key: Key('skill-archive-${skill.name}'),
                    tooltip: 'Archive',
                    onPressed: () => _archive(skill),
                    icon: const Icon(Icons.archive_outlined),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _PluginsTab extends StatefulWidget {
  const _PluginsTab({required this.admin});

  final CapabilityAdmin admin;

  @override
  State<_PluginsTab> createState() => _PluginsTabState();
}

class _PluginsTabState extends State<_PluginsTab> {
  final _identifier = TextEditingController();
  List<PluginRecord> _plugins = const [];
  String? _notice;
  List<String> _lines = const [];
  String? _pendingName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final plugins = await widget.admin.plugins();
      if (!mounted) return;
      setState(() => _plugins = plugins);
    } catch (error) {
      if (!mounted) return;
      setState(() => _notice = '$error');
    }
  }

  bool _consent = false;
  bool _scanBlocked = false;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() => _notice = '$error');
    }
  }

  Future<void> _show(PluginMutation result, String name) async {
    if (!mounted) return;
    setState(() {
      _consent = result.consentRequired;
      _scanBlocked = result.scanBlocked;
      _pendingName = result.consentRequired || result.scanBlocked ? name : null;
      _lines = result.lines;
      _notice = result.ok
          ? null
          : result.consentRequired
          ? 'This update adds capabilities. Nothing changed yet.'
          : result.scanBlocked
          ? 'The scan blocked this plugin.'
          : (result.message ?? 'The plugin was not changed.');
    });
    if (result.ok) await _load();
  }

  Future<void> _confirmScan(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Install $name despite the scan?'),
        content: Text(
          'The security scan blocked $name. This confirmation applies only to $name.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('plugin-scan-confirm'),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Install $name anyway'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _guard(() async {
      await _show(await widget.admin.updatePlugin(name, force: true), name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_notice != null) Text(_notice!, key: const Key('plugin-notice')),
        for (final line in _lines) Text(line),
        TextField(
          key: const Key('plugin-identifier'),
          controller: _identifier,
          decoration: const InputDecoration(labelText: 'Repository'),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              key: const Key('plugin-install'),
              onPressed: () => _guard(() async {
                final result = await widget.admin.installPlugin(
                  _identifier.text,
                );
                await _show(result, _identifier.text.trim());
              }),
              child: const Text('Install plugin'),
            ),
            TextButton(
              onPressed: () => _guard(() async {
                await _show(await widget.admin.updateAllPlugins(), '');
              }),
              child: const Text('Update plugins'),
            ),
            if (_pendingName != null)
              TextButton(
                key: const Key('plugin-accept'),
                onPressed: () {
                  final name = _pendingName!;
                  if (!_consent) {
                    setState(() {
                      _notice =
                          'Accepting capabilities does not override the scan of $name.';
                    });
                    return;
                  }
                  _guard(() async {
                    final result = await widget.admin.updatePlugin(
                      name,
                      acceptCapabilities: true,
                    );
                    await _show(result, name);
                  });
                },
                child: const Text('Accept capabilities'),
              ),
            if (_scanBlocked && _pendingName != null)
              TextButton(
                key: const Key('plugin-scan-review'),
                onPressed: () => _confirmScan(_pendingName!),
                child: Text('Review scan for $_pendingName'),
              ),
          ],
        ),
        for (final plugin in _plugins) ...[
          ListTile(
            title: Text(plugin.name),
            subtitle: Text(
              plugin.hasDesktopHalf
                  ? '${plugin.description}\nFolder and preview-script grants stay in the Desktop app on that computer. Removing the plugin here does not revoke those local grants.'
                  : plugin.description,
            ),
            trailing: Wrap(
              children: [
                if (plugin.key.isNotEmpty)
                  Switch(
                    key: Key('plugin-enable-${plugin.name}'),
                    value: plugin.enabled,
                    onChanged: (enabled) => _guard(() async {
                      await widget.admin.togglePlugin(plugin.key, enabled);
                      await _load();
                    }),
                  ),
                IconButton(
                  key: Key('plugin-update-${plugin.name}'),
                  tooltip: 'Update',
                  onPressed: () => _guard(() async {
                    await _show(
                      await widget.admin.updatePlugin(plugin.name),
                      plugin.name,
                    );
                  }),
                  icon: const Icon(Icons.system_update_alt),
                ),
                IconButton(
                  key: Key('plugin-remove-${plugin.name}'),
                  tooltip: 'Remove',
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Remove ${plugin.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            key: const Key('confirm-remove-plugin'),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await _guard(() async {
                        await widget.admin.removePlugin(plugin.name);
                        await _load();
                      });
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
          if (plugin.hasDesktopHalf)
            TextButton(
              key: Key('plugin-desktop-${plugin.name}'),
              onPressed: () => _guard(() async {
                await widget.admin.removePluginDesktopHalf(plugin.name);
                await _load();
              }),
              child: const Text('Remove desktop half'),
            ),
        ],
      ],
    );
  }
}

class _ConnectorsTab extends StatefulWidget {
  const _ConnectorsTab({required this.admin});

  final CapabilityAdmin admin;

  @override
  State<_ConnectorsTab> createState() => _ConnectorsTabState();
}

class _ConnectorsTabState extends State<_ConnectorsTab> {
  final _name = TextEditingController();
  final _command = TextEditingController();
  final _url = TextEditingController();
  final _connector = TextEditingController();
  final _alias = TextEditingController();
  final _toolConnector = TextEditingController();
  List<McpServerRecord> _servers = const [];
  List<ConnectorAccount> _accounts = const [];
  ConnectorToolGrant? _grant;
  String? _grantConnector;
  final Set<String> _disabled = {};
  String? _logs;
  String? _error;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _command.dispose();
    _url.dispose();
    _connector.dispose();
    _alias.dispose();
    _toolConnector.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final servers = await widget.admin.mcpServers();
      if (!mounted) return;
      setState(() => _servers = servers);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) Text(_error!, key: const Key('connector-error')),
        TextField(
          key: const Key('mcp-name'),
          controller: _name,
          decoration: const InputDecoration(labelText: 'Server name'),
        ),
        TextField(
          key: const Key('mcp-command'),
          controller: _command,
          decoration: const InputDecoration(labelText: 'Command'),
        ),
        TextField(
          key: const Key('mcp-url'),
          controller: _url,
          decoration: const InputDecoration(labelText: 'HTTP URL'),
        ),
        TextButton(
          key: const Key('mcp-add'),
          onPressed: () async {
            final spec = _url.text.trim().isEmpty
                ? McpServerSpec.stdio(command: _command.text.trim())
                : McpServerSpec.http(url: _url.text.trim());
            try {
              await widget.admin.addMcpServer(_name.text, spec);
              _command.clear();
              _url.clear();
              await _load();
            } catch (error) {
              if (mounted) setState(() => _error = '$error');
            }
          },
          child: const Text('Add server'),
        ),
        for (final server in _servers)
          ListTile(
            title: Text(server.name),
            subtitle: Text(server.detail),
            trailing: Wrap(
              children: [
                Switch(
                  key: Key('mcp-enable-${server.name}'),
                  value: server.enabled,
                  onChanged: (enabled) => _guard(() async {
                    await widget.admin.setMcpEnabled(server.name, enabled);
                    await _load();
                  }),
                ),
                IconButton(
                  key: Key('mcp-probe-${server.name}'),
                  tooltip: 'Probe',
                  onPressed: () => _guard(() async {
                    final probe = await widget.admin.probeMcpServer(
                      server.name,
                    );
                    if (!mounted) return;
                    setState(() {
                      _error = probe.ok
                          ? 'Probe ${server.name}: ${probe.tools.join(', ')}'
                          : (probe.error ?? 'Probe failed.');
                    });
                  }),
                  icon: const Icon(Icons.network_check),
                ),
                IconButton(
                  key: Key('mcp-logs-${server.name}'),
                  tooltip: 'Logs',
                  onPressed: () => _guard(() async {
                    final logs = await widget.admin.mcpLogs(
                      server: server.name,
                    );
                    if (!mounted) return;
                    setState(() => _logs = logs);
                  }),
                  icon: const Icon(Icons.receipt_long),
                ),
              ],
            ),
          ),
        if (_logs != null)
          SelectableText(_logs!, key: const Key('mcp-log-text')),
        TextButton(
          key: const Key('mcp-log-file'),
          onPressed: () => _guard(() async {
            final logs = await widget.admin.mcpLogs();
            if (!mounted) return;
            setState(() => _logs = logs);
          }),
          child: const Text('MCP log'),
        ),
        TextField(
          key: const Key('connector-slug'),
          controller: _connector,
          decoration: const InputDecoration(labelText: 'Connector'),
        ),
        TextField(
          controller: _alias,
          decoration: const InputDecoration(labelText: 'Account alias'),
        ),
        TextButton(
          key: const Key('connector-link'),
          onPressed: () => _guard(() async {
            await widget.admin.connectConnector(
              _connector.text,
              alias: _alias.text,
            );
            final accounts = await widget.admin.connectorAccounts();
            if (!mounted) return;
            setState(() => _accounts = accounts);
          }),
          child: const Text('Link account'),
        ),
        for (final account in _accounts)
          ListTile(
            title: Text(
              account.alias.isEmpty ? account.connector : account.alias,
            ),
            subtitle: Text(account.connector),
            trailing: IconButton(
              key: Key('account-remove-${account.connectionId}'),
              tooltip: 'Remove account',
              onPressed: () => _guard(() async {
                await widget.admin.removeConnectorAccount(account.connectionId);
                final accounts = await widget.admin.connectorAccounts();
                if (!mounted) return;
                setState(() => _accounts = accounts);
              }),
              icon: const Icon(Icons.link_off),
            ),
          ),
        TextField(
          key: const Key('tool-connector'),
          controller: _toolConnector,
          decoration: const InputDecoration(labelText: 'Tool connector'),
        ),
        TextButton(
          key: const Key('tool-load'),
          onPressed: () => _guard(() async {
            final connector = _toolConnector.text.trim();
            final grant = await widget.admin.connectorTools(connector);
            if (!mounted) return;
            setState(() {
              _grant = grant;
              _grantConnector = connector;
              _disabled
                ..clear()
                ..addAll(grant.disabled);
            });
          }),
          child: const Text('Load tools'),
        ),
        if (_grant != null)
          for (final tool in _grant!.tools)
            CheckboxListTile(
              key: Key('tool-$tool'),
              title: Text(tool),
              value: !_disabled.contains(tool),
              onChanged: _grant!.revision == null
                  ? null
                  : (allowed) {
                      setState(() {
                        if (allowed == true) {
                          _disabled.remove(tool);
                        } else {
                          _disabled.add(tool);
                        }
                      });
                    },
            ),
        if (_grant?.revision != null)
          TextButton(
            key: const Key('tool-save'),
            onPressed: () => _guard(() async {
              final connector = _grantConnector;
              final revision = _grant?.revision;
              if (connector == null || revision == null) return;
              await widget.admin.setDisabledTools(
                connector: connector,
                disabledTools: _disabled.toList(),
                expectedRevision: revision,
              );
            }),
            child: Text(
              _grantConnector == null
                  ? 'Save tool grants'
                  : 'Save tool grants for $_grantConnector',
            ),
          ),
        if (_grant != null && _grant!.revision == null)
          const Text(
            'This policy has no member revision, so tool grants stay unchanged.',
          ),
      ],
    );
  }
}

class _BackendsTab extends StatefulWidget {
  const _BackendsTab({required this.admin});

  final CapabilityAdmin admin;

  @override
  State<_BackendsTab> createState() => _BackendsTabState();
}

class _BackendsTabState extends State<_BackendsTab> {
  List<ToolsetSetup> _toolsets = const [];
  ToolsetSetup? _setup;
  List<TerminalBackendRecord> _backends = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _load() async {
    try {
      final toolsets = await widget.admin.toolsets();
      final backends = await widget.admin.terminalBackends();
      if (!mounted) return;
      setState(() {
        _toolsets = toolsets;
        _backends = backends;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) Text(_error!),
        for (final toolset in _toolsets)
          ListTile(
            title: Text(toolset.name),
            onTap: () => _guard(() async {
              final setup = await widget.admin.toolsetSetup(toolset.name);
              if (!mounted) return;
              setState(() => _setup = setup);
            }),
          ),
        if (_setup != null) ...[
          Text('Backends for ${_setup!.name}'),
          for (final provider in _setup!.providers) ...[
            ListTile(
              title: Text(provider.name),
              subtitle: Text(provider.status),
              trailing: provider.active
                  ? const Text('Active')
                  : TextButton(
                      key: Key('provider-${provider.name}'),
                      onPressed: () => _guard(() async {
                        await widget.admin.selectToolsetProvider(
                          _setup!.name,
                          provider.name,
                        );
                        final setup = await widget.admin.toolsetSetup(
                          _setup!.name,
                        );
                        if (!mounted) return;
                        setState(() => _setup = setup);
                      }),
                      child: const Text('Use'),
                    ),
            ),
            if (provider.setupKey != null)
              TextButton(
                key: Key('setup-${provider.name}'),
                onPressed: () => _guard(() async {
                  await widget.admin.runToolsetSetup(
                    _setup!.name,
                    provider.setupKey!,
                  );
                }),
                child: const Text('Run setup'),
              ),
          ],
        ],
        const Text('Terminal backends'),
        for (final backend in _backends)
          ListTile(
            title: Text(backend.label),
            subtitle: Text('${backend.status} ${backend.detail}'.trim()),
            trailing: backend.active
                ? const Text('Active')
                : TextButton(
                    key: Key('terminal-${backend.name}'),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Use ${backend.label}?'),
                          content: Text(
                            backend.detail.isEmpty
                                ? 'This changes the terminal backend for this profile.'
                                : backend.detail,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              key: const Key('confirm-terminal'),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Use backend'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await _guard(() async {
                          await widget.admin.selectTerminalBackend(
                            backend.name,
                          );
                          await _load();
                        });
                      }
                    },
                    child: const Text('Select'),
                  ),
          ),
      ],
    );
  }
}

class _BrowserVaultScreenState extends State<BrowserVaultScreen> {
  VaultInventory? _inventory;
  String? _error;
  final _label = TextEditingController();
  final _origin = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _otp = TextEditingController();
  final _line1 = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  final _country = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardName = TextEditingController();
  final _expMonth = TextEditingController();
  final _expYear = TextEditingController();
  final _cvc = TextEditingController();
  String _kind = 'login';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _label,
      _origin,
      _identifier,
      _password,
      _otp,
      _line1,
      _city,
      _postal,
      _country,
      _cardNumber,
      _cardName,
      _expMonth,
      _expYear,
      _cvc,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final inventory = await widget.admin.vaultInventory();
      if (!mounted) return;
      setState(() {
        _inventory = inventory;
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  VaultDraft _draft() {
    switch (_kind) {
      case 'address':
        return VaultDraft.address(
          label: _label.text,
          origin: _origin.text,
          line1: _line1.text,
          city: _city.text,
          postal: _postal.text,
          country: _country.text,
        );
      case 'payment':
        return VaultDraft.payment(
          label: _label.text,
          origin: _origin.text,
          cardNumber: _cardNumber.text,
          cardName: _cardName.text,
          expMonth: _expMonth.text,
          expYear: _expYear.text,
          cvc: _cvc.text,
          postal: _postal.text,
        );
      default:
        return VaultDraft.login(
          label: _label.text,
          origin: _origin.text,
          identifier: _identifier.text,
          password: _password.text,
          otpSecret: _otp.text,
        );
    }
  }

  void _clearSecrets() {
    _password.clear();
    _otp.clear();
    _cardNumber.clear();
    _cvc.clear();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = _inventory;
    return Scaffold(
      appBar: AppBar(title: const Text('Browser vault')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) Text(_error!, key: const Key('vault-error')),
          const Text(
            'Saved site logins, addresses and cards. Passwords stay in the secure fields and are not listed here.',
          ),
          if (inventory != null)
            for (final item in inventory.items)
              ListTile(
                title: Text(item.label),
                subtitle: Text(
                  '${item.kind} ${item.origin} ${item.backend}'.trim(),
                ),
                trailing: item.removable
                    ? IconButton(
                        key: Key('vault-remove-${item.id}'),
                        tooltip: 'Remove saved item',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete this item?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  key: const Key('confirm-vault-remove'),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await widget.admin.removeVaultItem(item.id);
                            await _load();
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      )
                    : null,
              ),
          if (inventory != null)
            for (final source in inventory.sources)
              SwitchListTile(
                key: Key('vault-source-${source.name}'),
                title: Text(source.label),
                subtitle: Text(
                  source.installed
                      ? (source.unlocked ? 'Unlocked' : 'Locked')
                      : 'Not detected',
                ),
                value: source.enabled,
                onChanged: source.installed
                    ? (enabled) async {
                        await widget.admin.setVaultSourceEnabled(
                          source.name,
                          enabled,
                        );
                        await _load();
                      }
                    : null,
                secondary: source.needsUnlock
                    ? TextButton(
                        key: Key('vault-unlock-${source.name}'),
                        onPressed: () async {
                          final password = TextEditingController();
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Unlock ${source.label}'),
                              content: TextField(
                                key: const Key('vault-master'),
                                controller: password,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  hintText: 'Master password',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  key: const Key('confirm-unlock'),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Unlock'),
                                ),
                              ],
                            ),
                          );
                          final secret = password.text;
                          password.dispose();
                          if (confirmed == true) {
                            if (source.unlocked) {
                              await widget.admin.lockVaultSource(source.name);
                            } else {
                              await widget.admin.unlockVaultSource(
                                source.name,
                                secret,
                              );
                            }
                            await _load();
                          }
                        },
                        child: Text(source.unlocked ? 'Lock' : 'Unlock'),
                      )
                    : null,
              ),
          DropdownButton<String>(
            key: const Key('vault-kind'),
            value: _kind,
            items: const [
              DropdownMenuItem(value: 'login', child: Text('Login')),
              DropdownMenuItem(value: 'address', child: Text('Address')),
              DropdownMenuItem(value: 'payment', child: Text('Card')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _kind = value);
            },
          ),
          TextField(
            key: const Key('vault-label'),
            controller: _label,
            decoration: const InputDecoration(labelText: 'Label'),
          ),
          TextField(
            key: const Key('vault-origin'),
            controller: _origin,
            decoration: const InputDecoration(labelText: 'Site origin'),
          ),
          if (_kind == 'login') ...[
            TextField(
              key: const Key('vault-identifier'),
              controller: _identifier,
              decoration: const InputDecoration(labelText: 'Identifier'),
            ),
            TextField(
              key: const Key('vault-password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              key: const Key('vault-otp'),
              controller: _otp,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Authenticator key'),
            ),
          ],
          if (_kind == 'address') ...[
            TextField(
              controller: _line1,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: _postal,
              decoration: const InputDecoration(labelText: 'Postal code'),
            ),
            TextField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
          ],
          if (_kind == 'payment') ...[
            TextField(
              key: const Key('vault-card-name'),
              controller: _cardName,
              decoration: const InputDecoration(labelText: 'Name on card'),
            ),
            TextField(
              key: const Key('vault-card-number'),
              controller: _cardNumber,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Card number'),
            ),
            TextField(
              controller: _expMonth,
              decoration: const InputDecoration(labelText: 'Expiry month'),
            ),
            TextField(
              controller: _expYear,
              decoration: const InputDecoration(labelText: 'Expiry year'),
            ),
            TextField(
              key: const Key('vault-cvc'),
              controller: _cvc,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Security code'),
            ),
          ],
          TextButton(
            key: const Key('vault-save'),
            onPressed: () async {
              try {
                await widget.admin.addVaultItem(_draft());
                _clearSecrets();
                await _load();
              } on VaultFormException catch (error) {
                if (mounted) setState(() => _error = error.message);
              } catch (error) {
                if (mounted) setState(() => _error = '$error');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AgentPolicyScreenState extends State<AgentPolicyScreen> {
  AgentPolicy? _policy;
  SharedMetricsConsent? _metrics;
  String? _metricsNote;
  final _allowlist = TextEditingController();
  final _timeout = TextEditingController();
  final _limit = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _allowlist.dispose();
    _timeout.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final policy = await widget.admin.agentPolicy();
      if (!mounted) return;
      _allowlist.text = policy.allowlist.join('\n');
      _timeout.text = '${policy.approvalTimeout}';
      _limit.text = '${policy.checkpointLimit}';
      setState(() => _policy = policy);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
    try {
      final metrics = await widget.admin.sharedMetrics();
      if (!mounted) return;
      setState(() => _metrics = metrics);
    } on CapabilityException catch (error) {
      if (!mounted) return;
      setState(() {
        _metricsNote = error.methodMissing
            ? 'This gateway has no shared-metrics consent method.'
            : error.message;
      });
    }
  }

  AgentPolicy? _edited() {
    final current = _policy;
    if (current == null) return null;
    return AgentPolicy(
      approvalMode: current.approvalMode,
      approvalTimeout: int.tryParse(_timeout.text.trim()) ?? -1,
      confirmMcpReload: current.confirmMcpReload,
      allowlist: [
        for (final line in _allowlist.text.split('\n'))
          if (line.trim().isNotEmpty) line.trim(),
      ],
      checkpointsEnabled: current.checkpointsEnabled,
      checkpointLimit: int.tryParse(_limit.text.trim()) ?? -1,
      browserPrivateUrls: current.browserPrivateUrls,
      realBrowserProfile: current.realBrowserProfile,
    );
  }

  Future<void> _save(AgentPolicy policy) async {
    await widget.admin.saveAgentPolicy(policy);
    if (!mounted) return;
    setState(() => _policy = policy);
  }

  @override
  Widget build(BuildContext context) {
    final policy = _policy;
    return Scaffold(
      appBar: AppBar(title: const Text('Agent policy')),
      body: policy == null
          ? Center(child: Text(_error ?? 'Loading policy'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_error != null) Text(_error!),
                DropdownButton<String>(
                  key: const Key('approval-mode'),
                  value: policy.approvalMode,
                  items: [
                    for (final mode in AgentPolicy.modes)
                      DropdownMenuItem(value: mode, child: Text(mode)),
                  ],
                  onChanged: (mode) {
                    if (mode == null) return;
                    setState(() {
                      _policy = AgentPolicy(
                        approvalMode: mode,
                        approvalTimeout: policy.approvalTimeout,
                        confirmMcpReload: policy.confirmMcpReload,
                        allowlist: policy.allowlist,
                        checkpointsEnabled: policy.checkpointsEnabled,
                        checkpointLimit: policy.checkpointLimit,
                        browserPrivateUrls: policy.browserPrivateUrls,
                        realBrowserProfile: policy.realBrowserProfile,
                      );
                    });
                  },
                ),
                TextField(
                  key: const Key('approval-timeout'),
                  controller: _timeout,
                  decoration: const InputDecoration(
                    labelText: 'Approval timeout',
                  ),
                ),
                SwitchListTile(
                  key: const Key('mcp-reload-confirm'),
                  title: const Text('Confirm MCP reloads'),
                  value: policy.confirmMcpReload,
                  onChanged: (value) => setState(() {
                    _policy = AgentPolicy(
                      approvalMode: policy.approvalMode,
                      approvalTimeout: policy.approvalTimeout,
                      confirmMcpReload: value,
                      allowlist: policy.allowlist,
                      checkpointsEnabled: policy.checkpointsEnabled,
                      checkpointLimit: policy.checkpointLimit,
                      browserPrivateUrls: policy.browserPrivateUrls,
                      realBrowserProfile: policy.realBrowserProfile,
                    );
                  }),
                ),
                TextField(
                  key: const Key('command-allowlist'),
                  controller: _allowlist,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Command allowlist',
                  ),
                ),
                SwitchListTile(
                  key: const Key('checkpoints-enabled'),
                  title: const Text('File checkpoints'),
                  value: policy.checkpointsEnabled,
                  onChanged: (value) => setState(() {
                    _policy = AgentPolicy(
                      approvalMode: policy.approvalMode,
                      approvalTimeout: policy.approvalTimeout,
                      confirmMcpReload: policy.confirmMcpReload,
                      allowlist: policy.allowlist,
                      checkpointsEnabled: value,
                      checkpointLimit: policy.checkpointLimit,
                      browserPrivateUrls: policy.browserPrivateUrls,
                      realBrowserProfile: policy.realBrowserProfile,
                    );
                  }),
                ),
                TextField(
                  key: const Key('checkpoint-limit'),
                  controller: _limit,
                  decoration: const InputDecoration(
                    labelText: 'Checkpoint limit',
                  ),
                ),
                SwitchListTile(
                  key: const Key('private-urls'),
                  title: const Text('Browser private URLs'),
                  value: policy.browserPrivateUrls,
                  onChanged: (value) => setState(() {
                    _policy = AgentPolicy(
                      approvalMode: policy.approvalMode,
                      approvalTimeout: policy.approvalTimeout,
                      confirmMcpReload: policy.confirmMcpReload,
                      allowlist: policy.allowlist,
                      checkpointsEnabled: policy.checkpointsEnabled,
                      checkpointLimit: policy.checkpointLimit,
                      browserPrivateUrls: value,
                      realBrowserProfile: policy.realBrowserProfile,
                    );
                  }),
                ),
                SwitchListTile(
                  key: const Key('real-browser-profile'),
                  title: const Text('Use my real browser profile'),
                  value: policy.realBrowserProfile,
                  onChanged: (value) => setState(() {
                    _policy = AgentPolicy(
                      approvalMode: policy.approvalMode,
                      approvalTimeout: policy.approvalTimeout,
                      confirmMcpReload: policy.confirmMcpReload,
                      allowlist: policy.allowlist,
                      checkpointsEnabled: policy.checkpointsEnabled,
                      checkpointLimit: policy.checkpointLimit,
                      browserPrivateUrls: policy.browserPrivateUrls,
                      realBrowserProfile: value,
                    );
                  }),
                ),
                TextButton(
                  key: const Key('policy-save'),
                  onPressed: () async {
                    final edited = _edited();
                    if (edited == null) return;
                    try {
                      await _save(edited);
                    } catch (error) {
                      if (mounted) setState(() => _error = '$error');
                    }
                  },
                  child: const Text('Save policy'),
                ),
                if (_metricsNote != null) Text(_metricsNote!),
                if (_metrics != null) ...[
                  SwitchListTile(
                    key: const Key('metrics-enabled'),
                    title: const Text('Shared metrics for this profile'),
                    value: _metrics!.enabled,
                    onChanged: (enabled) async {
                      final next = await widget.admin.setSharedMetrics(
                        enabled: enabled,
                        send: enabled && _metrics!.send,
                      );
                      if (!mounted) return;
                      setState(() => _metrics = next);
                    },
                  ),
                  SwitchListTile(
                    key: const Key('metrics-send'),
                    title: const Text('Send shared metrics'),
                    value: _metrics!.send,
                    onChanged: _metrics!.enabled
                        ? (send) async {
                            final next = await widget.admin.setSharedMetrics(
                              enabled: true,
                              send: send,
                            );
                            if (!mounted) return;
                            setState(() => _metrics = next);
                          }
                        : null,
                  ),
                ],
              ],
            ),
    );
  }
}
