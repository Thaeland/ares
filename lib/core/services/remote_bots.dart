part of 'remote_workspace.dart';

/// Bot Mode / rooms / Bot Desktop / routines (`F11`): typed gateway calls,
/// scoped to the bound [WorkspaceTarget] so a late reply never lands on a
/// different account or profile. Every RPC is sent with the target profile
/// explicit in params (the Desktop rewrites `profile` per `requestForBot`);
/// launch-home methods are sent with no profile param at all.
final class WorkspaceBotsUnsupported extends WorkspaceException {
  const WorkspaceBotsUnsupported(super.reason);
}

String botHandleFor(String name) => name == 'default' ? 'hermes' : name;

/// How a lease names its holder: the first 12 hex of sha256(viewer id)
/// (`tools/bot_desktop/lease.py` public view). The id itself never leaves the
/// connection that minted it.
String botDisplayViewerHash(String viewerId) =>
    sha256.convert(utf8.encode(viewerId)).toString().substring(0, 12);

final class BotRosterProfile {
  const BotRosterProfile({
    required this.name,
    required this.path,
    required this.isDefault,
    this.model = '',
    this.provider = '',
    this.description = '',
    this.displayName = '',
    this.skillCount = 0,
    this.hasAvatar = false,
    this.canonicalSessionId,
    this.workerSessionId,
    this.lastSessionPreview,
  });

  final String name;
  final String path;
  final bool isDefault;
  final String model;
  final String provider;
  final String description;
  final String displayName;
  final int skillCount;
  final bool hasAvatar;
  final String? canonicalSessionId;
  final String? workerSessionId;
  final String? lastSessionPreview;

  String get handle => botHandleFor(name);

  String get title =>
      displayName.isNotEmpty && displayName != name ? displayName : name;

  factory BotRosterProfile.fromJson(Map raw) {
    final name = raw['name'];
    if (name is! String || name.isEmpty) _fail(WorkspaceFailure.invalid);
    final path = raw['path'];
    final canonical = raw['canonical_session'];
    final lastSession = raw['last_session'];
    final worker = raw['worker_session'];
    return BotRosterProfile(
      name: name,
      path: path is String ? path : '',
      isDefault: raw['is_default'] == true,
      model: raw['model'] as String? ?? '',
      provider: raw['provider'] as String? ?? '',
      description: raw['description'] as String? ?? '',
      displayName:
          raw['display_name'] as String? ?? raw['displayName'] as String? ?? '',
      skillCount: (raw['skill_count'] as num?)?.toInt() ?? 0,
      hasAvatar: raw['has_avatar'] == true,
      canonicalSessionId: canonical is Map
          ? (canonical['id'] as String?) ??
                (canonical['resolved_id'] as String?)
          : null,
      workerSessionId: worker is Map ? worker['id'] as String? : null,
      lastSessionPreview: lastSession is Map
          ? lastSession['preview'] as String?
          : null,
    );
  }
}

final class BotRoster {
  const BotRoster({
    required this.profiles,
    required this.botModeProtocol,
    required this.installId,
  });

  final List<BotRosterProfile> profiles;

  /// When true the gateway injects the teammate-messaging protocol itself;
  /// clients must NOT re-append the protocol to SOUL.md.
  final bool botModeProtocol;
  final String? installId;

  BotRosterProfile? find(String? name) =>
      name == null ? null : profiles.where((p) => p.name == name).singleOrNull;

  factory BotRoster.fromJson(Map raw) {
    final rawProfiles = raw['profiles'];
    if (rawProfiles is! List) _fail(WorkspaceFailure.invalid);
    return BotRoster(
      profiles: List.unmodifiable(
        rawProfiles.map((item) {
          if (item is! Map) _fail(WorkspaceFailure.invalid);
          return BotRosterProfile.fromJson(item);
        }),
      ),
      botModeProtocol: raw['bot_mode_protocol'] == true,
      installId: raw['install_id'] as String?,
    );
  }
}

/// One canonical Bot Chat resolution. [minted] says the chat was just created
/// by this call; [find] says an existing chat was adopted.
final class CanonicalChat {
  const CanonicalChat({
    required this.profile,
    required this.sessionId,
    required this.title,
    required this.minted,
  });

  final String profile;
  final String sessionId;
  final String title;
  final bool minted;
}

final class RoutineJob {
  const RoutineJob({
    required this.jobId,
    required this.name,
    this.schedule = '',
    this.nextRunAt,
    this.lastRunAt,
    this.lastStatus = '',
    this.lastError,
    this.enabled = true,
    this.state = '',
    this.repeat,
    this.promptPreview = '',
    this.deliver = '',
  });

