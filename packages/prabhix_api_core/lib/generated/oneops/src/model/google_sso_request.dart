//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_sso_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleSsoRequest {
  /// Returns a new [GoogleSsoRequest] instance.
  GoogleSsoRequest({

    required  this.idToken,

     this.deviceId,

     this.deviceName,

     this.deviceType,
  });

  @JsonKey(
    
    name: r'idToken',
    required: true,
    includeIfNull: false,
  )


  final String idToken;



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
    bool operator ==(Object other) => identical(this, other) || other is GoogleSsoRequest &&
      other.idToken == idToken &&
      other.deviceId == deviceId &&
      other.deviceName == deviceName &&
      other.deviceType == deviceType;

    @override
    int get hashCode =>
        idToken.hashCode +
        deviceId.hashCode +
        deviceName.hashCode +
        deviceType.hashCode;

  factory GoogleSsoRequest.fromJson(Map<String, dynamic> json) => _$GoogleSsoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleSsoRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

