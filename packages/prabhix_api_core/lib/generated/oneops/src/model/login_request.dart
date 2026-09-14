//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginRequest {
  /// Returns a new [LoginRequest] instance.
  LoginRequest({

    required  this.email,

    required  this.password,

     this.deviceId,

     this.deviceName,

     this.deviceType,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;



  @JsonKey(
    
    name: r'deviceId',
    required: false,
    includeIfNull: false,
  )


  final String? deviceId;



  @JsonKey(
    
    name: r'deviceName',
    required: false,
    includeIfNull: false,
  )


  final String? deviceName;



  @JsonKey(
    
    name: r'deviceType',
    required: false,
    includeIfNull: false,
  )


  final String? deviceType;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LoginRequest &&
      other.email == email &&
      other.password == password &&
      other.deviceId == deviceId &&
      other.deviceName == deviceName &&
      other.deviceType == deviceType;

    @override
    int get hashCode =>
        email.hashCode +
        password.hashCode +
        deviceId.hashCode +
        deviceName.hashCode +
        deviceType.hashCode;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

