import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';

import 'app_release_policy.dart';

/// Why the person must sign in again (security cutover vs ordinary expiry).
enum SecuritySignInReason {
  sessionReplaced,
  tokenRevoked,
  unknown,
}

/// Blocks the app until the person upgrades or signs in again after a security event.
class ClientRecoveryController extends ChangeNotifier {
  ClientRecoveryController({
    required this.identity,
    this.appReleasePublicBase,
    this.appReleaseAppId,
    this.includeAppReleaseAppId = true,
    this.onSecuritySignIn,
  });

  final IdentityClient identity;
  final String? appReleasePublicBase;

  /// e.g. `oneops`, `admin`, `mailroom`, `mobistack` (MobiStack backend may ignore).
  final String? appReleaseAppId;
  final bool includeAppReleaseAppId;
  final Future<void> Function(SecuritySignInReason reason)? onSecuritySignIn;

  UpgradeGate? upgradeGate;
  SecuritySignInReason? pendingSecuritySignIn;
  String? journeyError;

  bool get blocksApp => upgradeGate != null || pendingSecuritySignIn != null;

  Future<void> checkReleasePolicy() async {
    final base = appReleasePublicBase;
    if (base == null || base.isEmpty) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final build = int.tryParse(info.buildNumber) ?? 0;
      final policy = await fetchAppReleasePolicy(
        publicApiBase: base,
        nativeBuild: build,
        appId: appReleaseAppId,
        includeAppId: includeAppReleaseAppId,
      );
      if (policy == null) return;
      if (!policy.updateRequired) {
        if (upgradeGate != null) {
          upgradeGate = null;
          notifyListeners();
        }
        return;
      }
      upgradeGate = UpgradeGate(
        policy: policy,
        currentBuild: build,
      );
      notifyListeners();
    } catch (e, st) {
      debugPrint('release policy check skipped: $e\n$st');
    }
  }

  /// Clears OIDC secrets only; offline business data stays on disk.
  Future<void> clearAuthSecrets() => identity.tokenStore.clearAuthSecrets();

  Future<void> handleApiException(ApiException error) async {
    final code = error.code?.toUpperCase();
    if (code == null) return;
    if (code == 'SESSION_REPLACED' || code == 'TOKEN_REVOKED') {
      final reason = code == 'SESSION_REPLACED'
          ? SecuritySignInReason.sessionReplaced
          : SecuritySignInReason.tokenRevoked;
      await onSecurityTokenRevoked(reason);
    }
  }

  /// After a forced revocation: drop auth secrets only, re-check minimum version, then sign-in UI.
  Future<void> onSecurityTokenRevoked(SecuritySignInReason reason) async {
    await clearAuthSecrets();
    await checkReleasePolicy();
    pendingSecuritySignIn = reason;
    notifyListeners();
    await onSecuritySignIn?.call(reason);
  }

  /// Call at startup before reading tokens. Returns false when an upgrade gate blocks the app.
  Future<bool> passReleaseGateOnStartup() async {
    await checkReleasePolicy();
    return upgradeGate == null;
  }

  void noteJourneyFailure(String message) {
    journeyError = message;
    notifyListeners();
  }

  void clearJourneyFailure() {
    if (journeyError == null) return;
    journeyError = null;
    notifyListeners();
  }

  void dismissSecuritySignIn() {
    pendingSecuritySignIn = null;
    notifyListeners();
  }

  void dismissUpgradeGate() {
    upgradeGate = null;
    notifyListeners();
  }
}

class UpgradeGate {
  const UpgradeGate({
    required this.policy,
    required this.currentBuild,
  });

  final AppReleasePolicy policy;
  final int currentBuild;
}

ClientRecoveryController attachRecoveryToApi(
  ApiClient api,
  ClientRecoveryController recovery,
) {
  api.recoveryHandler = recovery.handleApiException;
  return recovery;
}
