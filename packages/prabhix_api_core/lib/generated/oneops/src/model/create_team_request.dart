//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_team_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateTeamRequest {
  /// Returns a new [CreateTeamRequest] instance.
  CreateTeamRequest({

    required  this.name,

     this.description,

     this.leadUserId,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



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
    bool operator ==(Object other) => identical(this, other) || other is CreateTeamRequest &&
      other.name == name &&
      other.description == description &&
      other.leadUserId == leadUserId;

    @override
    int get hashCode =>
        name.hashCode +
        description.hashCode +
        leadUserId.hashCode;

  factory CreateTeamRequest.fromJson(Map<String, dynamic> json) => _$CreateTeamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTeamRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

