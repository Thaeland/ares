import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../../nextgen/data/nextgen_gateway.dart';
import '../../nextgen/nextgen_l10n.dart';
import '../../nextgen/nextgen_preferences.dart';
import '../../nextgen/theme/nextgen_theme.dart';
import '../../nextgen/ui/parallel_chat_pane.dart';
import '../../nextgen/ui/nextgen_scope.dart';
import '../l10n/l10n.dart';
import '../screens/chat_screen.dart';
import '../services/connection_manager.dart';
import '../services/desktop_gateway_client.dart';
import '../services/hermes_sign_in.dart';
import '../services/locale_preference.dart';
import '../services/theme_preference.dart';
import '../services/turn_notification_service.dart';
import '../theme/hermes_theme.dart';
import 'popout_owner.dart';
import 'popout_protocol.dart';

/// Other modes never open a pipe or install these process-local adapters.
void runWorkspacePopoutChild(List<String> args) {
  if (args.length != 1 ||
      args.single != workspacePopoutMarker ||
      !(Platform.isLinux || Platform.isWindows || Platform.isMacOS) ||
      stdioType(stdin) != StdioType.pipe) {
    exit(1);
  }
  final timeout = Timer(const Duration(seconds: 45), () => exit(1));
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    ),
  );
  unawaited(
    watchPopoutPipe(
      stdin,
      onLaunch: (frame) async {
        try {
          final target = PopoutTarget.decode(frame['target']);
          final nonce = frame['nonce'];
          final proof = frame['proof'];
          if (frame.length != 3 ||
              nonce is! String ||
              nonce.length != 36 ||
              proof is! String ||
              proof.length != 64) {
            throw const FormatException();
          }
          final directory = Directory.current;
          if (!directory.uri.pathSegments
              .where((s) => s.isNotEmpty)
              .last
              .startsWith('ares-chat-')) {
            throw StateError('No private cache');
          }
          final app = await preparePopout(target, nonce, proof, directory);
          timeout.cancel();
          runApp(app);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => stdout.writeln(workspacePopoutReady),
          );
        } catch (_) {
          stdout.writeln(workspacePopoutFailed);
          await stdout.flush();
          exit(1);
        }
      },
      onRevoked: () => exit(0),
    ),
  );
}

const _appearanceKeys = {
  LocalePreference.key,
  ThemePreferenceStore.modeKey,
  ThemePreferenceStore.paletteKey,
  NextGenPreferences.themeModeKey,
  NextGenPreferences.accentKey,
  NextGenPreferences.pureBlackKey,
  NextGenPreferences.glowKey,
};

/// Only the selected sanitized metadata row and cosmetic preferences enter
/// the child store. Existing transcripts, composer drafts and write-ahead
/// markers are neither imported nor overwritten by a second process.
Map<String, Object> popoutPreferences(
  Map<String, Object> source,
  PopoutTarget target,
) {
  const savedKey = 'flutter.saved_connections';
  final rows = (source[savedKey] as List).cast<String>().map(
    (encoded) => jsonDecode(encoded) as Map<String, dynamic>,
  );
  final row = rows.singleWhere((r) => r['id'] == target.connectionId);
  if (row.containsKey('api_key') ||
      row.containsKey('dashboard_password') ||
      (row['client_certificate'] is Map &&
          (row['client_certificate'] as Map).containsKey(
            'private_key_password',
          )) ||
      !matchesPopoutOwner(target, SavedConnection.fromMap(row))) {
    throw StateError('Connection is not eligible');
  }
  return {
    savedKey: <String>[jsonEncode(row)],
    for (final key in _appearanceKeys)
      if (source.containsKey('flutter.$key'))
        'flutter.$key': source['flutter.$key']!,
  };
}

/// Install only AFTER reading native credentials. Voice drafts, attachments
/// and scratch previews must not address files owned by the main process.
class PopoutPaths extends PathProviderPlatform {
  PopoutPaths(this.directory, this.original);
  final Directory directory;
  final PathProviderPlatform original;
  @override
  Future<String?> getTemporaryPath() async => directory.path;
  @override
  Future<String?> getApplicationCachePath() async => directory.path;
  @override
  Future<String?> getApplicationSupportPath() async => directory.path;
  @override
  Future<String?> getApplicationDocumentsPath() async => directory.path;
  @override
  Future<String?> getLibraryPath() async => directory.path;
  @override
  Future<String?> getDownloadsPath() => original.getDownloadsPath();
}

