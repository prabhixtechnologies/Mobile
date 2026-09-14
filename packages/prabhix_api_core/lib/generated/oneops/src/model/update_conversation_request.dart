//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_conversation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateConversationRequest {
  /// Returns a new [UpdateConversationRequest] instance.
  UpdateConversationRequest({

     this.status,

     this.priority,

     this.tags,
  });

  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final UpdateConversationRequestStatusEnum? status;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final UpdateConversationRequestPriorityEnum? priority;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateConversationRequest &&
      other.status == status &&
      other.priority == priority &&
      other.tags == tags;

    @override
    int get hashCode =>
        status.hashCode +
        priority.hashCode +
        tags.hashCode;

  factory UpdateConversationRequest.fromJson(Map<String, dynamic> json) => _$UpdateConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateConversationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UpdateConversationRequestStatusEnum {
@JsonValue(r'OPEN')
OPEN(r'OPEN'),
@JsonValue(r'PENDING')
PENDING(r'PENDING'),
@JsonValue(r'RESOLVED')
RESOLVED(r'RESOLVED'),
@JsonValue(r'CLOSED')
CLOSED(r'CLOSED');

const UpdateConversationRequestStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum UpdateConversationRequestPriorityEnum {
@JsonValue(r'LOW')
LOW(r'LOW'),
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'HIGH')
HIGH(r'HIGH'),
@JsonValue(r'URGENT')
URGENT(r'URGENT');

const UpdateConversationRequestPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


