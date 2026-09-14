//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/permission_entry.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'permission_category.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PermissionCategory {
  /// Returns a new [PermissionCategory] instance.
  PermissionCategory({

     this.category,

     this.permissions,
  });

  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final String? category;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final List<PermissionEntry>? permissions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PermissionCategory &&
      other.category == category &&
      other.permissions == permissions;

    @override
    int get hashCode =>
        category.hashCode +
        permissions.hashCode;

  factory PermissionCategory.fromJson(Map<String, dynamic> json) => _$PermissionCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionCategoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

