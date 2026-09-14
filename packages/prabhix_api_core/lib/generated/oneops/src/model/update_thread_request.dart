//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_thread_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateThreadRequest {
  /// Returns a new [UpdateThreadRequest] instance.
  UpdateThreadRequest({

     this.status,

     this.priority,
  });

  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final UpdateThreadRequestStatusEnum? status;



  @JsonKey(
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final UpdateThreadRequestPriorityEnum? priority;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateThreadRequest &&
      other.status == status &&
      other.priority == priority;

    @override
    int get hashCode =>
        status.hashCode +
        priority.hashCode;

  factory UpdateThreadRequest.fromJson(Map<String, dynamic> json) => _$UpdateThreadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateThreadRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum UpdateThreadRequestStatusEnum {
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

const UpdateThreadRequestStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum UpdateThreadRequestPriorityEnum {
@JsonValue(r'LOW')
LOW(r'LOW'),
@JsonValue(r'NORMAL')
NORMAL(r'NORMAL'),
@JsonValue(r'HIGH')
HIGH(r'HIGH'),
@JsonValue(r'URGENT')
URGENT(r'URGENT');

const UpdateThreadRequestPriorityEnum(this.value);

final String value;

@override
String toString() => value;
}


