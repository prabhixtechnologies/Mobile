//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_api_key_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateApiKeyRequest {
  /// Returns a new [CreateApiKeyRequest] instance.
  CreateApiKeyRequest({

    required  this.name,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateApiKeyRequest &&
      other.name == name &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        name.hashCode +
        expiresAt.hashCode;

  factory CreateApiKeyRequest.fromJson(Map<String, dynamic> json) => _$CreateApiKeyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateApiKeyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

