//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_role_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobRoleDetail {
  /// Returns a new [JobRoleDetail] instance.
  JobRoleDetail({

     this.id,

     this.slug,

     this.title,

     this.department,

     this.location,

     this.employmentType,

     this.workMode,

     this.experienceRange,

     this.salaryRange,

     this.summary,

     this.descriptionMd,

     this.publishedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'department',
    required: false,
    includeIfNull: false,
  )


  final String? department;



  @JsonKey(
    
    name: r'location',
    required: false,
    includeIfNull: false,
  )


  final String? location;



  @JsonKey(
    
    name: r'employmentType',
    required: false,
    includeIfNull: false,
  )


  final JobRoleDetailEmploymentTypeEnum? employmentType;



  @JsonKey(
    
    name: r'workMode',
    required: false,
    includeIfNull: false,
  )


  final JobRoleDetailWorkModeEnum? workMode;



  @JsonKey(
    
    name: r'experienceRange',
    required: false,
    includeIfNull: false,
  )


  final String? experienceRange;



  @JsonKey(
    
    name: r'salaryRange',
    required: false,
    includeIfNull: false,
  )


  final String? salaryRange;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'descriptionMd',
    required: false,
    includeIfNull: false,
  )


  final String? descriptionMd;



  @JsonKey(
    
    name: r'publishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is JobRoleDetail &&
      other.id == id &&
      other.slug == slug &&
      other.title == title &&
      other.department == department &&
      other.location == location &&
      other.employmentType == employmentType &&
      other.workMode == workMode &&
      other.experienceRange == experienceRange &&
      other.salaryRange == salaryRange &&
      other.summary == summary &&
      other.descriptionMd == descriptionMd &&
      other.publishedAt == publishedAt;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        title.hashCode +
        department.hashCode +
        location.hashCode +
        employmentType.hashCode +
        workMode.hashCode +
        experienceRange.hashCode +
        salaryRange.hashCode +
        summary.hashCode +
        descriptionMd.hashCode +
        publishedAt.hashCode;

  factory JobRoleDetail.fromJson(Map<String, dynamic> json) => _$JobRoleDetailFromJson(json);

  Map<String, dynamic> toJson() => _$JobRoleDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum JobRoleDetailEmploymentTypeEnum {
@JsonValue(r'FULL_TIME')
FULL_TIME(r'FULL_TIME'),
@JsonValue(r'PART_TIME')
PART_TIME(r'PART_TIME'),
@JsonValue(r'CONTRACT')
CONTRACT(r'CONTRACT'),
@JsonValue(r'INTERNSHIP')
INTERNSHIP(r'INTERNSHIP');

const JobRoleDetailEmploymentTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


enum JobRoleDetailWorkModeEnum {
@JsonValue(r'ONSITE')
ONSITE(r'ONSITE'),
@JsonValue(r'HYBRID')
HYBRID(r'HYBRID'),
@JsonValue(r'REMOTE')
REMOTE(r'REMOTE');

const JobRoleDetailWorkModeEnum(this.value);

final String value;

@override
String toString() => value;
}


