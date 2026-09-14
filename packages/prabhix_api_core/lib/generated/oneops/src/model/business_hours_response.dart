//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'business_hours_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BusinessHoursResponse {
  /// Returns a new [BusinessHoursResponse] instance.
  BusinessHoursResponse({

     this.timezone,

     this.workingDays,

     this.startTime,

     this.endTime,

     this.holidays,
  });

  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'workingDays',
    required: false,
    includeIfNull: false,
  )


  final List<int>? workingDays;



  @JsonKey(
    
    name: r'startTime',
    required: false,
    includeIfNull: false,
  )


  final String? startTime;



  @JsonKey(
    
    name: r'endTime',
    required: false,
    includeIfNull: false,
  )


  final String? endTime;



  @JsonKey(
    
    name: r'holidays',
    required: false,
    includeIfNull: false,
  )


  final List<String>? holidays;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BusinessHoursResponse &&
      other.timezone == timezone &&
      other.workingDays == workingDays &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.holidays == holidays;

    @override
    int get hashCode =>
        timezone.hashCode +
        workingDays.hashCode +
        startTime.hashCode +
        endTime.hashCode +
        holidays.hashCode;

  factory BusinessHoursResponse.fromJson(Map<String, dynamic> json) => _$BusinessHoursResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessHoursResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