  final String jobId;
  final String name;
  final String schedule;
  final String? nextRunAt;
  final String? lastRunAt;
  final String lastStatus;
  final String? lastError;
  final bool enabled;
  final String state;

  /// The gateway's own wording of the run limit (`cron/job_args.py`
  /// `_repeat_display`): `forever`, `once`, `3 times` or `1/3`. A string on
  /// the wire, never a count.
  final String? repeat;
  final String promptPreview;
  final String deliver;

  /// `[bot:<name>] <title>` → (bot, title). Untagged jobs keep an empty bot.
  static ({String bot, String title}) splitTags(String rawName) {
    final match = RegExp(
      r'^\[bot:([a-z0-9][a-z0-9_-]*)\]\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(rawName.trim());
    if (match == null) return (bot: '', title: rawName.trim());
    return (bot: match.group(1)!.toLowerCase(), title: match.group(2)!.trim());
  }

  String get title => splitTags(name).title;

  String get bot => splitTags(name).bot;

  bool get isLegacyDelegated =>
      promptPreview.startsWith('You are running the scheduled routine "') &&
      bot.isNotEmpty;

  factory RoutineJob.fromJson(Map raw) {
    final name = raw['name'];
    if (name is! String || name.isEmpty) _fail(WorkspaceFailure.invalid);
    final jobId = raw['job_id'] ?? raw['id'] ?? raw['name'];
    return RoutineJob(
      jobId: jobId is String && jobId.isNotEmpty ? jobId : name,
      name: name,
      schedule: raw['schedule'] as String? ?? '',
      nextRunAt: raw['next_run_at'] as String?,
      lastRunAt: raw['last_run_at'] as String?,
      lastStatus: raw['last_status'] as String? ?? '',
      lastError: raw['last_error'] as String?,
      enabled: raw['enabled'] != false && raw['state'] != 'paused',
      state: raw['state'] as String? ?? '',
      repeat: switch (raw['repeat']) {
        final String text when text.trim().isNotEmpty => text.trim(),
        final num count => '$count',
        _ => null,
      },
      promptPreview:
          raw['prompt_preview'] as String? ?? raw['prompt'] as String? ?? '',
      deliver: raw['deliver'] as String? ?? '',
    );
  }
}

final class RoomMember {
  const RoomMember({
    required this.memberId,
    required this.profile,
    this.handle = '',
    this.displayName = '',
    this.target,
  });

  final String memberId;
  final String profile;
  final String handle;
  final String displayName;
  final String? target;

  String get title => displayName.isNotEmpty
      ? displayName
      : (handle.isNotEmpty ? handle : profile);

  factory RoomMember.fromJson(Map raw) {
    final profile = raw['profile'];
    if (profile is! String || profile.isEmpty) _fail(WorkspaceFailure.invalid);
    final memberId = raw['member_id'] ?? profile;
    return RoomMember(
      memberId: memberId is String && memberId.isNotEmpty ? memberId : profile,
      profile: profile,
      handle: raw['handle'] as String? ?? '',
      displayName: raw['display_name'] as String? ?? '',
      target: raw['target'] as String?,
    );
  }
}

final class RoomCapabilities {
  const RoomCapabilities({
    required this.protocolVersion,
    required this.driver,
    required this.persistentProcess,
    required this.authorityGatewayId,
    required this.roomLink,
    required this.features,
    required this.methods,
    required this.maxLogLimit,
    required this.seatableProfiles,
  });

  final int protocolVersion;
  final bool driver;
  final bool persistentProcess;
  final String authorityGatewayId;
  final Map<String, dynamic> roomLink;
  final List<String> features;
  final List<String> methods;
  final int maxLogLimit;
  final List<String>? seatableProfiles;

  bool supports(String method) => methods.contains(method);

