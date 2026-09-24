//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderSummary {
  /// Returns a new [OrderSummary] instance.
  OrderSummary({

     this.id,

     this.orderNumber,

     this.status,

     this.totalPaise,

     this.currency,

     this.customerEmail,

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
    
    name: r'orderNumber',
    required: false,
    includeIfNull: false,
  )


  final String? orderNumber;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



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
    
    name: r'customerEmail',
    required: false,
    includeIfNull: false,
  )


  final String? customerEmail;



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
    bool operator ==(Object other) => identical(this, other) || other is OrderSummary &&
      other.id == id &&
      other.orderNumber == orderNumber &&
      other.status == status &&
      other.totalPaise == totalPaise &&
      other.currency == currency &&
      other.customerEmail == customerEmail &&
      other.createdAt == createdAt &&
      other.paidAt == paidAt;

    @override
    int get hashCode =>
        id.hashCode +
        orderNumber.hashCode +
        status.hashCode +
        totalPaise.hashCode +
        currency.hashCode +
        customerEmail.hashCode +
        createdAt.hashCode +
        paidAt.hashCode;

  factory OrderSummary.fromJson(Map<String, dynamic> json) => _$OrderSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

