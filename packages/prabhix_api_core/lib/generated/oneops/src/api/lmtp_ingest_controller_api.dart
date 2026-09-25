//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:prabhix_oneops_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:prabhix_oneops_api/src/model/lmtp_request.dart';
import 'package:prabhix_oneops_api/src/model/lmtp_response.dart';

class LmtpIngestControllerApi {

  final Dio _dio;

  const LmtpIngestControllerApi(this._dio);

  /// ingest1
  /// 
  ///
  /// Parameters:
  /// * [lmtpRequest] 
  /// * [xMailToken] 
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [LmtpResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<LmtpResponse>> ingest1({ 
    required LmtpRequest lmtpRequest,
    String? xMailToken,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/oneops/mail/inbound/lmtp';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        if (xMailToken != null) r'X-Mail-Token': xMailToken,
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = jsonEncode(lmtpRequest);

    } catch(error, stackTrace) {
      throw DioException(
         requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    LmtpResponse? _responseData;

    try {
final rawData = _response.data;
_responseData = rawData == null ? null : deserialize<LmtpResponse, LmtpResponse>(rawData, 'LmtpResponse', growable: true);

    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<LmtpResponse>(
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