  factory RoomCapabilities.fromJson(Map raw) {
    if (raw['protocol_version'] is! int) _fail(WorkspaceFailure.invalid);
    return RoomCapabilities(
      protocolVersion: raw['protocol_version'] as int,
      driver: raw['driver'] == true,
      persistentProcess: raw['persistent_process'] == true,
      authorityGatewayId: raw['authority_gateway_id'] as String? ?? '',
      roomLink: raw['room_link'] is Map
          ? Map<String, dynamic>.from(raw['room_link'])
          : const {},
      features: (raw['features'] is List ? raw['features'] as List : const [])
          .whereType<String>()
          .toList(),
      methods: (raw['methods'] is List ? raw['methods'] as List : const [])
          .whereType<String>()
          .toList(),
      maxLogLimit: (raw['max_log_limit'] as num?)?.toInt() ?? 500,
      seatableProfiles: raw['seatable_profiles'] is List
          ? List<String>.from(raw['seatable_profiles'] as List)
          : null,
    );
  }
}

final class RoomSummary {
  const RoomSummary({
    required this.roomId,
    required this.name,
    this.members = const [],
    this.authorityGatewayId = '',
    this.revision = 0,
    this.createdAt,
    this.updatedAt,
    this.disbandedAt,
    this.latestSeq,
    this.adopted = false,
  });

  final String roomId;
  final String name;
  final List<RoomMember> members;
  final String authorityGatewayId;
  final int revision;
  final double? createdAt;
  final double? updatedAt;
  final double? disbandedAt;
  final int? latestSeq;
  final bool adopted;

  bool get disbanded => disbandedAt != null;

  factory RoomSummary.fromJson(Map raw) {
    final roomId = raw['room_id'];
    if (roomId is! String || roomId.isEmpty) _fail(WorkspaceFailure.invalid);
    return RoomSummary(
      roomId: roomId,
      name: raw['name'] as String? ?? roomId,
      members: raw['members'] is List
          ? [
              for (final m in raw['members'] as List)
                if (m is Map) RoomMember.fromJson(m),
            ]
          : const [],
      authorityGatewayId: raw['authority_gateway_id'] as String? ?? '',
      revision: (raw['revision'] as num?)?.toInt() ?? 0,
      createdAt: (raw['created_at'] as num?)?.toDouble(),
      updatedAt: (raw['updated_at'] as num?)?.toDouble(),
      disbandedAt: (raw['disbanded_at'] as num?)?.toDouble(),
      latestSeq: (raw['latest_seq'] as num?)?.toInt(),
      adopted: raw['adopted'] == true,
    );
  }
}

final class RoomDriverStatus {
  const RoomDriverStatus({
    this.running = false,
    this.working = false,
    this.blocked = false,
    this.counts = const {},
    this.lastError,
  });

  final bool running;
  final bool working;
  final bool blocked;
  final Map<String, int> counts;
  final String? lastError;

  factory RoomDriverStatus.fromJson(Map raw) {
    final counts = <String, int>{};
    final rawCounts = raw['counts'];
    if (rawCounts is Map) {
      for (final entry in rawCounts.entries) {
        if (entry.key is String && entry.value is num) {
          counts[entry.key as String] = (entry.value as num).toInt();
        }
      }
    }
    return RoomDriverStatus(
      running: raw['running'] == true,
      working: raw['working'] == true,
      blocked: raw['blocked'] == true,
      counts: Map.unmodifiable(counts),
      lastError: raw['last_error'] as String?,
    );
  }
}

final class RoomContext {
  const RoomContext({
    this.purpose = '',
    this.notes = '',
    this.routing = 'everyone',
    this.leadMemberId = '',
  });

  final String purpose;
  final String notes;
  final String routing;
  final String leadMemberId;

  factory RoomContext.fromJson(Map raw) => RoomContext(
    purpose: raw['purpose'] as String? ?? '',
    notes: raw['notes'] as String? ?? '',
    routing: raw['routing'] as String? ?? 'everyone',
    leadMemberId: raw['lead_member_id'] as String? ?? '',
  );
}

final class RoomReadResult {
  const RoomReadResult({
    required this.room,
    this.driverStatus,
    this.context,
    this.changeEvents,
  });

  final RoomSummary room;
  final RoomDriverStatus? driverStatus;
  final RoomContext? context;
  final bool? changeEvents;

  factory RoomReadResult.fromJson(Map raw) {
    final room = raw['room'];
    if (room is! Map) _fail(WorkspaceFailure.invalid);
    return RoomReadResult(
      room: RoomSummary.fromJson(room),
      driverStatus: raw['driver_status'] is Map
          ? RoomDriverStatus.fromJson(raw['driver_status'] as Map)
          : null,
      context: raw['context'] is Map
          ? RoomContext.fromJson(raw['context'] as Map)
          : null,
      changeEvents: raw['change_events'] is bool
          ? raw['change_events'] as bool
          : null,
    );
  }
}

final class RoomSendResult {
  const RoomSendResult({
    required this.clientEventId,
    required this.accepted,
    this.driverStarted,
  });

  final String? clientEventId;
  final bool accepted;
  final bool? driverStarted;

