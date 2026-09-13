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
    const issuer = String.fromEnvironment(
      'IDENTITY_ISSUER',
      defaultValue: 'http://10.0.2.2:8081',
    );
    const apiBase = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080/api/v1',
    );
    return AppConfig(
      identity: IdentityConfig.applicationIdScheme(
        issuer: issuer,
        clientId: 'prabhix-oneops-android',
        applicationId: 'com.prabhix.operator',
      ),
      product: ProductConfig.platform(
        apiBaseUrl: apiBase,
        deviceHeader: 'mobile-android',
      ),
    );
  }

  String get apiHostBase {
    final url = product.apiBaseUrl;
    if (url.endsWith('/api/v1')) return url.substring(0, url.length - '/api/v1'.length);
    if (url.endsWith('/api/v1/')) return url.substring(0, url.length - '/api/v1/'.length);
    return url;
  }
}

/// Deep-link scheme for chat handoff: `prabhix://chat/{id}`.
const kDeepLinkScheme = 'prabhix';

bool get isDebugBuild => kDebugMode;
