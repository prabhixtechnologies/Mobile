//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckoutResponse {
  /// Returns a new [CheckoutResponse] instance.
  CheckoutResponse({

     this.orderId,

     this.orderNumber,

     this.accessToken,

     this.totalPaise,

     this.currency,

     this.razorpayOrderId,

     this.razorpayKeyId,

     this.razorpayNotes,

     this.subscriptionCheckout,
  });

  @JsonKey(
    
    name: r'orderId',
    required: false,
    includeIfNull: false,
  )


  final String? orderId;



  @JsonKey(
    
    name: r'orderNumber',
    required: false,
    includeIfNull: false,
  )


  final String? orderNumber;



  @JsonKey(
    
    name: r'accessToken',
    required: false,
    includeIfNull: false,
  )


  final String? accessToken;



  @JsonKey(
    
    name: r'totalPaise',
    required: false,
    includeIfNull: false,
  )


  final int? totalPaise;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'razorpayOrderId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayOrderId;



  @JsonKey(
    
    name: r'razorpayKeyId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayKeyId;



  @JsonKey(
    
    name: r'razorpayNotes',
    required: false,
    includeIfNull: false,
  )


  final Map<String, String>? razorpayNotes;



  @JsonKey(
    
    name: r'subscriptionCheckout',
    required: false,
    includeIfNull: false,
  )


  final bool? subscriptionCheckout;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckoutResponse &&
      other.orderId == orderId &&
      other.orderNumber == orderNumber &&
      other.accessToken == accessToken &&
      other.totalPaise == totalPaise &&
      other.currency == currency &&
      other.razorpayOrderId == razorpayOrderId &&
      other.razorpayKeyId == razorpayKeyId &&
      other.razorpayNotes == razorpayNotes &&
      other.subscriptionCheckout == subscriptionCheckout;

    @override
    int get hashCode =>
        orderId.hashCode +
        orderNumber.hashCode +
        accessToken.hashCode +
        totalPaise.hashCode +
        currency.hashCode +
        razorpayOrderId.hashCode +
        razorpayKeyId.hashCode +
        razorpayNotes.hashCode +
        subscriptionCheckout.hashCode;

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) => _$CheckoutResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