  factory RoomSendResult.fromJson(Map raw) => RoomSendResult(
    clientEventId: raw['client_event_id'] as String?,
    accepted: raw['accepted'] != false,
    driverStarted: raw['driver_started'] is bool
        ? raw['driver_started'] as bool
        : null,
  );
}

final class RoomLogEvent {
  const RoomLogEvent({
    required this.seq,
    required this.eventId,
    required this.kind,
    this.actor = '',
  });

  final int seq;
  final String eventId;
  final String kind;
  final String actor;

  factory RoomLogEvent.fromJson(Map raw) => RoomLogEvent(
    seq: (raw['seq'] as num?)?.toInt() ?? 0,
    eventId: raw['event_id'] as String? ?? '',
    kind: raw['kind'] as String? ?? '',
    actor: raw['actor'] is Map
        ? raw['actor']['id'] as String? ?? ''
        : raw['actor'] as String? ?? '',
  );
}

final class RoomLog {
  const RoomLog({
    required this.events,
    required this.cursor,
    required this.latestSeq,
    required this.hasMore,
  });

  final List<RoomLogEvent> events;
  final int cursor;
  final int latestSeq;
  final bool hasMore;

  factory RoomLog.fromJson(Map raw) {
    final events = raw['events'];
    if (events is! List) _fail(WorkspaceFailure.invalid);
    return RoomLog(
      events: List.unmodifiable(
        events.whereType<Map>().map(RoomLogEvent.fromJson).toList(),
      ),
      cursor: (raw['cursor'] as num?)?.toInt() ?? 0,
      latestSeq: (raw['latest_seq'] as num?)?.toInt() ?? 0,
      hasMore: raw['has_more'] == true,
    );
  }
}

final class DisplayLease {
  const DisplayLease({
    required this.holder,
    required this.viewerHash,
    required this.since,
    required this.epoch,
    required this.reason,
  });

  final String holder; // 'agent' | 'human'
  final String? viewerHash;
  final double since;
  final int epoch;
  final String reason;

  bool get isAgent => holder == 'agent';

  factory DisplayLease.fromJson(Map raw) {
    final holder = raw['holder'];
    if (holder is! String || (holder != 'agent' && holder != 'human')) {
      _fail(WorkspaceFailure.invalid);
    }
    return DisplayLease(
      holder: holder,
      viewerHash: raw['viewer_hash'] as String?,
      since: (raw['since'] as num?)?.toDouble() ?? 0.0,
      epoch: (raw['epoch'] as num?)?.toInt() ?? 0,
      reason: raw['reason'] as String? ?? '',
    );
  }

  static DisplayLease agent() => const DisplayLease(
    holder: 'agent',
    viewerHash: null,
    since: 0,
    epoch: 0,
    reason: '',
  );
}

final class DisplayStatus {
  const DisplayStatus({
    required this.profile,
    required this.supported,
    required this.installed,
    required this.missing,
    required this.running,
    this.pid,
    this.geometry = '',
    this.placement = 'gateway',
    this.blocker,
    this.memoryAvailableMb,
    this.memoryLimitMb,
    this.imageSwitch,
    required this.lease,
    this.profileKey,
  });

  final String profile;
  final bool supported;
  final bool installed;
  final List<String> missing;
  final bool running;
  final int? pid;
  final String geometry;
  final String placement;
  final String? blocker;
  final int? memoryAvailableMb;
  final int? memoryLimitMb;
  final Map<String, dynamic>? imageSwitch;
  final DisplayLease lease;
  final String? profileKey;

  factory DisplayStatus.fromJson(Map raw) {
    final missing = raw['missing'];
    return DisplayStatus(
      profile: raw['profile'] as String? ?? '',
      supported: raw['supported'] == true,
      installed: raw['installed'] == true,
      missing: missing is List
          ? List<String>.from(missing.whereType<String>())
          : const [],
      running: raw['running'] == true,
      pid: (raw['pid'] as num?)?.toInt(),
      geometry: raw['geometry'] as String? ?? '',
      placement: raw['placement'] as String? ?? 'gateway',
      blocker: raw['blocker'] as String?,
      memoryAvailableMb: (raw['memory_available_mb'] as num?)?.toInt(),
      memoryLimitMb: (raw['memory_limit_mb'] as num?)?.toInt(),
      imageSwitch: raw['image_switch'] is Map
          ? Map<String, dynamic>.from(raw['image_switch'] as Map)
          : null,
      lease: raw['lease'] is Map
          ? DisplayLease.fromJson(raw['lease'] as Map)
          : DisplayLease.agent(),
      profileKey: raw['profile_key'] as String?,
    );
  }
}

final class DisplayObserveResult {
  const DisplayObserveResult({
    required this.status,
    required this.ticket,
    required this.path,
    required this.viewerId,
  });

