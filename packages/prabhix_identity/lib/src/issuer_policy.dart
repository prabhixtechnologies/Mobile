import 'package:flutter/foundation.dart';

/// Release builds must not talk to Identity over plain HTTP.
class InsecureIdentityIssuerException implements Exception {
  InsecureIdentityIssuerException(this.issuer);

  final String issuer;

  @override
  String toString =>
      'Release builds require HTTPS Identity (got $issuer). Use --dart-define=IDENTITY_ISSUER only for local debug.';
}

/// Returns [issuer] when allowed; throws in release when the issuer is not HTTPS.
String requireSecureIdentityIssuer(
  String issuer, {
  bool allowInsecure = kDebugMode,
}) {
  final trimmed = issuer.replaceAll(RegExp(r'/+$'), '');
  final insecure = trimmed.startsWith('http://');
  if (insecure && !allowInsecure) {
    throw InsecureIdentityIssuerException(trimmed);
  }
  return trimmed;
}

bool identityAllowsInsecureConnections(String issuer) {
  return kDebugMode && issuer.startsWith('http://');
}
