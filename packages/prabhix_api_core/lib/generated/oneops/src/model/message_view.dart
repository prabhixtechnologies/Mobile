//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MessageView {
  /// Returns a new [MessageView] instance.
  MessageView({

     this.id,

     this.senderType,

     this.senderUserId,

     this.body,

     this.fileId,

     this.occurredAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'senderType',
    required: false,
    includeIfNull: false,
  )


  final MessageViewSenderTypeEnum? senderType;



  @JsonKey(
    
    name: r'senderUserId',
    required: false,
    includeIfNull: false,
  )


  final String? senderUserId;



  @JsonKey(
    
    name: r'body',
    required: false,
    includeIfNull: false,
  )


  final String? body;



  @JsonKey(
    
    name: r'fileId',
    required: false,
    includeIfNull: false,
  )


  final String? fileId;



  @JsonKey(
    
    name: r'occurredAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? occurredAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MessageView &&
      other.id == id &&
      other.senderType == senderType &&
      other.senderUserId == senderUserId &&
      other.body == body &&
      other.fileId == fileId &&
      other.occurredAt == occurredAt;

    @override
    int get hashCode =>
        id.hashCode +
        senderType.hashCode +
        senderUserId.hashCode +
        body.hashCode +
        fileId.hashCode +
        occurredAt.hashCode;

  factory MessageView.fromJson(Map<String, dynamic> json) => _$MessageViewFromJson(json);

  Map<String, dynamic> toJson() => _$MessageViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MessageViewSenderTypeEnum {
@JsonValue(r'VISITOR')
VISITOR(r'VISITOR'),
@JsonValue(r'AGENT')
AGENT(r'AGENT'),
@JsonValue(r'SYSTEM')
SYSTEM(r'SYSTEM'),
@JsonValue(r'NOTE')
NOTE(r'NOTE');

const MessageViewSenderTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


