//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateRequest {
  /// Returns a new [CreateRequest] instance.
  CreateRequest({

    required  this.address,

     this.reason,

     this.detail,
  });

  @JsonKey(
    
    name: r'address',
    required: true,
    includeIfNull: false,
  )


  final String address;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final CreateRequestReasonEnum? reason;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateRequest &&
      other.address == address &&
      other.reason == reason &&
      other.detail == detail;

    @override
    int get hashCode =>
        address.hashCode +
        reason.hashCode +
        detail.hashCode;

  factory CreateRequest.fromJson(Map<String, dynamic> json) => _$CreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CreateRequestReasonEnum {
@JsonValue(r'HARD_BOUNCE')
HARD_BOUNCE(r'HARD_BOUNCE'),
@JsonValue(r'SOFT_BOUNCE')
SOFT_BOUNCE(r'SOFT_BOUNCE'),
@JsonValue(r'COMPLAINT')
COMPLAINT(r'COMPLAINT'),
@JsonValue(r'UNSUBSCRIBE')
UNSUBSCRIBE(r'UNSUBSCRIBE'),
@JsonValue(r'MANUAL')
MANUAL(r'MANUAL'),
@JsonValue(r'INVALID')
INVALID(r'INVALID');

const CreateRequestReasonEnum(this.value);

final String value;

@override
String toString() => value;
}


