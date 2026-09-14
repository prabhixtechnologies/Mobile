//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_member_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeamMemberView {
  /// Returns a new [TeamMemberView] instance.
  TeamMemberView({

     this.id,

     this.userId,

     this.displayName,

     this.teamRole,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'teamRole',
    required: false,
    includeIfNull: false,
  )


  final String? teamRole;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TeamMemberView &&
      other.id == id &&
      other.userId == userId &&
      other.displayName == displayName &&
      other.teamRole == teamRole;

    @override
    int get hashCode =>
        id.hashCode +
        userId.hashCode +
        displayName.hashCode +
        teamRole.hashCode;

  factory TeamMemberView.fromJson(Map<String, dynamic> json) => _$TeamMemberViewFromJson(json);

  Map<String, dynamic> toJson() => _$TeamMemberViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

