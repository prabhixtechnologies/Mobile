//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invitation_preview.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvitationPreview {
  /// Returns a new [InvitationPreview] instance.
  InvitationPreview({

     this.organizationName,

     this.roleName,
  });

  @JsonKey(
    
    name: r'organizationName',
    required: false,
    includeIfNull: false,
  )


  final String? organizationName;



  @JsonKey(
    
    name: r'roleName',
    required: false,
    includeIfNull: false,
  )


  final String? roleName;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvitationPreview &&
      other.organizationName == organizationName &&
      other.roleName == roleName;

    @override
    int get hashCode =>
        organizationName.hashCode +
        roleName.hashCode;

  factory InvitationPreview.fromJson(Map<String, dynamic> json) => _$InvitationPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

