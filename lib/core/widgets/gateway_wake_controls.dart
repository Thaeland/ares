import 'dart:async';

import 'package:flutter/material.dart';

import '../../nextgen/ui/session_dock.dart' show ngAboveComposerMaxHeight;
import '../l10n/l10n.dart';
import '../services/gateway_wake_word.dart';

/// Menu value for the narrow-pane (`< 480 px`) "More chat tools" wake-word row.
const String wakeWordToolValue = 'gateway-wake-word';

String _wakeLabel(BuildContext context, GatewayWakeState state) {
  final l10n = context.sharedL10n;
  final phrase = state.phrase.trim().isEmpty
      ? 'hey hermes'
      : state.phrase.trim();
  if (state.pending) return l10n.wake_word_arming;
  if (state.paused) return l10n.wake_word_paused(phrase);
  if (state.listening) return l10n.wake_word_listening(phrase);
  return l10n.wake_word_off(phrase);
}

String _wakeTooltip(BuildContext context, GatewayWakeState state) {
  final base = _wakeLabel(context, state);
  final notice = state.notice.trim();
  if (!state.paused && notice.isNotEmpty) {
    return '$base — $notice';
  }
  return base;
}

/// Entry for a narrow pane's (`< 480 px`) "More chat tools" menu.
PopupMenuItem<String> wakeWordToolItem(
  BuildContext context,
  GatewayWakeState state,
) {
  final active = state.listening && !state.paused;
  return PopupMenuItem<String>(
    key: const ValueKey('chat-tools-wake-word'),
    value: wakeWordToolValue,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        active ? Icons.hearing : Icons.hearing_disabled_outlined,
        color: active ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(_wakeLabel(context, state)),
      subtitle: state.notice.trim().isEmpty
          ? null
          : Text(
              state.notice.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    ),
  );
}

/// Wide-pane (`>= 480 px`) toolbar wake-word toggle button.
class GatewayWakeToolbarButton extends StatelessWidget {
  const GatewayWakeToolbarButton({
    super.key,
    required this.controller,
    this.sessionId,
    this.onNotice,
  });

  final GatewayWakeWordController controller;
  final String? sessionId;
  final ValueChanged<String>? onNotice;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final active = state.listening && !state.paused;
        final scheme = Theme.of(context).colorScheme;
        return GestureDetector(
          onLongPress: () => unawaited(
            showGatewayWakeSheet(
              context,
              controller: controller,
              sessionId: sessionId,
            ),
          ),
          child: Semantics(
            label: _wakeLabel(context, state),
            toggled: active,
            button: true,
            excludeSemantics: true,
            child: IconButton(
              key: const ValueKey('gateway-wake-toggle'),
              tooltip: _wakeTooltip(context, state),
              icon: state.pending
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      active ? Icons.hearing : Icons.hearing_disabled_outlined,
                      color: active ? scheme.primary : null,
                    ),
              onPressed: (state.pending || state.paused)
                  ? null
                  : () async {
                      final wasListening =
                          state.listening || (state.enabled && state.paused);
                      final ok = await controller.toggle(sessionId: sessionId);
                      if (!ok &&
                          !wasListening &&
                          controller.state.notice.trim().isNotEmpty) {
                        onNotice?.call(controller.state.notice.trim());
                      }
                    },
            ),
          ),
        );
      },
    );
  }
}

/// Visible indicator shown above the composer whenever wake-word detection is
/// listening, arming, or paused for active voice/lifecycle.
///
/// Constrained with [ngAboveComposerMaxHeight] so an open soft keyboard never
/// pushes the composer off screen.
class GatewayWakeListeningBanner extends StatelessWidget {
  const GatewayWakeListeningBanner({
    super.key,
    required this.controller,
    this.available = double.infinity,
    this.sessionId,
  });

