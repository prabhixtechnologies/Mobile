//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/time_series_point.dart';
import 'package:prabhix_oneops_api/src/model/dimension_count.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AnalyticsSummary {
  /// Returns a new [AnalyticsSummary] instance.
  AnalyticsSummary({

     this.topPages,

     this.topReferrers,

     this.sessionsOverTime,

     this.totalVisitors,

     this.identifiedVisitors,

     this.chatConversions,
  });

  @JsonKey(
    
    name: r'topPages',
    required: false,
    includeIfNull: false,
  )


  final List<DimensionCount>? topPages;



  @JsonKey(
    
    name: r'topReferrers',
    required: false,
    includeIfNull: false,
  )


  final List<DimensionCount>? topReferrers;



  @JsonKey(
    
    name: r'sessionsOverTime',
    required: false,
    includeIfNull: false,
  )


  final List<TimeSeriesPoint>? sessionsOverTime;



  @JsonKey(
    
    name: r'totalVisitors',
    required: false,
    includeIfNull: false,
  )


  final int? totalVisitors;



  @JsonKey(
    
    name: r'identifiedVisitors',
    required: false,
    includeIfNull: false,
  )


  final int? identifiedVisitors;



  @JsonKey(
    
    name: r'chatConversions',
    required: false,
    includeIfNull: false,
  )


  final int? chatConversions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AnalyticsSummary &&
      other.topPages == topPages &&
      other.topReferrers == topReferrers &&
      other.sessionsOverTime == sessionsOverTime &&
      other.totalVisitors == totalVisitors &&
      other.identifiedVisitors == identifiedVisitors &&
      other.chatConversions == chatConversions;

    @override
    int get hashCode =>
        topPages.hashCode +
        topReferrers.hashCode +
        sessionsOverTime.hashCode +
        totalVisitors.hashCode +
        identifiedVisitors.hashCode +
        chatConversions.hashCode;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) => _$AnalyticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

