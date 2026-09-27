import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_identity/prabhix_identity.dart';

void main() {
  test('debug allows http issuer', () {
    expect(
      requireSecureIdentityIssuer('http://10.0.2.2:8081'),
      'http://10.0.2.2:8081',
    );
  });

  test('release rejects http issuer', () {
    expect(
      () => requireSecureIdentityIssuer(
        'http://10.0.2.2:8081',
        allowInsecure: false,
      ),
      throwsA(isA<InsecureIdentityIssuerException>()),
    );
  });
}
