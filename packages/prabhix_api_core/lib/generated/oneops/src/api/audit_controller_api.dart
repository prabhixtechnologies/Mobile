//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:prabhix_oneops_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:prabhix_oneops_api/src/model/cursor_page_audit_log_view.dart';
import 'package:prabhix_oneops_api/src/model/prabhix_principal.dart';

class AuditControllerApi {

  final Dio _dio;

  const AuditControllerApi(this._dio);

  /// list16
  /// 
  ///
  /// Parameters:
  /// * [principal] 
  /// * [action] 
  /// * [actorUserId] 
  /// * [resourceType] 
  /// * [from] 
  /// * [to] 
  /// * [cursor] 
  /// * [limit] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [CursorPageAuditLogView] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<CursorPageAuditLogView>> list16({ 
    required PrabhixPrincipal principal,
    String? action,
    String? actorUserId,
    String? resourceType,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int? limit,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/oneops/audit-logs';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'principal': principal,
      if (action != null) r'action': action,
      if (actorUserId != null) r'actorUserId': actorUserId,
      if (resourceType != null) r'resourceType': resourceType,
      if (from != null) r'from': from,
      if (to != null) r'to': to,
      if (cursor != null) r'cursor': cursor,
      if (limit != null) r'limit': limit,
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    CursorPageAuditLogView? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<CursorPageAuditLogView, CursorPageAuditLogView>(rawData, 'CursorPageAuditLogView', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<CursorPageAuditLogView>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

}
