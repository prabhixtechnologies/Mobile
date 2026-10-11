/// How long the phone keeps working after the last successful sign-in refresh.
/// Matches Identity's refresh-token lifetime.
const sessionLease = Duration(days: 30);

/// A day of connectivity should rotate the refresh token, which starts another 30 days.
const sessionExtendAfter = Duration(hours: 12);

class SessionState {
  const SessionState({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtEpochMs,
    this.leaseExtendedAtEpochMs = 0,
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

  /// When a refresh last succeeded. Zero means this install has not stamped a lease yet.
  final int leaseExtendedAtEpochMs;
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

  /// The phone may keep showing the last saved shop until this is false.
  bool coversLease([DateTime? now]) {
    if (leaseExtendedAtEpochMs <= 0) return true;
    final clock = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return clock < leaseExtendedAtEpochMs + sessionLease.inMilliseconds;
  }

  /// True when a successful refresh would start a new 30-day server token.
  bool dueForExtension([DateTime? now]) {
    if (leaseExtendedAtEpochMs <= 0) return true;
    final clock = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return clock >= leaseExtendedAtEpochMs + sessionExtendAfter.inMilliseconds;
  }

  SessionState copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresAtEpochMs,
    int? leaseExtendedAtEpochMs,
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
      leaseExtendedAtEpochMs: leaseExtendedAtEpochMs ?? this.leaseExtendedAtEpochMs,
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
