//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'change_member_role_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeMemberRoleRequest {
  /// Returns a new [ChangeMemberRoleRequest] instance.
  ChangeMemberRoleRequest({

    required  this.roleId,
  });

  @JsonKey(
    
    name: r'roleId',
    required: true,
    includeIfNull: false,
  )


  final String roleId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChangeMemberRoleRequest &&
      other.roleId == roleId;

    @override
    int get hashCode =>
        roleId.hashCode;

  factory ChangeMemberRoleRequest.fromJson(Map<String, dynamic> json) => _$ChangeMemberRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeMemberRoleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

