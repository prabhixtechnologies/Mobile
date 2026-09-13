/// Build-time Identity OIDC configuration for one Prabhix mobile app.
class IdentityConfig {
  const IdentityConfig({
    required this.issuer,
    required this.clientId,
    required this.redirectUri,
    this.postLogoutRedirectUri,
    this.prompt,
    this.scopes = const ['openid', 'profile', 'email'],
  });

  /// e.g. `https://api.prabhixtechnologies.com` or `http://10.0.2.2:8081`
  final String issuer;

  /// Seeded client id, e.g. `prabhix-admin-android`.
  final String clientId;

  /// Exact redirect registered in Identity, e.g. `com.prabhix.admin:/oauth2redirect`.
  final String redirectUri;

  /// Optional end-session return URI (same scheme family as [redirectUri]).
  final String? postLogoutRedirectUri;

  /// e.g. `select_account` for Admin, `create` for signup.
  final String? prompt;

  final List<String> scopes;

  String get authorizeEndpoint => '$issuer/oauth2/authorize';
  String get tokenEndpoint => '$issuer/oauth2/token';
  String get endSessionEndpoint => '$issuer/connect/logout';

  /// OneOps / Admin / Mailroom style: scheme == applicationId.
  factory IdentityConfig.applicationIdScheme({
    required String issuer,
    required String clientId,
    required String applicationId,
    String? prompt,
  }) {
    final redirect = '$applicationId:/oauth2redirect';
    return IdentityConfig(
      issuer: issuer.replaceAll(RegExp(r'/+$'), ''),
      clientId: clientId,
      redirectUri: redirect,
      postLogoutRedirectUri: redirect,
      prompt: prompt,
    );
  }

  /// MobiStack: OAuth scheme is `mobistack`, not `app.prabhix.fixflow`.
  factory IdentityConfig.mobistack({
    required String issuer,
    String clientId = 'prabhix-mobistack-android',
  }) {
    const redirect = 'mobistack://oauth2redirect';
    return IdentityConfig(
      issuer: issuer.replaceAll(RegExp(r'/+$'), ''),
      clientId: clientId,
      redirectUri: redirect,
      postLogoutRedirectUri: redirect,
    );
  }
}
