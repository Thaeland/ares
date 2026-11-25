part of 'remote_workspace.dart';

bool isProfileId(String value) =>
    value != 'current' && RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$').hasMatch(value);

class ProfileRoster {
  const ProfileRoster._(this.target, this.installId, this.names);
  final WorkspaceTarget target;
  final String? installId;
  final Map<String, String> names;
  static Future<ProfileRoster> read(WorkspaceTarget target) async {
    final result = await target.read(WorkspaceRead.profiles) as Map;
    final names = <String, String>{};
    for (final row in result['profiles'] as List) {
      final name = row['name'] as String;
      if (!isProfileId(name) || names.containsKey(name)) {
        _fail(WorkspaceFailure.invalid);
      }
      names[name] = row['display_name'] as String? ?? '';
    }
    return ProfileRoster._(
      target,
      result['install_id'] as String?,
      Map.unmodifiable(names),
    );
  }

  Future<ProfileRoster> refresh() async {
    final result = await read(target);
    if (result.installId != installId) _fail(WorkspaceFailure.mismatch);
    return result;
  }

  Future<void> create(String name, {String? clone}) async {
    if (!isProfileId(name) || name == 'default') {
      _fail(WorkspaceFailure.invalid);
    }
    final before = await refresh();
    if (before.names.containsKey(name) ||
        clone != null && !before.names.containsKey(clone)) {
      _fail(WorkspaceFailure.mismatch);
    }
    final result = await target._withOwner(
      () => target._rpc('profiles.create', {
        'name': name,
        'clone_from': ?clone,
        'clone_all': false,
        'clone_channels': false,
        'no_alias': true,
        'mirror_credentials': false,
        'share_auth': false,
      }),
    );
    if (result['ok'] != true ||
        result['name'] != name ||
        !(await refresh()).names.containsKey(name)) {
      _fail(WorkspaceFailure.mismatch);
    }
  }

  Future<RemoteProfileAdmin> settings(
    WorkspaceTarget selected,
    String name,
  ) async {
    target.checkCurrent();
    selected.checkCurrent();
    if (target.route.storedSessionId != null ||
        selected.route.storedSessionId != null ||
        !names.containsKey(name) ||
        selected.effectiveProfile != name ||
        selected.route.connectionId != target.route.connectionId ||
        selected._owner.expectedBaseUrl != target._owner.expectedBaseUrl) {
      _fail(WorkspaceFailure.mismatch);
    }
    final other = await read(selected);
    target.checkCurrent();
    if (installId == null ||
        installId!.isEmpty ||
        other.installId != installId ||
        !other.names.containsKey(name)) {
      _fail(WorkspaceFailure.mismatch);
    }
    return RemoteProfileAdmin._(this, selected, name);
  }
}

typedef ProfileSoul = ({String content, bool exists});
typedef ProfileField = ({String key, bool isSet, String? listValue});

class ProfileChannel {
  ProfileChannel._(Map row)
    : id = row['id'] as String,
      name = row['name'] as String,
      enabled = row['enabled'] as bool,
      state = row['state'] as String? ?? 'unknown',
      fields = List.unmodifiable([
        for (final f in row['env_vars'] as List)
          (
            key: f['key'] as String,
            isSet: f['is_set'] as bool,
            listValue: f['is_list'] == true && f['is_password'] == false
                ? (f['value'] as String? ?? '')
                : null,
          ),
      ]);
  final String id, name, state;
  final bool enabled;
  final List<ProfileField> fields;
}

typedef ProfilePair = ({
  String platform,
  String user,
  String? request,
  bool pending,
});
typedef ProfileHook = ({
  String name,
  String signature,
  String url,
  bool enabled,
});
typedef TelegramSetup = ({String id, String payload, DateTime expires});
typedef ProfileBackup = ({int pid, String archive});

class RemoteProfileAdmin {
  RemoteProfileAdmin._(this.roster, this._target, this.name);
  final ProfileRoster roster;
  final WorkspaceTarget _target;
  final String name;
  void check() {
    roster.target.checkCurrent();
    _target.checkCurrent();
  }