  final DisplayStatus status;
  final String ticket;
  final String path;
  final String viewerId;

  factory DisplayObserveResult.fromJson(Map raw) {
    return DisplayObserveResult(
      status: DisplayStatus.fromJson(raw),
      ticket: raw['ticket'] as String? ?? '',
      path: raw['path'] as String? ?? '/api/display/ws',
      viewerId: raw['viewer_id'] as String? ?? '',
    );
  }
}

final class DisplayThumbnail {
  const DisplayThumbnail({this.dataUrl, this.suppressed, this.bytes});

  /// The frame as the gateway sends it: a `data:image/jpeg;base64,...` URL.
  final String? dataUrl;
  final String? suppressed;

  /// The image decoded from [dataUrl], or null when there is no frame or it
  /// is not a bounded image. A `data:` URL is decoded here; no HTTP client
  /// can fetch one (dart:io refuses a URI without a host).
  final Uint8List? bytes;

  /// A thumbnail is a small JPEG; anything past this is not one.
  static const maxBytes = 4 * 1024 * 1024;

  static Uint8List? decode(String? dataUrl) {
    if (dataUrl == null ||
        !dataUrl.startsWith('data:image/') ||
        // base64 carries 3 bytes in 4 characters.
        dataUrl.length > maxBytes ~/ 3 * 4 + 128) {
      return null;
    }
    try {
      final data = UriData.parse(dataUrl);
      if (!data.mimeType.startsWith('image/')) return null;
      final bytes = data.contentAsBytes();
      return bytes.isEmpty || bytes.length > maxBytes ? null : bytes;
    } on FormatException {
      return null;
    }
  }

  factory DisplayThumbnail.fromJson(Map raw) {
    final dataUrl = raw['data_url'] as String?;
    return DisplayThumbnail(
      dataUrl: dataUrl,
      suppressed: raw['suppressed'] as String?,
      bytes: decode(dataUrl),
    );
  }
}

extension WorkspaceBots on WorkspaceTarget {
  /// Launch-home scoped JSON-RPC call (no `profile` param). Refusals are mapped
  /// through the same fences as workspace calls.
  Future<Map<String, dynamic>> _rpcLaunch(
    String method,
    Map<String, dynamic> params,
  ) => _guard(checkCurrent, () async {
    checkCurrent();
    final response = await _socket.send(method, params, includeProfile: false);
    checkCurrent();
    final error = response['error'];
    if (error != null) {
      if (error is Map && error['code'] == -32601) {
        _fail(WorkspaceFailure.unsupported);
      }
      if (error is Map && const {401, 403}.contains(error['code'])) {
        _fail(WorkspaceFailure.denied);
      }
      _fail(WorkspaceFailure.unavailable);
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) _fail(WorkspaceFailure.invalid);
    return result;
  });

  /// Target-profile scoped JSON-RPC call (profile param rewritten to the bot).
  Future<Map<String, dynamic>> _rpcBot(
    String? profile,
    String method,
    Map<String, dynamic> params,
  ) => _guard(checkCurrent, () async {
    checkCurrent();
    final response = await _socket.send(method, {
      ...params,
      'profile': ?profile,
    }, includeProfile: false);
    checkCurrent();
    final error = response['error'];
    if (error != null) {
      if (error is Map && error['code'] == -32601) {
        _fail(WorkspaceFailure.unsupported);
      }
      if (error is Map && const {401, 403}.contains(error['code'])) {
        _fail(WorkspaceFailure.denied);
      }
      _fail(WorkspaceFailure.unavailable);
    }
    final result = response['result'];
    if (result is! Map<String, dynamic>) _fail(WorkspaceFailure.invalid);
    return result;
  });

  // ── Roster ─────────────────────────────────────────────────────────────

  Future<BotRoster> botRoster({bool includeSessions = true}) async {
    final raw = await _rpcLaunch('profiles.list', {
      'include_sessions': includeSessions,
    });
    return BotRoster.fromJson(raw);
  }

  // ── Canonical bot chat ─────────────────────────────────────────────────

