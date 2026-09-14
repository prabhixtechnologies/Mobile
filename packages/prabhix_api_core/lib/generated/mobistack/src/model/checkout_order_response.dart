//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_order_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckoutOrderResponse {
  /// Returns a new [CheckoutOrderResponse] instance.
  CheckoutOrderResponse({

     this.id,

     this.orderId,

     this.amount,

     this.currency,

     this.keyId,

     this.priceCode,

     this.gateway,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'order_id',
    required: false,
    includeIfNull: false,
  )


  final String? orderId;



  @JsonKey(
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final int? amount;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'keyId',
    required: false,
    includeIfNull: false,
  )


  final String? keyId;



  @JsonKey(
    
    name: r'priceCode',
    required: false,
    includeIfNull: false,
  )


  final String? priceCode;



  @JsonKey(
    
    name: r'gateway',
    required: false,
    includeIfNull: false,
  )


  final String? gateway;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckoutOrderResponse &&
      other.id == id &&
      other.orderId == orderId &&
      other.amount == amount &&
      other.currency == currency &&
      other.keyId == keyId &&
      other.priceCode == priceCode &&
      other.gateway == gateway;

    @override
    int get hashCode =>
        id.hashCode +
        orderId.hashCode +
        amount.hashCode +
        currency.hashCode +
        keyId.hashCode +
        priceCode.hashCode +
        gateway.hashCode;

  factory CheckoutOrderResponse.fromJson(Map<String, dynamic> json) => _$CheckoutOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutOrderResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

