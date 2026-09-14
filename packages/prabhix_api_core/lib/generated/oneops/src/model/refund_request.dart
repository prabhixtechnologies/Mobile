//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refund_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefundRequest {
  /// Returns a new [RefundRequest] instance.
  RefundRequest({

    required  this.paymentId,

     this.amountPaise,
  });

  @JsonKey(
    
    name: r'paymentId',
    required: true,
    includeIfNull: false,
  )


  final String paymentId;



  @JsonKey(
    
    name: r'amountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? amountPaise;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RefundRequest &&
      other.paymentId == paymentId &&
      other.amountPaise == amountPaise;

    @override
    int get hashCode =>
        paymentId.hashCode +
        amountPaise.hashCode;

  factory RefundRequest.fromJson(Map<String, dynamic> json) => _$RefundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefundRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

