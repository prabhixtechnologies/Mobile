import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_identity/prabhix_identity.dart';

void main() {
  test('applicationIdScheme builds redirect from package id', () {
    final config = IdentityConfig.applicationIdScheme(
      issuer: 'http://10.0.2.2:8081/',
      clientId: 'prabhix-admin-android',
      applicationId: 'com.prabhix.admin',
      prompt: 'select_account',
    );
    expect(config.issuer, 'http://10.0.2.2:8081');
    expect(config.redirectUri, 'com.prabhix.admin:/oauth2redirect');
    expect(config.prompt, 'select_account');
    expect(config.authorizeEndpoint, endsWith('/oauth2/authorize'));
  });

  test('mobistack uses mobistack oauth scheme', () {
    final config = IdentityConfig.mobistack(issuer: 'https://api.prabhixtechnologies.com');
    expect(config.redirectUri, 'mobistack://oauth2redirect');
    expect(config.clientId, 'prabhix-mobistack-android');
  });
}
