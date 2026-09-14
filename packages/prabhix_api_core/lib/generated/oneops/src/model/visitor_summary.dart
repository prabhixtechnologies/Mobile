//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'visitor_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VisitorSummary {
  /// Returns a new [VisitorSummary] instance.
  VisitorSummary({

     this.id,

     this.externalKey,

     this.consentStatus,

     this.firstSeenAt,

     this.lastSeenAt,

     this.email,

     this.displayName,

     this.identified,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'externalKey',
    required: false,
    includeIfNull: false,
  )


  final String? externalKey;



  @JsonKey(
    
    name: r'consentStatus',
    required: false,
    includeIfNull: false,
  )


  final VisitorSummaryConsentStatusEnum? consentStatus;



  @JsonKey(
    
    name: r'firstSeenAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? firstSeenAt;



  @JsonKey(
    
    name: r'lastSeenAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastSeenAt;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'identified',
    required: false,
    includeIfNull: false,
  )


  final bool? identified;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VisitorSummary &&
      other.id == id &&
      other.externalKey == externalKey &&
      other.consentStatus == consentStatus &&
      other.firstSeenAt == firstSeenAt &&
      other.lastSeenAt == lastSeenAt &&
      other.email == email &&
      other.displayName == displayName &&
      other.identified == identified;

    @override
    int get hashCode =>
        id.hashCode +
        externalKey.hashCode +
        consentStatus.hashCode +
        firstSeenAt.hashCode +
        lastSeenAt.hashCode +
        email.hashCode +
        displayName.hashCode +
        identified.hashCode;

  factory VisitorSummary.fromJson(Map<String, dynamic> json) => _$VisitorSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$VisitorSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum VisitorSummaryConsentStatusEnum {
@JsonValue(r'FULL')
FULL(r'FULL'),
@JsonValue(r'MINIMAL')
MINIMAL(r'MINIMAL'),
@JsonValue(r'DELETED')
DELETED(r'DELETED');

const VisitorSummaryConsentStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


