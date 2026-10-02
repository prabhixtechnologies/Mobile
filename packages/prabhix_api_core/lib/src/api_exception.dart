import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

/// What to show a person when a call fails: the server's own sentence when it sent one,
/// otherwise a plain line for the kind of failure. Never Dio's developer text.
String describeError(Object error) {
  if (error is ApiException) return error.message;
  if (error is PlatformException) {
    return switch (error.code) {
      'authorize_and_exchange_code_failed' ||
      'authorize_failed' ||
      'null_intent' =>
        'Could not open secure sign-in. Try again.',
      _ => 'The phone could not complete that action. Try again.',
    };
  }
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['detail'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) return message.trim();
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to answer. Check the connection and try again.';
      case DioExceptionType.connectionError:
        return 'No connection to the server. Check the internet and try again.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      default:
        break;
    }
    final status = error.response?.statusCode;
    return switch (status) {
      401 => 'Your session has ended. Sign in again.',
      402 => 'This shop plan does not include this. Open Billing to upgrade.',
      403 => 'Your role in this shop does not allow this.',
      404 => 'That was not found on the server.',
      null => 'The request failed. Try again.',
      _ when status >= 500 => 'The server had a problem ($status). Try again in a minute.',
      _ => 'The request failed ($status).',
    };
  }
  final text = '$error';
  return text.startsWith('Exception: ') ? text.substring(11) : text;
}
