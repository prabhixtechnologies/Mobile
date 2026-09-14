//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:prabhix_oneops_api/src/auth/api_key_auth.dart';
import 'package:prabhix_oneops_api/src/auth/basic_auth.dart';
import 'package:prabhix_oneops_api/src/auth/bearer_auth.dart';
import 'package:prabhix_oneops_api/src/auth/oauth.dart';
import 'package:prabhix_oneops_api/src/api/api_key_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/audit_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/auth_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/billing_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/canned_reply_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/chat_api.dart';
import 'package:prabhix_oneops_api/src/api/chat_public_api.dart';
import 'package:prabhix_oneops_api/src/api/chat_stream_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/commerce_api.dart';
import 'package:prabhix_oneops_api/src/api/commerce_public_api.dart';
import 'package:prabhix_oneops_api/src/api/dashboard_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/feature_flag_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/file_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/invitation_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/lmtp_ingest_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/mail_domain_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/mail_stream_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/mailbox_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/member_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/organization_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/organization_select_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/permission_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/razorpay_webhook_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/role_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/site_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/suppression_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/tag_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/team_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/template_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/thread_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/tracking_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/user_controller_api.dart';
import 'package:prabhix_oneops_api/src/api/visitor_tracking_public_api.dart';
import 'package:prabhix_oneops_api/src/api/visitors_api.dart';

class PrabhixOneopsApi {
  static const String basePath = r'http://localhost:8080';

  final Dio dio;
  PrabhixOneopsApi({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : 
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens.remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens.remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo.remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys.remove(name);
    }
  }

  /// Get ApiKeyControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ApiKeyControllerApi getApiKeyControllerApi() {
    return ApiKeyControllerApi(dio);
  }

  /// Get AuditControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuditControllerApi getAuditControllerApi() {
    return AuditControllerApi(dio);
  }

  /// Get AuthControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthControllerApi getAuthControllerApi() {
    return AuthControllerApi(dio);
  }

  /// Get BillingControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BillingControllerApi getBillingControllerApi() {
    return BillingControllerApi(dio);
  }

  /// Get CannedReplyControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CannedReplyControllerApi getCannedReplyControllerApi() {
    return CannedReplyControllerApi(dio);
  }

  /// Get ChatApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ChatApi getChatApi() {
    return ChatApi(dio);
  }

  /// Get ChatPublicApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ChatPublicApi getChatPublicApi() {
    return ChatPublicApi(dio);
  }

  /// Get ChatStreamControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ChatStreamControllerApi getChatStreamControllerApi() {
    return ChatStreamControllerApi(dio);
  }

  /// Get CommerceApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CommerceApi getCommerceApi() {
    return CommerceApi(dio);
  }

  /// Get CommercePublicApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CommercePublicApi getCommercePublicApi() {
    return CommercePublicApi(dio);
  }

  /// Get DashboardControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DashboardControllerApi getDashboardControllerApi() {
    return DashboardControllerApi(dio);
  }

  /// Get FeatureFlagControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FeatureFlagControllerApi getFeatureFlagControllerApi() {
    return FeatureFlagControllerApi(dio);
  }

  /// Get FileControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  FileControllerApi getFileControllerApi() {
    return FileControllerApi(dio);
  }

  /// Get InvitationControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  InvitationControllerApi getInvitationControllerApi() {
    return InvitationControllerApi(dio);
  }

  /// Get LmtpIngestControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  LmtpIngestControllerApi getLmtpIngestControllerApi() {
    return LmtpIngestControllerApi(dio);
  }

  /// Get MailDomainControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MailDomainControllerApi getMailDomainControllerApi() {
    return MailDomainControllerApi(dio);
  }

  /// Get MailStreamControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MailStreamControllerApi getMailStreamControllerApi() {
    return MailStreamControllerApi(dio);
  }

  /// Get MailboxControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MailboxControllerApi getMailboxControllerApi() {
    return MailboxControllerApi(dio);
  }

  /// Get MemberControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MemberControllerApi getMemberControllerApi() {
    return MemberControllerApi(dio);
  }

  /// Get OrganizationControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OrganizationControllerApi getOrganizationControllerApi() {
    return OrganizationControllerApi(dio);
  }

  /// Get OrganizationSelectControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OrganizationSelectControllerApi getOrganizationSelectControllerApi() {
    return OrganizationSelectControllerApi(dio);
  }

  /// Get PermissionControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PermissionControllerApi getPermissionControllerApi() {
    return PermissionControllerApi(dio);
  }

  /// Get RazorpayWebhookControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RazorpayWebhookControllerApi getRazorpayWebhookControllerApi() {
    return RazorpayWebhookControllerApi(dio);
  }

  /// Get RoleControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RoleControllerApi getRoleControllerApi() {
    return RoleControllerApi(dio);
  }

  /// Get SiteControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SiteControllerApi getSiteControllerApi() {
    return SiteControllerApi(dio);
  }

  /// Get SuppressionControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SuppressionControllerApi getSuppressionControllerApi() {
    return SuppressionControllerApi(dio);
  }

  /// Get TagControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TagControllerApi getTagControllerApi() {
    return TagControllerApi(dio);
  }

  /// Get TeamControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TeamControllerApi getTeamControllerApi() {
    return TeamControllerApi(dio);
  }

  /// Get TemplateControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TemplateControllerApi getTemplateControllerApi() {
    return TemplateControllerApi(dio);
  }

  /// Get ThreadControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ThreadControllerApi getThreadControllerApi() {
    return ThreadControllerApi(dio);
  }

  /// Get TrackingControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TrackingControllerApi getTrackingControllerApi() {
    return TrackingControllerApi(dio);
  }

  /// Get UserControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UserControllerApi getUserControllerApi() {
    return UserControllerApi(dio);
  }

  /// Get VisitorTrackingPublicApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  VisitorTrackingPublicApi getVisitorTrackingPublicApi() {
    return VisitorTrackingPublicApi(dio);
  }

  /// Get VisitorsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  VisitorsApi getVisitorsApi() {
    return VisitorsApi(dio);
  }
}
