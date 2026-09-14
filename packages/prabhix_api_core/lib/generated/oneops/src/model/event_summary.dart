//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventSummary {
  /// Returns a new [EventSummary] instance.
  EventSummary({

     this.eventType,

     this.actorUserId,

     this.actorLabel,

     this.fromValue,

     this.toValue,

     this.createdAt,
  });

  @JsonKey(
    
    name: r'eventType',
    required: false,
    includeIfNull: false,
  )


  final EventSummaryEventTypeEnum? eventType;



  @JsonKey(
    
    name: r'actorUserId',
    required: false,
    includeIfNull: false,
  )


  final String? actorUserId;



  @JsonKey(
    
    name: r'actorLabel',
    required: false,
    includeIfNull: false,
  )


  final String? actorLabel;



  @JsonKey(
    
    name: r'fromValue',
    required: false,
    includeIfNull: false,
  )


  final String? fromValue;



  @JsonKey(
    
    name: r'toValue',
    required: false,
    includeIfNull: false,
  )


  final String? toValue;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EventSummary &&
      other.eventType == eventType &&
      other.actorUserId == actorUserId &&
      other.actorLabel == actorLabel &&
      other.fromValue == fromValue &&
      other.toValue == toValue &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        eventType.hashCode +
        actorUserId.hashCode +
        actorLabel.hashCode +
        fromValue.hashCode +
        toValue.hashCode +
        createdAt.hashCode;

  factory EventSummary.fromJson(Map<String, dynamic> json) => _$EventSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$EventSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum EventSummaryEventTypeEnum {
@JsonValue(r'CREATED')
CREATED(r'CREATED'),
@JsonValue(r'MESSAGE_RECEIVED')
MESSAGE_RECEIVED(r'MESSAGE_RECEIVED'),
@JsonValue(r'MESSAGE_SENT')
MESSAGE_SENT(r'MESSAGE_SENT'),
@JsonValue(r'ASSIGNED')
ASSIGNED(r'ASSIGNED'),
@JsonValue(r'UNASSIGNED')
UNASSIGNED(r'UNASSIGNED'),
@JsonValue(r'STATUS_CHANGED')
STATUS_CHANGED(r'STATUS_CHANGED'),
@JsonValue(r'PRIORITY_CHANGED')
PRIORITY_CHANGED(r'PRIORITY_CHANGED'),
@JsonValue(r'TAG_ADDED')
TAG_ADDED(r'TAG_ADDED'),
@JsonValue(r'TAG_REMOVED')
TAG_REMOVED(r'TAG_REMOVED'),
@JsonValue(r'NOTE_ADDED')
NOTE_ADDED(r'NOTE_ADDED'),
@JsonValue(r'SLA_BREACHED')
SLA_BREACHED(r'SLA_BREACHED'),
@JsonValue(r'MERGED')
MERGED(r'MERGED'),
@JsonValue(r'MOVED')
MOVED(r'MOVED'),
@JsonValue(r'AUTO_REPLIED')
AUTO_REPLIED(r'AUTO_REPLIED'),
@JsonValue(r'RULE_APPLIED')
RULE_APPLIED(r'RULE_APPLIED');

const EventSummaryEventTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


