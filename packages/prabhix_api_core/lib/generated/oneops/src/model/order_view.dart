//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderView {
  /// Returns a new [OrderView] instance.
  OrderView({

     this.id,

     this.razorpayOrderId,

     this.amountPaise,

     this.taxPaise,

     this.totalPaise,

     this.currency,

     this.status,

     this.receipt,

     this.localDevCheckout,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'razorpayOrderId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayOrderId;



  @JsonKey(
    
    name: r'amountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? amountPaise;



  @JsonKey(
    
    name: r'taxPaise',
    required: false,
    includeIfNull: false,
  )


  final int? taxPaise;



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
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final OrderViewStatusEnum? status;



  @JsonKey(
    
    name: r'receipt',
    required: false,
    includeIfNull: false,
  )


  final String? receipt;



  @JsonKey(
    
    name: r'localDevCheckout',
    required: false,
    includeIfNull: false,
  )


  final bool? localDevCheckout;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderView &&
      other.id == id &&
      other.razorpayOrderId == razorpayOrderId &&
      other.amountPaise == amountPaise &&
      other.taxPaise == taxPaise &&
      other.totalPaise == totalPaise &&
      other.currency == currency &&
      other.status == status &&
      other.receipt == receipt &&
      other.localDevCheckout == localDevCheckout;

    @override
    int get hashCode =>
        id.hashCode +
        razorpayOrderId.hashCode +
        amountPaise.hashCode +
        taxPaise.hashCode +
        totalPaise.hashCode +
        currency.hashCode +
        status.hashCode +
        receipt.hashCode +
        localDevCheckout.hashCode;

  factory OrderView.fromJson(Map<String, dynamic> json) => _$OrderViewFromJson(json);

  Map<String, dynamic> toJson() => _$OrderViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum OrderViewStatusEnum {
@JsonValue(r'CREATED')
CREATED(r'CREATED'),
@JsonValue(r'ATTEMPTED')
ATTEMPTED(r'ATTEMPTED'),
@JsonValue(r'CAPTURED')
CAPTURED(r'CAPTURED'),
@JsonValue(r'FAILED')
FAILED(r'FAILED'),
@JsonValue(r'REFUNDED')
REFUNDED(r'REFUNDED'),
@JsonValue(r'CANCELLED')
CANCELLED(r'CANCELLED'),
@JsonValue(r'EXPIRED')
EXPIRED(r'EXPIRED');

const OrderViewStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


