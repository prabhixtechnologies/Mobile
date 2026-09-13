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
            // Platform admin routes are cross-tenant — do not attach a customer org.
            final isPlatformAdminPath = options.path.contains('admin/platform') ||
                options.path.contains('admin/site') ||
                options.path.startsWith('event-logs');
            final session = await identity.tokenStore.session();
            final org = session?.organizationId;
            if (!isPlatformAdminPath && org != null && org.isNotEmpty) {
              options.headers[config.orgHeaderName] = org;
            } else {
              options.headers.remove(config.orgHeaderName);
            }
            options.headers[config.deviceHeaderName] =
                await identity.tokenStore.deviceId();
            options.headers['X-Correlation-Id'] = const Uuid().v4();
            options.headers['X-Prabhix-Device-Label'] = config.deviceHeader;
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

  Dio get dio => _dio;

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
      await _dio.post<void>('organizations/$organizationId/select');
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

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await _dio.get<dynamic>(path);
      final data = res.data;
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } on DioException catch (e) {
      throw _map(e);
    }
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
