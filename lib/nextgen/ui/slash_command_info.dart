// Slash-command highlighting and the tap-for-details card for the NextGen
// composer. Display only: NextGen sends a `/command` draft as an ordinary
// prompt, and the card says so.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/widgets/slash_command_highlight.dart';
import '../data/chat_controller.dart';
import '../data/slash_catalog.dart';
import '../nextgen_l10n.dart';
import '../theme/nextgen_theme.dart';

class NgSlashCommandInfo extends StatefulWidget {
  const NgSlashCommandInfo({
    super.key,
    required this.chat,
    required this.controller,
    required this.focusNode,
    required this.child,
    this.catalog,
  });

  final NgChatController chat;
  final SlashCommandHighlightController controller;
  final FocusNode focusNode;
  final Widget child;

  /// Test hook: a reader with custom timing.
  final NgSlashCatalog? catalog;

  @override
  State<NgSlashCommandInfo> createState() => _NgSlashCommandInfoState();
}

class _NgSlashCommandInfoState extends State<NgSlashCommandInfo> {
  late final NgSlashCatalog _catalog = widget.catalog ?? NgSlashCatalog();

  @override
  void initState() {
    super.initState();
    _scope();
  }

  @override
  void didUpdateWidget(covariant NgSlashCommandInfo old) {
    super.didUpdateWidget(old);
    // A chat switch (or a draft gaining its live session) changes the scope;
    // a cached answer for it shows at once, otherwise the next edit loads.
    _scope();
  }

  void _scope() =>
      _catalog.scopeTo(widget.chat.gateway, sessionId: widget.chat.runtimeId);

  @override
  void dispose() {
    if (widget.catalog == null) _catalog.dispose();
    super.dispose();
  }

  /// Fetches the catalogue lazily, the first time a draft starts with `/`,
  /// for the chat's current connection, profile and live session.
  void _onToken() {
    _scope();
    unawaited(_catalog.ensureLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final c = NgColors.of(context);
    return SlashCommandInfoAnchor(
      controller: widget.controller,
      focusNode: widget.focusNode,
      resolver: _catalog.resolve,
      highlightStyleOf: (context) => TextStyle(
        color: NgColors.of(context).accentText,
        fontWeight: FontWeight.w500,
      ),
      strings: SlashCommandInfoStrings(
        noDescription: ngL.ng_slash_command_no_description,
        loading: ngL.ng_slash_command_no_description,
        aliasOf: ngL.ng_slash_command_alias,
        argumentsOptions: ngL.ng_slash_command_arguments_options,
        argumentsText: ngL.ng_slash_command_arguments_text,
        argumentsMixed: ngL.ng_slash_command_arguments_mixed,
      ),
      style: SlashCommandInfoStyle(
        background: c.sheet,
        foreground: c.text,
        muted: c.text3,
        accent: c.accentText,
        border: c.stroke,
        textStyle: NgType.bodySmall,
        radius: NgRadii.md,
      ),
      note: ngL.ng_slash_command_sent_as_message,
      scope: widget.chat,
      refresh: _catalog,
      onToken: _onToken,
      child: widget.child,
    );
  }
}
