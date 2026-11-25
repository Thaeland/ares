import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/session.dart';
import '../data/chat_controller.dart';
import '../data/nextgen_gateway.dart';
import 'chat_view.dart';
import 'sessions_sidebar.dart';

/// A stored chat on the workspace gateway. A new owner or stored ID gets a
/// fresh controller even when a layout reuses this pane's position.
class NgParallelChatPane extends StatefulWidget {
  NgParallelChatPane({
    required this.gateway,
    required this.session,
    required this.close,
  }) : super(key: ValueKey((gateway, session.id)));
  final NextGenGateway gateway;
  final Session session;
  final VoidCallback close;

  @override
  State<NgParallelChatPane> createState() => _NgPaneState();
}

class _NgPaneState extends State<NgParallelChatPane>
    with WidgetsBindingObserver {
  late final _chat = NgChatController(
    widget.gateway,
    sessionId: widget.session.id,
    title: ngSessionTitle(widget.session),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_chat.open());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _chat.resync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NgChatView(chat: _chat, onClose: widget.close);
}
