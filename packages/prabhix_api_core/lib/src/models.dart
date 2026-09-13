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
    this.planCode,
    this.planName,
    this.periodEnd,
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
  final String? planCode;
  final String? planName;
  final String? periodEnd;

  bool hasFeature(String code) =>
      systemAdmin || platformAdmin || features.contains(code);

  bool hasPermission(String code) =>
      systemAdmin || platformAdmin || permissions.contains(code);

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
      displayName:
          '${json['displayName'] ?? json['fullName'] ?? json['name'] ?? ''}',
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
      planCode: _nullIfBlank(json['planCode']?.toString()),
      planName: _nullIfBlank(json['planName']?.toString()),
      periodEnd: _nullIfBlank(json['periodEnd']?.toString()),
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

// --- MobiStack billing ---

class BillingPlan {
  BillingPlan({
    required this.code,
    required this.name,
    required this.amount,
    this.description,
    this.interval,
    this.features = const [],
  });

  final String code;
  final String name;
  final double amount;
  final String? description;
  final String? interval;
  final List<String> features;

  factory BillingPlan.fromJson(Map<String, dynamic> json) => BillingPlan(
        code: '${json['code']}',
        name: '${json['name'] ?? json['code']}',
        amount: (json['amount'] is num)
            ? (json['amount'] as num).toDouble()
            : double.tryParse('${json['amount']}') ?? 0,
        description: json['description']?.toString(),
        interval: json['interval']?.toString(),
        features: _asStringSet(json['features']).toList(),
      );
}

class BillingSubscription {
  BillingSubscription({
    this.planCode,
    this.planName,
    this.status,
    this.periodEnd,
    this.features = const [],
  });

  final String? planCode;
  final String? planName;
  final String? status;
  final String? periodEnd;
  final List<String> features;

  factory BillingSubscription.fromJson(Map<String, dynamic> json) =>
      BillingSubscription(
        planCode: json['planCode']?.toString(),
        planName: json['planName']?.toString(),
        status: json['status']?.toString(),
        periodEnd: json['periodEnd']?.toString(),
        features: _asStringSet(json['features']).toList(),
      );
}

class BillingScreens {
  BillingScreens({
    this.included = 0,
    this.extra = 0,
    this.seats = 0,
    this.inUse = 0,
  });

  final int included;
  final int extra;
  final int seats;
  final int inUse;

  factory BillingScreens.fromJson(Map<String, dynamic> json) => BillingScreens(
        included: _int(json['included']),
        extra: _int(json['extra']),
        seats: _int(json['seats']),
        inUse: _int(json['inUse']),
      );
}

class BillingPayment {
  BillingPayment({
    required this.id,
    required this.amount,
    this.planName,
    this.status,
  });

  final String id;
  final double amount;
  final String? planName;
  final String? status;

  factory BillingPayment.fromJson(Map<String, dynamic> json) => BillingPayment(
        id: '${json['id']}',
        amount: (json['amount'] is num)
            ? (json['amount'] as num).toDouble()
            : double.tryParse('${json['amount']}') ?? 0,
        planName: json['planName']?.toString(),
        status: json['status']?.toString(),
      );
}

class BillingOverview {
  BillingOverview({
    this.plans = const [],
    this.subscription,
    this.screens,
    this.recentPayments = const [],
    this.razorpayKeyId,
    this.razorpayEnabled = false,
    this.paymentRequired = false,
  });

  final List<BillingPlan> plans;
  final BillingSubscription? subscription;
  final BillingScreens? screens;
  final List<BillingPayment> recentPayments;
  final String? razorpayKeyId;
  final bool razorpayEnabled;
  final bool paymentRequired;

  factory BillingOverview.fromJson(Map<String, dynamic> json) {
    return BillingOverview(
      plans: _asMapList(json['plans']).map(BillingPlan.fromJson).toList(),
      subscription: json['subscription'] is Map
          ? BillingSubscription.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map),
            )
          : null,
      screens: json['screens'] is Map
          ? BillingScreens.fromJson(
              Map<String, dynamic>.from(json['screens'] as Map),
            )
          : null,
      recentPayments: _asMapList(json['recentPayments'])
          .map(BillingPayment.fromJson)
          .toList(),
      razorpayKeyId: json['razorpayKeyId']?.toString(),
      razorpayEnabled: json['razorpayEnabled'] == true,
      paymentRequired: json['paymentRequired'] == true,
    );
  }
}

