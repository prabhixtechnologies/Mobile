//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/order_view.dart';
import 'package:prabhix_oneops_api/src/model/subscription_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'billing_change_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BillingChangeResponse {
  /// Returns a new [BillingChangeResponse] instance.
  BillingChangeResponse({

     this.subscription,

     this.checkoutOrder,

     this.message,
  });

  @JsonKey(
    
    name: r'subscription',
    required: false,
    includeIfNull: false,
  )


  final SubscriptionView? subscription;



  @JsonKey(
    
    name: r'checkoutOrder',
    required: false,
    includeIfNull: false,
  )


  final OrderView? checkoutOrder;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BillingChangeResponse &&
      other.subscription == subscription &&
      other.checkoutOrder == checkoutOrder &&
      other.message == message;

    @override
    int get hashCode =>
        subscription.hashCode +
        checkoutOrder.hashCode +
        message.hashCode;

  factory BillingChangeResponse.fromJson(Map<String, dynamic> json) => _$BillingChangeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BillingChangeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

