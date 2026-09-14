//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserProfile {
  /// Returns a new [UserProfile] instance.
  UserProfile({

     this.id,

     this.email,

     this.emailVerified,

     this.fullName,

     this.displayName,

     this.avatarUrl,

     this.jobTitle,

     this.timezone,

     this.locale,

     this.status,

     this.platformAdmin,

     this.defaultOrganizationId,

     this.notificationPrefs,

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
    
    name: r'emailVerified',
    required: false,
    includeIfNull: false,
  )


  final bool? emailVerified;



  @JsonKey(
    
    name: r'fullName',
    required: false,
    includeIfNull: false,
  )


  final String? fullName;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'avatarUrl',
    required: false,
    includeIfNull: false,
  )


  final String? avatarUrl;



  @JsonKey(
    
    name: r'jobTitle',
    required: false,
    includeIfNull: false,
  )


  final String? jobTitle;



  @JsonKey(
    
    name: r'timezone',
    required: false,
    includeIfNull: false,
  )


  final String? timezone;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'platformAdmin',
    required: false,
    includeIfNull: false,
  )


  final bool? platformAdmin;



  @JsonKey(
    
    name: r'defaultOrganizationId',
    required: false,
    includeIfNull: false,
  )


  final String? defaultOrganizationId;



  @JsonKey(
    
    name: r'notificationPrefs',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? notificationPrefs;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserProfile &&
      other.id == id &&
      other.email == email &&
      other.emailVerified == emailVerified &&
      other.fullName == fullName &&
      other.displayName == displayName &&
      other.avatarUrl == avatarUrl &&
      other.jobTitle == jobTitle &&
      other.timezone == timezone &&
      other.locale == locale &&
      other.status == status &&
      other.platformAdmin == platformAdmin &&
      other.defaultOrganizationId == defaultOrganizationId &&
      other.notificationPrefs == notificationPrefs &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        emailVerified.hashCode +
        fullName.hashCode +
        displayName.hashCode +
        avatarUrl.hashCode +
        jobTitle.hashCode +
        timezone.hashCode +
        locale.hashCode +
        status.hashCode +
        platformAdmin.hashCode +
        defaultOrganizationId.hashCode +
        notificationPrefs.hashCode +
        createdAt.hashCode;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

