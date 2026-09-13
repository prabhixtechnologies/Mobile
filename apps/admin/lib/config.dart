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
        clientId: 'prabhix-admin-android',
        applicationId: 'com.prabhix.admin',
        prompt: 'select_account',
      ),
      product: ProductConfig.platform(
        apiBaseUrl: apiBase,
        deviceHeader: 'mobile-android-admin',
      ),
    );
  }
}
