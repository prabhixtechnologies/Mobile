//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvoiceSummary {
  /// Returns a new [InvoiceSummary] instance.
  InvoiceSummary({

     this.id,

     this.invoiceNumber,

     this.status,

     this.issueDate,

     this.totalPaise,

     this.currency,

     this.paidAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'invoiceNumber',
    required: false,
    includeIfNull: false,
  )


  final String? invoiceNumber;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final InvoiceSummaryStatusEnum? status;



  @JsonKey(
    
    name: r'issueDate',
    required: false,
    includeIfNull: false,
  )


  final DateTime? issueDate;



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
    
    name: r'paidAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? paidAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvoiceSummary &&
      other.id == id &&
      other.invoiceNumber == invoiceNumber &&
      other.status == status &&
      other.issueDate == issueDate &&
      other.totalPaise == totalPaise &&
      other.currency == currency &&
      other.paidAt == paidAt;

    @override
    int get hashCode =>
        id.hashCode +
        invoiceNumber.hashCode +
        status.hashCode +
        issueDate.hashCode +
        totalPaise.hashCode +
        currency.hashCode +
        paidAt.hashCode;

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) => _$InvoiceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum InvoiceSummaryStatusEnum {
@JsonValue(r'DRAFT')
DRAFT(r'DRAFT'),
@JsonValue(r'ISSUED')
ISSUED(r'ISSUED'),
@JsonValue(r'PAID')
PAID(r'PAID'),
@JsonValue(r'VOID')
VOID(r'VOID'),
@JsonValue(r'REFUNDED')
REFUNDED(r'REFUNDED');

const InvoiceSummaryStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


