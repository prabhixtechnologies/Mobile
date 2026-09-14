//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_organization_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateOrganizationRequest {
  /// Returns a new [UpdateOrganizationRequest] instance.
  UpdateOrganizationRequest({

     this.name,

     this.legalName,

     this.gstin,

     this.pan,

     this.billingEmail,

     this.phone,

     this.website,

     this.timezone,

     this.locale,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'legalName',
    required: false,
    includeIfNull: false,
  )


  final String? legalName;



  @JsonKey(
    
    name: r'gstin',
    required: false,
    includeIfNull: false,
  )


  final String? gstin;



  @JsonKey(
    
    name: r'pan',
    required: false,
    includeIfNull: false,
  )


  final String? pan;



  @JsonKey(
    
    name: r'billingEmail',
    required: false,
    includeIfNull: false,
  )


  final String? billingEmail;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'website',
    required: false,
    includeIfNull: false,
  )


  final String? website;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateOrganizationRequest &&
      other.name == name &&
      other.legalName == legalName &&
      other.gstin == gstin &&
      other.pan == pan &&
      other.billingEmail == billingEmail &&
      other.phone == phone &&
      other.website == website &&
      other.timezone == timezone &&
      other.locale == locale;

    @override
    int get hashCode =>
        name.hashCode +
        legalName.hashCode +
        gstin.hashCode +
        pan.hashCode +
        billingEmail.hashCode +
        phone.hashCode +
        website.hashCode +
        timezone.hashCode +
        locale.hashCode;

  factory UpdateOrganizationRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrganizationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOrganizationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

