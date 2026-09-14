import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../config.dart';

enum AuthPhase { loading, signedOut, needsOrg, ready }

class AppState extends ChangeNotifier {
  AppState({required AppConfig config})
      : config = config,
        identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
  }

  final AppConfig config;
  final IdentityClient identity;
  late final ApiClient api;
  final ConnectivityMonitor connectivity = ConnectivityMonitor();
  final SyncNotifier syncNotifier = SyncNotifier();
  final KvStore cache = KvStore('admin_offline.db');

  AuthPhase phase = AuthPhase.loading;
  AuthMe? me;
  List<OrganizationSummary> organizations = const [];
  PlatformOverview? overview;
  List<TenantSummary> tenants = const [];
  List<SiteLead> leads = const [];
  List<SiteSubscriber> subscribers = const [];
  List<SiteApplication> applications = const [];
  List<EventLogSummary> eventLogs = const [];

  List<AdminWorkspace> workspaces = const [];
  List<AdminPayment> payments = const [];
  List<AdminPlan> plans = const [];
  List<AdminFeatureFlag> featureFlags = const [];
  List<AdminLiveUser> liveUsers = const [];
  List<AdminSupportTicket> supportTickets = const [];
  List<AdminAppRelease> releases = const [];
  List<StaffGrant> staffGrants = const [];
  Set<String> staffRoles = const {};
  List<IdentityUserRow> identityUsers = const [];
  MailHealth? mailHealth;
  List<CommonsReviewItem> commonsQueue = const [];

  RevenueSnapshot mobiRevenue = const RevenueSnapshot();
  RevenueSnapshot oneopsRevenue = const RevenueSnapshot();
  String? commerceAuthError;

  AwsSummary? awsSummary;
  List<Ec2InstanceRow> ec2Instances = const [];
  List<ProductHealthRow> productHealth = const [];
  List<GithubCheckRow> githubChecks = const [];
  PnLSnapshot? pnl;
  String? infraError;

  String? tenantStatusFilter;
  String? error;
  bool busy = false;
  bool hubLoading = false;
  bool commerceLoading = false;
  bool infraLoading = false;
  bool servingFromCache = false;
  DateTime? lastSyncedAt;

  bool get online => connectivity.online;

  RevenueSnapshot get revenue => mobiRevenue.capturedCount > 0 ||
          mobiRevenue.capturedTotal > 0 ||
          mobiRevenue.pendingTotal > 0
      ? mobiRevenue
      : RevenueSnapshot.fromPayments(payments);

  int get activeShops => workspaces.where((w) => w.active).length;

  Future<void> bootstrap() async {
    phase = AuthPhase.loading;
    notifyListeners();
    try {
      await connectivity.start();
      await syncNotifier.init(channelName: 'Admin sync');
      connectivity.addListener(_onNet);
      final session = await identity.tokenStore.session();
      if (session == null) {
        phase = AuthPhase.signedOut;
        notifyListeners();
        return;
      }
      await identity.refreshIfNeeded();
      await _loadMeAndRoute();
    } catch (e) {
      debugPrint('bootstrap failed: $e');
      error = '$e';
      phase = AuthPhase.signedOut;
      notifyListeners();
    }
  }

  void _onNet() {
    notifyListeners();
    if (online && phase == AuthPhase.ready) {
      unawaited(refreshAll());
    }
  }

  Future<void> signIn() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await identity.signIn();
      await _loadMeAndRoute();
    } catch (e, st) {
      debugPrint('Identity signIn failed: $e\n$st');
      error = '$e';
      phase = AuthPhase.signedOut;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> selectOrg(OrganizationSummary org) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await api.selectOrganization(org.id);
      await identity.tokenStore.saveProfile(
        userId: me?.id ?? '',
        email: me?.email ?? '',
        displayName: me?.displayName ?? '',
        platformAdmin: me?.platformAdmin ?? false,
      );
      phase = AuthPhase.ready;
      await refreshAll();
    } catch (e) {
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshPlatform({String? status}) =>
      refreshHub(tenantStatus: status, updateTenantFilter: true);

  Future<void> refreshAll() async {
    await Future.wait([
      refreshHub(),
      refreshCommerce(),
      refreshInfra(),
      refreshStaffTools(),
    ]);
  }

  Future<void> refreshHub({
    String? tenantStatus,
    bool updateTenantFilter = false,
  }) async {
    if (updateTenantFilter) {
      tenantStatusFilter = tenantStatus;
    }
    hubLoading = true;
    error = null;
    notifyListeners();

    if (connectivity.offline) {
      servingFromCache = overview != null || tenants.isNotEmpty;
      error = servingFromCache
          ? 'Offline · showing last synced hub'
          : 'Offline · connect to load the ops hub';
      hubLoading = false;
      busy = false;
      notifyListeners();
      return;
    }

    final failures = <String>[];

    Future<T?> soft<T>(String label, Future<T> Function() run) async {
      try {
        return await run();
      } catch (e, st) {
        debugPrint('refreshHub $label failed: $e\n$st');
        failures.add(label);
        return null;
      }
    }

    final results = await Future.wait([
      soft('overview', api.platformOverview),
      soft(
        'tenants',
        () => api.platformTenants(status: tenantStatusFilter),
      ),
      soft('leads', api.siteLeads),
      soft('subscribers', api.siteSubscribers),
      soft('applications', api.siteApplications),
      soft('eventLogs', api.eventLogs),
      soft('staffRoles', api.platformStaffRolesMe),
      soft('staffGrants', api.platformStaffGrants),
      soft('oneopsRevenue', api.platformBillingRevenue),
    ]);

    final nextOverview = results[0] as PlatformOverview?;
    final nextTenants = results[1] as CursorPage<TenantSummary>?;
    final nextLeads = results[2] as CursorPage<SiteLead>?;
    final nextSubs = results[3] as CursorPage<SiteSubscriber>?;
    final nextApps = results[4] as CursorPage<SiteApplication>?;
    final nextLogs = results[5] as CursorPage<EventLogSummary>?;
    final nextRoles = results[6] as Set<String>?;
    final nextGrants = results[7] as List<StaffGrant>?;
    final nextOneopsRev = results[8] as RevenueSnapshot?;

    if (nextOverview != null) overview = nextOverview;
    if (nextTenants != null) tenants = nextTenants.items;
    if (nextLeads != null) leads = nextLeads.items;
    if (nextSubs != null) subscribers = nextSubs.items;
    if (nextApps != null) applications = nextApps.items;
    if (nextLogs != null) eventLogs = nextLogs.items;
    if (nextRoles != null) staffRoles = nextRoles;
    if (nextGrants != null) staffGrants = nextGrants;
    if (nextOneopsRev != null) oneopsRevenue = nextOneopsRev;

    servingFromCache =
        failures.isNotEmpty && (overview != null || tenants.isNotEmpty);
    if (failures.isNotEmpty) {
      error = servingFromCache
          ? 'Showing cached hub · some sections failed: ${failures.join(', ')}'
          : 'Some hub sections failed: ${failures.join(', ')}';
    } else {
      lastSyncedAt = DateTime.now();
      await cache.putMeta('lastSyncedAt', lastSyncedAt!.toIso8601String());
      await syncNotifier.showSynced(flushed: 0, detail: 'Ops hub updated');
    }

    hubLoading = false;
    busy = false;
    notifyListeners();
  }

  Future<void> refreshCommerce() async {
    commerceLoading = true;
    commerceAuthError = null;
    notifyListeners();

    if (connectivity.offline) {
      commerceLoading = false;
      notifyListeners();
      return;
    }

    final failures = <String>[];

    Future<T?> soft<T>(String label, Future<T> Function() run) async {
      try {
        return await run();
      } on ApiException catch (e) {
        debugPrint('refreshCommerce $label failed: $e');
        if (e.statusCode == 403) {
          commerceAuthError =
              'This needs a SUPPORT or BILLING staff role on the oneOps admin BFF.';
        }
        failures.add(label);
        return null;
      } catch (e, st) {
        debugPrint('refreshCommerce $label failed: $e\n$st');
        failures.add(label);
        return null;
      }
    }

    final results = await Future.wait([
      soft('workspaces', api.adminWorkspaces),
      soft('payments', api.adminBillingOrders),
      soft('plans', api.adminPlans),
      soft('flags', api.adminFeatureFlags),
      soft('live', api.adminLiveUsers),
      soft('support', api.adminSupportTickets),
      soft('releases', api.adminAppReleases),
      soft('mobiRevenue', api.adminBillingRevenue),
    ]);

    final nextShops = results[0] as List<AdminWorkspace>?;
    final nextPayments = results[1] as List<AdminPayment>?;
    final nextPlans = results[2] as List<AdminPlan>?;
    final nextFlags = results[3] as List<AdminFeatureFlag>?;
    final nextLive = results[4] as List<AdminLiveUser>?;
    final nextTickets = results[5] as List<AdminSupportTicket>?;
    final nextReleases = results[6] as List<AdminAppRelease>?;
    final nextRev = results[7] as RevenueSnapshot?;

    if (nextShops != null) workspaces = nextShops;
    if (nextPayments != null) payments = nextPayments;
    if (nextPlans != null) plans = nextPlans;
    if (nextFlags != null) featureFlags = nextFlags;
    if (nextLive != null) liveUsers = nextLive;
    if (nextTickets != null) supportTickets = nextTickets;
    if (nextReleases != null) releases = nextReleases;
    if (nextRev != null) {
      mobiRevenue = nextRev;
    } else if (nextPayments != null) {
      mobiRevenue = RevenueSnapshot.fromPayments(nextPayments);
    }

    if (commerceAuthError != null) {
      error = commerceAuthError;
    } else if (failures.isNotEmpty) {
      final msg = 'MobiStack ops partial: ${failures.join(', ')}';
      error = error == null ? msg : '$error · $msg';
    }

    commerceLoading = false;
    notifyListeners();
  }

  Future<void> refreshInfra() async {
    infraLoading = true;
    infraError = null;
    notifyListeners();

    if (connectivity.offline) {
      infraLoading = false;
      notifyListeners();
      return;
    }

    final failures = <String>[];

    Future<T?> soft<T>(String label, Future<T> Function() run) async {
      try {
        return await run();
      } catch (e, st) {
        debugPrint('refreshInfra $label failed: $e\n$st');
        failures.add(label);
        return null;
      }
    }

    final results = await Future.wait([
      soft('awsSummary', api.platformAwsSummary),
      soft('instances', api.platformAwsInstances),
      soft('health', api.platformProductHealth),
      soft('github', api.platformGithubChecks),
    ]);

    final nextAws = results[0] as AwsSummary?;
    final nextEc2 = results[1] as List<Ec2InstanceRow>?;
    final nextHealth = results[2] as List<ProductHealthRow>?;
    final nextGh = results[3] as List<GithubCheckRow>?;

    if (nextAws != null) awsSummary = nextAws;
    if (nextEc2 != null) ec2Instances = nextEc2;
    if (nextHealth != null) productHealth = nextHealth;
    if (nextGh != null) githubChecks = nextGh;

    try {
      pnl = await api.platformPnl(
        mobiCaptured: revenue.capturedTotal,
        oneopsCaptured: oneopsRevenue.capturedTotal,
        awsMtd: awsSummary?.mtdUsd,
      );
    } catch (e) {
      debugPrint('pnl failed: $e');
      failures.add('pnl');
    }

    if (failures.isNotEmpty) {
      infraError =
          'Platform infra partial (${failures.join(', ')}). Deploy backend with AWS ops + attach ops-tool-read-policy to EC2 role.';
    }

    infraLoading = false;
    notifyListeners();
  }

  Future<void> toggleWorkspace(AdminWorkspace workspace) async {
    try {
      await api.setWorkspaceActive(
        id: workspace.id,
        active: !workspace.active,
      );
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> updateWorkspaceScreens(
    AdminWorkspace workspace,
    int extraScreens,
  ) async {
    try {
      await api.setWorkspaceScreens(
        id: workspace.id,
        extraScreens: extraScreens,
      );
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> toggleFeatureFlag(AdminFeatureFlag flag) async {
    try {
      await api.setFeatureFlag(code: flag.code, enabled: !flag.enabled);
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> resolveTicket(AdminSupportTicket ticket) async {
    try {
      await api.resolveSupportTicket(ticket.id);
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> replyTicket(AdminSupportTicket ticket, String body) async {
    try {
      await api.replySupportTicket(id: ticket.id, body: body);
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> updateLeadStatus(SiteLead lead, String status) async {
    try {
      final updated = await api.patchLead(id: lead.id, status: status);
      leads = [
        for (final item in leads)
          if (item.id == lead.id) updated else item,
      ];
      notifyListeners();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> updateApplicationStatus(
    SiteApplication app,
    String status,
  ) async {
    try {
      final updated = await api.patchApplication(id: app.id, status: status);
      applications = [
        for (final item in applications)
          if (item.id == app.id) updated else item,
      ];
      notifyListeners();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> refreshStaffTools() async {
    Future<T?> soft<T>(String label, Future<T> Function() run) async {
      try {
        return await run();
      } catch (e, st) {
        debugPrint('refreshStaffTools $label failed: $e\n$st');
        return null;
      }
    }

    final results = await Future.wait([
      soft('identity', api.platformIdentityUsers),
      soft('mailHealth', api.platformMailHealth),
      soft('commons', api.platformCommonsQueue),
    ]);
    final users = results[0] as List<IdentityUserRow>?;
    final health = results[1] as MailHealth?;
    final commons = results[2] as List<CommonsReviewItem>?;
    if (users != null) identityUsers = users;
    if (health != null) mailHealth = health;
    if (commons != null) commonsQueue = commons;
    notifyListeners();
  }

  Future<void> identityAction(IdentityUserRow user, String action) async {
    try {
      await api.identityUserAction(userId: user.id, action: action);
      await refreshStaffTools();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> grantRole({
    required String userId,
    required String role,
    String? note,
  }) async {
    try {
      await api.grantStaffRole(userId: userId, role: role, note: note);
      await refreshHub();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> breakGlass({
    required String userId,
    required String reason,
  }) async {
    try {
      await api.breakGlassRevokeTokens(userId: userId, reason: reason);
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> kickUser(AdminLiveUser user) async {
    try {
      await api.kickLiveUser(userId: user.userId, deviceId: user.deviceId);
      await refreshCommerce();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> promote({required String service, required String tag}) async {
    try {
      await api.promoteRelease(service: service, tag: tag);
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> reviewCommonsItem(CommonsReviewItem item, String decision) async {
    try {
      await api.reviewCommons(id: item.id, decision: decision);
      await refreshStaffTools();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> openAccount() {
    return identity.openAccount();
  }

  Future<void> signOut() async {
    busy = true;
    notifyListeners();
    try {
      await api.platformLogout();
      await identity.signOut();
    } finally {
      me = null;
      organizations = const [];
      overview = null;
      tenants = const [];
      leads = const [];
      subscribers = const [];
      applications = const [];
      eventLogs = const [];
      workspaces = const [];
      payments = const [];
      plans = const [];
      featureFlags = const [];
      liveUsers = const [];
      supportTickets = const [];
      releases = const [];
      staffGrants = const [];
      staffRoles = const {};
      identityUsers = const [];
      mailHealth = null;
      commonsQueue = const [];
      mobiRevenue = const RevenueSnapshot();
      oneopsRevenue = const RevenueSnapshot();
      awsSummary = null;
      ec2Instances = const [];
      productHealth = const [];
      githubChecks = const [];
      pnl = null;
      phase = AuthPhase.signedOut;
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _loadMeAndRoute() async {
    me = await api.authMe();
    await identity.tokenStore.saveProfile(
      userId: me!.id,
      email: me!.email,
      displayName: me!.displayName,
      platformAdmin: me!.platformAdmin,
    );

    if (!me!.platformAdmin) {
      error = 'This account is not a platform admin.';
      phase = AuthPhase.signedOut;
      await identity.tokenStore.clear();
      notifyListeners();
      return;
    }

    try {
      organizations = me!.organizations.isNotEmpty
          ? me!.organizations
          : await api.organizations();
    } catch (e) {
      debugPrint('organizations fetch skipped: $e');
      organizations = me!.organizations;
    }

    phase = AuthPhase.ready;
    notifyListeners();
    await refreshAll();
  }

  @override
  void dispose() {
    connectivity.removeListener(_onNet);
    connectivity.dispose();
    unawaited(cache.close());
    super.dispose();
  }
}
