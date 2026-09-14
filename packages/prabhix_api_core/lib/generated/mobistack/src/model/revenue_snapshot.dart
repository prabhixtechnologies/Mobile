//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revenue_snapshot.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevenueSnapshot {
  /// Returns a new [RevenueSnapshot] instance.
  RevenueSnapshot({

     this.capturedTotal,

     this.pendingTotal,

     this.capturedCount,

     this.pendingCount,

     this.failedCount,

     this.currency,

     this.asOf,
  });

  @JsonKey(
    
    name: r'capturedTotal',
    required: false,
    includeIfNull: false,
  )


  final num? capturedTotal;



  @JsonKey(
    
    name: r'pendingTotal',
    required: false,
    includeIfNull: false,
  )


  final num? pendingTotal;



  @JsonKey(
    
    name: r'capturedCount',
    required: false,
    includeIfNull: false,
  )


  final int? capturedCount;



  @JsonKey(
    
    name: r'pendingCount',
    required: false,
    includeIfNull: false,
  )


  final int? pendingCount;



  @JsonKey(
    
    name: r'failedCount',
    required: false,
    includeIfNull: false,
  )


  final int? failedCount;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'asOf',
    required: false,
    includeIfNull: false,
  )


  final DateTime? asOf;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RevenueSnapshot &&
      other.capturedTotal == capturedTotal &&
      other.pendingTotal == pendingTotal &&
      other.capturedCount == capturedCount &&
      other.pendingCount == pendingCount &&
      other.failedCount == failedCount &&
      other.currency == currency &&
      other.asOf == asOf;

    @override
    int get hashCode =>
        capturedTotal.hashCode +
        pendingTotal.hashCode +
        capturedCount.hashCode +
        pendingCount.hashCode +
        failedCount.hashCode +
        currency.hashCode +
        asOf.hashCode;

  factory RevenueSnapshot.fromJson(Map<String, dynamic> json) => _$RevenueSnapshotFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueSnapshotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

