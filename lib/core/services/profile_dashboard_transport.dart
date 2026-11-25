part of 'connection_manager.dart';

/// Closed catalogue: @ is the transport's own canonical profile, # is a
/// single opaque path component. Neither the caller nor a server response can
/// select an HTTP method, origin or arbitrary endpoint.
enum ProfileDashboardOp {
  rename('PATCH', 'profiles/@'),
  remove('DELETE', 'profiles/@'),
  soul('GET', 'profiles/@/soul'),
  saveSoul('PUT', 'profiles/@/soul'),
  export('POST', 'profiles/@/export'),
  importArchive('POST', 'profiles/import'),
  channels('GET', 'messaging/platforms'),
  channel('PUT', 'messaging/platforms/#'),
  pairs('GET', 'pairing'),
  approve('POST', 'pairing/approve'),
  revoke('POST', 'pairing/revoke'),
  telegramStart('POST', 'messaging/telegram/onboarding/start'),
  telegramStatus('GET', 'messaging/telegram/onboarding/#'),
  telegramApply('POST', 'messaging/telegram/onboarding/#/apply'),
  telegramCancel('DELETE', 'messaging/telegram/onboarding/#'),
  hooks('GET', 'webhooks'),
  enableHooks('POST', 'webhooks/enable'),
  createHook('POST', 'webhooks'),
  toggleHook('PUT', 'webhooks/#/enabled'),
  deleteHook('DELETE', 'webhooks/#'),
  backup('POST', 'ops/backup'),
  backupStatus('GET', 'actions/backup/status');

  const ProfileDashboardOp(this.method, this.template);
  final String method, template;
}

extension ProfileDashboardTransport on DashboardClient {
  Future<Object?> profileOperation(
    ProfileDashboardOp op, {
    required void Function() check,
    String? key,
    Map<String, Object?>? fields,
  }) {
    final profile = gatewayProfile;
    if (profile == null ||
        profile == 'current' ||
        !RegExp(r'^[a-z0-9][a-z0-9_-]{0,63}$').hasMatch(profile) ||
        fields?.containsKey('profile') == true) {
      throw const FormatException('Invalid profile scope');
    }
    final bodyScope = const {
      ProfileDashboardOp.approve,
      ProfileDashboardOp.revoke,
      ProfileDashboardOp.telegramApply,
    }.contains(op);
    return _workspaceExchange(
      [
        for (final segment in op.template.split('/'))
          switch (segment) {
            '@' => profile,
            '#' => key ?? '',
            _ => segment,
          },
      ],
      query: {
        'profile': profile,
        if (op == ProfileDashboardOp.backupStatus) 'lines': '1',
      },
      method: op.method,
      check: check,
      body: bodyScope ? {...?fields, 'profile': profile} : fields,
    );
  }
}
