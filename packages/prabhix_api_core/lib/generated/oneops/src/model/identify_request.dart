//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'identify_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IdentifyRequest {
  /// Returns a new [IdentifyRequest] instance.
  IdentifyRequest({

    required  this.visitorKey,

     this.name,

     this.email,

     this.userId,
  });

  @JsonKey(
    
    name: r'visitorKey',
    required: true,
    includeIfNull: false,
  )


  final String visitorKey;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IdentifyRequest &&
      other.visitorKey == visitorKey &&
      other.name == name &&
      other.email == email &&
      other.userId == userId;

    @override
    int get hashCode =>
        visitorKey.hashCode +
        name.hashCode +
        email.hashCode +
        userId.hashCode;

  factory IdentifyRequest.fromJson(Map<String, dynamic> json) => _$IdentifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$IdentifyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

