// Classic's server-owned Projects browser on the selected NextGen connection.
// Keep its nested navigation and repository in one gateway-owned subtree: a
// changed connection/profile discards both drill-in routes and pending reads.
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/l10n.dart';
import '../../core/models/hermes_project.dart';
import '../../core/models/session.dart';
import '../../core/services/project_folder_discovery.dart';
import '../../core/services/project_folder_provisioner.dart';
import '../../core/services/projects_gateway_client.dart';
import '../../core/services/projects_repository.dart';
import '../../core/services/projects_root_preference.dart';
import '../../core/services/projects_root_resolver.dart';
import '../../core/services/remote_files_client.dart';
import '../../core/services/ws_client.dart';
import '../../core/widgets/project_detail_screen.dart';
import '../../core/widgets/projects_pane.dart';
import '../data/nextgen_gateway.dart';
import 'nextgen_scope.dart';

class NgProjectsPage extends StatelessWidget {
  const NgProjectsPage({
    super.key,
    required this.onOpenSession,
    required this.onNewProjectChat,
  });

  final ValueChanged<Session> onOpenSession;
  final ValueChanged<HermesProject>? onNewProjectChat;

  @override
  Widget build(BuildContext context) {
    final scope = NgScope.of(context);
    return _ProjectsBrowser(
      key: ObjectKey(scope.gateway),
      gateway: scope.gateway,
      preferences: scope.prefs,
      onOpenSession: onOpenSession,
      onNewProjectChat: onNewProjectChat,
      onBack: () => Navigator.of(context).pop(),
    );
  }
}

class _ProjectsBrowser extends StatefulWidget {
  const _ProjectsBrowser({
    super.key,
    required this.gateway,
    required this.preferences,
    required this.onOpenSession,
    required this.onNewProjectChat,
    required this.onBack,
  });

  final NextGenGateway gateway;
  final SharedPreferences preferences;
  final ValueChanged<Session> onOpenSession;
  final ValueChanged<HermesProject>? onNewProjectChat;
  final VoidCallback onBack;

  @override
  State<_ProjectsBrowser> createState() => _ProjectsBrowserState();
}

class _ProjectsBrowserState extends State<_ProjectsBrowser> {
  final _navigator = GlobalKey<NavigatorState>();
  late final ProjectsRepository _repository;
  late final ProjectFolderDiscovery _folderDiscovery;

  bool get _isCurrent =>
      mounted && identical(NgScope.of(context).gateway, widget.gateway);

  @override
  void initState() {
    super.initState();
    final gateway = widget.gateway;
    final connection = gateway.connection;
    final roots = ProjectsRootPreference(widget.preferences);
    String? readConfiguredRoot() => roots.read(
      connectionIdentity: ProjectsRootPreference.identityOf(connection),
    );
    // Never reuse another profile's disk snapshot, even when a saved
    // connection is edited in place. Only the digest is written to prefs.
    final cacheScope = sha256.convert(
      utf8.encode(
        jsonEncode([
          connection.toMap(),
          connection.apiKey,
          connection.dashboardPassword,
          connection.clientCertificate?.privateKeyPassword,
        ]),
      ),
    );
    _repository = ProjectsRepository(
      client: ProjectsGatewayClient(_call),
      preferences: widget.preferences,
      connectionId: 'nextgen_$cacheScope',
      folderProvisioner: DashboardFolderProvisioner(
        gateway.dashboard,
        readConfiguredRoot: readConfiguredRoot,
      ),
    );
    // These collaborators borrow the selected gateway's authenticated client;
    // do not close it when leaving Projects or allocate another chat socket.
    final files = RemoteFilesClient(
      dashboard: gateway.dashboard,
      profile: gateway.profile,
    );
    _folderDiscovery = DashboardProjectFolderDiscovery(
      listDirectory: files.listDirectory,
      roots: ProjectsRootResolver(
        dashboard: gateway.dashboard,
        readConfiguredRoot: readConfiguredRoot,
      ),
    );
  }

  /// ProjectsGatewayClient consumes envelopes; NextGenGateway returns results
  /// and throws typed RPC errors. Preserve codes so old hosts keep Classic's
  /// compatibility state rather than appearing empty or as a network failure.
  Future<Map<String, dynamic>> _call(
    String method,
    Map<String, dynamic> params,
  ) async {
    if (!_isCurrent) throw StateError('Projects scope is no longer selected');
    await widget.gateway.connected();
    if (!_isCurrent) throw StateError('Projects scope is no longer selected');
    try {
      return {'result': await widget.gateway.call(method, params)};
    } on JsonRpcError catch (error) {
      return {
        'error': {
          'code': error.code,
          'message': error.message,
          'data': error.data,
        },
      };
    }
  }

  @override
  void dispose() {
    unawaited(_repository.close());
    super.dispose();
  }

  void _openSession(Session session) {
    if (!_isCurrent) return;
    // The normal main-page owner retains its cached controllers, notifications
    // and stored-id routing. Do not mount a second chat under the browser.
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onOpenSession(session);
  }

  Future<void> _newChat(HermesProject project) async {
    if (!_isCurrent || widget.onNewProjectChat == null) return;
    if (project.workingDirectory?.trim().isNotEmpty != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.this_project_has_no_folder_to_open_the_chat_in,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    widget.onNewProjectChat!(project);
  }

  Future<void> _openProject(String projectId) async {
    if (!_isCurrent) return;
    final project = _repository.current.projects
        .where((project) => project.id == projectId)
        .firstOrNull;
    if (project == null) return;
    await _navigator.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(
          projectId: project.id,
          projectName: project.name,
          loadSessions: ({required refresh}) =>
              _repository.projectSessions(project.id, refresh: refresh),
          onOpenSession: _openSession,
          onNewChat: widget.onNewProjectChat == null
              ? null
              : () => _newChat(project),
          projects: _repository.current.projects,
          onMoveSession: (session, destination) =>
              _repository.moveSessionToProject(session.id, destination),
          onRenameProject: (name) => _repository.rename(project.id, name),
          onArchiveProject: () => _repository.archive(project.id),
          onDeleteProject: () => _repository.delete(project.id),
        ),
      ),
    );
    // ProjectsPane refreshes the overview after this future completes, just
    // as it does in Classic (the detail's chat count is a separate read).
  }

  @override
  Widget build(BuildContext context) => NavigatorPopHandler(
    onPopWithResult: (_) => _navigator.currentState?.maybePop(),
    child: Navigator(
      key: _navigator,
      onGenerateInitialRoutes: (_, _) => [
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: widget.onBack),
              title: Text(context.l10n.projects),
            ),
            body: ProjectsPane(
              repository: _repository,
              folderDiscovery: _folderDiscovery,
              onProjectSelected: _openProject,
            ),
          ),
        ),
      ],
    ),
  );
}
