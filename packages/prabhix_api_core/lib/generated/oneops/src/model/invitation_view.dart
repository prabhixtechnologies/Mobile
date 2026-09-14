//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invitation_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvitationView {
  /// Returns a new [InvitationView] instance.
  InvitationView({

     this.id,

     this.email,

     this.roleId,

     this.roleName,

     this.invitedBy,

     this.expiresAt,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'roleId',
    required: false,
    includeIfNull: false,
  )


  final String? roleId;



  @JsonKey(
    
    name: r'roleName',
    required: false,
    includeIfNull: false,
  )


  final String? roleName;



  @JsonKey(
    
    name: r'invitedBy',
    required: false,
    includeIfNull: false,
  )


  final String? invitedBy;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvitationView &&
      other.id == id &&
      other.email == email &&
      other.roleId == roleId &&
      other.roleName == roleName &&
      other.invitedBy == invitedBy &&
      other.expiresAt == expiresAt &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        roleId.hashCode +
        roleName.hashCode +
        invitedBy.hashCode +
        expiresAt.hashCode +
        createdAt.hashCode;

  factory InvitationView.fromJson(Map<String, dynamic> json) => _$InvitationViewFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

