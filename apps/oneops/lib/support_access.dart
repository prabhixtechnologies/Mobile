/// Thin mobile parity with web `support-access` / `?viewAs=` staff handoff.
///
/// Stores an optional viewing organization id. The API client must send
/// `X-Prabhix-Org` with this value when set (wired via [ApiClient.orgHeaderOverride]).
/// The server decides whether the caller may name that org; this store is a request only.
import 'package:prabhix_api_core/prabhix_api_core.dart';

const kViewAsQueryParam = 'viewAs';

/// In-memory viewing-org pin for the current process.
class SupportAccess {
  SupportAccess._();

  static String? viewAsOrgId;

  static void setViewingOrg(String? organizationId) {
    final trimmed = organizationId?.trim();
    viewAsOrgId = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static void clear() => viewAsOrgId = null;

  /// Applies [viewAsOrgId] onto [api] so Dio sends `X-Prabhix-Org` for that tenant.
  static void syncToApi(ApiClient api) {
    api.orgHeaderOverride = viewAsOrgId;
  }

  /// Reads `?viewAs=<organizationId>` from a deep-link / App Link URI.
  static String? parseViewAsOrgId(Uri uri) {
    final raw = uri.queryParameters[kViewAsQueryParam]?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }
}
