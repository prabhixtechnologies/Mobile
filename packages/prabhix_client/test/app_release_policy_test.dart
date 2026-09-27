import 'package:flutter_test/flutter_test.dart';
import 'package:prabhix_client/prabhix_client.dart';

void main() {
  test('parses server policy without forcing when update not required', () {
    final policy = AppReleasePolicy.fromJson({
      'platform': 'ANDROID',
      'minNativeBuild': 1,
      'latestNativeBuild': 8,
      'forceNativeUpdate': false,
      'updateRequired': false,
    });
    expect(policy.updateRequired, isFalse);
    expect(policy.minNativeBuild, 1);
  });

  test('buildAppReleaseQuery adds app for OneOps family clients', () {
    expect(
      buildAppReleaseQuery(nativeBuild: 3, appId: 'oneops'),
      {'platform': 'ANDROID', 'build': 3, 'app': 'oneops'},
    );
  });

  test('buildAppReleaseQuery can omit app for MobiStack', () {
    expect(
      buildAppReleaseQuery(
        nativeBuild: 8,
        appId: 'mobistack',
        includeAppId: false,
      ),
      {'platform': 'ANDROID', 'build': 8},
    );
  });
}
