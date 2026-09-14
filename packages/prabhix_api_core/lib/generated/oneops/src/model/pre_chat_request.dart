//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pre_chat_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreChatRequest {
  /// Returns a new [PreChatRequest] instance.
  PreChatRequest({

    required  this.name,

    required  this.email,

     this.subject,

     this.visitorKey,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'visitorKey',
    required: false,
    includeIfNull: false,
  )


  final String? visitorKey;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreChatRequest &&
      other.name == name &&
      other.email == email &&
      other.subject == subject &&
      other.visitorKey == visitorKey;

    @override
    int get hashCode =>
        name.hashCode +
        email.hashCode +
        subject.hashCode +
        visitorKey.hashCode;

  factory PreChatRequest.fromJson(Map<String, dynamic> json) => _$PreChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PreChatRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

