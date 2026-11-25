import 'package:flutter/material.dart';

import '../models/gateway_approval.dart';

import 'package:hermes_android/core/l10n/l10n.dart';

typedef ApprovalResponder = Future<void> Function(GatewayApprovalChoice choice);

class GatewayApprovalDialog extends StatefulWidget {
  final GatewayApprovalRequest request;
  final ApprovalResponder onRespond;

  const GatewayApprovalDialog({
    required this.request,
    required this.onRespond,
    super.key,
  });

  @override
  State<GatewayApprovalDialog> createState() => _GatewayApprovalDialogState();
}

class _GatewayApprovalDialogState extends State<GatewayApprovalDialog> {
  GatewayApprovalChoice? _submitting;
  bool _confirmAlways = false;
  String? _error;

  Future<void> _respond(GatewayApprovalChoice choice) async {
    if (_submitting != null) return;
    if (choice == GatewayApprovalChoice.always && !_confirmAlways) {
      setState(() {
        _confirmAlways = true;
        _error = null;
      });
      return;
    }

    final route = ModalRoute.of(context);
    setState(() {
      _submitting = choice;
      _error = null;
    });
    try {
      await widget.onRespond(choice);
      // Normal-owner cleanup may already have removed this dialog's route.
      if (!mounted || route?.isActive != true) return;
      final navigator = route!.navigator;
      if (route.isCurrent) {
        navigator?.pop(true);
      } else {
        // A newer prompt may be above this one; close only our own route.
        navigator?.removeRoute(route, true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = null;
        _error = context.l10n.could_not_send_the_approval(error);
      });
    }
  }

  String _labelFor(GatewayApprovalChoice choice) {
    return switch (choice) {
      GatewayApprovalChoice.once => context.l10n.allow_once,
      GatewayApprovalChoice.session => context.l10n.allow_for_this_session,
      GatewayApprovalChoice.always =>
        _confirmAlways
            ? context.l10n.confirm_always_allow
            : context.l10n.always_allow,
      GatewayApprovalChoice.deny => context.l10n.deny,
    };
  }

  String _scopeFor(GatewayApprovalChoice choice) {
    final request = widget.request;
    if (request.kind == GatewayApprovalKind.access) {
      return switch (choice) {
        GatewayApprovalChoice.once =>
          'Allow this folder for this request only.',
        GatewayApprovalChoice.session =>
          'Allow this folder until the session ends.',
        GatewayApprovalChoice.always =>
          'Save this folder grant for later requests.',
        GatewayApprovalChoice.deny => 'Do not grant this folder.',
      };
    }
    if (request.kind == GatewayApprovalKind.network) {
      return switch (choice) {
        GatewayApprovalChoice.once =>
          'Allow this website for this request only.',
        GatewayApprovalChoice.session =>
          'Allow this website until the session ends.',
        GatewayApprovalChoice.always =>
          'Save this website grant for later requests.',
        GatewayApprovalChoice.deny => 'Do not grant this website.',
      };
    }
    return switch (choice) {
      GatewayApprovalChoice.once => context.l10n.run_only_this_command,
      GatewayApprovalChoice.session =>
        context.l10n.allow_matching_commands_until_this_hermes_session_ends,
      GatewayApprovalChoice.always =>
        context.l10n.save_a_permanent_rule_in_the_hermes_configuration,
      GatewayApprovalChoice.deny => context.l10n.do_not_run_this_command,
    };
  }

  IconData _iconFor(GatewayApprovalChoice choice) {
    return switch (choice) {
      GatewayApprovalChoice.once => Icons.play_arrow_rounded,
      GatewayApprovalChoice.session => Icons.timer_outlined,
      GatewayApprovalChoice.always => Icons.verified_user_outlined,
      GatewayApprovalChoice.deny => Icons.block_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = widget.request;
    final busy = _submitting != null;

    final title = switch (request.kind) {
      GatewayApprovalKind.access => 'Folder access',
      GatewayApprovalKind.network => 'Website access',
      GatewayApprovalKind.command => context.l10n.approval_needed,
    };
    final accessLabel = switch (request.folderAccess) {
      'read' => 'Read-only',
      'read_write' => 'Read and write',
      _ => 'The gateway did not say whether this is read-only or read-write.',
    };

    // Back is a denial only before submission. Once a response is in flight,
    // dismissing would race that response against the route owner's denial.
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        icon: Icon(
          request.kind == GatewayApprovalKind.command
              ? Icons.gpp_maybe_outlined
              : Icons.folder_shared_outlined,
        ),
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(request.description),
                if (request.kind == GatewayApprovalKind.access) ...[
                  const SizedBox(height: 16),
                  Text('Folder', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SelectableText(
                    request.folderPath?.isNotEmpty == true
                        ? request.folderPath!
                        : 'The gateway did not name a folder.',
                  ),
                  const SizedBox(height: 8),
                  Text(accessLabel, key: const Key('approval-access')),
                ],
                if (request.kind == GatewayApprovalKind.network) ...[
                  const SizedBox(height: 16),
                  Text('Website', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SelectableText(
                    request.host?.isNotEmpty == true
                        ? request.host!
                        : 'The gateway did not name a website.',
                    key: const Key('approval-host'),
                  ),
                ],
                if (request.kind == GatewayApprovalKind.command &&
                    request.command.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(context.l10n.command, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      request.command,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                if (_confirmAlways) ...[
                  const SizedBox(height: 14),
                  Text(
                    context
                        .l10n
                        .this_creates_a_permanent_rule_in_hermes_review_the_full,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    key: const Key('approval-error'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                for (final choice in request.choices) ...[
                  OutlinedButton.icon(
                    key: Key('approval-${choice.wireValue}'),
                    onPressed: busy ? null : () => _respond(choice),
                    icon: _submitting == choice
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_iconFor(choice)),
                    label: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_labelFor(choice)),
                          Text(
                            _scopeFor(choice),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    style: choice == GatewayApprovalChoice.deny
                        ? OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
