//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_message_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendMessageRequest {
  /// Returns a new [SendMessageRequest] instance.
  SendMessageRequest({

    required  this.body,

     this.fileId,
  });

  @JsonKey(
    
    name: r'body',
    required: true,
    includeIfNull: false,
  )


  final String body;



  @JsonKey(
    
    name: r'fileId',
    required: false,
    includeIfNull: false,
  )


  final String? fileId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SendMessageRequest &&
      other.body == body &&
      other.fileId == fileId;

    @override
    int get hashCode =>
        body.hashCode +
        fileId.hashCode;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

