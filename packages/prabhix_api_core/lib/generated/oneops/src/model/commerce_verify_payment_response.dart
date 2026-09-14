//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commerce_verify_payment_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommerceVerifyPaymentResponse {
  /// Returns a new [CommerceVerifyPaymentResponse] instance.
  CommerceVerifyPaymentResponse({

     this.orderId,

     this.orderNumber,

     this.status,
  });

  @JsonKey(
    
    name: r'orderId',
    required: false,
    includeIfNull: false,
  )


  final String? orderId;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommerceVerifyPaymentResponse &&
      other.orderId == orderId &&
      other.orderNumber == orderNumber &&
      other.status == status;

    @override
    int get hashCode =>
        orderId.hashCode +
        orderNumber.hashCode +
        status.hashCode;

  factory CommerceVerifyPaymentResponse.fromJson(Map<String, dynamic> json) => _$CommerceVerifyPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CommerceVerifyPaymentResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

