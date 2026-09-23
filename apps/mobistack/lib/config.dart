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
    final defaultApi = kReleaseMode
        ? 'https://mobistack.prabhixtechnologies.com/api/v1'
        : 'http://10.0.2.2:8085/api/v1';
    final apiBase = apiOverride.isNotEmpty ? apiOverride : defaultApi;
    return AppConfig(
      identity: IdentityConfig.mobistack(issuer: issuer),
      product: ProductConfig.mobistack(
        apiBaseUrl: apiBase,
      ),
    );
  }
}
