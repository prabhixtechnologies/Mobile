//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_receipt.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentReceipt {
  /// Returns a new [PaymentReceipt] instance.
  PaymentReceipt({

     this.id,

     this.planName,

     this.priceCode,

     this.amount,

     this.currency,

     this.status,

     this.paidAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'planName',
    required: false,
    includeIfNull: false,
  )


  final String? planName;



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
    
    name: r'paidAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? paidAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaymentReceipt &&
      other.id == id &&
      other.planName == planName &&
      other.priceCode == priceCode &&
      other.amount == amount &&
      other.currency == currency &&
      other.status == status &&
      other.paidAt == paidAt;

    @override
    int get hashCode =>
        id.hashCode +
        planName.hashCode +
        priceCode.hashCode +
        amount.hashCode +
        currency.hashCode +
        status.hashCode +
        paidAt.hashCode;

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) => _$PaymentReceiptFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReceiptToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

