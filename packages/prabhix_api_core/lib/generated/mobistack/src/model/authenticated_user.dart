//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'authenticated_user.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthenticatedUser {
  /// Returns a new [AuthenticatedUser] instance.
  AuthenticatedUser({

     this.id,

     this.shopId,

     this.shopName,

     this.workspaceId,

     this.workspaceName,

     this.fullName,

     this.email,

     this.phone,

     this.avatarUrl,

     this.roles,

     this.permissions,

     this.systemAdmin,

     this.emailVerified,

     this.phoneVerified,

     this.paymentRequired,

     this.catalogOnly,

     this.features,

     this.planCode,

     this.planName,

     this.periodEnd,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'shopId',
    required: false,
    includeIfNull: false,
  )


  final String? shopId;



  @JsonKey(
    
    name: r'shopName',
    required: false,
    includeIfNull: false,
  )


  final String? shopName;



  @JsonKey(
    
    name: r'workspaceId',
    required: false,
    includeIfNull: false,
  )


  final String? workspaceId;



  @JsonKey(
    
    name: r'workspaceName',
    required: false,
    includeIfNull: false,
  )


  final String? workspaceName;



  @JsonKey(
    
    name: r'fullName',
    required: false,
    includeIfNull: false,
  )


  final String? fullName;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'phone',
    required: false,
    includeIfNull: false,
  )


  final String? phone;



  @JsonKey(
    
    name: r'avatarUrl',
    required: false,
    includeIfNull: false,
  )


  final String? avatarUrl;



  @JsonKey(
    
    name: r'roles',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? roles;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? permissions;



  @JsonKey(
    
    name: r'systemAdmin',
    required: false,
    includeIfNull: false,
  )


  final bool? systemAdmin;



  @JsonKey(
    
    name: r'emailVerified',
    required: false,
    includeIfNull: false,
  )


  final bool? emailVerified;



  @JsonKey(
    
    name: r'phoneVerified',
    required: false,
    includeIfNull: false,
  )


  final bool? phoneVerified;



  @JsonKey(
    
    name: r'paymentRequired',
    required: false,
    includeIfNull: false,
  )


  final bool? paymentRequired;



  @JsonKey(
    
    name: r'catalogOnly',
    required: false,
    includeIfNull: false,
  )


  final bool? catalogOnly;



  @JsonKey(
    
    name: r'features',
    required: false,
    includeIfNull: false,
  )


  final List<String>? features;



  @JsonKey(
    
    name: r'planCode',
    required: false,
    includeIfNull: false,
  )


  final String? planCode;



  @JsonKey(
    
    name: r'planName',
    required: false,
    includeIfNull: false,
  )


  final String? planName;



  @JsonKey(
    
    name: r'periodEnd',
    required: false,
    includeIfNull: false,
  )


  final DateTime? periodEnd;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuthenticatedUser &&
      other.id == id &&
      other.shopId == shopId &&
      other.shopName == shopName &&
      other.workspaceId == workspaceId &&
      other.workspaceName == workspaceName &&
      other.fullName == fullName &&
      other.email == email &&
      other.phone == phone &&
      other.avatarUrl == avatarUrl &&
      other.roles == roles &&
      other.permissions == permissions &&
      other.systemAdmin == systemAdmin &&
      other.emailVerified == emailVerified &&
      other.phoneVerified == phoneVerified &&
      other.paymentRequired == paymentRequired &&
      other.catalogOnly == catalogOnly &&
      other.features == features &&
      other.planCode == planCode &&
      other.planName == planName &&
      other.periodEnd == periodEnd;

    @override
    int get hashCode =>
        id.hashCode +
        shopId.hashCode +
        shopName.hashCode +
        workspaceId.hashCode +
        workspaceName.hashCode +
        fullName.hashCode +
        email.hashCode +
        phone.hashCode +
        avatarUrl.hashCode +
        roles.hashCode +
        permissions.hashCode +
        systemAdmin.hashCode +
        emailVerified.hashCode +
        phoneVerified.hashCode +
        paymentRequired.hashCode +
        catalogOnly.hashCode +
        features.hashCode +
        planCode.hashCode +
        planName.hashCode +
        periodEnd.hashCode;

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) => _$AuthenticatedUserFromJson(json);

  Map<String, dynamic> toJson() => _$AuthenticatedUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

