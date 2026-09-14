import 'package:prabhix_mobistack_api/src/model/admin_app_release.dart';
import 'package:prabhix_mobistack_api/src/model/admin_live_user.dart';
import 'package:prabhix_mobistack_api/src/model/admin_payment.dart';
import 'package:prabhix_mobistack_api/src/model/admin_support_message.dart';
import 'package:prabhix_mobistack_api/src/model/admin_support_ticket.dart';
import 'package:prabhix_mobistack_api/src/model/authenticated_user.dart';
import 'package:prabhix_mobistack_api/src/model/billing_overview.dart';
import 'package:prabhix_mobistack_api/src/model/checkout_order_response.dart';
import 'package:prabhix_mobistack_api/src/model/flag_card.dart';
import 'package:prabhix_mobistack_api/src/model/payment_receipt.dart';
import 'package:prabhix_mobistack_api/src/model/plan_card.dart';
import 'package:prabhix_mobistack_api/src/model/revenue_snapshot.dart';
import 'package:prabhix_mobistack_api/src/model/screen_card.dart';
import 'package:prabhix_mobistack_api/src/model/subscription_card.dart';
import 'package:prabhix_mobistack_api/src/model/verify_payment_request.dart';
import 'package:prabhix_mobistack_api/src/model/workspace_admin_card.dart';

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
        case 'AdminAppRelease':
          return AdminAppRelease.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminLiveUser':
          return AdminLiveUser.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminPayment':
          return AdminPayment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminSupportMessage':
          return AdminSupportMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AdminSupportTicket':
          return AdminSupportTicket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AuthenticatedUser':
          return AuthenticatedUser.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BillingOverview':
          return BillingOverview.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CheckoutOrderResponse':
          return CheckoutOrderResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'FlagCard':
          return FlagCard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaymentReceipt':
          return PaymentReceipt.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PlanCard':
          return PlanCard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RevenueSnapshot':
          return RevenueSnapshot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ScreenCard':
          return ScreenCard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SubscriptionCard':
          return SubscriptionCard.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'VerifyPaymentRequest':
          return VerifyPaymentRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkspaceAdminCard':
          return WorkspaceAdminCard.fromJson(value as Map<String, dynamic>) as ReturnType;
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