  Future<Map> _request(
    ProfileDashboardOp op, {
    String? key,
    Map<String, Object?>? fields,
  }) => _guard(check, () async {
    final response = await _target._owner._dashboard.profileOperation(
      op,
      check: check,
      key: key,
      fields: fields,
    );
    if (response is! Map) _fail(WorkspaceFailure.invalid);
    return response;
  });
  Future<void> _ok(
    ProfileDashboardOp op, {
    String? key,
    Map<String, Object?>? fields,
  }) async {
    if ((await _request(op, key: key, fields: fields))['ok'] != true) {
      _fail(WorkspaceFailure.unavailable);
    }
  }

  Future<ProfileSoul> soul() async {
    final r = await _request(ProfileDashboardOp.soul);
    return (content: r['content'] as String, exists: r['exists'] as bool);
  }

  Future<void> saveSoul(ProfileSoul before, String value) async {
    if (await soul() != before) _fail(WorkspaceFailure.mismatch);
    await _ok(ProfileDashboardOp.saveSoul, fields: {'content': value});
    if ((await soul()).content != value) _fail(WorkspaceFailure.mismatch);
  }

  Future<void> rename(String value) async {
    if (value.isEmpty ||
        value.trim() != value ||
        value.length > 64 ||
        (name != 'default' && (!isProfileId(value) || value == 'default'))) {
      _fail(WorkspaceFailure.invalid);
    }
    final before = await roster.refresh();
    if (!before.names.containsKey(name) ||
        name != 'default' && before.names.containsKey(value)) {
      _fail(WorkspaceFailure.mismatch);
    }
    final r = await _request(
      ProfileDashboardOp.rename,
      fields: {'new_name': value},
    );
    final after = await roster.refresh();
    if (r['ok'] != true ||
        (name == 'default'
            ? r['name'] != 'default' || after.names[name] != value
            : r['name'] != value ||
                  !after.names.containsKey(value) ||
                  after.names.containsKey(name))) {
      _fail(WorkspaceFailure.mismatch);
    }
  }

  Future<bool> remove() async {
    if (name == 'default' ||
        !(await roster.refresh()).names.containsKey(name)) {
      _fail(WorkspaceFailure.mismatch);
    }
    final r = await _request(ProfileDashboardOp.remove);
    if (r['ok'] != true || (await roster.refresh()).names.containsKey(name)) {
      _fail(WorkspaceFailure.mismatch);
    }
    return r['settlement_pending'] != true;
  }

  Future<String> exportProfile() async {
    final r = await _request(ProfileDashboardOp.export, fields: {});
    final path = r['archive'];
    if (r['ok'] != true ||
        path is! String ||
        !_canonicalPath(path) ||
        !path.endsWith('.tar.gz')) {
      _fail(WorkspaceFailure.invalid);
    }
    return path;
  }

  Future<void> importProfile(String archive, String dest) async {
    if (!isProfileId(dest) ||
        dest == 'default' ||
        !_canonicalPath(archive) ||
        !archive.endsWith('.tar.gz')) {
      _fail(WorkspaceFailure.invalid);
    }
    if ((await roster.refresh()).names.containsKey(dest)) {
      _fail(WorkspaceFailure.mismatch);
    }
    final r = await _request(
      ProfileDashboardOp.importArchive,
      fields: {'archive': archive, 'name': dest},
    );
    if (r['ok'] != true ||
        r['name'] != dest ||
        !(await roster.refresh()).names.containsKey(dest)) {
      _fail(WorkspaceFailure.mismatch);
    }
  }

  Future<List<ProfileChannel>> channels() async => [
    for (final row
        in (await _request(ProfileDashboardOp.channels))['platforms'] as List)
      ProfileChannel._(row as Map),
  ];
  Future<bool> updateChannel(
    ProfileChannel channel,
    bool enabled,
    Map<String, String> env,
    List<String> clear,
  ) async {
    final keys = channel.fields.map((f) => f.key).toSet();
    if (!keys.containsAll({...env.keys, ...clear}) ||
        clear.any(env.containsKey)) {
      _fail(WorkspaceFailure.invalid);
    }
    final r = await _request(
      ProfileDashboardOp.channel,
      key: channel.id,
      fields: {'enabled': enabled, 'env': env, 'clear_env': clear},
    );
    final saved = (await channels()).where((c) => c.id == channel.id).single;
    if (r['ok'] != true ||
        r['platform'] != channel.id ||
        saved.enabled != enabled ||
        env.entries.any(
          (e) => !saved.fields.any(
            (f) =>
                f.key == e.key &&
                f.isSet &&
                (f.listValue == null || f.listValue == e.value),
          ),
        ) ||
        clear.any((k) => !saved.fields.any((f) => f.key == k && !f.isSet))) {
      _fail(WorkspaceFailure.mismatch);
    }
    return r['hot_served'] == true;
  }

  Future<List<ProfilePair>> pairs() async {
    final r = await _request(ProfileDashboardOp.pairs);
    return [
      for (final group in ['pending', 'approved'])
        for (final row in r[group] as List)
          (
            platform: row['platform'] as String,
            user: row['user_id'] as String,
            request: row['request_id'] as String?,
            pending: group == 'pending',
          ),
    ];
  }

  Future<void> changePair(ProfilePair pair, {String? code}) async {
    if (!(await pairs()).contains(pair)) _fail(WorkspaceFailure.mismatch);
    final id = pair.request;
    if (pair.pending &&
        (id == null || id.isEmpty) &&
        (code == null || code.isEmpty)) {
      _fail(WorkspaceFailure.invalid);
    }
    final r = await _request(
      pair.pending ? ProfileDashboardOp.approve : ProfileDashboardOp.revoke,
      fields: {
        'platform': pair.platform,
        if (!pair.pending)
          'user_id': pair.user
        else if (id != null && id.isNotEmpty)
          'request_id': id
        else
          'code': code,
      },
    );
    if (r['ok'] != true ||
        pair.pending && r['user']?['user_id'] != pair.user ||
        (await pairs()).any(
              (p) =>
                  p.platform == pair.platform &&
                  p.user == pair.user &&
                  !p.pending,
            ) !=
            pair.pending) {
      _fail(WorkspaceFailure.mismatch);
    }
  }

  Future<({bool enabled, List<ProfileHook> entries})> hooks() async {
    final r = await _request(ProfileDashboardOp.hooks);
    return (
      enabled: r['enabled'] as bool,
      entries: [
        for (final h in r['subscriptions'] as List)
          (
            name: h['name'] as String,
            signature: h['signature'] as String? ?? 'unpinned',
            url: h['url'] as String,
            enabled: h['enabled'] as bool,
          ),
      ],
    );
  }

  Future<bool> enableHooks() async {
    final r = await _request(ProfileDashboardOp.enableHooks, fields: {});
    if (r['ok'] != true || !(await hooks()).enabled) {
      _fail(WorkspaceFailure.mismatch);
    }
    return r['needs_restart'] == true;
  }

  Future<({String url, String secret})> createHook({
    required String route,
    required String signature,
    required List<String> events,
    required String delivery,
    required String prompt,
    required List<String> skills,
  }) async {
    if (!isProfileId(route) ||
        !{'generic', 'github', 'gitlab', 'linear'}.contains(signature) ||
        delivery.isEmpty) {
      _fail(WorkspaceFailure.invalid);
    }
    final before = await hooks();
    if (!before.enabled || before.entries.any((e) => e.name == route)) {
      _fail(WorkspaceFailure.mismatch);
    }
    final r = await _request(
      ProfileDashboardOp.createHook,
      fields: {
        'name': route,
        'signature': signature,
        'events': events,
        'deliver': delivery,
        'prompt': prompt,
        'skills': skills,
      },
    );
    if (r['name'] != route ||
        r['secret'] is! String ||
        (r['secret'] as String).isEmpty ||
        !(await hooks()).entries.any(
          (h) =>
              h.name == route && h.signature == signature && h.url == r['url'],
        )) {
      _fail(WorkspaceFailure.mismatch);
    }
    return (url: r['url'] as String, secret: r['secret'] as String);
  }

