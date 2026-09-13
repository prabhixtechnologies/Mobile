class AuthMe {
  AuthMe({
    required this.id,
    required this.email,
    required this.displayName,
    this.organizations = const [],
    this.permissions = const {},
    this.features = const {},
    this.platformAdmin = false,
    this.systemAdmin = false,
    this.selectedOrganizationId,
    this.paymentRequired = false,
    this.catalogOnly = false,
  });

  final String id;
  final String email;
  final String displayName;
  final List<OrganizationSummary> organizations;
  final Set<String> permissions;
  final Set<String> features;
  final bool platformAdmin;
  final bool systemAdmin;
  final String? selectedOrganizationId;
  final bool paymentRequired;
  final bool catalogOnly;

  bool hasFeature(String code) =>
      systemAdmin || platformAdmin || features.contains(code);

  factory AuthMe.fromJson(Map<String, dynamic> json) {
    var orgs = _asMapList(json['organizations'])
        .map(OrganizationSummary.fromJson)
        .toList();
    // MobiStack /auth/me uses shopId/workspaceId instead of organizations[].
    if (orgs.isEmpty) {
      final shopId = json['shopId'] ?? json['workspaceId'];
      if (shopId != null) {
        orgs = [
          OrganizationSummary(
            id: '$shopId',
            name: '${json['shopName'] ?? json['workspaceName'] ?? 'Workspace'}',
          ),
        ];
      }
    }
    final perms = _asStringSet(json['permissions'] ?? json['permissionSet']);
    final feats = _asStringSet(json['features']);
    return AuthMe(
      id: '${json['id'] ?? json['userId'] ?? ''}',
      email: '${json['email'] ?? ''}',
      displayName: '${json['displayName'] ?? json['fullName'] ?? json['name'] ?? ''}',
      organizations: orgs,
      permissions: perms,
      features: feats,
      platformAdmin: json['platformAdmin'] == true,
      systemAdmin: json['systemAdmin'] == true || json['platformAdmin'] == true,
      selectedOrganizationId: _nullIfBlank(
        json['selectedOrganizationId']?.toString() ??
            json['organizationId']?.toString() ??
            json['workspaceId']?.toString() ??
            json['shopId']?.toString(),
      ),
      paymentRequired: json['paymentRequired'] == true,
      catalogOnly: json['catalogOnly'] == true,
    );
  }
}

class OrganizationSummary {
  OrganizationSummary({
    required this.id,
    required this.name,
    this.slug,
  });

  final String id;
  final String name;
  final String? slug;

  factory OrganizationSummary.fromJson(Map<String, dynamic> json) {
    return OrganizationSummary(
      id: '${json['id']}',
      name: '${json['name'] ?? json['displayName'] ?? ''}',
      slug: json['slug']?.toString(),
    );
  }
}

/// Matches OpsDtos.PlatformOverview — nested sections, not flat KPI fields.
class PlatformOverview {
  PlatformOverview({
    this.tenants = const TenantCounts(),
    this.accounts = const AccountCounts(),
    this.queues = const QueueDepths(),
    this.activity = const ActivityCounts(),
    this.generatedAt,
  });

  final TenantCounts tenants;
  final AccountCounts accounts;
  final QueueDepths queues;
  final ActivityCounts activity;
  final String? generatedAt;

  int get tenantCount => tenants.total;
  int get accountCount => accounts.total;
  int get openChatBacklog => 0; // chat backlog is not on this DTO
  int get openMailBacklog => queues.mailPending;
  int get eventsLast24h => activity.errorsLast24h + activity.securityEventsLast24h;

  factory PlatformOverview.fromJson(Map<String, dynamic> json) {
    return PlatformOverview(
      tenants: TenantCounts.fromJson(_asMap(json['tenants'])),
      accounts: AccountCounts.fromJson(_asMap(json['accounts'])),
      queues: QueueDepths.fromJson(_asMap(json['queues'])),
      activity: ActivityCounts.fromJson(_asMap(json['activity'])),
      generatedAt: json['generatedAt']?.toString(),
    );
  }
}

class TenantCounts {
  const TenantCounts({
    this.total = 0,
    this.active = 0,
    this.trial = 0,
    this.suspended = 0,
    this.cancelled = 0,
    this.createdLast30Days = 0,
  });

  final int total;
  final int active;
  final int trial;
  final int suspended;
  final int cancelled;
  final int createdLast30Days;

  factory TenantCounts.fromJson(Map<String, dynamic> json) => TenantCounts(
        total: _int(json['total']),
        active: _int(json['active']),
        trial: _int(json['trial']),
        suspended: _int(json['suspended']),
        cancelled: _int(json['cancelled']),
        createdLast30Days: _int(json['createdLast30Days']),
      );
}

class AccountCounts {
  const AccountCounts({
    this.total = 0,
    this.active = 0,
    this.invited = 0,
    this.disabled = 0,
    this.lockedOut = 0,
    this.platformAdmins = 0,
    this.createdLast30Days = 0,
  });

  final int total;
  final int active;
  final int invited;
  final int disabled;
  final int lockedOut;
  final int platformAdmins;
  final int createdLast30Days;

  factory AccountCounts.fromJson(Map<String, dynamic> json) => AccountCounts(
        total: _int(json['total']),
        active: _int(json['active']),
        invited: _int(json['invited']),
        disabled: _int(json['disabled']),
        lockedOut: _int(json['lockedOut']),
        platformAdmins: _int(json['platformAdmins']),
        createdLast30Days: _int(json['createdLast30Days']),
      );
}

class QueueDepths {
  const QueueDepths({
    this.mailPending = 0,
    this.mailFailed = 0,
    this.activeSessions = 0,
  });

  final int mailPending;
  final int mailFailed;
  final int activeSessions;

  factory QueueDepths.fromJson(Map<String, dynamic> json) => QueueDepths(
        mailPending: _int(json['mailPending']),
        mailFailed: _int(json['mailFailed']),
        activeSessions: _int(json['activeSessions']),
      );
}

class ActivityCounts {
  const ActivityCounts({
    this.errorsLast24h = 0,
    this.securityEventsLast24h = 0,
  });

  final int errorsLast24h;
  final int securityEventsLast24h;

  factory ActivityCounts.fromJson(Map<String, dynamic> json) => ActivityCounts(
        errorsLast24h: _int(json['errorsLast24h']),
        securityEventsLast24h: _int(json['securityEventsLast24h']),
      );
}

class TenantSummary {
  TenantSummary({
    required this.id,
    required this.name,
    this.slug,
    this.status,
    this.plan,
    this.memberCount,
    this.seatLimit,
    this.trialEndsAt,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? slug;
  final String? status;
  final String? plan;
  final int? memberCount;
  final int? seatLimit;
  final String? trialEndsAt;
  final String? createdAt;

  factory TenantSummary.fromJson(Map<String, dynamic> json) {
    return TenantSummary(
      id: '${json['id']}',
      name: '${json['name'] ?? ''}',
      slug: json['slug']?.toString(),
      status: json['status']?.toString(),
      plan: json['plan']?.toString() ?? json['planName']?.toString(),
      memberCount: _intOrNull(json['memberCount']),
      seatLimit: _intOrNull(json['seatLimit']),
      trialEndsAt: json['trialEndsAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class SiteLead {
  SiteLead({
    required this.id,
    required this.name,
    this.email,
    this.company,
    this.status,
    this.createdAt,
    this.internalNotes,
  });

  final String id;
  final String name;
  final String? email;
  final String? company;
  final String? status;
  final String? createdAt;
  final String? internalNotes;

  factory SiteLead.fromJson(Map<String, dynamic> json) => SiteLead(
        id: '${json['id']}',
        name: '${json['name'] ?? json['fullName'] ?? json['email'] ?? 'Lead'}',
        email: json['email']?.toString(),
        company: json['company']?.toString() ?? json['organization']?.toString(),
        status: json['status']?.toString(),
        createdAt: json['createdAt']?.toString(),
        internalNotes: json['internalNotes']?.toString(),
      );
}

class SiteSubscriber {
  SiteSubscriber({
    required this.id,
    required this.email,
    this.status,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? status;
  final String? createdAt;

  factory SiteSubscriber.fromJson(Map<String, dynamic> json) => SiteSubscriber(
        id: '${json['id']}',
        email: '${json['email'] ?? ''}',
        status: json['status']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

class SiteApplication {
  SiteApplication({
    required this.id,
    required this.name,
    this.email,
    this.status,
    this.createdAt,
    this.internalNotes,
  });

  final String id;
  final String name;
  final String? email;
  final String? status;
  final String? createdAt;
  final String? internalNotes;

  factory SiteApplication.fromJson(Map<String, dynamic> json) => SiteApplication(
        id: '${json['id']}',
        name: '${json['name'] ?? json['companyName'] ?? json['email'] ?? 'Application'}',
        email: json['email']?.toString(),
        status: json['status']?.toString(),
        createdAt: json['createdAt']?.toString(),
        internalNotes: json['internalNotes']?.toString(),
      );
}

class EventLogSummary {
  EventLogSummary({
    required this.id,
    required this.message,
    this.level,
    this.organizationId,
    this.createdAt,
    this.correlationId,
  });

  final String id;
  final String message;
  final String? level;
  final String? organizationId;
  final String? createdAt;
  final String? correlationId;

  factory EventLogSummary.fromJson(Map<String, dynamic> json) => EventLogSummary(
        id: '${json['id']}',
        message: '${json['message'] ?? json['summary'] ?? json['action'] ?? 'Event'}',
        level: json['level']?.toString() ?? json['severity']?.toString(),
        organizationId: json['organizationId']?.toString(),
        createdAt: json['createdAt']?.toString() ?? json['occurredAt']?.toString(),
        correlationId: json['correlationId']?.toString() ?? json['traceId']?.toString(),
      );
}

class CursorPage<T> {
  CursorPage({required this.items, this.nextCursor, this.hasMore = false});

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

Set<String> _asStringSet(dynamic value) {
  if (value is! List) return {};
  return value.map((e) => '$e').toSet();
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

int? _intOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

String? _nullIfBlank(String? value) {
  if (value == null || value.isEmpty || value == 'null') return null;
  return value;
}
