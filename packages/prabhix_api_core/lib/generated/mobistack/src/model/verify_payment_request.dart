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

     this.razorpayOrderId,

     this.razorpayPaymentId,

     this.razorpaySignature,
  });

  @JsonKey(
    
    name: r'razorpayOrderId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayOrderId;



  @JsonKey(
    
    name: r'razorpayPaymentId',
    required: false,
    includeIfNull: false,
  )


  final String? razorpayPaymentId;



  @JsonKey(
    
    name: r'razorpaySignature',
    required: false,
    includeIfNull: false,
  )


  final String? razorpaySignature;





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

