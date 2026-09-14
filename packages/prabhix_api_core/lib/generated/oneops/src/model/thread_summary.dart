//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'thread_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ThreadSummary {
  /// Returns a new [ThreadSummary] instance.
  ThreadSummary({

     this.id,

     this.mailboxId,

     this.referenceKey,

     this.subject,

     this.status,

     this.priority,

     this.assigneeUserId,

     this.assigneeTeamId,

     this.customerEmail,

     this.snippet,

     this.messageCount,

     this.unreadCount,

     this.hasAttachments,

     this.lastMessageAt,

     this.lastMessageDirection,

     this.slaDueAt,

     this.slaBreachedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'mailboxId',
    required: false,
    includeIfNull: false,
  )


  final String? mailboxId;



  @JsonKey(
    
    name: r'referenceKey',
    required: false,
    includeIfNull: false,
  )


  final String? referenceKey;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final ThreadSummaryStatusEnum? status;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final ThreadSummaryPriorityEnum? priority;



  @JsonKey(
    
    name: r'assigneeUserId',
    required: false,
    includeIfNull: false,
  )


  final String? assigneeUserId;



  @JsonKey(
    
    name: r'assigneeTeamId',
    required: false,
    includeIfNull: false,
  )


  final String? assigneeTeamId;



  @JsonKey(
    
    name: r'customerEmail',
    required: false,
    includeIfNull: false,
  )


  final String? customerEmail;



  @JsonKey(
    
    name: r'snippet',
    required: false,
    includeIfNull: false,
  )


  final String? snippet;



  @JsonKey(
    
    name: r'messageCount',
    required: false,
    includeIfNull: false,
  )


  final int? messageCount;



  @JsonKey(
    
    name: r'unreadCount',
    required: false,
    includeIfNull: false,
  )


  final int? unreadCount;



  @JsonKey(
    
    name: r'hasAttachments',
    required: false,
    includeIfNull: false,
  )


  final bool? hasAttachments;



  @JsonKey(
    
    name: r'lastMessageAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastMessageAt;



  @JsonKey(
    
    name: r'lastMessageDirection',
    required: false,
    includeIfNull: false,
  )


  final ThreadSummaryLastMessageDirectionEnum? lastMessageDirection;



  @JsonKey(
    
    name: r'slaDueAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? slaDueAt;



  @JsonKey(
    
    name: r'slaBreachedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? slaBreachedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ThreadSummary &&
      other.id == id &&
      other.mailboxId == mailboxId &&
      other.referenceKey == referenceKey &&
      other.subject == subject &&
      other.status == status &&
      other.priority == priority &&
      other.assigneeUserId == assigneeUserId &&
      other.assigneeTeamId == assigneeTeamId &&
      other.customerEmail == customerEmail &&
      other.snippet == snippet &&
      other.messageCount == messageCount &&
      other.unreadCount == unreadCount &&
      other.hasAttachments == hasAttachments &&
      other.lastMessageAt == lastMessageAt &&
      other.lastMessageDirection == lastMessageDirection &&
      other.slaDueAt == slaDueAt &&
      other.slaBreachedAt == slaBreachedAt;

    @override
    int get hashCode =>
        id.hashCode +
        mailboxId.hashCode +
        referenceKey.hashCode +
        subject.hashCode +
        status.hashCode +
        priority.hashCode +
        assigneeUserId.hashCode +
        assigneeTeamId.hashCode +
        customerEmail.hashCode +
        snippet.hashCode +
        messageCount.hashCode +
        unreadCount.hashCode +
        hasAttachments.hashCode +
        lastMessageAt.hashCode +
        lastMessageDirection.hashCode +
        slaDueAt.hashCode +
        slaBreachedAt.hashCode;

  factory ThreadSummary.fromJson(Map<String, dynamic> json) => _$ThreadSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum ThreadSummaryStatusEnum {
@JsonValue(r'OPEN')
OPEN(r'OPEN'),
@JsonValue(r'PENDING_CUSTOMER')
PENDING_CUSTOMER(r'PENDING_CUSTOMER'),
@JsonValue(r'ON_HOLD')
ON_HOLD(r'ON_HOLD'),
@JsonValue(r'RESOLVED')
RESOLVED(r'RESOLVED'),
@JsonValue(r'CLOSED')
CLOSED(r'CLOSED'),
@JsonValue(r'SPAM')
SPAM(r'SPAM'),
@JsonValue(r'TRASH')
TRASH(r'TRASH');

const ThreadSummaryStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ThreadSummaryPriorityEnum {
@JsonValue(r'LOW')
LOW(r'LOW'),
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'HIGH')
HIGH(r'HIGH'),
@JsonValue(r'URGENT')
URGENT(r'URGENT');

const ThreadSummaryPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


enum ThreadSummaryLastMessageDirectionEnum {
@JsonValue(r'INBOUND')
INBOUND(r'INBOUND'),
@JsonValue(r'OUTBOUND')
OUTBOUND(r'OUTBOUND');

const ThreadSummaryLastMessageDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}


