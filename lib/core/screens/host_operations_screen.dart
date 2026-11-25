import 'package:flutter/material.dart';

import '../services/connection_manager.dart';
import '../services/remote_workspace.dart';

/// Remote-host logs, health, maintenance, Curator and update. This is not the
/// Ares client update check and it does not operate this device.
class HostOperationsScreen extends StatefulWidget {
  const HostOperationsScreen({
    super.key,
    required this.owner,
    required this.route,
    required this.connection,
  });

  final RemoteWorkspaceOwner owner;
  final WorkspaceRoute route;
  final SavedConnection connection;

  @override
  State<HostOperationsScreen> createState() => _HostOperationsScreenState();
}

class _HostOperationsScreenState extends State<HostOperationsScreen> {
  static const _files = ['agent', 'errors', 'gateway', 'desktop'];
  WorkspacePane? _pane;
  WorkspaceTarget? _target;
  var _file = 'gateway';
  String? _level;
  final _search = TextEditingController();
  var _consent = false;
  var _busy = false;
  String? _error;
  String _output = '';
  RemoteHostStatus? _status;
  RemoteHostLogs? _logs;
  HostUpdateEligibility? _eligibility;
  RemoteComputerUse? _computer;
  RemoteCuratorStatus? _curator;
  String? _launchedUpdate;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void dispose() {
    _search.dispose();
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
      final status = await target.hostStatus();
      final logs = await target.hostLogs(
        file: _file,
        level: _level,
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );
      final eligibility = await target.updateEligibility();
      final computer = await target.computerUse();
      final curator = await target.curatorStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _logs = logs;
        _eligibility = eligibility;
        _computer = computer;
        _curator = curator;
      });
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body) async {
    final answer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return answer == true && mounted;
  }

  Future<void> _update() async {
    final eligibility = _eligibility;
    if (eligibility == null || !hostUpdateMayStart(eligibility)) return;
    final agreed = await _confirm(
      'Update remote Hermes',
      'This starts an in-place update on the gateway host for ${widget.route.profile}. '
          'It does not update Ares on this device. Success is the matching update receipt, '
          'not the host staying reachable.',
    );
    if (!agreed) return;
    await _guard(() async {
      final target = await _bound();
      final launch = await target.startHostUpdate();
      if (launch.refused != null) {
        _output = launch.refused!;
        return;
      }
      await _readUpdate(target, launch.actionId!);
    });
  }

  Future<void> _recheckUpdate() async {
    final actionId = _launchedUpdate;
    if (actionId == null) return;
    await _guard(() async {
      await _readUpdate(await _bound(), actionId);
    });
  }

  /// Reads the receipt for [actionId]. Does not send another update.
  Future<void> _readUpdate(WorkspaceTarget target, String actionId) async {
    final status = await target.actionStatus('hermes-update');
    final verdict = judgeHostUpdate(
      actionId: actionId,
      running: status.running,
      receipt: status.receipt,
    );
    final unmatched =
        status.receipt == null || status.receipt!.actionId != actionId;
    _launchedUpdate = actionId;
    _output = unmatched && status.running
        ? 'Awaiting matching receipt. Update is still running.'
        : switch (verdict) {
            HostUpdateVerdict.success => 'Update receipt succeeded.',
            HostUpdateVerdict.partial =>
              'Update committed, with follow-up steps still owed.',
            HostUpdateVerdict.failed => 'Update receipt failed.',
            HostUpdateVerdict.refused => 'Update receipt refused.',
            HostUpdateVerdict.pending => 'Update is still running.',
            HostUpdateVerdict.unknown =>
              'Update outcome is unknown. A live gateway is not a successful update.',
          };
  }

  Future<void> _restart() async {
    final shared = _status?.sharedWith ?? const <String>[];
    final profile = widget.route.profile ?? 'the gateway default';
    final agreed = await _confirm(
      'Restart remote gateway',
      shared.length > 1
          ? 'This restarts the gateway shared by ${shared.join(', ')}. '
                'Live turns on this gateway are interrupted. '
                'Reconnect afterwards. Reachability is not proof the restart finished.'
          : 'This restarts the remote gateway for $profile. '
                'Live turns on this gateway are interrupted. '
                'Reconnect afterwards.',
    );
    if (!agreed) return;
    await _guard(() async {
      final target = await _bound();
      await target.restartHost();
      final status = await target.actionStatus('gateway-restart');
      _output = status.running
          ? 'Restart command is still running.'
          : status.exitCode == 0
          ? 'Restart command finished. Reconnect to the host yourself.'
          : 'Restart command failed.';
    });
  }

  Future<void> _maintenance(String name) async {
    await _guard(() async {
      final target = await _bound();
      final status = await target.startMaintenance(name);
      final head = status.running
          ? '$name is still running'
          : status.exitCode == 0
          ? '$name finished'
          : '$name failed';
      _output = '$head\n${status.lines.join('\n')}';
    });
  }

  Future<void> _pauseCurator(bool paused) async {
    await _guard(() async {
      final target = await _bound();
      _curator = await target.setCuratorPaused(paused);
      _output = paused ? 'Curator paused.' : 'Curator resumed.';
    });
  }

  Future<void> _reset(String targetName) async {
    final agreed = await _confirm(
      'Reset remote memory files',
      'Delete the $targetName memory file on ${widget.route.profile}? This cannot be undone from Ares.',
    );
    if (!agreed) return;
    await _guard(() async {
      final target = await _bound();
      final deleted = await target.resetMemoryFiles(targetName);
      _output = 'Reset $targetName. Removed ${deleted.length} remote file(s).';
    });
  }

  Future<void> _share() async {
    if (!_consent) return;
    await _guard(() async {
      final target = await _bound();
      final share = await target.shareDiagnostics(consent: true);
      if (!share.redacted) {
        _output =
            'The host did not confirm the bundle was redacted. No link is shown.';
        return;
      }
      _output = share.urls.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
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
    final scheme = Theme.of(context).colorScheme;
    final eligibility = _eligibility;
    final mayUpdate = eligibility != null && hostUpdateMayStart(eligibility);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Host'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _busy ? null : _open,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'These controls operate the remote gateway ${widget.connection.label} for '
            "${widget.route.profile ?? 'the gateway default'}"
            ', not this device and not the Ares client update.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          if (_error != null) Text(_error!, key: const Key('host-error')),
          if (_status != null)
            Text(
              '${_status!.running ? 'Gateway process running' : 'Gateway process stopped'} '
              '${_status!.version} · ${_status!.activeSessions} sessions',
              key: const Key('host-health'),
            ),
          if (_status?.heartbeatStaleSeconds != null)
            Text(
              'Host heartbeat is stale (${_status!.heartbeatStaleSeconds}s).',
            ),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                key: const Key('host-restart'),
                onPressed: _busy ? null : _restart,
                child: const Text('Restart remote gateway'),
              ),
              FilledButton(
                key: const Key('host-update'),
                onPressed: _busy || !mayUpdate ? null : _update,
                child: const Text('Update remote Hermes'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _maintenance('doctor'),
                child: const Text('Run Doctor'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _maintenance('security-audit'),
                child: const Text('Security audit'),
              ),
            ],
          ),
          if (eligibility?.message != null)
            Text(eligibility!.message!, key: const Key('host-update-message')),
          Text(_output, key: const Key('host-output')),
          if (_launchedUpdate != null)
            OutlinedButton(
              key: const Key('host-update-recheck'),
              onPressed: _busy ? null : _recheckUpdate,
              child: const Text('Check update receipt'),
            ),
          const SizedBox(height: 12),
          const Text('Remote host logs'),
          Wrap(
            spacing: 8,
            children: [
              for (final file in _files)
                ChoiceChip(
                  label: Text(file),
                  selected: _file == file,
                  onSelected: _busy
                      ? null
                      : (_) {
                          setState(() => _file = file);
                          _open();
                        },
                ),
              for (final level in ['INFO', 'WARNING', 'ERROR'])
                ChoiceChip(
                  label: Text(level),
                  selected: _level == level,
                  onSelected: _busy
                      ? null
                      : (selected) {
                          setState(() => _level = selected ? level : null);
                          _open();
                        },
                ),
            ],
          ),
          TextField(
            controller: _search,
            decoration: const InputDecoration(labelText: 'Search host logs'),
            onSubmitted: (_) => _open(),
          ),
          Text(_logs?.lines.join('\n') ?? '', key: const Key('host-logs')),
          const SizedBox(height: 12),
          const Text('Remote host driver'),
          Text(
            'Computer Use readiness is the gateway machine\'s driver and OS permissions, not this device.',
          ),
          if (_computer != null)
            Text(
              '${_computer!.platform} · installed ${_computer!.installed} · ready ${_computer!.ready}',
              key: const Key('host-computer-use'),
            ),
          for (final check in _computer?.checks ?? const [])
            Text('${check.label}: ${check.status}. ${check.message}'),
          const SizedBox(height: 12),
          const Text('Curator'),
          if (_curator != null)
            SwitchListTile(
              key: const Key('host-curator-paused'),
              title: Text(
                _curator!.paused ? 'Curator paused' : 'Curator running',
              ),
              subtitle: Text(_curator!.lastRunAt ?? 'No completed run'),
              value: _curator!.paused,
              onChanged: _busy ? null : _pauseCurator,
            ),
          OutlinedButton(
            onPressed: _busy ? null : () => _maintenance('curator-run'),
            child: const Text('Run Curator now'),
          ),
          const SizedBox(height: 12),
          const Text('Reset remote memory files'),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                key: const Key('host-reset-memory'),
                onPressed: _busy ? null : () => _reset('memory'),
                child: const Text('Reset memory file'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _reset('user'),
                child: const Text('Reset user file'),
              ),
              OutlinedButton(
                onPressed: _busy ? null : () => _reset('all'),
                child: const Text('Reset both files'),
              ),
            ],
          ),
          CheckboxListTile(
            key: const Key('host-consent'),
            value: _consent,
            onChanged: _busy
                ? null
                : (value) => setState(() => _consent = value ?? false),
            title: const Text(
              'I agree to upload a redacted diagnostic bundle from the remote host',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          FilledButton(
            key: const Key('host-share'),
            onPressed: _busy || !_consent ? null : _share,
            child: const Text('Share redacted diagnostics'),
          ),
        ],
      ),
    );
  }
}
