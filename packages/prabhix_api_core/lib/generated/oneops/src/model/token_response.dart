//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TokenResponse {
  /// Returns a new [TokenResponse] instance.
  TokenResponse({

     this.accessToken,

     this.refreshToken,

     this.expiresInSeconds,

     this.organizationId,

     this.permissions,
  });

  @JsonKey(
    
    name: r'accessToken',
    required: false,
    includeIfNull: false,
  )


  final String? accessToken;



  @JsonKey(
    
    name: r'refreshToken',
    required: false,
    includeIfNull: false,
  )


  final String? refreshToken;



  @JsonKey(
    
    name: r'expiresInSeconds',
    required: false,
    includeIfNull: false,
  )


  final int? expiresInSeconds;



  @JsonKey(
    
    name: r'organizationId',
    required: false,
    includeIfNull: false,
  )


  final String? organizationId;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final Set<String>? permissions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TokenResponse &&
      other.accessToken == accessToken &&
      other.refreshToken == refreshToken &&
      other.expiresInSeconds == expiresInSeconds &&
      other.organizationId == organizationId &&
      other.permissions == permissions;

    @override
    int get hashCode =>
        accessToken.hashCode +
        refreshToken.hashCode +
        expiresInSeconds.hashCode +
        organizationId.hashCode +
        permissions.hashCode;

  factory TokenResponse.fromJson(Map<String, dynamic> json) => _$TokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

