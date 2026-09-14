//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'role_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RoleView {
  /// Returns a new [RoleView] instance.
  RoleView({

     this.id,

     this.roleKey,

     this.name,

     this.description,

     this.system,

     this.rank,

     this.permissions,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'roleKey',
    required: false,
    includeIfNull: false,
  )


  final String? roleKey;



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
    
    name: r'system',
    required: false,
    includeIfNull: false,
  )


  final bool? system;



  @JsonKey(
    
    name: r'rank',
    required: false,
    includeIfNull: false,
  )


  final int? rank;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? permissions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RoleView &&
      other.id == id &&
      other.roleKey == roleKey &&
      other.name == name &&
      other.description == description &&
      other.system == system &&
      other.rank == rank &&
      other.permissions == permissions;

    @override
    int get hashCode =>
        id.hashCode +
        roleKey.hashCode +
        name.hashCode +
        description.hashCode +
        system.hashCode +
        rank.hashCode +
        permissions.hashCode;

  factory RoleView.fromJson(Map<String, dynamic> json) => _$RoleViewFromJson(json);

  Map<String, dynamic> toJson() => _$RoleViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

