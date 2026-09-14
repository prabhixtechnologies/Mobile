//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mailbox_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MailboxResponse {
  /// Returns a new [MailboxResponse] instance.
  MailboxResponse({

     this.id,

     this.address,

     this.name,

     this.kind,

     this.status,

     this.openThreadCount,

     this.unassignedCount,
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
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final MailboxResponseKindEnum? kind;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final MailboxResponseStatusEnum? status;



  @JsonKey(
    
    name: r'openThreadCount',
    required: false,
    includeIfNull: false,
  )


  final int? openThreadCount;



  @JsonKey(
    
    name: r'unassignedCount',
    required: false,
    includeIfNull: false,
  )


  final int? unassignedCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MailboxResponse &&
      other.id == id &&
      other.address == address &&
      other.name == name &&
      other.kind == kind &&
      other.status == status &&
      other.openThreadCount == openThreadCount &&
      other.unassignedCount == unassignedCount;

    @override
    int get hashCode =>
        id.hashCode +
        address.hashCode +
        name.hashCode +
        kind.hashCode +
        status.hashCode +
        openThreadCount.hashCode +
        unassignedCount.hashCode;

  factory MailboxResponse.fromJson(Map<String, dynamic> json) => _$MailboxResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MailboxResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum MailboxResponseKindEnum {
@JsonValue(r'SHARED')
SHARED(r'SHARED'),
@JsonValue(r'PERSONAL')
PERSONAL(r'PERSONAL'),
@JsonValue(r'SYSTEM')
SYSTEM(r'SYSTEM');

const MailboxResponseKindEnum(this.value);

final String value;

@override
String toString() => value;
}


enum MailboxResponseStatusEnum {
@JsonValue(r'ACTIVE')
ACTIVE(r'ACTIVE'),
@JsonValue(r'PAUSED')
PAUSED(r'PAUSED'),
@JsonValue(r'ARCHIVED')
ARCHIVED(r'ARCHIVED');

const MailboxResponseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


