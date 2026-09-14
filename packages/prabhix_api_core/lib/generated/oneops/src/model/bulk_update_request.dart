//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bulk_update_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BulkUpdateRequest {
  /// Returns a new [BulkUpdateRequest] instance.
  BulkUpdateRequest({

    required  this.threadIds,

     this.status,

     this.priority,
  });

  @JsonKey(
    
    name: r'threadIds',
    required: true,
    includeIfNull: false,
  )


  final List<String> threadIds;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final BulkUpdateRequestStatusEnum? status;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final BulkUpdateRequestPriorityEnum? priority;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BulkUpdateRequest &&
      other.threadIds == threadIds &&
      other.status == status &&
      other.priority == priority;

    @override
    int get hashCode =>
        threadIds.hashCode +
        status.hashCode +
        priority.hashCode;

  factory BulkUpdateRequest.fromJson(Map<String, dynamic> json) => _$BulkUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkUpdateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum BulkUpdateRequestStatusEnum {
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

const BulkUpdateRequestStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum BulkUpdateRequestPriorityEnum {
@JsonValue(r'LOW')
LOW(r'LOW'),
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'HIGH')
HIGH(r'HIGH'),
@JsonValue(r'URGENT')
URGENT(r'URGENT');

const BulkUpdateRequestPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


