import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_client/prabhix_client.dart';

void main() {
  test('accepts UUID chat ids', () {
    expect(
      isValidDeepLinkId('550e8400-e29b-41d4-a716-446655440000'),
      isTrue,
    );
  });

  test('rejects path traversal', () {
    expect(isValidDeepLinkId('../admin'), isFalse);
    expect(isValidDeepLinkId(''), isFalse);
  });
}
