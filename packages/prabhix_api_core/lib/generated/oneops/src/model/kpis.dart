//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'kpis.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Kpis {
  /// Returns a new [Kpis] instance.
  Kpis({

     this.openThreads,

     this.avgFirstResponseMinutes,

     this.slaBreaches,

     this.seatsUsed,

     this.seatsLimit,

     this.mrr,

     this.currency,
  });

  @JsonKey(
    
    name: r'openThreads',
    required: false,
    includeIfNull: false,
  )


  final int? openThreads;



  @JsonKey(
    
    name: r'avgFirstResponseMinutes',
    required: false,
    includeIfNull: false,
  )


  final double? avgFirstResponseMinutes;



  @JsonKey(
    
    name: r'slaBreaches',
    required: false,
    includeIfNull: false,
  )


  final int? slaBreaches;



  @JsonKey(
    
    name: r'seatsUsed',
    required: false,
    includeIfNull: false,
  )


  final int? seatsUsed;



  @JsonKey(
    
    name: r'seatsLimit',
    required: false,
    includeIfNull: false,
  )


  final int? seatsLimit;



  @JsonKey(
    
    name: r'mrr',
    required: false,
    includeIfNull: false,
  )


  final int? mrr;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;





    @override
    bool operator ==(Object other) => identical(this, other) || other is Kpis &&
      other.openThreads == openThreads &&
      other.avgFirstResponseMinutes == avgFirstResponseMinutes &&
      other.slaBreaches == slaBreaches &&
      other.seatsUsed == seatsUsed &&
      other.seatsLimit == seatsLimit &&
      other.mrr == mrr &&
      other.currency == currency;

    @override
    int get hashCode =>
        openThreads.hashCode +
        avgFirstResponseMinutes.hashCode +
        slaBreaches.hashCode +
        seatsUsed.hashCode +
        seatsLimit.hashCode +
        mrr.hashCode +
        currency.hashCode;

  factory Kpis.fromJson(Map<String, dynamic> json) => _$KpisFromJson(json);

  Map<String, dynamic> toJson() => _$KpisToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

