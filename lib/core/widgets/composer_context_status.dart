import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../composer/context_status.dart';

/// Customisable live status. Hidden items stay off until chosen. A visible
/// item with no reported figure says so in the menu and stays off the bar.
class ComposerContextStatus extends StatefulWidget {
  const ComposerContextStatus({
    super.key,
    required this.layout,
    required this.usage,
    required this.onLayout,
    this.breakdown,
    this.breakdownLoading = false,
    this.runningSinceMs,
    this.sessionSinceMs,
    this.nowMs,
  });

  final StatusBarLayout layout;
  final UsageReading usage;
  final ContextReading? breakdown;
  final bool breakdownLoading;
  final int? runningSinceMs;
  final int? sessionSinceMs;
  final int? nowMs;
  final ValueChanged<StatusBarLayout> onLayout;

  @override
  State<ComposerContextStatus> createState() => _ComposerContextStatusState();
}

class _ComposerContextStatusState extends State<ComposerContextStatus> {
  Timer? _tick;
  int _now = 0;

  @override
  void initState() {
    super.initState();
    _now = widget.nowMs ?? DateTime.now().millisecondsSinceEpoch;
    _arm();
  }

  @override
  void didUpdateWidget(covariant ComposerContextStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nowMs != null) _now = widget.nowMs!;
    _arm();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _arm() {
    final live =
        widget.nowMs == null &&
        ((widget.layout.visible('running-timer') &&
                widget.runningSinceMs != null) ||
            (widget.layout.visible('session-timer') &&
                widget.sessionSinceMs != null));
    if (!live) {
      _tick?.cancel();
      _tick = null;
      return;
    }
    _tick ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now().millisecondsSinceEpoch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.sharedL10n;
    final reading = widget.breakdown != null && widget.breakdown!.usable
        ? UsageReading(
            cacheHitPct: widget.usage.cacheHitPct,
            avgTps: widget.usage.avgTps,
            contextUsed:
                widget.breakdown!.contextUsed ?? widget.usage.contextUsed,
            contextMax: widget.breakdown!.contextMax ?? widget.usage.contextMax,
            contextPercent:
                widget.breakdown!.contextPercent ?? widget.usage.contextPercent,
            estimated: widget.breakdown!.estimated || widget.usage.estimated,
            compressions: widget.usage.compressions,
          )
        : widget.usage;
    final chips = <Widget>[
      if (widget.layout.visible('context-usage') &&
          contextSummary(reading).isNotEmpty)
        _chip(l10n.composer_status_context, contextSummary(reading)),
      if (widget.layout.visible('cache-hit-rate') &&
          cacheHitLabel(reading.cacheHitPct).isNotEmpty)
        _chip(l10n.composer_status_cache, cacheHitLabel(reading.cacheHitPct)),
      if (widget.layout.visible('tokens-per-second') &&
          tokensPerSecondLabel(reading.avgTps).isNotEmpty)
        _chip(
          l10n.composer_status_throughput,
          tokensPerSecondLabel(reading.avgTps),
        ),
      if (widget.layout.visible('running-timer') &&
          widget.runningSinceMs != null)
        _chip(
          l10n.composer_status_running,
          formatDuration(_now - widget.runningSinceMs!),
        ),
      if (widget.layout.visible('session-timer') &&
          widget.sessionSinceMs != null)
        _chip(
          l10n.composer_status_session,
          formatDuration(_now - widget.sessionSinceMs!),
        ),
    ];
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        ...chips,
        PopupMenuButton<String>(
          key: const ValueKey('composer-status-menu'),
          tooltip: l10n.composer_status,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(l10n.composer_status),
          ),
          itemBuilder: (context) => [
            _item(
              'context-usage',
              l10n.composer_status_context,
              _contextReported,
            ),
            _item(
              'cache-hit-rate',
              l10n.composer_status_cache,
              cacheHitLabel(widget.usage.cacheHitPct).isNotEmpty,
            ),
            _item(
              'tokens-per-second',
              l10n.composer_status_throughput,
              tokensPerSecondLabel(widget.usage.avgTps).isNotEmpty,
            ),
            _item(
              'running-timer',
              l10n.composer_status_running,
              widget.runningSinceMs != null,
            ),
            _item(
              'session-timer',
              l10n.composer_status_session,
              widget.sessionSinceMs != null,
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'reset',
              child: Text(l10n.composer_status_reset),
            ),
          ],
          onSelected: (id) {
            if (id == 'reset') {
              widget.onLayout(widget.layout.reset());
              return;
            }
            widget.onLayout(
              widget.layout.setVisible(id, !widget.layout.visible(id)),
            );
          },
        ),
        if (widget.layout.visible('context-usage')) _breakdown(l10n),
      ],
    );
  }

  bool get _contextReported {
    final breakdown = widget.breakdown;
    if (breakdown != null && breakdown.usable) return true;
    return contextSummary(widget.usage).isNotEmpty;
  }

  PopupMenuItem<String> _item(String id, String label, bool reported) {
    final l10n = context.sharedL10n;
    final on = widget.layout.visible(id);
    return PopupMenuItem(
      value: id,
      child: Text(
        '$label ${on ? '\u2713' : ''}${reported ? '' : ' \u00b7 ${l10n.composer_status_not_reported}'}',
      ),
    );
  }

  Widget _breakdown(AppLocalizations l10n) {
    final breakdown = widget.breakdown;
    if (widget.breakdownLoading && (breakdown == null || !breakdown.usable)) {
      return Text(l10n.composer_status_loading);
    }
    if (breakdown == null ||
        !breakdown.usable ||
        breakdown.categories.isEmpty) {
      return Text(l10n.composer_status_empty);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final category in breakdown.categories)
          Text('${category.label} ${category.tokens}'),
      ],
    );
  }

  Widget _chip(String label, String value) =>
      Chip(label: Text('$label $value'));
}
