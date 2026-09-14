//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refund_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefundView {
  /// Returns a new [RefundView] instance.
  RefundView({

     this.paymentId,

     this.refundedPaise,

     this.totalRefundedPaise,

     this.status,
  });

  @JsonKey(
    
    name: r'paymentId',
    required: false,
    includeIfNull: false,
  )


  final String? paymentId;



  @JsonKey(
    
    name: r'refundedPaise',
    required: false,
    includeIfNull: false,
  )


  final int? refundedPaise;



  @JsonKey(
    
    name: r'totalRefundedPaise',
    required: false,
    includeIfNull: false,
  )


  final int? totalRefundedPaise;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final RefundViewStatusEnum? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RefundView &&
      other.paymentId == paymentId &&
      other.refundedPaise == refundedPaise &&
      other.totalRefundedPaise == totalRefundedPaise &&
      other.status == status;

    @override
    int get hashCode =>
        paymentId.hashCode +
        refundedPaise.hashCode +
        totalRefundedPaise.hashCode +
        status.hashCode;

  factory RefundView.fromJson(Map<String, dynamic> json) => _$RefundViewFromJson(json);

  Map<String, dynamic> toJson() => _$RefundViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum RefundViewStatusEnum {
@JsonValue(r'CREATED')
CREATED(r'CREATED'),
@JsonValue(r'AUTHORIZED')
AUTHORIZED(r'AUTHORIZED'),
@JsonValue(r'CAPTURED')
CAPTURED(r'CAPTURED'),
@JsonValue(r'REFUNDED')
REFUNDED(r'REFUNDED'),
@JsonValue(r'FAILED')
FAILED(r'FAILED');

const RefundViewStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


