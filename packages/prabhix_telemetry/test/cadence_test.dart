import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_telemetry/prabhix_telemetry.dart';

void main() {
  group('shouldFlush', () {
    test('first run flushes', () {
      expect(
        shouldFlush(const FlushPolicyState(), DateTime(2026, 1, 1)),
        isTrue,
      );
    });

    test('waits 24h after success', () {
      final t0 = DateTime(2026, 1, 1, 12);
      final state = FlushPolicyState(
        lastSuccessAt: t0,
        lastAttemptAt: t0,
      );
      expect(shouldFlush(state, t0.add(const Duration(hours: 23))), isFalse);
      expect(shouldFlush(state, t0.add(const Duration(hours: 24))), isTrue);
    });

    test('retries 1h after failure', () {
      final t0 = DateTime(2026, 1, 1, 12);
      final state = FlushPolicyState(
        lastFailureAt: t0,
        lastAttemptAt: t0,
      );
      expect(shouldFlush(state, t0.add(const Duration(minutes: 59))), isFalse);
      expect(shouldFlush(state, t0.add(const Duration(hours: 1))), isTrue);
    });
  });

  group('scrubProps', () {
    test('strips sensitive keys', () {
      final scrubbed = scrubProps({
        'screen': 'Inbox',
        'password': 'x',
        'access_token': 'y',
        'Authorization': 'Bearer z',
        'count': 2,
      });
      expect(scrubbed, equals({'screen': 'Inbox', 'count': 2}));
    });
  });
}
