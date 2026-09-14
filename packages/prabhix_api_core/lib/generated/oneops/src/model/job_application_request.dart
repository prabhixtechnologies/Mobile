//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_application_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobApplicationRequest {
  /// Returns a new [JobApplicationRequest] instance.
  JobApplicationRequest({

    required  this.roleSlug,

    required  this.name,

    required  this.email,

     this.phone,

     this.portfolioUrl,

     this.linkedinUrl,

     this.coverLetter,
  });

  @JsonKey(
    
    name: r'roleSlug',
    required: true,
    includeIfNull: false,
  )


  final String roleSlug;



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
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'portfolioUrl',
    required: false,
    includeIfNull: false,
  )


  final String? portfolioUrl;



  @JsonKey(
    
    name: r'linkedinUrl',
    required: false,
    includeIfNull: false,
  )


  final String? linkedinUrl;



  @JsonKey(
    
    name: r'coverLetter',
    required: false,
    includeIfNull: false,
  )


  final String? coverLetter;





    @override
    bool operator ==(Object other) => identical(this, other) || other is JobApplicationRequest &&
      other.roleSlug == roleSlug &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.portfolioUrl == portfolioUrl &&
      other.linkedinUrl == linkedinUrl &&
      other.coverLetter == coverLetter;

    @override
    int get hashCode =>
        roleSlug.hashCode +
        name.hashCode +
        email.hashCode +
        phone.hashCode +
        portfolioUrl.hashCode +
        linkedinUrl.hashCode +
        coverLetter.hashCode;

  factory JobApplicationRequest.fromJson(Map<String, dynamic> json) => _$JobApplicationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$JobApplicationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

