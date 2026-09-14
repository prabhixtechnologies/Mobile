//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_payment_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyPaymentRequest {
  /// Returns a new [VerifyPaymentRequest] instance.
  VerifyPaymentRequest({

    required  this.razorpayOrderId,

    required  this.razorpayPaymentId,

    required  this.razorpaySignature,
  });

  @JsonKey(
    
    name: r'razorpayOrderId',
    required: true,
    includeIfNull: false,
  )


  final String razorpayOrderId;



  @JsonKey(
    
    name: r'razorpayPaymentId',
    required: true,
    includeIfNull: false,
  )


  final String razorpayPaymentId;



  @JsonKey(
    
    name: r'razorpaySignature',
    required: true,
    includeIfNull: false,
  )


  final String razorpaySignature;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VerifyPaymentRequest &&
      other.razorpayOrderId == razorpayOrderId &&
      other.razorpayPaymentId == razorpayPaymentId &&
      other.razorpaySignature == razorpaySignature;

    @override
    int get hashCode =>
        razorpayOrderId.hashCode +
        razorpayPaymentId.hashCode +
        razorpaySignature.hashCode;

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json) => _$VerifyPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPaymentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

