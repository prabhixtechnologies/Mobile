//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suppression_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuppressionResponse {
  /// Returns a new [SuppressionResponse] instance.
  SuppressionResponse({

     this.id,

     this.address,

     this.reason,

     this.detail,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'address',
    required: false,
    includeIfNull: false,
  )


  final String? address;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final SuppressionResponseReasonEnum? reason;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SuppressionResponse &&
      other.id == id &&
      other.address == address &&
      other.reason == reason &&
      other.detail == detail &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        id.hashCode +
        address.hashCode +
        reason.hashCode +
        detail.hashCode +
        expiresAt.hashCode;

  factory SuppressionResponse.fromJson(Map<String, dynamic> json) => _$SuppressionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuppressionResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SuppressionResponseReasonEnum {
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

const SuppressionResponseReasonEnum(this.value);

final String value;

@override
String toString() => value;
}


