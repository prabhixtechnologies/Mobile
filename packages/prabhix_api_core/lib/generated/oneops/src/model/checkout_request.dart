//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'checkout_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CheckoutRequest {
  /// Returns a new [CheckoutRequest] instance.
  CheckoutRequest({

     this.email,

     this.name,

     this.phone,

     this.marketingConsent,

     this.visitorId,
  });

  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'marketingConsent',
    required: false,
    includeIfNull: false,
  )


  final bool? marketingConsent;



  @JsonKey(
    
    name: r'visitorId',
    required: false,
    includeIfNull: false,
  )


  final String? visitorId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CheckoutRequest &&
      other.email == email &&
      other.name == name &&
      other.phone == phone &&
      other.marketingConsent == marketingConsent &&
      other.visitorId == visitorId;

    @override
    int get hashCode =>
        email.hashCode +
        name.hashCode +
        phone.hashCode +
        marketingConsent.hashCode +
        visitorId.hashCode;

  factory CheckoutRequest.fromJson(Map<String, dynamic> json) => _$CheckoutRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckoutRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

