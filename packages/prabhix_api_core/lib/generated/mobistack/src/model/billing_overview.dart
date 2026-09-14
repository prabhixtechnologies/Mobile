//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_mobistack_api/src/model/payment_receipt.dart';
import 'package:prabhix_mobistack_api/src/model/subscription_card.dart';
import 'package:prabhix_mobistack_api/src/model/plan_card.dart';
import 'package:prabhix_mobistack_api/src/model/screen_card.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'billing_overview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BillingOverview {
  /// Returns a new [BillingOverview] instance.
  BillingOverview({

     this.plans,

     this.subscription,

     this.recentPayments,

     this.screens,

     this.razorpayKeyId,

     this.razorpayEnabled,

     this.paymentRequired,
  });

  @JsonKey(
    
    name: r'plans',
    required: false,
    includeIfNull: false,
  )


  final List<PlanCard>? plans;



  @JsonKey(
    
    name: r'subscription',
    required: false,
    includeIfNull: false,
  )


  final SubscriptionCard? subscription;



  @JsonKey(
    
    name: r'recentPayments',
    required: false,
    includeIfNull: false,
  )


  final List<PaymentReceipt>? recentPayments;



  @JsonKey(
    
    name: r'screens',
    required: false,
    includeIfNull: false,
  )


  final ScreenCard? screens;



  @JsonKey(
    
    name: r'razorpayKeyId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayKeyId;



  @JsonKey(
    
    name: r'razorpayEnabled',
    required: false,
    includeIfNull: false,
  )


  final bool? razorpayEnabled;



  @JsonKey(
    
    name: r'paymentRequired',
    required: false,
    includeIfNull: false,
  )


  final bool? paymentRequired;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BillingOverview &&
      other.plans == plans &&
      other.subscription == subscription &&
      other.recentPayments == recentPayments &&
      other.screens == screens &&
      other.razorpayKeyId == razorpayKeyId &&
      other.razorpayEnabled == razorpayEnabled &&
      other.paymentRequired == paymentRequired;

    @override
    int get hashCode =>
        plans.hashCode +
        subscription.hashCode +
        recentPayments.hashCode +
        screens.hashCode +
        razorpayKeyId.hashCode +
        razorpayEnabled.hashCode +
        paymentRequired.hashCode;

  factory BillingOverview.fromJson(Map<String, dynamic> json) => _$BillingOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$BillingOverviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