class CheckoutOrder {
  CheckoutOrder({
    required this.id,
    required this.amount,
    required this.currency,
    required this.gateway,
    this.orderId,
    this.keyId,
    this.priceCode,
    this.alreadyPaid = false,
  });

  final String id;
  final int amount; // paise for Razorpay
  final String currency;
  final String gateway;
  final String? orderId;
  final String? keyId;
  final String? priceCode;
  final bool alreadyPaid;

  bool get needsRazorpay =>
      keyId != null &&
      keyId!.isNotEmpty &&
      orderId != null &&
      orderId!.isNotEmpty &&
      gateway != 'DEV' &&
      gateway != 'PAID' &&
      !alreadyPaid;

  factory CheckoutOrder.fromJson(Map<String, dynamic> json) => CheckoutOrder(
        id: '${json['id']}',
        orderId: (json['order_id'] ?? json['orderId'])?.toString(),
        amount: _int(json['amount']),
        currency: '${json['currency'] ?? 'INR'}',
        keyId: json['keyId']?.toString(),
        priceCode: (json['priceCode'] ?? json['planCode'])?.toString(),
        gateway: '${json['gateway'] ?? 'RAZORPAY'}',
        alreadyPaid: json['alreadyPaid'] == true,
      );
}

class RazorpaySlip {
  RazorpaySlip({
    required this.orderId,
    required this.paymentId,
    required this.signature,
  });

  final String orderId;
  final String paymentId;
  final String signature;

  Map<String, dynamic> toJson() => {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      };
}

// --- Platform staff (oneOps) ---

class StaffGrant {
  StaffGrant({
    required this.id,
    required this.userId,
    required this.role,
    this.grantedAt,
    this.grantedBy,
    this.note,
  });

  final String id;
  final String userId;
  final String role;
  final String? grantedAt;
  final String? grantedBy;
  final String? note;

  factory StaffGrant.fromJson(Map<String, dynamic> json) => StaffGrant(
        id: '${json['id']}',
        userId: '${json['userId']}',
        role: '${json['role']}',
        grantedAt: json['grantedAt']?.toString(),
        grantedBy: json['grantedBy']?.toString(),
        note: json['note']?.toString(),
      );
}

// --- MobiStack admin ---

class AdminWorkspace {
  AdminWorkspace({
    required this.id,
    required this.name,
    this.city,
    this.active = true,
    this.members = 0,
    this.extraScreens = 0,
    this.screenSeats,
  });

  final String id;
  final String name;
  final String? city;
  final bool active;
  final int members;
  final int extraScreens;
  final int? screenSeats;

  factory AdminWorkspace.fromJson(Map<String, dynamic> json) => AdminWorkspace(
        id: '${json['id']}',
        name: '${json['name'] ?? ''}',
        city: json['city']?.toString(),
        active: json['active'] != false,
        members: _int(json['members']),
        extraScreens: _int(json['extraScreens']),
        screenSeats: json['screenSeats'] == null
            ? null
            : _int(json['screenSeats']),
      );
}

class AdminPayment {
  AdminPayment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.shopId,
    this.shopName,
    this.priceCode,
    this.gateway,
    this.paidAt,
  });

  final String id;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;
  final String? shopId;
  final String? shopName;
  final String? priceCode;
  final String? gateway;
  final String? paidAt;

  bool get captured =>
      status.toUpperCase() == 'CAPTURED' ||
      status.toUpperCase() == 'PAID' ||
      status.toUpperCase() == 'SUCCESS';

  factory AdminPayment.fromJson(Map<String, dynamic> json) => AdminPayment(
        id: '${json['id']}',
        shopId: json['shopId']?.toString(),
        shopName: json['shopName']?.toString(),
        priceCode: json['priceCode']?.toString(),
        amount: (json['amount'] is num)
            ? (json['amount'] as num).toDouble()
            : double.tryParse('${json['amount']}') ?? 0,
        currency: '${json['currency'] ?? 'INR'}',
        status: '${json['status'] ?? ''}',
        gateway: json['gateway']?.toString(),
        createdAt: '${json['createdAt'] ?? ''}',
        paidAt: json['paidAt']?.toString(),
      );
}

