import 'package:flutter/foundation.dart';
import 'package:prabhix_client/prabhix_client.dart';

import 'config.dart';

/// Verified HTTPS App Link host for chat handoff.
const kVerifiedOneOpsAppLinkHost = 'oneops.prabhixtechnologies.com';

/// Parses `prabhix://chat/{id}` or `https://oneops.prabhixtechnologies.com/chat/{id}`.
///
/// Returns a validated conversation id, or null when the URI is not an allowed handoff.
String? parseOneOpsChatDeepLink(Uri uri) {
  final raw = _rawChatId(uri);
  if (raw == null) return null;
  return validatedDeepLinkId(raw);
}

String? _rawChatId(Uri uri) {
  if (uri.scheme == kDeepLinkScheme) {
    return _customSchemeChatId(uri);
  }
  if (uri.scheme == 'https') {
    return _verifiedHttpsChatId(uri);
  }
  if (!kReleaseMode && uri.scheme == 'http') {
    return _verifiedHttpsChatId(uri);
  }
  return null;
}

String? _customSchemeChatId(Uri uri) {
  // Frozen handoff: `prabhix://chat/{id}` (host is `chat`, single path segment).
  if (uri.host != 'chat') return null;
  final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
  if (segments.length != 1) return null;
  return segments.first;
}

String? _verifiedHttpsChatId(Uri uri) {
  if (!_isVerifiedAppLinkHost(uri)) return null;
  final segments = uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
  if (segments.length != 2) return null;
  if (segments[0] != 'chat') return null;
  if (uri.query.isNotEmpty || uri.fragment.isNotEmpty) return null;
  return segments[1];
}

bool isVerifiedOneOpsAppLinkUri(Uri uri) {
  if (kReleaseMode && uri.scheme != 'https') return false;
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;
  if (uri.userInfo.isNotEmpty) return false;
  return uri.host.toLowerCase() == kVerifiedOneOpsAppLinkHost;
}

bool _isVerifiedAppLinkHost(Uri uri) => isVerifiedOneOpsAppLinkUri(uri);
