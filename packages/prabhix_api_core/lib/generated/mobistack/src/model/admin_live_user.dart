//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_live_user.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminLiveUser {
  /// Returns a new [AdminLiveUser] instance.
  AdminLiveUser({

     this.userId,

     this.fullName,

     this.email,

     this.shopName,

     this.deviceId,

     this.platform,

     this.appVersion,

     this.ipAddress,

     this.seenAt,
  });

  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



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
    
    name: r'shopName',
    required: false,
    includeIfNull: false,
  )


  final String? shopName;



  @JsonKey(
    
    name: r'deviceId',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



  @JsonKey(
    
    name: r'platform',
    required: false,
    includeIfNull: false,
  )


  final String? platform;



  @JsonKey(
    
    name: r'appVersion',
    required: false,
    includeIfNull: false,
  )


  final String? appVersion;



  @JsonKey(
    
    name: r'ipAddress',
    required: false,
    includeIfNull: false,
  )


  final String? ipAddress;



  @JsonKey(
    
    name: r'seenAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? seenAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminLiveUser &&
      other.userId == userId &&
      other.fullName == fullName &&
      other.email == email &&
      other.shopName == shopName &&
      other.deviceId == deviceId &&
      other.platform == platform &&
      other.appVersion == appVersion &&
      other.ipAddress == ipAddress &&
      other.seenAt == seenAt;

    @override
    int get hashCode =>
        userId.hashCode +
        fullName.hashCode +
        email.hashCode +
        shopName.hashCode +
        deviceId.hashCode +
        platform.hashCode +
        appVersion.hashCode +
        ipAddress.hashCode +
        seenAt.hashCode;

  factory AdminLiveUser.fromJson(Map<String, dynamic> json) => _$AdminLiveUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminLiveUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