  Future<void> changeHook(ProfileHook hook, {required bool delete}) async {
    if (!(await hooks()).entries.contains(hook)) {
      _fail(WorkspaceFailure.mismatch);
    }
    await _ok(
      delete ? ProfileDashboardOp.deleteHook : ProfileDashboardOp.toggleHook,
      key: hook.name,
      fields: delete ? null : {'enabled': !hook.enabled},
    );
    final after = (await hooks()).entries.where((h) => h.name == hook.name);
    if (delete
        ? after.isNotEmpty
        : after.length != 1 || after.single.enabled == hook.enabled) {
      _fail(WorkspaceFailure.mismatch);
    }
  }

  Future<TelegramSetup> startTelegram(String bot) async {
    final r = await _request(
      ProfileDashboardOp.telegramStart,
      fields: {'bot_name': bot},
    );
    final payload = r['qr_payload'] as String;
    final uri = Uri.tryParse(payload);
    if (payload.length > 800 ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host != 't.me' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort) {
      _fail(WorkspaceFailure.invalid);
    }
    return (
      id: r['pairing_id'] as String,
      payload: payload,
      expires: DateTime.parse(r['expires_at'] as String),
    );
  }

  Future<({bool ready, String user, String bot})> telegramStatus(
    TelegramSetup setup,
  ) async {
    if (!setup.expires.isAfter(DateTime.now())) {
      _fail(WorkspaceFailure.unavailable);
    }
    final r = await _request(ProfileDashboardOp.telegramStatus, key: setup.id);
    if (!{'waiting', 'ready'}.contains(r['status'])) {
      _fail(WorkspaceFailure.invalid);
    }
    return (
      ready: r['status'] == 'ready',
      user: r['owner_user_id'] as String? ?? '',
      bot: r['bot_username'] as String? ?? '',
    );
  }

  Future<bool> applyTelegram(TelegramSetup setup, List<String> users) async {
    if (users.isEmpty ||
        users.any((u) => !RegExp(r'^[0-9]+$').hasMatch(u)) ||
        !(await telegramStatus(setup)).ready) {
      _fail(WorkspaceFailure.invalid);
    }
    final r = await _request(
      ProfileDashboardOp.telegramApply,
      key: setup.id,
      fields: {'allowed_user_ids': users},
    );
    if (r['ok'] != true ||
        r['platform'] != 'telegram' ||
        !(await channels()).any(
          (c) =>
              c.id == 'telegram' &&
              c.enabled &&
              c.fields.any(
                (f) =>
                    f.key == 'TELEGRAM_ALLOWED_USERS' &&
                    f.listValue == users.join(','),
              ),
        )) {
      _fail(WorkspaceFailure.mismatch);
    }
    return r['needs_restart'] == true;
  }

  Future<void> cancelTelegram(TelegramSetup setup) =>
      _ok(ProfileDashboardOp.telegramCancel, key: setup.id);
  Future<ProfileBackup> startBackup() async {
    final r = await _request(ProfileDashboardOp.backup, fields: {});
    final path = r['archive'];
    if (r['ok'] != true ||
        r['pid'] is! int ||
        (r['pid'] as int) <= 0 ||
        r['name'] != 'backup' ||
        path is! String ||
        !_canonicalPath(path) ||
        !path.endsWith('.zip')) {
      _fail(WorkspaceFailure.invalid);
    }
    return (pid: r['pid'] as int, archive: path);
  }

  Future<bool> backupDone(ProfileBackup backup) async {
    final r = await _request(ProfileDashboardOp.backupStatus);
    if (r['pid'] != backup.pid || r['name'] != 'backup') {
      _fail(WorkspaceFailure.mismatch);
    }
    if (r['running'] == true) return false;
    if (r['running'] != false || r['exit_code'] != 0) {
      _fail(WorkspaceFailure.unavailable);
    }
    return true;
  }
}
