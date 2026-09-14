//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/activity_item.dart';
import 'package:prabhix_oneops_api/src/model/chart_point.dart';
import 'package:prabhix_oneops_api/src/model/kpis.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardResponse {
  /// Returns a new [DashboardResponse] instance.
  DashboardResponse({

     this.kpis,

     this.recentActivity,

     this.threadsTrend,

     this.responseTimeTrend,
  });

  @JsonKey(
    
    name: r'kpis',
    required: false,
    includeIfNull: false,
  )


  final Kpis? kpis;



  @JsonKey(
    
    name: r'recentActivity',
    required: false,
    includeIfNull: false,
  )


  final List<ActivityItem>? recentActivity;



  @JsonKey(
    
    name: r'threadsTrend',
    required: false,
    includeIfNull: false,
  )


  final List<ChartPoint>? threadsTrend;



  @JsonKey(
    
    name: r'responseTimeTrend',
    required: false,
    includeIfNull: false,
  )


  final List<ChartPoint>? responseTimeTrend;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DashboardResponse &&
      other.kpis == kpis &&
      other.recentActivity == recentActivity &&
      other.threadsTrend == threadsTrend &&
      other.responseTimeTrend == responseTimeTrend;

    @override
    int get hashCode =>
        kpis.hashCode +
        recentActivity.hashCode +
        threadsTrend.hashCode +
        responseTimeTrend.hashCode;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => _$DashboardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

