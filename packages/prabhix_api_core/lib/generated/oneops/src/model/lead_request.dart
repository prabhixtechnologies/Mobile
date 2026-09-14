//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lead_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LeadRequest {
  /// Returns a new [LeadRequest] instance.
  LeadRequest({

    required  this.name,

    required  this.email,

     this.company,

     this.phone,

     this.employeeCount,

     this.interest,

    required  this.message,

     this.source_,

     this.utm,

     this.referrer,

     this.website,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'company',
    required: false,
    includeIfNull: false,
  )


  final String? company;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'employeeCount',
    required: false,
    includeIfNull: false,
  )


  final String? employeeCount;



  @JsonKey(
    
    name: r'interest',
    required: false,
    includeIfNull: false,
  )


  final LeadRequestInterestEnum? interest;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final String? source_;



  @JsonKey(
    
    name: r'utm',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? utm;



  @JsonKey(
    
    name: r'referrer',
    required: false,
    includeIfNull: false,
  )


  final String? referrer;



  @JsonKey(
    
    name: r'website',
    required: false,
    includeIfNull: false,
  )


  final String? website;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LeadRequest &&
      other.name == name &&
      other.email == email &&
      other.company == company &&
      other.phone == phone &&
      other.employeeCount == employeeCount &&
      other.interest == interest &&
      other.message == message &&
      other.source_ == source_ &&
      other.utm == utm &&
      other.referrer == referrer &&
      other.website == website;

    @override
    int get hashCode =>
        name.hashCode +
        email.hashCode +
        company.hashCode +
        phone.hashCode +
        employeeCount.hashCode +
        interest.hashCode +
        message.hashCode +
        source_.hashCode +
        utm.hashCode +
        referrer.hashCode +
        website.hashCode;

  factory LeadRequest.fromJson(Map<String, dynamic> json) => _$LeadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LeadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum LeadRequestInterestEnum {
@JsonValue(r'PLATFORM')
PLATFORM(r'PLATFORM'),
@JsonValue(r'MOBISTACK')
MOBISTACK(r'MOBISTACK'),
@JsonValue(r'CUSTOM_SOFTWARE')
CUSTOM_SOFTWARE(r'CUSTOM_SOFTWARE'),
@JsonValue(r'CLOUD_DEVOPS')
CLOUD_DEVOPS(r'CLOUD_DEVOPS'),
@JsonValue(r'AI_ML')
AI_ML(r'AI_ML'),
@JsonValue(r'MOBILE_APPS')
MOBILE_APPS(r'MOBILE_APPS'),
@JsonValue(r'CONSULTING')
CONSULTING(r'CONSULTING'),
@JsonValue(r'PARTNERSHIP')
PARTNERSHIP(r'PARTNERSHIP'),
@JsonValue(r'OTHER')
OTHER(r'OTHER');

const LeadRequestInterestEnum(this.value);

final String value;

@override
String toString() => value;
}