  /// Fail-closed find of the canonical "Bot Chat": returns the stored session
  /// id of the first live row titled "Bot Chat", or null when the gateway
  /// confirms there is none (zero rows, not an error).
  Future<String?> findCanonicalChat(String profile) async {
    final raw = await _rpcBot(profile, 'session.list', {
      'title': botCanonicalChatTitle,
      'limit': 200,
      'include_hidden': true,
    });
    final sessions = raw['sessions'];
    if (sessions is! List) _fail(WorkspaceFailure.invalid);
    for (final row in sessions) {
      if (row is! Map) continue;
      final title = row['title'];
      if (title is String && title.trim() == botCanonicalChatTitle.trim()) {
        final id = row['id'] ?? row['session_id'];
        if (id is String && id.trim().isNotEmpty) return id.trim();
      }
    }
    return null;
  }

  /// Create the canonical "Bot Chat" chat for [profile] and title it. Used
  /// only when a find-first proves the chat absent.
  Future<CanonicalChat> createCanonicalChat(String profile) async {
    final raw = await _rpcBot(profile, 'session.create', {
      'title': botCanonicalChatTitle,
      'hidden': true,
      'follow_profile_config': true,
      'source': 'desktop',
    });
    final stored = raw['stored_session_id'] ?? raw['session_id'];
    final runtime = raw['session_id'] ?? raw['stored_session_id'];
    if (stored is! String || stored.trim().isEmpty) {
      _fail(WorkspaceFailure.unavailable);
    }
    if (runtime is String && runtime.trim().isNotEmpty && runtime != stored) {
      try {
        await _rpcBot(profile, 'session.title', {
          'session_id': runtime,
          'title': botCanonicalChatTitle,
        });
      } catch (_) {
        // Older gateways may reject the eager write; the kickoff path is not
        // part of this mint and the chat is still usable.
      }
    }
    return CanonicalChat(
      profile: profile,
      sessionId: stored.trim(),
      title: botCanonicalChatTitle,
      minted: true,
    );
  }

  /// Find-first, minting only on explicit absence. Never mints on a probe
  /// error: an unknown outcome stays unknown (no duplicate chats).
  Future<CanonicalChat> resolveCanonicalChat(String profile) async {
    final found = await findCanonicalChat(profile);
    if (found != null) {
      return CanonicalChat(
        profile: profile,
        sessionId: found,
        title: botCanonicalChatTitle,
        minted: false,
      );
    }
    return createCanonicalChat(profile);
  }

  // ── Routines (per-bot cron) ─────────────────────────────────────────────

  Future<({List<RoutineJob> jobs, String? scoped})> botRoutines(
    String profile,
  ) async {
    final raw = await _rpcBot(profile, 'cron.manage', {
      'action': 'list',
      'include_disabled': true,
    });
    final jobs = raw['jobs'];
    final scoped = raw['scoped'] as String?;
    if (jobs is! List) _fail(WorkspaceFailure.invalid);
    final List<RoutineJob> parsed = <RoutineJob>[
      for (final item in jobs)
        if (item is Map) RoutineJob.fromJson(item),
    ];
    return (jobs: List<RoutineJob>.unmodifiable(parsed), scoped: scoped);
  }

  /// Force-pauses legacy delegated routines on load and returns the cleaned list.
  Future<({List<RoutineJob> jobs, String? scoped})> botRoutinesWithLegacyPause(
    String profile,
  ) async {
    final raw = await botRoutines(profile);
    final pausedIds = <String>{};
    await Future.wait([
      for (final job in raw.jobs)
        if (job.isLegacyDelegated && job.enabled)
          () async {
            try {
              await _rpcBot(profile, 'cron.manage', {
                'action': 'pause',
                'name': job.jobId,
              });
              pausedIds.add(job.jobId);
            } catch (_) {
              // Each pause swallows its own error; the next poll retries.
            }
          }(),
    ]);
    if (pausedIds.isEmpty) return raw;
    final List<RoutineJob> jobs = [
      for (final job in raw.jobs)
        if (pausedIds.contains(job.jobId))
          RoutineJob(
            jobId: job.jobId,
            name: job.name,
            schedule: job.schedule,
            nextRunAt: job.nextRunAt,
            lastRunAt: job.lastRunAt,
            lastStatus: job.lastStatus,
            lastError: job.lastError,
            enabled: false,
            state: 'paused',
            repeat: job.repeat,
            promptPreview: job.promptPreview,
            deliver: job.deliver,
          )
        else
          job,
    ];
    return (jobs: List<RoutineJob>.unmodifiable(jobs), scoped: raw.scoped);
  }

