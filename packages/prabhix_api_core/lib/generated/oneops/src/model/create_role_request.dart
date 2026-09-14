//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_role_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateRoleRequest {
  /// Returns a new [CreateRoleRequest] instance.
  CreateRoleRequest({

    required  this.roleKey,

    required  this.name,

     this.description,

    required  this.permissions,
  });

  @JsonKey(
    
    name: r'roleKey',
    required: true,
    includeIfNull: false,
  )


  final String roleKey;



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
    
    name: r'permissions',
    required: true,
    includeIfNull: false,
  )


  final Set<String> permissions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateRoleRequest &&
      other.roleKey == roleKey &&
      other.name == name &&
      other.description == description &&
      other.permissions == permissions;

    @override
    int get hashCode =>
        roleKey.hashCode +
        name.hashCode +
        description.hashCode +
        permissions.hashCode;

  factory CreateRoleRequest.fromJson(Map<String, dynamic> json) => _$CreateRoleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRoleRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

