//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_payment_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyPaymentResponse {
  /// Returns a new [VerifyPaymentResponse] instance.
  VerifyPaymentResponse({

     this.orderId,

     this.status,

     this.signatureVerified,
  });

  @JsonKey(
    
    name: r'orderId',
    required: false,
    includeIfNull: false,
  )


  final String? orderId;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final VerifyPaymentResponseStatusEnum? status;



  @JsonKey(
    
    name: r'signatureVerified',
    required: false,
    includeIfNull: false,
  )


  final bool? signatureVerified;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VerifyPaymentResponse &&
      other.orderId == orderId &&
      other.status == status &&
      other.signatureVerified == signatureVerified;

    @override
    int get hashCode =>
        orderId.hashCode +
        status.hashCode +
        signatureVerified.hashCode;

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) => _$VerifyPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPaymentResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum VerifyPaymentResponseStatusEnum {
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

const VerifyPaymentResponseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


