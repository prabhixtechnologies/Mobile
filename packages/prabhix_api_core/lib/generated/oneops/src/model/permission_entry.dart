//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'permission_entry.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PermissionEntry {
  /// Returns a new [PermissionEntry] instance.
  PermissionEntry({

     this.code,

     this.description,
  });

  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PermissionEntry &&
      other.code == code &&
      other.description == description;

    @override
    int get hashCode =>
        code.hashCode +
        description.hashCode;

  factory PermissionEntry.fromJson(Map<String, dynamic> json) => _$PermissionEntryFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionEntryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