class AdminPlan {
  AdminPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.amount,
    required this.currency,
    required this.interval,
    this.description,
    this.sortOrder = 0,
    this.active = true,
    this.features = const [],
  });

  final String id;
  final String code;
  final String name;
  final double amount;
  final String currency;
  final String interval;
  final String? description;
  final int sortOrder;
  final bool active;
  final List<String> features;

  factory AdminPlan.fromJson(Map<String, dynamic> json) => AdminPlan(
        id: '${json['id']}',
        code: '${json['code'] ?? ''}',
        name: '${json['name'] ?? ''}',
        description: json['description']?.toString(),
        amount: (json['amount'] is num)
            ? (json['amount'] as num).toDouble()
            : double.tryParse('${json['amount']}') ?? 0,
        currency: '${json['currency'] ?? 'INR'}',
        interval: '${json['interval'] ?? ''}',
        sortOrder: _int(json['sortOrder']),
        active: json['active'] != false,
        features: _asStringSet(json['features']).toList(),
      );
}

class AdminFeatureFlag {
  AdminFeatureFlag({required this.code, required this.enabled});

  final String code;
  final bool enabled;

  factory AdminFeatureFlag.fromJson(Map<String, dynamic> json) =>
      AdminFeatureFlag(
        code: '${json['code']}',
        enabled: json['enabled'] == true,
      );
}

class AdminLiveUser {
  AdminLiveUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.deviceId,
    required this.platform,
    required this.seenAt,
    this.shopName,
    this.appVersion,
    this.ipAddress,
  });

  final String userId;
  final String fullName;
  final String email;
  final String deviceId;
  final String platform;
  final String seenAt;
  final String? shopName;
  final String? appVersion;
  final String? ipAddress;

  factory AdminLiveUser.fromJson(Map<String, dynamic> json) => AdminLiveUser(
        userId: '${json['userId']}',
        fullName: '${json['fullName'] ?? ''}',
        email: '${json['email'] ?? ''}',
        shopName: json['shopName']?.toString(),
        deviceId: '${json['deviceId'] ?? ''}',
        platform: '${json['platform'] ?? ''}',
        appVersion: json['appVersion']?.toString(),
        ipAddress: json['ipAddress']?.toString(),
        seenAt: '${json['seenAt'] ?? ''}',
      );
}

class AdminSupportTicket {
  AdminSupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.lastMessageAt,
    this.userName,
    this.messages = const [],
  });

  final String id;
  final String subject;
  final String status;
  final String lastMessageAt;
  final String? userName;
  final List<AdminSupportMessage> messages;

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) =>
      AdminSupportTicket(
        id: '${json['id']}',
        subject: '${json['subject'] ?? ''}',
        status: '${json['status'] ?? ''}',
        userName: json['userName']?.toString(),
        lastMessageAt: '${json['lastMessageAt'] ?? ''}',
        messages: _asMapList(json['messages'])
            .map(AdminSupportMessage.fromJson)
            .toList(),
      );
}

class AdminSupportMessage {
  AdminSupportMessage({
    required this.id,
    required this.authorType,
    required this.body,
  });

  final String id;
  final String authorType;
  final String body;

  factory AdminSupportMessage.fromJson(Map<String, dynamic> json) =>
      AdminSupportMessage(
        id: '${json['id']}',
        authorType: '${json['authorType'] ?? ''}',
        body: '${json['body'] ?? ''}',
      );
}

class AdminAppRelease {
  AdminAppRelease({
    required this.platform,
    required this.minNativeBuild,
    required this.latestNativeBuild,
    this.forceNativeUpdate = false,
    this.otaChannel = '',
    this.storeUrl,
    this.notes,
  });

