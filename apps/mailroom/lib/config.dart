import 'package:flutter/foundation.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';

class AppConfig {
  const AppConfig({
    required this.identity,
    required this.product,
  });

  final IdentityConfig identity;
  final ProductConfig product;

  factory AppConfig.fromEnvironment() {
    const issuerOverride = String.fromEnvironment('IDENTITY_ISSUER');
    const apiOverride = String.fromEnvironment('API_BASE_URL');
    final issuer = issuerOverride.isNotEmpty
        ? issuerOverride
        : (kReleaseMode
            ? 'https://api.prabhixtechnologies.com'
            : 'http://10.0.2.2:8081');
    final apiBase = apiOverride.isNotEmpty
        ? apiOverride
        : (kReleaseMode
            ? 'https://api.prabhixtechnologies.com/api/v1'
            : 'http://10.0.2.2:8080/api/v1');
    return AppConfig(
      identity: IdentityConfig.applicationIdScheme(
        issuer: issuer,
        clientId: 'prabhix-mailroom-android',
        applicationId: 'com.prabhix.mailroom',
      ),
      product: ProductConfig.platform(
        apiBaseUrl: apiBase,
        deviceHeader: 'mobile-android-mailroom',
      ),
    );
  }
}
