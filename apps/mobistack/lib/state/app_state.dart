import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../config.dart';
import '../models/shop_models.dart';
import '../services/counter_payloads.dart';
import '../services/open_bill.dart';
import '../services/push_registration.dart';
import '../services/sync_store.dart';

enum AuthPhase { loading, signedOut, ready }

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState({required this.config})
      : identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
    sync = SyncStore(api);
    api.traceRequests((message) => debugPrint('mobistack $message'));
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
  ThemeMode themeMode = ThemeMode.dark;

  CachedDashboard dashboard = CachedDashboard();
  List<CachedVariant> variants = const [];
  List<CachedSale> sales = const [];
  List<CachedRepair> repairs = const [];
  List<CachedCustomer> customers = const [];
  final OpenBill bill = OpenBill();
  List<CachedDevice> devices = const [];
  List<CachedDevice> commonsDevices = const [];
  int pendingOps = 0;
  String? lastScan;
  bool servingFromCache = false;
  List<FitmentGroup> fitmentGroups = const [];
  String? fitmentGroupId;

  FitmentGroup? get selectedFitmentGroup {
    for (final group in fitmentGroups) {
      if (group.id == fitmentGroupId) return group;
    }
    return fitmentGroups.isEmpty ? null : fitmentGroups.first;
  }

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
    await _loadAppearance();
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
      final cached = await _showCachedShop();
      if (cached) {
        unawaited(_refreshLive());
      } else {
        await _refreshLive();
      }
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
    // Shop sync, sales, and stock are closed. Catalog and billing load themselves.
    busy = false;
    error = null;
    notifyListeners();
  }

  /// Queues a sync operation. Returns a failure message, or null when the
  /// server accepted it or it is waiting for a connection.
  Future<CounterResult> submitOp({
    required String type,
    required Map<String, dynamic> body,
  }) async {
    await sync.enqueue(type: type, payload: body);
    pendingOps = await sync.pendingCount();
    notifyListeners();
    if (!online) {
      await syncNotifier.showPendingOutbox(pendingOps);
      return const CounterResult.queued();
    }
    final results = await sync.flush();
    final failed = results.where((row) => '${row['status']}' != 'SYNCED').toList();
    await refreshAll();
    if (pendingOps > 0) {
      final message = failed.isEmpty
          ? 'Change stayed in the outbox'
          : '${failed.first['message'] ?? 'Sync rejected the change'}';
      return CounterResult.failed(message);
    }
    return const CounterResult.synced();
  }

  Future<String?> createPart({
    required String name,
    required String sku,
    required double price,
    required int qty,
    String? barcode,
    int reorderLevel = 0,
  }) async {
    if (!online) return 'Offline · connect to add a part';
    try {
      final listed = await api.dio.get<dynamic>('categories');
      String? categoryId;
      final data = listed.data;
      if (data is List) {
        for (final row in data) {
          if (row is! Map) continue;
          final id = '${row['id'] ?? ''}';
          if (id.isNotEmpty) {
            categoryId = id;
            break;
          }
        }
      }
      if (categoryId == null) {
        final created = await api.dio.post<dynamic>(
          'categories',
          data: {'code': 'PARTS', 'name': 'Parts'},
        );
        categoryId = created.data is Map ? '${(created.data as Map)['id']}' : '';
      }
      if (categoryId.isEmpty) return 'Could not open a parts category';
      final product = await api.dio.post<dynamic>(
        'products',
        data: {
          'categoryId': categoryId,
          'name': name,
          'unit': 'pcs',
          'active': true,
        },
      );
      final productId = product.data is Map ? '${(product.data as Map)['id']}' : '';
      if (productId.isEmpty) return 'Could not create the part';
      await api.dio.post<dynamic>(
        'products/$productId/variants',
        data: {
          'variantName': name,
          'sku': sku,
          if (barcode != null && barcode.isNotEmpty) 'barcode': barcode,
          'costPrice': price,
          'retailPrice': price,
          'openingStock': qty,
          if (reorderLevel > 0) 'reorderLevel': reorderLevel,
        },
      );
      await refreshAll();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> addVariant({
    required String variantId,
    required String name,
    required String sku,
    required double price,
    int qty = 0,
    int reorderLevel = 0,
  }) async {
    if (!online) return 'Offline · connect to add a variant';
    try {
      final current = await api.dio.get<dynamic>('variants/$variantId');
      final productId = current.data is Map ? '${(current.data as Map)['productId'] ?? ''}' : '';
      if (productId.isEmpty) return 'Could not find the product';
      await api.dio.post<dynamic>(
        'products/$productId/variants',
        data: {
          'variantName': name,
          'sku': sku,
          'costPrice': price,
          'retailPrice': price,
          'openingStock': qty,
          if (reorderLevel > 0) 'reorderLevel': reorderLevel,
        },
      );
      await refreshAll();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  void setLastScan(String code) {
    lastScan = code;
    notifyListeners();
  }

  CachedVariant? matchCode(String code) {
    final q = code.trim().toLowerCase();
    if (q.isEmpty) return null;
    for (final variant in variants) {
      if (variant.sku.toLowerCase() == q) return variant;
      final barcode = variant.barcode?.trim().toLowerCase() ?? '';
      if (barcode.isNotEmpty && barcode == q) return variant;
    }
    return null;
  }

  void addToBill(CachedVariant variant) {
    bill.add(variant);
    notifyListeners();
  }

  void setBillQuantity(int index, int quantity) {
    if (index < 0 || index >= bill.lines.length) return;
    if (quantity < 1) {
      bill.removeAt(index);
    } else {
      bill.lines[index].quantity = quantity;
    }
    notifyListeners();
  }

  void removeBillLine(int index) {
    bill.removeAt(index);
    notifyListeners();
  }

  void setBillCustomer(CachedCustomer? customer) {
    bill.customerId = customer?.id;
    bill.customerName = customer?.name;
    notifyListeners();
  }

  void setBillMethod(String method) {
    bill.method = method;
    notifyListeners();
  }

  void setBillDiscount(double discount) {
    bill.discount = discount < 0 ? 0 : discount;
    notifyListeners();
  }

  Future<SaleOutcome> checkoutBill() async {
    if (bill.isEmpty) {
      return const SaleOutcome.failed('The bill is empty');
    }
    final body = bill.toSaleBody();
    if (!online) {
      final result = await submitOp(type: 'SALE', body: {'sale': body});
      if (!result.ok) return SaleOutcome.failed(result.message ?? 'Sale failed');
      bill.clear();
      notifyListeners();
      return const SaleOutcome.done(queued: true);
    }
    try {
      final res = await api.dio.post<dynamic>('sales', data: body);
      final data = res.data;
      final id = data is Map ? '${data['id'] ?? ''}' : '';
      final invoice = data is Map ? '${data['invoiceNumber'] ?? ''}' : '';
      bill.clear();
      notifyListeners();
      await refreshAll();
      return SaleOutcome.done(
        saleId: id.isEmpty ? null : id,
        invoiceNumber: invoice.isEmpty ? null : invoice,
      );
    } catch (e) {
      return SaleOutcome.failed('$e');
    }
  }

  Future<String?> voidSale(String saleId) async {
    if (!online) return 'Offline · connect to void a sale';
    try {
      await api.dio.post<dynamic>('sales/$saleId/void', data: {'reason': 'Voided on the counter'});
      await refreshAll();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  void setBillPrice(int index, double price) {
    if (index < 0 || index >= bill.lines.length) return;
    bill.lines[index].unitPrice = price < 0 ? 0 : price;
    notifyListeners();
  }

  Future<String?> onlinePut(String path, Object data) async {
    if (!online) return 'Offline · connect to do this';
    try {
      await api.dio.put<dynamic>(path, data: data);
      await refreshAll();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String?> onlinePost(String path, Object data) async {
    if (!online) return 'Offline · connect to do this';
    try {
      await api.dio.post<dynamic>(path, data: data);
      await refreshAll();
      return null;
    } catch (e) {
      return '$e';
    }
  }

  Future<String> invoiceHtml(String saleId) => api.getText('sales/$saleId/invoice');

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

  Future<void> _loadAppearance() async {
    final saved = await sync.appearance();
    themeMode = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setAppearance(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await sync.saveAppearance(mode == ThemeMode.light ? 'light' : 'dark');
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
      await sync.clearLocal();
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

  Future<void> _hydrateFromDisk() async {
    dashboard = await sync.dashboard();
    variants = await sync.variants();
    sales = await sync.sales();
    repairs = await sync.repairs();
    customers = await sync.customers();
    devices = await sync.devices();
    commonsDevices = await sync.commonsDevices();
    pendingOps = await sync.pendingCount();
  }

  Future<bool> _showCachedShop() async {
    final raw = await sync.sessionProfile();
    if (raw == null) return false;
    me = AuthMe.fromJson(raw);
    await _hydrateFromDisk();
    servingFromCache = true;
    phase = AuthPhase.ready;
    notifyListeners();
    return true;
  }

  Future<void> _refreshLive() async {
    try {
      await identity.refreshIfNeeded();
      await _loadSession();
    } catch (e, st) {
      debugPrint('live session failed: $e\n$st');
      if (e is ApiException && e.statusCode == 401) {
        error = e.message;
        phase = AuthPhase.signedOut;
        notifyListeners();
        return;
      }
      if (me != null) {
        error = online
            ? 'Server unreachable · showing the last saved shop'
            : 'Offline · showing the last saved shop';
        servingFromCache = true;
        if (phase != AuthPhase.ready) phase = AuthPhase.ready;
        notifyListeners();
        return;
      }
      error = 'Could not reach the shop. Sign in once while online.';
      phase = AuthPhase.signedOut;
      notifyListeners();
    }
  }

  Map<String, dynamic> _sessionJson(AuthMe profile) {
    return {
      'id': profile.id,
      'email': profile.email,
      'fullName': profile.displayName,
      'organizations': [
        for (final org in profile.organizations)
          {
            'id': org.id,
            'name': org.name,
            if (org.slug != null) 'slug': org.slug,
          },
      ],
      'permissions': profile.permissions.toList(),
      'features': profile.features.toList(),
      'platformAdmin': profile.platformAdmin,
      'systemAdmin': profile.systemAdmin,
      'selectedOrganizationId': profile.selectedOrganizationId,
      'paymentRequired': profile.paymentRequired,
      'catalogOnly': profile.catalogOnly,
      'planCode': profile.planCode,
      'planName': profile.planName,
      'periodEnd': profile.periodEnd,
    };
  }

  Future<void> _loadSession() async {
    me = await api.authMe();
    await sync.saveSession(_sessionJson(me!));
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
    await loadFitmentGroups();
    debugPrint(
      'session ready paymentRequired=${me!.paymentRequired} '
      'features=${me!.features.toList()} plan=${me!.planCode}',
    );
    await refreshAll();
    unawaited(PushRegistration.register(api));
  }

  Future<void> loadFitmentGroups() async {
    try {
      final res = await api.dio.get<dynamic>('groups');
      final data = res.data;
      final rows = data is List ? data : const [];
      final loaded = <FitmentGroup>[
        for (final row in rows)
          if (row is Map) FitmentGroup.fromJson(Map<String, dynamic>.from(row)),
      ];
      fitmentGroups = loaded;
      final stillThere = loaded.any((group) => group.id == fitmentGroupId);
      fitmentGroupId = stillThere
          ? fitmentGroupId
          : (loaded.isEmpty ? null : loaded.first.id);
      api.fitmentGroupId = fitmentGroupId;
    } catch (e, st) {
      debugPrint('fitment groups unavailable: $e\n$st');
    }
    notifyListeners();
  }

  void selectFitmentGroup(String id) {
    fitmentGroupId = id;
    api.fitmentGroupId = id;
    notifyListeners();
  }

  Future<String?> createFitmentGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'A group needs a name';
    try {
      final res = await api.dio.post<dynamic>('groups', data: {'name': trimmed});
      final id = res.data is Map ? '${(res.data as Map)['id'] ?? ''}' : '';
      await loadFitmentGroups();
      if (id.isNotEmpty) selectFitmentGroup(id);
      return null;
    } catch (e) {
      final data = (e as dynamic).response?.data;
      if (data is Map && data['message'] != null) return '${data['message']}';
      return 'Could not create the group';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivity.removeListener(_onNet);
    connectivity.dispose();
    super.dispose();
  }
}

class FitmentGroup {
  const FitmentGroup({required this.id, required this.name, required this.callerRole});

  final String id;
  final String name;
  final String callerRole;

  bool get canManage => callerRole == 'OWNER' || callerRole == 'ADMIN';
  bool get isOwner => callerRole == 'OWNER';

  factory FitmentGroup.fromJson(Map<String, dynamic> json) {
    return FitmentGroup(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? 'Group'}',
      callerRole: '${json['callerRole'] ?? 'MEMBER'}',
    );
  }
}
