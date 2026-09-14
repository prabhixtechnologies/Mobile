import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Live check against a local seeded stack.
///
/// Env (PowerShell):
///   $env:INTEGRATION = "1"
///   $env:IDENTITY_ISSUER = "http://127.0.0.1:8081"
///   $env:API_BASE_URL = "http://127.0.0.1:8080/api/v1"
///   flutter test test/integration_stack_test.dart
///
/// Skipped unless INTEGRATION=1 so CI without Docker still passes.
bool get _run =>
    Platform.environment['INTEGRATION'] == '1' ||
    Platform.environment['INTEGRATION'] == 'true';

Uri _health(String origin) {
  final trimmed = origin.replaceAll(RegExp(r'/+$'), '');
  return Uri.parse('$trimmed/actuator/health');
}

String _apiOrigin(String apiBase) {
  var origin = apiBase.replaceAll(RegExp(r'/+$'), '');
  if (origin.endsWith('/api/v1')) {
    origin = origin.substring(0, origin.length - '/api/v1'.length);
  }
  return origin;
}

Future<int> _status(Uri uri) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    final res = await req.close();
    await res.drain<void>();
    return res.statusCode;
  } finally {
    client.close(force: true);
  }
}

void main() {
  test(
    'seeded Identity and Admin BFF are up',
    () async {
      final issuer =
          Platform.environment['IDENTITY_ISSUER'] ?? 'http://127.0.0.1:8081';
      final apiBase =
          Platform.environment['API_BASE_URL'] ?? 'http://127.0.0.1:8080/api/v1';
      expect(await _status(_health(issuer)), lessThan(500));
      expect(await _status(_health(_apiOrigin(apiBase))), lessThan(500));
    },
    skip: _run
        ? false
        : 'Set INTEGRATION=1 against a local seeded stack (Identity + OneOps admin BFF).',
  );
}