  final String platform;
  final int minNativeBuild;
  final int latestNativeBuild;
  final bool forceNativeUpdate;
  final String otaChannel;
  final String? storeUrl;
  final String? notes;

  factory AdminAppRelease.fromJson(Map<String, dynamic> json) =>
      AdminAppRelease(
        platform: '${json['platform']}',
        minNativeBuild: _int(json['minNativeBuild']),
        latestNativeBuild: _int(json['latestNativeBuild']),
        forceNativeUpdate: json['forceNativeUpdate'] == true,
        otaChannel: '${json['otaChannel'] ?? ''}',
        storeUrl: json['storeUrl']?.toString(),
        notes: json['notes']?.toString(),
      );
}

class RevenueSnapshot {
  const RevenueSnapshot({
    this.capturedTotal = 0,
    this.pendingTotal = 0,
    this.capturedCount = 0,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.currency = 'INR',
    this.asOf,
  });

  final double capturedTotal;
  final double pendingTotal;
  final int capturedCount;
  final int pendingCount;
  final int failedCount;
  final String currency;
  final String? asOf;

  factory RevenueSnapshot.fromJson(Map<String, dynamic> json) => RevenueSnapshot(
        capturedTotal: (json['capturedTotal'] is num)
            ? (json['capturedTotal'] as num).toDouble()
            : double.tryParse('${json['capturedTotal']}') ?? 0,
        pendingTotal: (json['pendingTotal'] is num)
            ? (json['pendingTotal'] as num).toDouble()
            : double.tryParse('${json['pendingTotal']}') ?? 0,
        capturedCount: _int(json['capturedCount']),
        pendingCount: _int(json['pendingCount']),
        failedCount: _int(json['failedCount']),
        currency: '${json['currency'] ?? 'INR'}',
        asOf: json['asOf']?.toString(),
      );

  factory RevenueSnapshot.fromPayments(Iterable<AdminPayment> payments) {
    var captured = 0.0;
    var pending = 0.0;
    var capturedCount = 0;
    var pendingCount = 0;
    var failedCount = 0;
    for (final p in payments) {
      final status = p.status.toUpperCase();
      if (p.captured) {
        captured += p.amount;
        capturedCount++;
      } else if (status.contains('FAIL') ||
          status.contains('CANCEL') ||
          status == 'REFUNDED') {
        failedCount++;
      } else {
        pending += p.amount;
        pendingCount++;
      }
    }
    return RevenueSnapshot(
      capturedTotal: captured,
      pendingTotal: pending,
      capturedCount: capturedCount,
      pendingCount: pendingCount,
      failedCount: failedCount,
    );
  }
}

class AwsSummary {
  AwsSummary({
    this.mtdUsd = 0,
    this.running = 0,
    this.stopped = 0,
    this.other = 0,
    this.ok = true,
    this.error,
  });

  final double mtdUsd;
  final int running;
  final int stopped;
  final int other;
  final bool ok;
  final String? error;

  factory AwsSummary.fromJson(Map<String, dynamic> json) {
    final instances = json['instances'] is Map
        ? Map<String, dynamic>.from(json['instances'] as Map)
        : <String, dynamic>{};
    final costs = json['costs'] is Map
        ? Map<String, dynamic>.from(json['costs'] as Map)
        : <String, dynamic>{};
    return AwsSummary(
      mtdUsd: (costs['mtdUsd'] is num)
          ? (costs['mtdUsd'] as num).toDouble()
          : (json['mtdUsd'] is num)
              ? (json['mtdUsd'] as num).toDouble()
              : double.tryParse('${costs['mtdUsd'] ?? json['mtdUsd']}') ?? 0,
      running: _int(instances['running'] ?? json['running']),
      stopped: _int(instances['stopped'] ?? json['stopped']),
      other: _int(instances['other'] ?? json['other']),
      ok: json['ok'] != false,
      error: json['error'] is Map
          ? '${(json['error'] as Map)['message'] ?? json['error']}'
          : (costs['error'] is Map
              ? '${(costs['error'] as Map)['message']}'
              : json['error']?.toString()),
    );
  }
}

