//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'domain_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DomainResponse {
  /// Returns a new [DomainResponse] instance.
  DomainResponse({

     this.id,

     this.domain,

     this.status,

     this.mode,

     this.isDefault,

     this.mxVerifiedAt,

     this.spfVerifiedAt,

     this.dkimVerifiedAt,

     this.dmarcVerifiedAt,

     this.ownershipVerifiedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'domain',
    required: false,
    includeIfNull: false,
  )


  final String? domain;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final DomainResponseStatusEnum? status;



  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final DomainResponseModeEnum? mode;



  @JsonKey(
    
    name: r'isDefault',
    required: false,
    includeIfNull: false,
  )


  final bool? isDefault;



  @JsonKey(
    
    name: r'mxVerifiedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? mxVerifiedAt;



  @JsonKey(
    
    name: r'spfVerifiedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? spfVerifiedAt;



  @JsonKey(
    
    name: r'dkimVerifiedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? dkimVerifiedAt;



  @JsonKey(
    
    name: r'dmarcVerifiedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? dmarcVerifiedAt;



  @JsonKey(
    
    name: r'ownershipVerifiedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? ownershipVerifiedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DomainResponse &&
      other.id == id &&
      other.domain == domain &&
      other.status == status &&
      other.mode == mode &&
      other.isDefault == isDefault &&
      other.mxVerifiedAt == mxVerifiedAt &&
      other.spfVerifiedAt == spfVerifiedAt &&
      other.dkimVerifiedAt == dkimVerifiedAt &&
      other.dmarcVerifiedAt == dmarcVerifiedAt &&
      other.ownershipVerifiedAt == ownershipVerifiedAt;

    @override
    int get hashCode =>
        id.hashCode +
        domain.hashCode +
        status.hashCode +
        mode.hashCode +
        isDefault.hashCode +
        mxVerifiedAt.hashCode +
        spfVerifiedAt.hashCode +
        dkimVerifiedAt.hashCode +
        dmarcVerifiedAt.hashCode +
        ownershipVerifiedAt.hashCode;

  factory DomainResponse.fromJson(Map<String, dynamic> json) => _$DomainResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DomainResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DomainResponseStatusEnum {
@JsonValue(r'PENDING')
PENDING(r'PENDING'),
@JsonValue(r'VERIFYING')
VERIFYING(r'VERIFYING'),
@JsonValue(r'VERIFIED')
VERIFIED(r'VERIFIED'),
@JsonValue(r'FAILED')
FAILED(r'FAILED'),
@JsonValue(r'DISABLED')
DISABLED(r'DISABLED');

const DomainResponseStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


enum DomainResponseModeEnum {
@JsonValue(r'SELF_HOSTED')
SELF_HOSTED(r'SELF_HOSTED'),
@JsonValue(r'EXTERNAL_IMAP')
EXTERNAL_IMAP(r'EXTERNAL_IMAP'),
@JsonValue(r'RELAY_ONLY')
RELAY_ONLY(r'RELAY_ONLY');

const DomainResponseModeEnum(this.value);

final String value;

@override
String toString() => value;
}


