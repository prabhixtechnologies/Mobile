//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_billing_address_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateBillingAddressRequest {
  /// Returns a new [UpdateBillingAddressRequest] instance.
  UpdateBillingAddressRequest({

    required  this.line1,

     this.line2,

    required  this.city,

    required  this.state,

    required  this.pincode,

     this.country,

     this.gstin,

     this.billingEmail,
  });

  @JsonKey(
    
    name: r'line1',
    required: true,
    includeIfNull: false,
  )


  final String line1;



  @JsonKey(
    
    name: r'line2',
    required: false,
    includeIfNull: false,
  )


  final String? line2;



  @JsonKey(
    
    name: r'city',
    required: true,
    includeIfNull: false,
  )


  final String city;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final String state;



  @JsonKey(
    
    name: r'pincode',
    required: true,
    includeIfNull: false,
  )


  final String pincode;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    
    name: r'gstin',
    required: false,
    includeIfNull: false,
  )


  final String? gstin;



  @JsonKey(
    
    name: r'billingEmail',
    required: false,
    includeIfNull: false,
  )


  final String? billingEmail;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateBillingAddressRequest &&
      other.line1 == line1 &&
      other.line2 == line2 &&
      other.city == city &&
      other.state == state &&
      other.pincode == pincode &&
      other.country == country &&
      other.gstin == gstin &&
      other.billingEmail == billingEmail;

    @override
    int get hashCode =>
        line1.hashCode +
        line2.hashCode +
        city.hashCode +
        state.hashCode +
        pincode.hashCode +
        country.hashCode +
        gstin.hashCode +
        billingEmail.hashCode;

  factory UpdateBillingAddressRequest.fromJson(Map<String, dynamic> json) => _$UpdateBillingAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateBillingAddressRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