  final GatewayWakeWordController controller;
  final double available;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (!state.listening && !state.paused && !state.pending) {
          return const SizedBox.shrink();
        }
        final l10n = context.sharedL10n;
        final scheme = Theme.of(context).colorScheme;
        final cap = ngAboveComposerMaxHeight(
          context,
          available: available,
          fraction: 0.22,
          withKeyboard: 0.16,
        );
        final captureLabel = state.usesClientMic
            ? l10n.wake_word_capture_client
            : l10n.wake_word_capture_local;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: cap),
          child: SingleChildScrollView(
            child: Container(
              key: const ValueKey('gateway-wake-banner'),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.audioSilent
                    ? scheme.errorContainer.withValues(alpha: 0.7)
                    : scheme.secondaryContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: state.listening
                      ? scheme.primary.withValues(alpha: 0.45)
                      : scheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  if (state.pending)
                    const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      state.paused ? Icons.pause_circle_outline : Icons.hearing,
                      size: 18,
                      color: state.listening
                          ? scheme.primary
                          : scheme.onSecondaryContainer,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _wakeLabel(context, state),
                            key: const ValueKey('gateway-wake-banner-label'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          if (state.listening)
                            Text(
                              state.audioSilent && state.notice.isNotEmpty
                                  ? state.notice
                                  : captureLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('gateway-wake-settings'),
                    visualDensity: VisualDensity.compact,
                    tooltip: l10n.wake_word_title,
                    icon: const Icon(Icons.tune, size: 18),
                    onPressed: () => unawaited(
                      showGatewayWakeSheet(
                        context,
                        controller: controller,
                        sessionId: sessionId,
                      ),
                    ),
                  ),
                  if (!state.pending)
                    TextButton(
                      key: const ValueKey('gateway-wake-stop'),
                      onPressed: () => unawaited(controller.stopExplicit()),
                      child: Text(l10n.wake_word_stop),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Opens a sheet with full wake-word controls (opt-in toggle, status/refusal,
/// capture mode, input microphone, and re-arm).
Future<void> showGatewayWakeSheet(
  BuildContext context, {
  required GatewayWakeWordController controller,
  String? sessionId,
}) {
  unawaited(controller.refreshStatus());
  unawaited(controller.refreshClientInputDevices());
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: GatewayWakeSettingsPanel(
          controller: controller,
          sessionId: sessionId,
        ),
      ),
    ),
  );
}

/// Shared wake-word control panel usable in sheets and Settings screens.
class GatewayWakeSettingsPanel extends StatelessWidget {
  const GatewayWakeSettingsPanel({
    super.key,
    required this.controller,
    this.sessionId,
  });

  final GatewayWakeWordController controller;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.sharedL10n;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        final captureRaw = state.capture.trim().toLowerCase();
        final captureChoice = switch (captureRaw) {
          'client' || 'remote' || 'external' => 'client',
          'local' => 'local',
          _ => 'auto',
        };
        final devices = controller.clientDevices;
        final selected = controller.selectedClientDevice;
        final serverDevice = state.serverInputDevice;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              key: const ValueKey('gateway-wake-switch'),
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                state.listening
                    ? Icons.hearing
                    : Icons.hearing_disabled_outlined,
              ),
              title: Text(l10n.wake_word_title),
              subtitle: Text(
                state.notice.trim().isNotEmpty
                    ? '${_wakeLabel(context, state)} — ${state.notice.trim()}'
                    : l10n.wake_word_subtitle,
              ),
              value: state.listening || (state.enabled && state.paused),
              onChanged: state.pending
                  ? null
                  : (_) => unawaited(controller.toggle(sessionId: sessionId)),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.wake_word_capture_mode,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  key: const ValueKey('gateway-wake-capture-auto'),
                  label: Text(l10n.wake_word_capture_auto),
                  selected: captureChoice == 'auto',
                  onSelected: state.pending
                      ? null
                      : (_) =>
                            unawaited(controller.setCapturePreference('auto')),
                ),
                ChoiceChip(
                  key: const ValueKey('gateway-wake-capture-client'),
                  label: Text(l10n.wake_word_capture_client),
                  selected: captureChoice == 'client',
                  onSelected: state.pending
                      ? null
                      : (_) => unawaited(
                          controller.setCapturePreference('client'),
                        ),
                ),
                ChoiceChip(
                  key: const ValueKey('gateway-wake-capture-local'),
                  label: Text(l10n.wake_word_capture_local),
                  selected: captureChoice == 'local',
                  onSelected: state.pending
                      ? null
                      : (_) =>
                            unawaited(controller.setCapturePreference('local')),
                ),
              ],
            ),
            if (devices.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<WakeClientInputDevice?>(
                key: ValueKey('gateway-wake-device-${selected?.id ?? "auto"}'),
                initialValue: devices.contains(selected) ? selected : null,
                decoration: InputDecoration(
                  labelText: l10n.wake_word_input_device,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem<WakeClientInputDevice?>(
                    value: null,
                    child: Text(l10n.wake_word_default_device),
                  ),
                  for (final d in devices)
                    DropdownMenuItem<WakeClientInputDevice?>(
                      value: d,
                      child: Text(d.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (d) =>
                    unawaited(controller.selectClientInputDevice(d)),
              ),
            ],
            if (serverDevice != null &&
                ((serverDevice.name?.isNotEmpty ?? false) ||
                    (serverDevice.error?.isNotEmpty ?? false))) ...[
              const SizedBox(height: 8),
              Text(
                serverDevice.error?.isNotEmpty == true
                    ? '${l10n.wake_word_input_device}: ${serverDevice.error}'
                    : '${l10n.wake_word_input_device}: ${serverDevice.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (state.enabled ||
                state.listening ||
                state.notice.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OutlinedButton.icon(
                  key: const ValueKey('gateway-wake-rearm'),
                  onPressed: state.pending
                      ? null
                      : () => unawaited(controller.rearm()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.wake_word_rearm),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