  Future<RoutineJob> botRoutineAdd({
    required String profile,
    required String title,
    required String schedule,
    required String instruction,

    /// How many runs before the gateway retires the job (`cronjob_tools.py`:
    /// "Optional repeat count"). Null sends nothing: a recurring schedule
    /// then runs forever, a one-shot runs once.
    int? repeat,

    /// Each run continues from the previous run's session.
    bool continuity = false,

    /// Posts each run's output into the bot's own Bot Chat (one agent turn
    /// per run). Off leaves the output in the run's own history.
    bool deliverToBotChat = false,
  }) async {
    final bot = profile;
    final raw = await _rpcBot(profile, 'cron.manage', {
      'action': 'add',
      'name': '[bot:$bot] $title',
      'schedule': schedule,
      'prompt': instruction,
      if (repeat != null && repeat > 0) 'repeat': repeat,
      if (continuity) 'continuity': true,
      if (deliverToBotChat) 'deliver': 'bot-chat',
    });
    final job = raw['job'] ?? raw['job_id'];
    if (job is Map) return RoutineJob.fromJson(job);
    if (job is String) {
      // The gateway created the job but returned only an id; resolve it.
      final listed = await botRoutines(profile);
      for (final j in listed.jobs) {
        if (j.jobId == job || job == j.name) return j;
      }
      return RoutineJob(
        jobId: job,
        name: '[bot:$bot] $title',
        schedule: schedule,
      );
    }
    final jobId = raw['job_id'] ?? raw['id'];
    if (jobId is String && jobId.isNotEmpty) {
      return RoutineJob(
        jobId: jobId,
        name: '[bot:$bot] $title',
        schedule: schedule,
      );
    }
    _fail(WorkspaceFailure.invalid);
  }

  Future<void> botRoutinePause(String profile, String jobId) => _guard(
    checkCurrent,
    () async {
      await _rpcBot(profile, 'cron.manage', {'action': 'pause', 'name': jobId});
    },
  );

  Future<void> botRoutineResume(String profile, String jobId) =>
      _guard(checkCurrent, () async {
        await _rpcBot(profile, 'cron.manage', {
          'action': 'resume',
          'name': jobId,
        });
      });

  Future<void> botRoutineRemove(String profile, String jobId) =>
      _guard(checkCurrent, () async {
        await _rpcBot(profile, 'cron.manage', {
          'action': 'remove',
          'name': jobId,
        });
      });

  // ── Multi-bot rooms ──────────────────────────────────────────────────────

  Future<RoomCapabilities> roomCapabilities() async {
    final raw = await _rpcLaunch('groups.capabilities', {});
    return RoomCapabilities.fromJson(raw);
  }

  Future<List<RoomSummary>> roomList({
    bool includeDisbanded = false,
    int limit = 50,
    int offset = 0,
  }) async {
    final raw = await _rpcLaunch('groups.list', {
      'include_disbanded': includeDisbanded,
      'limit': limit,
      'offset': offset,
    });
    final rooms = raw['rooms'];
    if (rooms is! List) _fail(WorkspaceFailure.invalid);
    return List.unmodifiable(rooms.whereType<Map>().map(RoomSummary.fromJson));
  }

  Future<RoomReadResult> roomState(String roomId) async {
    final raw = await _rpcLaunch('groups.state', {'room_id': roomId});
    return RoomReadResult.fromJson(raw);
  }

  Future<RoomSummary> roomCreate({
    required String roomId,
    required String name,
    required List<RoomMember> members,
  }) async {
    final raw = await _rpcLaunch('groups.create', {
      'room_id': roomId,
      'name': name,
      'members': [
        for (final m in members)
          {
            'member_id': m.memberId,
            'profile': m.profile,
            if (m.handle.isNotEmpty) 'handle': m.handle,
            if (m.displayName.isNotEmpty) 'display_name': m.displayName,
            'target': ?m.target,
          },
      ],
    });
    final room = raw['room'];
    if (room is! Map) _fail(WorkspaceFailure.invalid);
    return RoomSummary.fromJson(room);
  }

  Future<RoomSummary> roomRename(
    String roomId,
    String eventId,
    String name,
  ) async {
    final raw = await _rpcLaunch('groups.rename', {
      'room_id': roomId,
      'event_id': eventId,
      'name': name,
    });
    final room = raw['room'];
    if (room is! Map) _fail(WorkspaceFailure.invalid);
    return RoomSummary.fromJson(room);
  }

  Future<RoomSendResult> roomSend(
    String roomId,
    Map<String, dynamic> payload, {
    String? eventId,
  }) async {
    final raw = await _rpcLaunch('groups.send', {
      'room_id': roomId,
      'event_id': ?eventId,
      'payload': payload,
    });
    return RoomSendResult.fromJson(raw);
  }

