//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/dns_record.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dns_report.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DnsReport {
  /// Returns a new [DnsReport] instance.
  DnsReport({

     this.domainId,

     this.records,

     this.domainStatus,
  });

  @JsonKey(
    
    name: r'domainId',
    required: false,
    includeIfNull: false,
  )


  final String? domainId;



  @JsonKey(
    
    name: r'records',
    required: false,
    includeIfNull: false,
  )


  final List<DnsRecord>? records;



  @JsonKey(
    
    name: r'domainStatus',
    required: false,
    includeIfNull: false,
  )


  final DnsReportDomainStatusEnum? domainStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DnsReport &&
      other.domainId == domainId &&
      other.records == records &&
      other.domainStatus == domainStatus;

    @override
    int get hashCode =>
        domainId.hashCode +
        records.hashCode +
        domainStatus.hashCode;

  factory DnsReport.fromJson(Map<String, dynamic> json) => _$DnsReportFromJson(json);

  Map<String, dynamic> toJson() => _$DnsReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum DnsReportDomainStatusEnum {
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

const DnsReportDomainStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


