//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_team_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateTeamRequest {
  /// Returns a new [UpdateTeamRequest] instance.
  UpdateTeamRequest({

     this.name,

     this.description,

     this.leadUserId,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'leadUserId',
    required: false,
    includeIfNull: false,
  )


  final String? leadUserId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateTeamRequest &&
      other.name == name &&
      other.description == description &&
      other.leadUserId == leadUserId;

    @override
    int get hashCode =>
        name.hashCode +
        description.hashCode +
        leadUserId.hashCode;

  factory UpdateTeamRequest.fromJson(Map<String, dynamic> json) => _$UpdateTeamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTeamRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

