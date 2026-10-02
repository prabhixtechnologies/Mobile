import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';

void main() {
  test('AppAuth failures do not expose platform exception text', () {
    final message = describeError(
      PlatformException(
        code: 'null_intent',
        message: 'Failed to authorize: Null intent received',
      ),
    );

    expect(message, 'Could not open secure sign-in. Try again.');
    expect(message, isNot(contains('PlatformException')));
    expect(message, isNot(contains('null_intent')));
  });
}