class Ec2InstanceRow {
  Ec2InstanceRow({
    required this.id,
    required this.state,
    this.name,
    this.instanceType,
    this.az,
    this.privateIp,
    this.cpuPercent,
  });

  final String id;
  final String state;
  final String? name;
  final String? instanceType;
  final String? az;
  final String? privateIp;
  final double? cpuPercent;

  factory Ec2InstanceRow.fromJson(Map<String, dynamic> json) => Ec2InstanceRow(
        id: '${json['id'] ?? json['instanceId'] ?? ''}',
        name: (json['name'] ?? json['Name'])?.toString(),
        state: '${json['state'] ?? ''}',
        instanceType: (json['instanceType'] ?? json['type'])?.toString(),
        az: (json['az'] ?? json['availabilityZone'])?.toString(),
        privateIp: json['privateIp']?.toString(),
        cpuPercent: (json['cpuPercent'] ?? json['cpuAverage1h']) is num
            ? ((json['cpuPercent'] ?? json['cpuAverage1h']) as num).toDouble()
            : double.tryParse('${json['cpuPercent'] ?? json['cpuAverage1h']}'),
      );
}

class ProductHealthRow {
  ProductHealthRow({
    required this.name,
    required this.ok,
    this.statusCode,
    this.latencyMs,
    this.error,
  });

  final String name;
  final bool ok;
  final int? statusCode;
  final int? latencyMs;
  final String? error;

  factory ProductHealthRow.fromJson(Map<String, dynamic> json) =>
      ProductHealthRow(
        name: '${json['name'] ?? json['id'] ?? ''}',
        ok: json['ok'] == true,
        statusCode: json['statusCode'] == null ? null : _int(json['statusCode']),
        latencyMs: json['latencyMs'] == null ? null : _int(json['latencyMs']),
        error: json['error']?.toString(),
      );
}

class GithubCheckRow {
  GithubCheckRow({
    required this.repo,
    this.conclusion,
    this.status,
    this.htmlUrl,
    this.name,
  });

  final String repo;
  final String? conclusion;
  final String? status;
  final String? htmlUrl;
  final String? name;

  factory GithubCheckRow.fromJson(Map<String, dynamic> json) => GithubCheckRow(
        repo: '${json['repo'] ?? ''}',
        conclusion: json['conclusion']?.toString(),
        status: json['status']?.toString(),
        htmlUrl: json['htmlUrl']?.toString(),
        name: json['name']?.toString(),
      );
}

class PnLSnapshot {
  PnLSnapshot({
    this.mobiCaptured = 0,
    this.oneopsCaptured = 0,
    this.revenueTotal = 0,
    this.awsMtd = 0,
    this.contribution = 0,
    this.ok = true,
    this.note,
  });

  final double mobiCaptured;
  final double oneopsCaptured;
  final double revenueTotal;
  final double awsMtd;
  final double contribution;
  final bool ok;
  final String? note;

  factory PnLSnapshot.fromJson(Map<String, dynamic> json) {
    final revenue = json['revenue'] is Map
        ? Map<String, dynamic>.from(json['revenue'] as Map)
        : <String, dynamic>{};
    return PnLSnapshot(
      mobiCaptured: (revenue['mobiCaptured'] is num)
          ? (revenue['mobiCaptured'] as num).toDouble()
          : 0,
      oneopsCaptured: (revenue['oneopsCaptured'] is num)
          ? (revenue['oneopsCaptured'] as num).toDouble()
          : 0,
      revenueTotal: (revenue['total'] is num)
          ? (revenue['total'] as num).toDouble()
          : 0,
      awsMtd: (json['awsMtd'] is num) ? (json['awsMtd'] as num).toDouble() : 0,
      contribution:
          (json['contribution'] is num) ? (json['contribution'] as num).toDouble() : 0,
      ok: json['ok'] != false,
      note: json['note']?.toString(),
    );
  }
}