Future<Widget> preparePopout(
  PopoutTarget target,
  String nonce,
  String proof,
  Directory cache,
) async {
  final data = await SharedPreferencesStorePlatform.instance
      .getAllWithParameters(
        GetAllParameters(
          filter: PreferencesFilter(
            prefix: 'flutter.',
            allowList: {
              'flutter.saved_connections',
              for (final key in _appearanceKeys) 'flutter.$key',
            },
          ),
        ),
      );
  SharedPreferencesStorePlatform.instance =
      InMemorySharedPreferencesStore.withData(popoutPreferences(data, target));
  final prefs = await SharedPreferences.getInstance();
  final manager = ConnectionManager(prefs);
  // Deliberately no ConnectionManager.create/initialize: those migrate/write.
  final connection = (await manager.loadConnectionsWithSecrets()).single;
  HermesSignInVault.useReadOnlyWindowStore(
    DesktopGatewayClient.normalizedGatewayBaseUrl(connection),
  );
  await HermesSignInVault.instance.load();
  if (!matchesPopoutOwner(target, connection) ||
      popoutOwnerProof(nonce, connection) != proof) {
    throw StateError('Saved owner changed');
  }
  PathProviderPlatform.instance = PopoutPaths(
    cache,
    PathProviderPlatform.instance,
  );
  NextGenPreferences.load(prefs);
  final gateway = target.nextGen ? NextGenGateway(connection) : null;
  final api = gateway?.api ?? ApiClient.forConnection(connection);
  late Session session;
  try {
    session = await exactPopoutSession(target, api.getSession);
  } catch (_) {
    gateway?.dispose();
    rethrow;
  } finally {
    if (gateway == null) api.close();
  }
  return PopoutChatApp(
    manager: manager,
    connection: connection,
    session: session,
    gateway: gateway,
  );
}

Future<Session> exactPopoutSession(
  PopoutTarget target,
  Future<Map<String, dynamic>> Function(String) get,
) async {
  final row = await get(target.sessionId);
  // An older gateway may ignore a profile query. An ID shared by two
  // profiles is not enough to open a named profile's transcript.
  final profile = row['profile'];
  final matchesProfile = target.profile.isNotEmpty
      ? profile == target.profile
      : profile == null || profile == '' || profile == 'default';
  if (row['id'] != target.sessionId ||
      row['is_local_draft'] == true ||
      !matchesProfile) {
    throw StateError('Stored chat unavailable');
  }
  return Session.fromJson(row);
}

/// A single route using the real interfaces; not Home, the workspace, or a
/// fallback new chat. NextGen also requires NgScope above pushed sheets.
class PopoutChatApp extends StatefulWidget {
  const PopoutChatApp({
    super.key,
    required this.manager,
    required this.connection,
    required this.session,
    required this.gateway,
  });
  final ConnectionManager manager;
  final SavedConnection connection;
  final Session session;
  final NextGenGateway? gateway;
  @override
  State<PopoutChatApp> createState() => _PopoutChatAppState();
}

/// A child window has no notification authority. Only the primary window
/// posts/dismisses OS alerts and consumes startup or live activations.
class _PopoutNotificationSink implements TurnNotificationSink {
  const _PopoutNotificationSink();

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> checkPermission() async => false;
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<Null> takeInitialLaunchResponse() async => null;
  @override
  Future<void> show(TurnNotification notification) async =>
      throw StateError('Notifications belong to the primary window.');
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll() async {}
}

class _PopoutChatAppState extends State<PopoutChatApp> {
  final notifications = TurnNotificationService(
    sink: const _PopoutNotificationSink(),
  );
  @override
  void initState() {
    super.initState();
    widget.gateway?.start();
  }

  @override
  void dispose() {
    widget.gateway?.dispose();
    super.dispose();
  }

  final _messenger = GlobalKey<ScaffoldMessengerState>();
  Future<void> mainOnly() async {
    _messenger.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Use the main window to change your connection.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = widget.manager.prefs;
    final gateway = widget.gateway;
    final theme = ThemePreferenceStore(prefs);
    final look = NextGenLook.instance;
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ares — Chat',
      scaffoldMessengerKey: _messenger,
      supportedLocales: preferredSupportedLocales(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: resolvePreferredLocale,
      locale: LocalePreference.read(prefs),
      themeMode: gateway == null ? theme.readMode() : look.themeMode,
      theme: gateway == null
          ? hermesTheme(Brightness.light, palette: theme.readPalette())
          : nextGenTheme(Brightness.light, look),
      darkTheme: gateway == null
          ? hermesTheme(Brightness.dark, palette: theme.readPalette())
          : nextGenTheme(Brightness.dark, look),
      builder: (_, child) => NgLocalizationScope(child: child!),
      home: gateway == null
          ? ChatScreen(
              connection: widget.connection,
              session: widget.session,
              singleSession: true,
              notifications: notifications,
              onClose: () => exit(0),
            )
          : NgParallelChatPane(
              gateway: gateway,
              session: widget.session,
              close: () => exit(0),
            ),
    );
    if (gateway == null) return app;
    return NgScope(
      connManager: widget.manager,
      gateway: gateway,
      connections: [widget.connection],
      switchTo: (_) => mainOnly(),
      addGateway: mainOnly,
      signOut: (_) => mainOnly(),
      reload: mainOnly,
      signInAgain: mainOnly,
      child: app,
    );
  }
}
