//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_me_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthMeResponse {
  /// Returns a new [AuthMeResponse] instance.
  AuthMeResponse({

     this.userId,

     this.email,

     this.displayName,

     this.organizationId,

     this.sessionId,

     this.permissions,

     this.platformAdmin,
  });

  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'organizationId',
    required: false,
    includeIfNull: false,
  )


  final String? organizationId;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? permissions;



  @JsonKey(
    
    name: r'platformAdmin',
    required: false,
    includeIfNull: false,
  )


  final bool? platformAdmin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuthMeResponse &&
      other.userId == userId &&
      other.email == email &&
      other.displayName == displayName &&
      other.organizationId == organizationId &&
      other.sessionId == sessionId &&
      other.permissions == permissions &&
      other.platformAdmin == platformAdmin;

    @override
    int get hashCode =>
        userId.hashCode +
        email.hashCode +
        displayName.hashCode +
        organizationId.hashCode +
        sessionId.hashCode +
        permissions.hashCode +
        platformAdmin.hashCode;

  factory AuthMeResponse.fromJson(Map<String, dynamic> json) => _$AuthMeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthMeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