  Future<RoomContext> roomContext(
    String roomId, {
    required String eventId,
    required String purpose,
    required String notes,
    String routing = 'everyone',
    String leadMemberId = '',
  }) async {
    final raw = await _rpcLaunch('groups.context', {
      'room_id': roomId,
      'event_id': eventId,
      'purpose': purpose,
      'notes': notes,
      'routing': routing,
      if (leadMemberId.isNotEmpty) 'lead_member_id': leadMemberId,
    });
    final context = raw['context'];
    if (context is! Map) _fail(WorkspaceFailure.invalid);
    return RoomContext.fromJson(context);
  }

  Future<RoomLog> roomLog(
    String roomId, {
    int? sinceSeq,
    int limit = 100,
  }) async {
    final raw = await _rpcLaunch('groups.log', {
      'room_id': roomId,
      'since_seq': ?sinceSeq,
      'limit': limit,
    });
    return RoomLog.fromJson(raw);
  }

  Future<int> roomStop(String roomId) async {
    final raw = await _rpcLaunch('groups.stop', {'room_id': roomId});
    return (raw['cancelled'] as num?)?.toInt() ?? 0;
  }

  // ── Bot Desktop ───────────────────────────────────────────────────────

  Future<DisplayStatus> displayStatus(String? profile) async {
    final raw = await _rpcBot(profile, 'display.status', {});
    return DisplayStatus.fromJson(raw);
  }

  Future<DisplayStatus> displayStart(String? profile) async {
    final raw = await _rpcBot(profile, 'display.start', {});
    return DisplayStatus.fromJson(raw);
  }

  Future<DisplayStatus> displayStop(
    String? profile, {
    bool force = false,
  }) async {
    final raw = await _rpcBot(profile, 'display.stop', {
      if (force) 'force': true,
    });
    return DisplayStatus.fromJson(raw);
  }

  Future<DisplayObserveResult> displayObserve(
    String? profile, {
    String? viewerId,
  }) async {
    final raw = await _rpcBot(profile, 'display.observe', {
      'viewer_id': ?viewerId,
    });
    return DisplayObserveResult.fromJson(raw);
  }

  /// The live screen for one `display.observe` ticket (single use, 30 s):
  /// raw RFB over `/api/display/ws`, same origin, no redirects.
  Future<BotDisplayChannel> openDisplayChannel(DisplayObserveResult observe) =>
      _guard(checkCurrent, () async {
        final socket = await _owner._dashboard.openBotDisplaySocket(
          displayTicket: observe.ticket,
          check: checkCurrent,
        );
        return WebSocketDisplayChannel(socket);
      });

  Future<DisplayThumbnail> displayThumbnail(String? profile) async {
    final raw = await _rpcBot(profile, 'display.thumbnail', {});
    return DisplayThumbnail.fromJson(raw);
  }

  /// Kick off the gateway's install flow and report the command it launched.
  Future<({bool started, String? command, String? profileKey})> displayInstall(
    String? profile,
  ) async {
    final raw = await _rpcBot(profile, 'display.install', {});
    return (
      started: raw['started'] == true,
      command: raw['command'] as String?,
      profileKey: raw['profile_key'] as String?,
    );
  }

  Future<DisplayLease> displayLeaseAcquire(
    String? profile,
    String viewerId, {
    String? reason,
  }) async {
    final raw = await _rpcBot(profile, 'display.lease.acquire', {
      'viewer_id': viewerId,
      'reason': ?reason,
    });
    final lease = raw['lease'];
    if (lease is! Map) _fail(WorkspaceFailure.invalid);
    return DisplayLease.fromJson(lease);
  }

  Future<DisplayLease> displayLeaseRelease(
    String? profile, {
    String? viewerId,
    bool force = false,
  }) async {
    final raw = await _rpcBot(profile, 'display.lease.release', {
      'viewer_id': ?viewerId,
      if (force) 'force': true,
    });
    final lease = raw['lease'];
    if (lease is! Map) _fail(WorkspaceFailure.invalid);
    return DisplayLease.fromJson(lease);
  }

  Future<DisplayStatus> displaySwitchSandboxImage(
    String? profile, {
    bool approve = true,
  }) async {
    final raw = await _rpcBot(profile, 'display.switchSandboxImage', {
      'approve': approve,
    });
    return DisplayStatus.fromJson(raw);
  }
}

const botCanonicalChatTitle = 'Bot Chat';
