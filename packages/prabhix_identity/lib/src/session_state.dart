class SessionState {
  const SessionState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtEpochMs,
    this.idToken,
    this.organizationId,
    this.permissions = const {},
    this.userId,
    this.displayName,
    this.email,
    this.platformAdmin = false,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresAtEpochMs;
  final String? idToken;
  final String? organizationId;
  final Set<String> permissions;
  final String? userId;
  final String? displayName;
  final String? email;
  final bool platformAdmin;

  bool get accessTokenFresh {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now < expiresAtEpochMs - 60 * 1000;
  }

  SessionState copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresAtEpochMs,
    String? idToken,
    String? organizationId,
    Set<String>? permissions,
    String? userId,
    String? displayName,
    String? email,
    bool? platformAdmin,
  }) {
    return SessionState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAtEpochMs: expiresAtEpochMs ?? this.expiresAtEpochMs,
      idToken: idToken ?? this.idToken,
      organizationId: organizationId ?? this.organizationId,
      permissions: permissions ?? this.permissions,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      platformAdmin: platformAdmin ?? this.platformAdmin,
    );
  }
}

class OidcTokens {
  const OidcTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtEpochMs,
    this.idToken,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresAtEpochMs;
  final String? idToken;
}
