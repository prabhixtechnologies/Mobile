import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../config.dart';

enum AuthPhase { loading, signedOut, needsOrg, ready }

class AppState extends ChangeNotifier {
  AppState({required AppConfig config})
      : identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
  }

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
  String? tenantStatusFilter;
  String? error;
  bool busy = false;
  bool hubLoading = false;
  bool servingFromCache = false;
  DateTime? lastSyncedAt;

  bool get online => connectivity.online;

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
      unawaited(refreshHub());
    }
  }

  Future<void> signIn() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      debugPrint(
        'Identity signIn start issuer=${identity.config.issuer} '
        'client=${identity.config.clientId} redirect=${identity.config.redirectUri}',
      );
      await identity.signIn();
      debugPrint('Identity signIn tokens ok; loading /auth/me');
      await _loadMeAndRoute();
      debugPrint('Identity signIn complete phase=$phase');
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
      await refreshHub();
    } catch (e) {
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshPlatform({String? status}) =>
      refreshHub(tenantStatus: status, updateTenantFilter: true);

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
    ]);

    final nextOverview = results[0] as PlatformOverview?;
    final nextTenants = results[1] as CursorPage<TenantSummary>?;
    final nextLeads = results[2] as CursorPage<SiteLead>?;
    final nextSubs = results[3] as CursorPage<SiteSubscriber>?;
    final nextApps = results[4] as CursorPage<SiteApplication>?;
    final nextLogs = results[5] as CursorPage<EventLogSummary>?;

    if (nextOverview != null) overview = nextOverview;
    if (nextTenants != null) tenants = nextTenants.items;
    if (nextLeads != null) leads = nextLeads.items;
    if (nextSubs != null) subscribers = nextSubs.items;
    if (nextApps != null) applications = nextApps.items;
    if (nextLogs != null) eventLogs = nextLogs.items;

    servingFromCache =
        failures.isNotEmpty && (overview != null || tenants.isNotEmpty);
    if (failures.isNotEmpty) {
      error = servingFromCache
          ? 'Showing cached hub · some sections failed: ${failures.join(', ')}'
          : 'Some hub sections failed: ${failures.join(', ')}';
    } else {
      lastSyncedAt = DateTime.now();
      await cache.putMeta('lastSyncedAt', lastSyncedAt!.toIso8601String());
      await syncNotifier.showSynced(
        flushed: 0,
        detail: 'Ops hub updated',
      );
    }

    debugPrint(
      'hub loaded tenants=${tenants.length} leads=${leads.length} '
      'subs=${subscribers.length} apps=${applications.length} '
      'logs=${eventLogs.length} failures=$failures',
    );
    hubLoading = false;
    busy = false;
    notifyListeners();
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
    await refreshHub();
  }

  @override
  void dispose() {
    connectivity.removeListener(_onNet);
    connectivity.dispose();
    unawaited(cache.close());
    super.dispose();
  }
}
