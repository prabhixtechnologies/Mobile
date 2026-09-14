//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_team_member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddTeamMemberRequest {
  /// Returns a new [AddTeamMemberRequest] instance.
  AddTeamMemberRequest({

    required  this.userId,

     this.teamRole,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final String userId;



  @JsonKey(
    
    name: r'teamRole',
    required: false,
    includeIfNull: false,
  )


  final String? teamRole;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddTeamMemberRequest &&
      other.userId == userId &&
      other.teamRole == teamRole;

    @override
    int get hashCode =>
        userId.hashCode +
        teamRole.hashCode;

  factory AddTeamMemberRequest.fromJson(Map<String, dynamic> json) => _$AddTeamMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddTeamMemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

