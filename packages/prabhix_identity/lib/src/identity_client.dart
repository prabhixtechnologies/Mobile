import 'dart:async';

import 'package:flutter_appauth/flutter_appauth.dart';

import 'identity_config.dart';
import 'session_state.dart';
import 'token_store.dart';

/// Signs in against Prabhix Identity through the system browser / Custom Tab.
///
/// No password field. PKCE is mandatory. Refresh goes to Identity, never the product API.
class IdentityClient {
  IdentityClient({
    required this.config,
    TokenStore? tokenStore,
    FlutterAppAuth? appAuth,
  })  : tokenStore = tokenStore ?? TokenStore(),
        _appAuth = appAuth ?? const FlutterAppAuth();

  final IdentityConfig config;
  final TokenStore tokenStore;
  final FlutterAppAuth _appAuth;
  Completer<String?>? _inFlightRefresh;

  Future<OidcTokens> signIn({String? promptOverride}) async {
    final AuthorizationTokenResponse result =
        await _appAuth.authorizeAndExchangeCode(
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
        allowInsecureConnections: config.issuer.startsWith('http://'),
      ),
    );
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
          allowInsecureConnections: config.issuer.startsWith('http://'),
        ),
      );
      final access = result.accessToken;
      if (access == null) {
        await tokenStore.clear();
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
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _inFlightRefresh = null;
    }
  }

  Future<void> signOut() async {
    final idToken = await tokenStore.idToken();
    await tokenStore.clear();
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
          allowInsecureConnections: config.issuer.startsWith('http://'),
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
