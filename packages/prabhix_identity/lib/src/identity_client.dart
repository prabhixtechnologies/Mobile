import 'dart:async';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'identity_config.dart';
import 'issuer_policy.dart';
import 'session_state.dart';
import 'token_store.dart';

typedef UrlOpener = Future<bool> Function(Uri uri);

/// The person closed the sign-in page before finishing. Nothing failed.
class SignInCancelled implements Exception {
  const SignInCancelled();

  @override
  String toString() => 'Sign-in was cancelled.';
}

/// Signs in against Prabhix Identity through the system browser / Custom Tab.
///
/// No password field. PKCE is mandatory. Refresh goes to Identity, never the product API.
class IdentityClient {
  IdentityClient({
    required this.config,
    TokenStore? tokenStore,
    FlutterAppAuth? appAuth,
    UrlOpener? openUrl,
  })  : tokenStore = tokenStore ?? TokenStore(),
        _appAuth = appAuth ?? const FlutterAppAuth(),
        _openUrl = openUrl;

  final IdentityConfig config;
  final TokenStore tokenStore;
  final FlutterAppAuth _appAuth;
  final UrlOpener? _openUrl;
  Completer<String?>? _inFlightRefresh;

  /// Opens `{issuer}/account?return_to=...` in the system browser.
  Future<bool> openAccount({String? returnTo}) {
    final uri = config.accountUri(returnTo: returnTo);
    final opener = _openUrl ?? _launchExternal;
    return opener(uri);
  }

  static Future<bool> _launchExternal(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<OidcTokens> signIn({String? promptOverride}) async {
    final AuthorizationTokenResponse result;
    try {
      result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          config.clientId,
          config.redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: config.authorizeEndpoint,
            tokenEndpoint: config.tokenEndpoint,
            endSessionEndpoint: config.endSessionEndpoint,
          ),
          scopes: config.scopes,
          promptValues: _promptList(promptOverride ?? config.prompt),
          allowInsecureConnections: identityAllowsInsecureConnections(config.issuer),
        ),
      );
    } on FlutterAppAuthUserCancelledException {
      throw const SignInCancelled();
    }
    final access = result.accessToken;
    final refresh = result.refreshToken;
    if (access == null || refresh == null) {
      throw StateError('Identity returned no tokens');
    }
    final tokens = OidcTokens(
      accessToken: access,
      refreshToken: refresh,
      idToken: result.idToken,
      expiresAtEpochMs: _expiresAt(result.accessTokenExpirationDateTime),
    );
    await tokenStore.saveOidcTokens(tokens);
    return tokens;
  }

  Future<String?> refreshIfNeeded({bool force = false}) async {
    if (!force) {
      final cached = tokenStore.cachedSession;
      if (cached != null && cached.accessTokenFresh) {
        return cached.accessToken;
      }
    }
    if (_inFlightRefresh != null) {
      return _inFlightRefresh!.future;
    }
    final completer = Completer<String?>();
    _inFlightRefresh = completer;
    try {
      final session = await tokenStore.session();
      if (session == null) {
        completer.complete(null);
        return null;
      }
      if (!force && session.accessTokenFresh) {
        completer.complete(session.accessToken);
        return session.accessToken;
      }
      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          config.clientId,
          config.redirectUri,
          refreshToken: session.refreshToken,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: config.authorizeEndpoint,
            tokenEndpoint: config.tokenEndpoint,
            endSessionEndpoint: config.endSessionEndpoint,
          ),
          allowInsecureConnections: identityAllowsInsecureConnections(config.issuer),
        ),
      );
      final access = result.accessToken;
      if (access == null) {
        await tokenStore.clearAuthSecrets();
        completer.complete(null);
        return null;
      }
      final tokens = OidcTokens(
        accessToken: access,
        refreshToken: result.refreshToken ?? session.refreshToken,
        idToken: result.idToken ?? session.idToken,
        expiresAtEpochMs: _expiresAt(result.accessTokenExpirationDateTime),
      );
      await tokenStore.saveOidcTokens(tokens);
      completer.complete(tokens.accessToken);
      return tokens.accessToken;
    } on FlutterAppAuthPlatformException catch (e, st) {
      // Identity refused the refresh token: the account is gone or its sign-in was revoked.
      // Retrying cannot help, so the session ends here instead of failing every request.
      if (e.platformErrorDetails.error == 'invalid_grant') {
        await tokenStore.clearAuthSecrets();
        completer.complete(null);
        return null;
      }
      completer.completeError(e, st);
      rethrow;
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _inFlightRefresh = null;
    }
  }

  /// Asks Identity for a fresh proof. Sensitive actions call this, then retry.
  Future<OidcTokens> stepUp() {
    return signIn(promptOverride: 'login');
  }

  Future<void> signOut() async {
    final idToken = await tokenStore.idToken();
    await tokenStore.clearAuthSecrets();
    if (idToken == null) return;
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: config.postLogoutRedirectUri ?? config.redirectUri,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: config.authorizeEndpoint,
            tokenEndpoint: config.tokenEndpoint,
            endSessionEndpoint: config.endSessionEndpoint,
          ),
          allowInsecureConnections: identityAllowsInsecureConnections(config.issuer),
        ),
      );
    } catch (_) {
      // Local session already cleared.
    }
  }

  static List<String>? _promptList(String? prompt) {
    if (prompt == null || prompt.isEmpty) return null;
    return [prompt];
  }

  static int _expiresAt(DateTime? expiration) {
    if (expiration != null) return expiration.millisecondsSinceEpoch;
    return DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch;
  }
}
