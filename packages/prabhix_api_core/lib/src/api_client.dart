import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:uuid/uuid.dart';

import 'api_exception.dart';
import 'models.dart';
import 'product_config.dart';

/// Authenticated product API client. Refresh runs against Identity via [IdentityClient].
class ApiClient {
  ApiClient({
    required this.config,
    required this.identity,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl.endsWith('/')
                ? config.apiBaseUrl
                : '${config.apiBaseUrl}/',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await identity.refreshIfNeeded();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            // Admin / cross-tenant routes must not pin a customer org or shop.
            final isAdminPath = options.path.contains('admin/') ||
                options.path.startsWith('event-logs');
            final session = await identity.tokenStore.session();
            final org = session?.organizationId;
            if (!isAdminPath && org != null && org.isNotEmpty) {
              options.headers[config.orgHeaderName] = org;
            } else {
              options.headers.remove(config.orgHeaderName);
            }
            options.headers[config.deviceHeaderName] =
                await identity.tokenStore.deviceId();
            options.headers['X-Correlation-Id'] = const Uuid().v4();
            options.headers['X-Prabhix-Device-Label'] = config.deviceHeader;
            final group = fitmentGroupId;
            if (group != null && group.isNotEmpty) {
              options.headers['X-Fitment-Group'] = group;
            } else {
              options.headers.remove('X-Fitment-Group');
            }
            handler.next(options);
          } catch (e, st) {
            debugPrint('ApiClient onRequest failed: $e\n$st');
            handler.reject(
              DioException(
                requestOptions: options,
                error: e,
                stackTrace: st,
                type: DioExceptionType.unknown,
              ),
            );
          }
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried401'] != true) {
            try {
              debugPrint('ApiClient 401 → force Identity refresh');
              final token = await identity.refreshIfNeeded(force: true);
              if (token != null) {
                final req = error.requestOptions;
                req.headers['Authorization'] = 'Bearer $token';
                req.extra['retried401'] = true;
                final clone = await _dio.fetch(req);
                return handler.resolve(clone);
              }
            } catch (e, st) {
              debugPrint('ApiClient 401 refresh failed: $e\n$st');
              await identity.tokenStore.clear();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final ProductConfig config;
  final IdentityClient identity;
  final Dio _dio;

  /// Selected fitment group. Sent on every request so catalog reads stay in that group.
  String? fitmentGroupId;

  Dio get dio => _dio;

  /// Logs method, URL, status, and elapsed time. Safe for a release build:
  /// no headers, no body.
  void traceRequests(void Function(String message) log) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['t0'] = DateTime.now();
          log('→ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final started = response.requestOptions.extra['t0'];
          final ms = started is DateTime
              ? DateTime.now().difference(started).inMilliseconds
              : -1;
          log('← ${response.statusCode} ${response.requestOptions.uri} ${ms}ms');
          handler.next(response);
        },
        onError: (error, handler) {
          final started = error.requestOptions.extra['t0'];
          final ms = started is DateTime
              ? DateTime.now().difference(started).inMilliseconds
              : -1;
          log(
            '✕ ${error.response?.statusCode ?? '-'} ${error.requestOptions.uri} ${ms}ms ${error.type}',
          );
          handler.next(error);
        },
      ),
    );
  }

  Future<AuthMe> authMe() async {
    debugPrint('GET ${config.apiBaseUrl}/auth/me');
    final res = await _get('auth/me');
    debugPrint('auth/me ok keys=${res.keys.join(",")}');
    return AuthMe.fromJson(res);
  }

  Future<List<OrganizationSummary>> organizations() async {
    final res = await _dio.get<dynamic>('organizations');
    final data = res.data;
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((e) => OrganizationSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> platformLogout() async {
    try {
      await _dio.post<void>('auth/logout');
    } catch (_) {
      // Best-effort; Identity end-session still runs.
    }
  }

  /// Pins the active org for subsequent product API calls.
  Future<void> selectOrganization(String organizationId) async {
    try {
      await _dio.post<void>(config.selectPath(organizationId));
    } catch (_) {
      // Some products only need the header; continue with local pin.
    }
    await identity.tokenStore.saveAuthorization(
      organizationId: organizationId,
      permissions: (await identity.tokenStore.session())?.permissions ?? {},
    );
  }

  Future<void> registerPushToken({
    required String token,
    String platform = 'FCM',
  }) async {
    await _dio.post<void>(
      'devices/push-tokens',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<PlatformOverview> platformOverview() async {
    final res = await _get('admin/platform/overview');
    return PlatformOverview.fromJson(res);
  }

  Future<CursorPage<TenantSummary>> platformTenants({
    String? status,
    String? cursor,
  }) async {
    return _cursorPage(
      path: 'admin/platform/tenants',
      query: {
        if (status != null) 'status': status,
        if (cursor != null) 'cursor': cursor,
        'limit': 50,
      },
      parse: TenantSummary.fromJson,
    );
  }

  Future<CursorPage<SiteLead>> siteLeads({String? status, String? cursor}) {
    return _cursorPage(
      path: 'admin/site/leads',
      query: {
        if (status != null) 'status': status,
        if (cursor != null) 'cursor': cursor,
        'limit': 50,
      },
      parse: SiteLead.fromJson,
    );
  }

  Future<CursorPage<SiteSubscriber>> siteSubscribers({
    String? status,
    String? cursor,
  }) {
    return _cursorPage(
      path: 'admin/site/subscribers',
      query: {
        if (status != null) 'status': status,
        if (cursor != null) 'cursor': cursor,
        'limit': 50,
      },
      parse: SiteSubscriber.fromJson,
    );
  }

  Future<CursorPage<SiteApplication>> siteApplications({
    String? status,
    String? cursor,
  }) {
    return _cursorPage(
      path: 'admin/site/applications',
      query: {
        if (status != null) 'status': status,
        if (cursor != null) 'cursor': cursor,
        'limit': 50,
      },
      parse: SiteApplication.fromJson,
    );
  }

  Future<SiteLead> patchLead({
    required String id,
    required String status,
    String? internalNotes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      'admin/site/leads/$id',
      data: {
        'status': status,
        if (internalNotes != null) 'internalNotes': internalNotes,
      },
    );
    return SiteLead.fromJson(Map<String, dynamic>.from(res.data ?? {}));
  }

  Future<SiteApplication> patchApplication({
    required String id,
    required String status,
    String? internalNotes,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      'admin/site/applications/$id',
      data: {
        'status': status,
        if (internalNotes != null) 'internalNotes': internalNotes,
      },
    );
    return SiteApplication.fromJson(Map<String, dynamic>.from(res.data ?? {}));
  }

  Future<CursorPage<EventLogSummary>> eventLogs({String? cursor}) {
    return _cursorPage(
      path: 'event-logs',
      query: {
        'allOrganizations': true,
        if (cursor != null) 'cursor': cursor,
        'limit': 50,
      },
      parse: EventLogSummary.fromJson,
    );
  }

  // --- oneOps staff ---

  Future<Set<String>> platformStaffRolesMe() async {
    final res = await _get('admin/platform/staff/me');
    final roles = res['roles'];
    if (roles is List) {
      return roles.map((e) => '$e').toSet();
    }
    return {};
  }

  Future<List<StaffGrant>> platformStaffGrants() async {
    return _listGet('admin/platform/staff', StaffGrant.fromJson);
  }

  Future<void> breakGlassRevokeTokens({
    required String userId,
    required String reason,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/staff/break-glass/users/$userId/revoke-tokens',
        data: {'reason': reason},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> grantStaffRole({
    required String userId,
    required String role,
    String? note,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/staff/grants',
        data: {
          'userId': userId,
          'role': role,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<IdentityUserRow>> platformIdentityUsers({String? q}) async {
    try {
      final res = await _dio.get<dynamic>(
        'admin/platform/identity/users',
        queryParameters: {
          if (q != null && q.isNotEmpty) 'q': q,
          'limit': 50,
        },
      );
      return _parseMapList(res.data).map(IdentityUserRow.fromJson).toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> identityUserAction({
    required String userId,
    required String action,
    String? reason,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/identity/users/$userId/$action',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<MailHealth> platformMailHealth() async {
    final res = await _get('admin/platform/mail/health');
    return MailHealth.fromJson(res);
  }

  Future<List<CommonsReviewItem>> platformCommonsQueue() async {
    try {
      final res = await _dio.get<dynamic>('admin/platform/commons/queue');
      return _parseMapList(res.data).map(CommonsReviewItem.fromJson).toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> reviewCommons({
    required String id,
    required String decision,
    String? note,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/commons/$id/$decision',
        data: {
          if (note != null && note.isNotEmpty) 'note': note,
          if (note != null && note.isNotEmpty) 'reason': note,
        },
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> kickLiveUser({
    required String userId,
    String? deviceId,
    String? reason,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/mobistack/live/$userId/kick',
        data: {
          if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> promoteRelease({
    required String service,
    required String tag,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/github/promote',
        data: {'service': service, 'tag': tag},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  // --- MobiStack platform admin (oneOps BFF) ---

  Future<List<AdminWorkspace>> adminWorkspaces() =>
      _listGet('admin/platform/mobistack/workspaces', AdminWorkspace.fromJson);

  Future<void> setWorkspaceActive({
    required String id,
    required bool active,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/mobistack/workspaces/$id/${active ? 'activate' : 'suspend'}',
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> setWorkspaceScreens({
    required String id,
    required int extraScreens,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/mobistack/workspaces/$id/screens',
        data: {'extraScreens': extraScreens},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<AdminPayment>> adminBillingOrders() =>
      _listGet('admin/platform/mobistack/billing/orders', AdminPayment.fromJson);

  Future<List<AdminPlan>> adminPlans() =>
      _listGet('admin/platform/mobistack/plans', AdminPlan.fromJson);

  Future<List<AdminFeatureFlag>> adminFeatureFlags() =>
      _listGet('admin/platform/mobistack/feature-flags', AdminFeatureFlag.fromJson);

  Future<void> setFeatureFlag({
    required String code,
    required bool enabled,
  }) async {
    try {
      await _dio.put<void>(
        'admin/platform/mobistack/feature-flags',
        data: {'code': code, 'enabled': enabled},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<AdminLiveUser>> adminLiveUsers() =>
      _listGet('admin/platform/mobistack/live', AdminLiveUser.fromJson);

  Future<List<AdminSupportTicket>> adminSupportTickets() =>
      _listGet('admin/platform/mobistack/support', AdminSupportTicket.fromJson);

  Future<void> resolveSupportTicket(String id) async {
    try {
      await _dio.post<void>('admin/platform/mobistack/support/$id/resolve');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> replySupportTicket({
    required String id,
    required String body,
  }) async {
    try {
      await _dio.post<void>(
        'admin/platform/mobistack/support/$id/messages',
        data: {'body': body, 'message': body},
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<AdminAppRelease>> adminAppReleases() =>
      _listGet('admin/platform/mobistack/app-releases', AdminAppRelease.fromJson);

  Future<RevenueSnapshot> adminBillingRevenue() async {
    final res = await _get('admin/platform/mobistack/billing/revenue');
    return RevenueSnapshot.fromJson(res);
  }

  Future<RevenueSnapshot> platformBillingRevenue() async {
    final res = await _get('admin/platform/billing/revenue');
    return RevenueSnapshot.fromJson(res);
  }

  Future<AwsSummary> platformAwsSummary({String range = '30d'}) async {
    final res = await _get('admin/platform/aws/summary', query: {'range': range});
    return AwsSummary.fromJson(res);
  }

  Future<List<Ec2InstanceRow>> platformAwsInstances() async {
    final res = await _get('admin/platform/aws/instances');
    final list = res['instances'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => Ec2InstanceRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ProductHealthRow>> platformProductHealth() async {
    final res = await _get('admin/platform/health/products');
    final list = res['products'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => ProductHealthRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<GithubCheckRow>> platformGithubChecks() async {
    final res = await _get('admin/platform/github/checks');
    final list = res['checks'] as List? ?? const [];
    return list
        .whereType<Map>()
        .map((e) => GithubCheckRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<PnLSnapshot> platformPnl({
    required double mobiCaptured,
    required double oneopsCaptured,
    double? awsMtd,
  }) async {
    final res = await _get(
      'admin/platform/pnl',
      query: {
        'mobiCaptured': mobiCaptured,
        'oneopsCaptured': oneopsCaptured,
        if (awsMtd != null) 'awsMtd': awsMtd,
      },
    );
    return PnLSnapshot.fromJson(res);
  }

  Future<BillingOverview> billingOverview() async {
    final res = await _get('billing');
    return BillingOverview.fromJson(res);
  }

  Future<CheckoutOrder> createBillingOrder(String planCode) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        'billing/orders',
        data: {'planCode': planCode},
      );
      return CheckoutOrder.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> verifyBillingPayment(RazorpaySlip slip) async {
    try {
      await _dio.post<void>('billing/verify', data: slip.toJson());
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<void> confirmBillingOrder(String orderId) async {
    try {
      await _dio.post<void>('billing/orders/$orderId/confirm');
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<CursorPage<T>> _cursorPage<T>({
    required String path,
    required Map<String, dynamic> query,
    required T Function(Map<String, dynamic>) parse,
  }) async {
    try {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      final raw = res.data;
      final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final list = data['items'] as List? ?? data['content'] as List? ?? const [];
      final items = list
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
      return CursorPage(
        items: items,
        nextCursor: data['nextCursor']?.toString(),
        hasMore: data['hasMore'] == true,
      );
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<List<T>> _listGet<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final res = await _dio.get<dynamic>(path);
      return _parseMapList(res.data).map(parse).toList();
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<String> getText(String path) async {
    try {
      final res = await _dio.get<String>(
        path,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/html'},
        ),
      );
      return res.data ?? '';
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  List<Map<String, dynamic>> _parseMapList(dynamic data) {
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : (data is Map && data['content'] is List)
                ? data['content'] as List
                : const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  ApiException _map(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return ApiException(
        '${data['message']}',
        statusCode: e.response?.statusCode,
        code: data['code']?.toString(),
      );
    }
    return ApiException(
      e.message ?? 'Request failed',
      statusCode: e.response?.statusCode,
    );
  }
}
