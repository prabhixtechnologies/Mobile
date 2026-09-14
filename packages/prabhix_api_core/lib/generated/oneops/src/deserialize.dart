import 'package:prabhix_oneops_api/src/model/accept_invitation_request.dart';
import 'package:prabhix_oneops_api/src/model/ack_response.dart';
import 'package:prabhix_oneops_api/src/model/activity_item.dart';
import 'package:prabhix_oneops_api/src/model/add_cart_item_request.dart';
import 'package:prabhix_oneops_api/src/model/add_mailbox_member_request.dart';
import 'package:prabhix_oneops_api/src/model/add_team_member_request.dart';
import 'package:prabhix_oneops_api/src/model/analytics_summary.dart';
import 'package:prabhix_oneops_api/src/model/api_key_view.dart';
import 'package:prabhix_oneops_api/src/model/application_ack.dart';
import 'package:prabhix_oneops_api/src/model/assign_request.dart';
import 'package:prabhix_oneops_api/src/model/audit_log_view.dart';
import 'package:prabhix_oneops_api/src/model/auth_me_response.dart';
import 'package:prabhix_oneops_api/src/model/batch_ingest_request.dart';
import 'package:prabhix_oneops_api/src/model/billing_address_view.dart';
import 'package:prabhix_oneops_api/src/model/billing_change_response.dart';
import 'package:prabhix_oneops_api/src/model/bulk_update_request.dart';
import 'package:prabhix_oneops_api/src/model/business_hours_response.dart';
import 'package:prabhix_oneops_api/src/model/cancel_subscription_request.dart';
import 'package:prabhix_oneops_api/src/model/canned_reply_request.dart';
import 'package:prabhix_oneops_api/src/model/canned_reply_response.dart';
import 'package:prabhix_oneops_api/src/model/canned_reply_view.dart';
import 'package:prabhix_oneops_api/src/model/cart_item_view.dart';
import 'package:prabhix_oneops_api/src/model/cart_view.dart';
import 'package:prabhix_oneops_api/src/model/change_member_role_request.dart';
import 'package:prabhix_oneops_api/src/model/change_password_request.dart';
import 'package:prabhix_oneops_api/src/model/change_plan_request.dart';
import 'package:prabhix_oneops_api/src/model/change_seats_request.dart';
import 'package:prabhix_oneops_api/src/model/chart_point.dart';
import 'package:prabhix_oneops_api/src/model/checkout_request.dart';
import 'package:prabhix_oneops_api/src/model/checkout_response.dart';
import 'package:prabhix_oneops_api/src/model/commerce_dashboard_view.dart';
import 'package:prabhix_oneops_api/src/model/commerce_dashboard_view_top_products_inner.dart';
import 'package:prabhix_oneops_api/src/model/commerce_settings_view.dart';
import 'package:prabhix_oneops_api/src/model/commerce_verify_payment_response.dart';
import 'package:prabhix_oneops_api/src/model/conversation_detail.dart';
import 'package:prabhix_oneops_api/src/model/conversation_summary.dart';
import 'package:prabhix_oneops_api/src/model/create_api_key_request.dart';
import 'package:prabhix_oneops_api/src/model/create_cart_response.dart';
import 'package:prabhix_oneops_api/src/model/create_domain_request.dart';
import 'package:prabhix_oneops_api/src/model/create_invitation_request.dart';
import 'package:prabhix_oneops_api/src/model/create_mailbox_request.dart';
import 'package:prabhix_oneops_api/src/model/create_note_request.dart';
import 'package:prabhix_oneops_api/src/model/create_order_request.dart';
import 'package:prabhix_oneops_api/src/model/create_organization_request.dart';
import 'package:prabhix_oneops_api/src/model/create_request.dart';
import 'package:prabhix_oneops_api/src/model/create_role_request.dart';
import 'package:prabhix_oneops_api/src/model/create_tag_request.dart';
import 'package:prabhix_oneops_api/src/model/create_team_request.dart';
import 'package:prabhix_oneops_api/src/model/created_api_key_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_audit_log_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_conversation_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_customer_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_event_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_invoice_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_member_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_message_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_order_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_page_view_view.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_product_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_thread_summary.dart';
import 'package:prabhix_oneops_api/src/model/cursor_page_visitor_summary.dart';
import 'package:prabhix_oneops_api/src/model/custom_event_input.dart';
import 'package:prabhix_oneops_api/src/model/customer_summary.dart';
import 'package:prabhix_oneops_api/src/model/dashboard_response.dart';
import 'package:prabhix_oneops_api/src/model/device_session_view.dart';
import 'package:prabhix_oneops_api/src/model/dimension_count.dart';
import 'package:prabhix_oneops_api/src/model/discount_view.dart';
import 'package:prabhix_oneops_api/src/model/dns_record.dart';
import 'package:prabhix_oneops_api/src/model/dns_report.dart';
import 'package:prabhix_oneops_api/src/model/domain_response.dart';
import 'package:prabhix_oneops_api/src/model/download_link_response.dart';
import 'package:prabhix_oneops_api/src/model/effective_flags.dart';
import 'package:prabhix_oneops_api/src/model/email_request.dart';
import 'package:prabhix_oneops_api/src/model/event_summary.dart';
import 'package:prabhix_oneops_api/src/model/event_view.dart';
import 'package:prabhix_oneops_api/src/model/file_upload_response.dart';
import 'package:prabhix_oneops_api/src/model/generic_ack.dart';
import 'package:prabhix_oneops_api/src/model/google_sso_request.dart';
import 'package:prabhix_oneops_api/src/model/identify_request.dart';
import 'package:prabhix_oneops_api/src/model/inbox_counts.dart';
import 'package:prabhix_oneops_api/src/model/ingest_ack.dart';
import 'package:prabhix_oneops_api/src/model/invitation_preview.dart';
import 'package:prabhix_oneops_api/src/model/invitation_view.dart';
import 'package:prabhix_oneops_api/src/model/invoice_summary.dart';
import 'package:prabhix_oneops_api/src/model/job_application_request.dart';
import 'package:prabhix_oneops_api/src/model/job_role_detail.dart';
import 'package:prabhix_oneops_api/src/model/job_role_summary.dart';
import 'package:prabhix_oneops_api/src/model/kpis.dart';
import 'package:prabhix_oneops_api/src/model/lead_request.dart';
import 'package:prabhix_oneops_api/src/model/live_visitor.dart';
import 'package:prabhix_oneops_api/src/model/lmtp_request.dart';
import 'package:prabhix_oneops_api/src/model/lmtp_response.dart';
import 'package:prabhix_oneops_api/src/model/login_request.dart';
import 'package:prabhix_oneops_api/src/model/logout_request.dart';
import 'package:prabhix_oneops_api/src/model/magic_link_verify_request.dart';
import 'package:prabhix_oneops_api/src/model/mailbox_detail_response.dart';
import 'package:prabhix_oneops_api/src/model/mailbox_member_response.dart';
import 'package:prabhix_oneops_api/src/model/mailbox_response.dart';
import 'package:prabhix_oneops_api/src/model/member_view.dart';
import 'package:prabhix_oneops_api/src/model/message_summary.dart';
import 'package:prabhix_oneops_api/src/model/message_view.dart';
import 'package:prabhix_oneops_api/src/model/note_summary.dart';
import 'package:prabhix_oneops_api/src/model/notification_prefs_request.dart';
import 'package:prabhix_oneops_api/src/model/order_address_view.dart';
import 'package:prabhix_oneops_api/src/model/order_detail.dart';
import 'package:prabhix_oneops_api/src/model/order_event_view.dart';
import 'package:prabhix_oneops_api/src/model/order_item_view.dart';
import 'package:prabhix_oneops_api/src/model/order_summary.dart';
import 'package:prabhix_oneops_api/src/model/order_view.dart';
import 'package:prabhix_oneops_api/src/model/organization_view.dart';
import 'package:prabhix_oneops_api/src/model/otp_verify_request.dart';
import 'package:prabhix_oneops_api/src/model/page_response_api_key_view.dart';
import 'package:prabhix_oneops_api/src/model/page_response_invitation_view.dart';
import 'package:prabhix_oneops_api/src/model/page_response_plan_view.dart';
import 'package:prabhix_oneops_api/src/model/page_response_role_view.dart';
import 'package:prabhix_oneops_api/src/model/page_response_team_member_view.dart';
import 'package:prabhix_oneops_api/src/model/page_response_team_view.dart';
import 'package:prabhix_oneops_api/src/model/page_view_input.dart';
import 'package:prabhix_oneops_api/src/model/page_view_view.dart';
import 'package:prabhix_oneops_api/src/model/password_reset_request.dart';
import 'package:prabhix_oneops_api/src/model/payment_method_view.dart';
import 'package:prabhix_oneops_api/src/model/permission_category.dart';
import 'package:prabhix_oneops_api/src/model/permission_entry.dart';
import 'package:prabhix_oneops_api/src/model/plan_view.dart';
import 'package:prabhix_oneops_api/src/model/prabhix_principal.dart';
import 'package:prabhix_oneops_api/src/model/pre_chat_request.dart';
import 'package:prabhix_oneops_api/src/model/presence_update.dart';
import 'package:prabhix_oneops_api/src/model/preview_request.dart';
import 'package:prabhix_oneops_api/src/model/preview_response.dart';
import 'package:prabhix_oneops_api/src/model/product_detail.dart';
import 'package:prabhix_oneops_api/src/model/product_summary.dart';
import 'package:prabhix_oneops_api/src/model/refresh_request.dart';
import 'package:prabhix_oneops_api/src/model/refund_request.dart';
import 'package:prabhix_oneops_api/src/model/refund_view.dart';
import 'package:prabhix_oneops_api/src/model/register_request.dart';
import 'package:prabhix_oneops_api/src/model/reply_request.dart';
import 'package:prabhix_oneops_api/src/model/role_view.dart';
import 'package:prabhix_oneops_api/src/model/routing_rule_response.dart';
import 'package:prabhix_oneops_api/src/model/send_message_request.dart';
import 'package:prabhix_oneops_api/src/model/session_context.dart';
import 'package:prabhix_oneops_api/src/model/session_view.dart';
import 'package:prabhix_oneops_api/src/model/settings_update_request.dart';
import 'package:prabhix_oneops_api/src/model/settings_view.dart';
import 'package:prabhix_oneops_api/src/model/sse_emitter.dart';
import 'package:prabhix_oneops_api/src/model/start_conversation_response.dart';
import 'package:prabhix_oneops_api/src/model/subscribe_request.dart';
import 'package:prabhix_oneops_api/src/model/subscription_view.dart';
import 'package:prabhix_oneops_api/src/model/suppression_response.dart';
import 'package:prabhix_oneops_api/src/model/tag_response.dart';
import 'package:prabhix_oneops_api/src/model/team_member_view.dart';
import 'package:prabhix_oneops_api/src/model/team_view.dart';
import 'package:prabhix_oneops_api/src/model/template_detail_response.dart';
import 'package:prabhix_oneops_api/src/model/template_response.dart';
import 'package:prabhix_oneops_api/src/model/template_variable.dart';
import 'package:prabhix_oneops_api/src/model/thread_detail.dart';
import 'package:prabhix_oneops_api/src/model/thread_summary.dart';
import 'package:prabhix_oneops_api/src/model/time_series_point.dart';
import 'package:prabhix_oneops_api/src/model/token_response.dart';
import 'package:prabhix_oneops_api/src/model/update_billing_address_request.dart';
import 'package:prabhix_oneops_api/src/model/update_conversation_request.dart';
import 'package:prabhix_oneops_api/src/model/update_mailbox_request.dart';
import 'package:prabhix_oneops_api/src/model/update_organization_request.dart';
import 'package:prabhix_oneops_api/src/model/update_profile_request.dart';
import 'package:prabhix_oneops_api/src/model/update_role_request.dart';
import 'package:prabhix_oneops_api/src/model/update_team_request.dart';
import 'package:prabhix_oneops_api/src/model/update_template_request.dart';
import 'package:prabhix_oneops_api/src/model/update_thread_request.dart';
import 'package:prabhix_oneops_api/src/model/user_profile.dart';
import 'package:prabhix_oneops_api/src/model/variant_view.dart';
import 'package:prabhix_oneops_api/src/model/verify_payment_request.dart';
import 'package:prabhix_oneops_api/src/model/verify_payment_response.dart';
import 'package:prabhix_oneops_api/src/model/visitor_detail.dart';
import 'package:prabhix_oneops_api/src/model/visitor_summary.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'AcceptInvitationRequest':
          return AcceptInvitationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AckResponse':
          return AckResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityItem':
          return ActivityItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AddCartItemRequest':
          return AddCartItemRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AddMailboxMemberRequest':
          return AddMailboxMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AddTeamMemberRequest':
          return AddTeamMemberRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AnalyticsSummary':
          return AnalyticsSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApiKeyView':
          return ApiKeyView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApplicationAck':
          return ApplicationAck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AssignRequest':
          return AssignRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AuditLogView':
          return AuditLogView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AuthMeResponse':
          return AuthMeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BatchIngestRequest':
          return BatchIngestRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingAddressView':
          return BillingAddressView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingChangeResponse':
          return BillingChangeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingInterval':
          
          
        case 'BulkUpdateRequest':
          return BulkUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BusinessHoursResponse':
          return BusinessHoursResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CancelSubscriptionRequest':
          return CancelSubscriptionRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CannedReplyRequest':
          return CannedReplyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CannedReplyResponse':
          return CannedReplyResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CannedReplyView':
          return CannedReplyView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CartItemView':
          return CartItemView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CartView':
          return CartView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangeMemberRoleRequest':
          return ChangeMemberRoleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangePasswordRequest':
          return ChangePasswordRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangePlanRequest':
          return ChangePlanRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChangeSeatsRequest':
          return ChangeSeatsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChartPoint':
          return ChartPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckoutRequest':
          return CheckoutRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckoutResponse':
          return CheckoutResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommerceDashboardView':
          return CommerceDashboardView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommerceDashboardViewTopProductsInner':
          return CommerceDashboardViewTopProductsInner.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommerceSettingsView':
          return CommerceSettingsView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CommerceVerifyPaymentResponse':
          return CommerceVerifyPaymentResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConversationDetail':
          return ConversationDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ConversationSummary':
          return ConversationSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateApiKeyRequest':
          return CreateApiKeyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateCartResponse':
          return CreateCartResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateDomainRequest':
          return CreateDomainRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateInvitationRequest':
          return CreateInvitationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateMailboxRequest':
          return CreateMailboxRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateNoteRequest':
          return CreateNoteRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateOrderRequest':
          return CreateOrderRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateOrganizationRequest':
          return CreateOrganizationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateRequest':
          return CreateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateRoleRequest':
          return CreateRoleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateTagRequest':
          return CreateTagRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateTeamRequest':
          return CreateTeamRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreatedApiKeyView':
          return CreatedApiKeyView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageAuditLogView':
          return CursorPageAuditLogView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageConversationSummary':
          return CursorPageConversationSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageCustomerSummary':
          return CursorPageCustomerSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageEventView':
          return CursorPageEventView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageInvoiceSummary':
          return CursorPageInvoiceSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageMemberView':
          return CursorPageMemberView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageMessageView':
          return CursorPageMessageView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageOrderSummary':
          return CursorPageOrderSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPagePageViewView':
          return CursorPagePageViewView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageProductSummary':
          return CursorPageProductSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageThreadSummary':
          return CursorPageThreadSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CursorPageVisitorSummary':
          return CursorPageVisitorSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomEventInput':
          return CustomEventInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomerSummary':
          return CustomerSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DashboardResponse':
          return DashboardResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeviceSessionView':
          return DeviceSessionView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DimensionCount':
          return DimensionCount.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DiscountType':
          
          
        case 'DiscountView':
          return DiscountView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DnsRecord':
          return DnsRecord.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DnsReport':
          return DnsReport.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DomainResponse':
          return DomainResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DownloadLinkResponse':
          return DownloadLinkResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EffectiveFlags':
          return EffectiveFlags.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EmailRequest':
          return EmailRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EventSummary':
          return EventSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EventView':
          return EventView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FileUploadResponse':
          return FileUploadResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GenericAck':
          return GenericAck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GoogleSsoRequest':
          return GoogleSsoRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IdentifyRequest':
          return IdentifyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InboxCounts':
          return InboxCounts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IngestAck':
          return IngestAck.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvitationPreview':
          return InvitationPreview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvitationView':
          return InvitationView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'InvoiceSummary':
          return InvoiceSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobApplicationRequest':
          return JobApplicationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobRoleDetail':
          return JobRoleDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'JobRoleSummary':
          return JobRoleSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Kpis':
          return Kpis.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LeadRequest':
          return LeadRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LiveVisitor':
          return LiveVisitor.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LmtpRequest':
          return LmtpRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LmtpResponse':
          return LmtpResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LoginRequest':
          return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'LogoutRequest':
          return LogoutRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MagicLinkVerifyRequest':
          return MagicLinkVerifyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MailboxDetailResponse':
          return MailboxDetailResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MailboxMemberResponse':
          return MailboxMemberResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MailboxResponse':
          return MailboxResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MemberView':
          return MemberView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MessageSummary':
          return MessageSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MessageView':
          return MessageView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NoteSummary':
          return NoteSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NotificationPrefsRequest':
          return NotificationPrefsRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderAddressView':
          return OrderAddressView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderDetail':
          return OrderDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderEventView':
          return OrderEventView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderItemView':
          return OrderItemView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderSummary':
          return OrderSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrderView':
          return OrderView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OrganizationView':
          return OrganizationView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'OtpVerifyRequest':
          return OtpVerifyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseApiKeyView':
          return PageResponseApiKeyView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseInvitationView':
          return PageResponseInvitationView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponsePlanView':
          return PageResponsePlanView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseRoleView':
          return PageResponseRoleView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseTeamMemberView':
          return PageResponseTeamMemberView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageResponseTeamView':
          return PageResponseTeamView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageViewInput':
          return PageViewInput.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PageViewView':
          return PageViewView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PasswordResetRequest':
          return PasswordResetRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaymentMethodView':
          return PaymentMethodView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PermissionCategory':
          return PermissionCategory.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PermissionEntry':
          return PermissionEntry.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlanView':
          return PlanView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PrabhixPrincipal':
          return PrabhixPrincipal.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreChatRequest':
          return PreChatRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PresenceUpdate':
          return PresenceUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewRequest':
          return PreviewRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PreviewResponse':
          return PreviewResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProductDetail':
          return ProductDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProductStatus':
          
          
        case 'ProductSummary':
          return ProductSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ProductType':
          
          
        case 'RefreshRequest':
          return RefreshRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefundRequest':
          return RefundRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RefundView':
          return RefundView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RegisterRequest':
          return RegisterRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ReplyRequest':
          return ReplyRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RoleView':
          return RoleView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RoutingRuleResponse':
          return RoutingRuleResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendMessageRequest':
          return SendMessageRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SessionContext':
          return SessionContext.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SessionView':
          return SessionView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SettingsUpdateRequest':
          return SettingsUpdateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SettingsView':
          return SettingsView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SseEmitter':
          return SseEmitter.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StartConversationResponse':
          return StartConversationResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SubscribeRequest':
          return SubscribeRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SubscriptionView':
          return SubscriptionView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SuppressionResponse':
          return SuppressionResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TagResponse':
          return TagResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TeamMemberView':
          return TeamMemberView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TeamView':
          return TeamView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TemplateDetailResponse':
          return TemplateDetailResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TemplateResponse':
          return TemplateResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TemplateVariable':
          return TemplateVariable.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ThreadDetail':
          return ThreadDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ThreadSummary':
          return ThreadSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TimeSeriesPoint':
          return TimeSeriesPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'TokenResponse':
          return TokenResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateBillingAddressRequest':
          return UpdateBillingAddressRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateConversationRequest':
          return UpdateConversationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateMailboxRequest':
          return UpdateMailboxRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateOrganizationRequest':
          return UpdateOrganizationRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateProfileRequest':
          return UpdateProfileRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateRoleRequest':
          return UpdateRoleRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateTeamRequest':
          return UpdateTeamRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateTemplateRequest':
          return UpdateTemplateRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateThreadRequest':
          return UpdateThreadRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UserProfile':
          return UserProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VariantView':
          return VariantView.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyPaymentRequest':
          return VerifyPaymentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyPaymentResponse':
          return VerifyPaymentResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VisitorDetail':
          return VisitorDetail.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VisitorSummary':
          return VisitorSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }