//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dns_record.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DnsRecord {
  /// Returns a new [DnsRecord] instance.
  DnsRecord({

     this.name,

     this.type,

     this.expected,

     this.observed,

     this.status,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'type',
    required: false,
    includeIfNull: false,
  )


  final String? type;



  @JsonKey(
    
    name: r'expected',
    required: false,
    includeIfNull: false,
  )


  final String? expected;



  @JsonKey(
    
    name: r'observed',
    required: false,
    includeIfNull: false,
  )


  final String? observed;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DnsRecord &&
      other.name == name &&
      other.type == type &&
      other.expected == expected &&
      other.observed == observed &&
      other.status == status;

    @override
    int get hashCode =>
        name.hashCode +
        type.hashCode +
        expected.hashCode +
        observed.hashCode +
        status.hashCode;

  factory DnsRecord.fromJson(Map<String, dynamic> json) => _$DnsRecordFromJson(json);

  Map<String, dynamic> toJson() => _$DnsRecordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

