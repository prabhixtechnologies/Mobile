import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../config.dart';
import '../models/shop_models.dart';
import '../services/push_registration.dart';
import '../services/sync_store.dart';

enum AuthPhase { loading, signedOut, ready }

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState({required this.config})
      : identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
    sync = SyncStore(api);
    WidgetsBinding.instance.addObserver(this);
  }

  final AppConfig config;
  final IdentityClient identity;
  late final ApiClient api;
  late final SyncStore sync;
  final ConnectivityMonitor connectivity = ConnectivityMonitor();
  final SyncNotifier syncNotifier = SyncNotifier();

  AuthPhase phase = AuthPhase.loading;
  AuthMe? me;
  String? error;
  bool busy = false;
  bool allowCreateAccount = false;

  CachedDashboard dashboard = CachedDashboard();
  List<CachedVariant> variants = const [];
  List<CachedSale> sales = const [];
  List<CachedRepair> repairs = const [];
  List<CachedCustomer> customers = const [];
  List<CachedDevice> devices = const [];
  List<CachedDevice> commonsDevices = const [];
  int pendingOps = 0;
  String? lastScan;
  bool servingFromCache = false;

  bool get online => connectivity.online;

  bool hasFeature(String code) {
    if (me == null) return false;
    // Match Expo: admins + explicit plan features only.
    // Unpaid shops get paymentRequired + empty features until billing activates.
    return me!.hasFeature(code);
  }

  bool get canManageBilling =>
      me == null ? false : me!.hasPermission('WORKSPACE_BILLING') || me!.systemAdmin || me!.platformAdmin;

  Future<void> refreshMe() async {
    me = await api.authMe();
    debugPrint(
      'auth/me refresh paymentRequired=${me!.paymentRequired} '
      'catalogOnly=${me!.catalogOnly} features=${me!.features.length} '
      'plan=${me!.planCode}',
    );
    notifyListeners();
    if (!me!.paymentRequired) {
      await refreshAll();
    }
  }

  Future<void> bootstrap() async {
    phase = AuthPhase.loading;
    notifyListeners();
    try {
      await connectivity.start();
      await syncNotifier.init(channelName: 'MobiStack sync');
      connectivity.addListener(_onNet);
      final session = await identity.tokenStore.session();
      if (session == null) {
        phase = AuthPhase.signedOut;
        notifyListeners();
        return;
      }
      await identity.refreshIfNeeded();
      await _loadSession();
    } catch (e) {
      error = '$e';
      phase = AuthPhase.signedOut;
      notifyListeners();
    }
  }

  void _onNet() {
    notifyListeners();
    if (online && phase == AuthPhase.ready) {
      unawaited(refreshAll());
    } else if (!online && pendingOps > 0) {
      unawaited(syncNotifier.showPendingOutbox(pendingOps));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && phase == AuthPhase.ready) {
      unawaited(refreshAll());
    }
  }

  Future<void> signIn({bool create = false}) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await identity.signIn(promptOverride: create ? 'create' : null);
      await _loadSession();
    } catch (e) {
      error = '$e';
      phase = AuthPhase.signedOut;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    busy = true;
    error = null;
    notifyListeners();
    final failures = <String>[];
    final beforePending = await sync.pendingCount();
    if (online) {
      try {
        await sync.flush();
      } catch (e, st) {
        debugPrint('sync flush failed: $e\n$st');
        failures.add('flush');
      }
      try {
        await sync.pullSnapshot();
      } catch (e, st) {
        debugPrint('sync pull failed: $e\n$st');
        failures.add('pull');
      }
    } else {
      failures.add('offline');
    }
    try {
      dashboard = await sync.dashboard();
      variants = await sync.variants();
      sales = await sync.sales();
      repairs = await sync.repairs();
      customers = await sync.customers();
      devices = await sync.devices();
      commonsDevices = await sync.commonsDevices();
      pendingOps = await sync.pendingCount();
      servingFromCache = !online || failures.contains('pull');
      debugPrint(
        'mobistack loaded variants=${variants.length} sales=${sales.length} '
        'repairs=${repairs.length} customers=${customers.length} pending=$pendingOps',
      );
    } catch (e, st) {
      debugPrint('sync read failed: $e\n$st');
      failures.add('cache');
    }
    if (pendingOps > 0 && !online) {
      await syncNotifier.showPendingOutbox(pendingOps);
    } else if (beforePending > pendingOps && pendingOps == 0) {
      await syncNotifier.showSynced(flushed: beforePending);
    }
    if (failures.isNotEmpty) {
      error = online
          ? 'Some sync steps failed: ${failures.join(', ')}'
          : 'Offline · showing cached shop data'
              '${pendingOps > 0 ? ' · $pendingOps queued' : ''}';
    }
    busy = false;
    notifyListeners();
  }

  Future<void> enqueueSale(Map<String, dynamic> sale) async {
    await sync.enqueue(type: 'SALE', payload: {'sale': sale});
    pendingOps = await sync.pendingCount();
    await syncNotifier.showPendingOutbox(pendingOps);
    notifyListeners();
    if (online) {
      await sync.flush();
      await refreshAll();
    }
  }

  void setLastScan(String code) {
    lastScan = code;
    notifyListeners();
  }

  List<CachedVariant> searchVariants(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return variants;
    return variants.where((v) {
      final hay = '${v.productName} ${v.variantName} ${v.sku} ${v.barcode ?? ''}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  void setAllowCreateAccount(bool value) {
    allowCreateAccount = value;
    notifyListeners();
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
      variants = const [];
      sales = const [];
      repairs = const [];
      customers = const [];
      devices = const [];
      commonsDevices = const [];
      phase = AuthPhase.signedOut;
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _loadSession() async {
    me = await api.authMe();
    final orgId = me!.selectedOrganizationId ??
        (me!.organizations.isNotEmpty ? me!.organizations.first.id : null);
    if (orgId != null) {
      await api.selectOrganization(orgId);
    }
    await identity.tokenStore.saveProfile(
      userId: me!.id,
      email: me!.email,
      displayName: me!.displayName,
      platformAdmin: me!.platformAdmin || me!.systemAdmin,
    );
    phase = AuthPhase.ready;
    debugPrint(
      'session ready paymentRequired=${me!.paymentRequired} '
      'features=${me!.features.toList()} plan=${me!.planCode}',
    );
    await refreshAll();
    unawaited(PushRegistration.register(api));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivity.removeListener(_onNet);
    connectivity.dispose();
    super.dispose();
  }
}
