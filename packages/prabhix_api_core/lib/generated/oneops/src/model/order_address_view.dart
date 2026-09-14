//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_address_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderAddressView {
  /// Returns a new [OrderAddressView] instance.
  OrderAddressView({

     this.addressType,

     this.name,

     this.line1,

     this.line2,

     this.city,

     this.state,

     this.pincode,

     this.phone,
  });

  @JsonKey(
    
    name: r'addressType',
    required: false,
    includeIfNull: false,
  )


  final String? addressType;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'line1',
    required: false,
    includeIfNull: false,
  )


  final String? line1;



  @JsonKey(
    
    name: r'line2',
    required: false,
    includeIfNull: false,
  )


  final String? line2;



  @JsonKey(
    
    name: r'city',
    required: false,
    includeIfNull: false,
  )


  final String? city;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final String? state;



  @JsonKey(
    
    name: r'pincode',
    required: false,
    includeIfNull: false,
  )


  final String? pincode;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderAddressView &&
      other.addressType == addressType &&
      other.name == name &&
      other.line1 == line1 &&
      other.line2 == line2 &&
      other.city == city &&
      other.state == state &&
      other.pincode == pincode &&
      other.phone == phone;

    @override
    int get hashCode =>
        addressType.hashCode +
        name.hashCode +
        line1.hashCode +
        line2.hashCode +
        city.hashCode +
        state.hashCode +
        pincode.hashCode +
        phone.hashCode;

  factory OrderAddressView.fromJson(Map<String, dynamic> json) => _$OrderAddressViewFromJson(json);

  Map<String, dynamic> toJson() => _$OrderAddressViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

