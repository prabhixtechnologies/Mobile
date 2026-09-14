//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_payment.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminPayment {
  /// Returns a new [AdminPayment] instance.
  AdminPayment({

     this.id,

     this.shopId,

     this.shopName,

     this.priceCode,

     this.amount,

     this.currency,

     this.status,

     this.gateway,

     this.createdAt,

     this.paidAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'shopId',
    required: false,
    includeIfNull: false,
  )


  final String? shopId;



  @JsonKey(
    
    name: r'shopName',
    required: false,
    includeIfNull: false,
  )


  final String? shopName;



  @JsonKey(
    
    name: r'priceCode',
    required: false,
    includeIfNull: false,
  )


  final String? priceCode;



  @JsonKey(
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final num? amount;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'gateway',
    required: false,
    includeIfNull: false,
  )


  final String? gateway;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'paidAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? paidAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminPayment &&
      other.id == id &&
      other.shopId == shopId &&
      other.shopName == shopName &&
      other.priceCode == priceCode &&
      other.amount == amount &&
      other.currency == currency &&
      other.status == status &&
      other.gateway == gateway &&
      other.createdAt == createdAt &&
      other.paidAt == paidAt;

    @override
    int get hashCode =>
        id.hashCode +
        shopId.hashCode +
        shopName.hashCode +
        priceCode.hashCode +
        amount.hashCode +
        currency.hashCode +
        status.hashCode +
        gateway.hashCode +
        createdAt.hashCode +
        paidAt.hashCode;

  factory AdminPayment.fromJson(Map<String, dynamic> json) => _$AdminPaymentFromJson(json);

  Map<String, dynamic> toJson() => _$AdminPaymentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

