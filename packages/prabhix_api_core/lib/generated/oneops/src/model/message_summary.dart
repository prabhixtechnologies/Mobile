//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MessageSummary {
  /// Returns a new [MessageSummary] instance.
  MessageSummary({

     this.id,

     this.direction,

     this.fromAddress,

     this.fromName,

     this.subject,

     this.snippet,

     this.bodyText,

     this.bodyHtml,

     this.deliveryStatus,

     this.occurredAt,

     this.attachmentCount,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'direction',
    required: false,
    includeIfNull: false,
  )


  final MessageSummaryDirectionEnum? direction;



  @JsonKey(
    
    name: r'fromAddress',
    required: false,
    includeIfNull: false,
  )


  final String? fromAddress;



  @JsonKey(
    
    name: r'fromName',
    required: false,
    includeIfNull: false,
  )


  final String? fromName;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'snippet',
    required: false,
    includeIfNull: false,
  )


  final String? snippet;



  @JsonKey(
    
    name: r'bodyText',
    required: false,
    includeIfNull: false,
  )


  final String? bodyText;



  @JsonKey(
    
    name: r'bodyHtml',
    required: false,
    includeIfNull: false,
  )


  final String? bodyHtml;



  @JsonKey(
    
    name: r'deliveryStatus',
    required: false,
    includeIfNull: false,
  )


  final MessageSummaryDeliveryStatusEnum? deliveryStatus;



  @JsonKey(
    
    name: r'occurredAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? occurredAt;



  @JsonKey(
    
    name: r'attachmentCount',
    required: false,
    includeIfNull: false,
  )


  final int? attachmentCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MessageSummary &&
      other.id == id &&
      other.direction == direction &&
      other.fromAddress == fromAddress &&
      other.fromName == fromName &&
      other.subject == subject &&
      other.snippet == snippet &&
      other.bodyText == bodyText &&
      other.bodyHtml == bodyHtml &&
      other.deliveryStatus == deliveryStatus &&
      other.occurredAt == occurredAt &&
      other.attachmentCount == attachmentCount;

    @override
    int get hashCode =>
        id.hashCode +
        direction.hashCode +
        fromAddress.hashCode +
        fromName.hashCode +
        subject.hashCode +
        snippet.hashCode +
        bodyText.hashCode +
        bodyHtml.hashCode +
        deliveryStatus.hashCode +
        occurredAt.hashCode +
        attachmentCount.hashCode;

  factory MessageSummary.fromJson(Map<String, dynamic> json) => _$MessageSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MessageSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MessageSummaryDirectionEnum {
@JsonValue(r'INBOUND')
INBOUND(r'INBOUND'),
@JsonValue(r'OUTBOUND')
OUTBOUND(r'OUTBOUND');

const MessageSummaryDirectionEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MessageSummaryDeliveryStatusEnum {
@JsonValue(r'RECEIVED')
RECEIVED(r'RECEIVED'),
@JsonValue(r'QUEUED')
QUEUED(r'QUEUED'),
@JsonValue(r'SENDING')
SENDING(r'SENDING'),
@JsonValue(r'SENT')
SENT(r'SENT'),
@JsonValue(r'FAILED')
FAILED(r'FAILED'),
@JsonValue(r'BOUNCED')
BOUNCED(r'BOUNCED'),
@JsonValue(r'DRAFT')
DRAFT(r'DRAFT');

const MessageSummaryDeliveryStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


