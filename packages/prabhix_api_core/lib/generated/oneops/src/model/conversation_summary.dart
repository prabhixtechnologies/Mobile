//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conversation_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConversationSummary {
  /// Returns a new [ConversationSummary] instance.
  ConversationSummary({

     this.id,

     this.status,

     this.priority,

     this.subject,

     this.visitorName,

     this.visitorEmail,

     this.assignedAgentId,

     this.tags,

     this.unreadAgentCount,

     this.lastMessageAt,

     this.lastMessagePreview,

     this.visitorId,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final ConversationSummaryStatusEnum? status;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final ConversationSummaryPriorityEnum? priority;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'visitorName',
    required: false,
    includeIfNull: false,
  )


  final String? visitorName;



  @JsonKey(
    
    name: r'visitorEmail',
    required: false,
    includeIfNull: false,
  )


  final String? visitorEmail;



  @JsonKey(
    
    name: r'assignedAgentId',
    required: false,
    includeIfNull: false,
  )


  final String? assignedAgentId;



  @JsonKey(
    
    name: r'tags',
    required: false,
    includeIfNull: false,
  )


  final List<String>? tags;



  @JsonKey(
    
    name: r'unreadAgentCount',
    required: false,
    includeIfNull: false,
  )


  final int? unreadAgentCount;



  @JsonKey(
    
    name: r'lastMessageAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastMessageAt;



  @JsonKey(
    
    name: r'lastMessagePreview',
    required: false,
    includeIfNull: false,
  )


  final String? lastMessagePreview;



  @JsonKey(
    
    name: r'visitorId',
    required: false,
    includeIfNull: false,
  )


  final String? visitorId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ConversationSummary &&
      other.id == id &&
      other.status == status &&
      other.priority == priority &&
      other.subject == subject &&
      other.visitorName == visitorName &&
      other.visitorEmail == visitorEmail &&
      other.assignedAgentId == assignedAgentId &&
      other.tags == tags &&
      other.unreadAgentCount == unreadAgentCount &&
      other.lastMessageAt == lastMessageAt &&
      other.lastMessagePreview == lastMessagePreview &&
      other.visitorId == visitorId;

    @override
    int get hashCode =>
        id.hashCode +
        status.hashCode +
        priority.hashCode +
        subject.hashCode +
        visitorName.hashCode +
        visitorEmail.hashCode +
        assignedAgentId.hashCode +
        tags.hashCode +
        unreadAgentCount.hashCode +
        lastMessageAt.hashCode +
        lastMessagePreview.hashCode +
        visitorId.hashCode;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) => _$ConversationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ConversationSummaryStatusEnum {
@JsonValue(r'OPEN')
OPEN(r'OPEN'),
@JsonValue(r'PENDING')
PENDING(r'PENDING'),
@JsonValue(r'RESOLVED')
RESOLVED(r'RESOLVED'),
@JsonValue(r'CLOSED')
CLOSED(r'CLOSED');

const ConversationSummaryStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ConversationSummaryPriorityEnum {
@JsonValue(r'LOW')
LOW(r'LOW'),
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'HIGH')
HIGH(r'HIGH'),
@JsonValue(r'URGENT')
URGENT(r'URGENT');

const ConversationSummaryPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


