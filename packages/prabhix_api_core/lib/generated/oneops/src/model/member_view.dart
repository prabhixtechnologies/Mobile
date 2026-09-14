//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MemberView {
  /// Returns a new [MemberView] instance.
  MemberView({

     this.id,

     this.userId,

     this.displayName,

     this.email,

     this.roleId,

     this.roleName,

     this.status,

     this.department,

     this.employeeId,

     this.joinedAt,

     this.lastActiveAt,
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
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'department',
    required: false,
    includeIfNull: false,
  )


  final String? department;



  @JsonKey(
    
    name: r'employeeId',
    required: false,
    includeIfNull: false,
  )


  final String? employeeId;



  @JsonKey(
    
    name: r'joinedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? joinedAt;



  @JsonKey(
    
    name: r'lastActiveAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastActiveAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MemberView &&
      other.id == id &&
      other.userId == userId &&
      other.displayName == displayName &&
      other.email == email &&
      other.roleId == roleId &&
      other.roleName == roleName &&
      other.status == status &&
      other.department == department &&
      other.employeeId == employeeId &&
      other.joinedAt == joinedAt &&
      other.lastActiveAt == lastActiveAt;

    @override
    int get hashCode =>
        id.hashCode +
        userId.hashCode +
        displayName.hashCode +
        email.hashCode +
        roleId.hashCode +
        roleName.hashCode +
        status.hashCode +
        department.hashCode +
        employeeId.hashCode +
        joinedAt.hashCode +
        lastActiveAt.hashCode;

  factory MemberView.fromJson(Map<String, dynamic> json) => _$MemberViewFromJson(json);

  Map<String, dynamic> toJson() => _$MemberViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

