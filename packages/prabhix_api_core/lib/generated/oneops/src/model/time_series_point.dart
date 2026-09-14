//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time_series_point.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TimeSeriesPoint {
  /// Returns a new [TimeSeriesPoint] instance.
  TimeSeriesPoint({

     this.date,

     this.count,
  });

  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final String? date;



  @JsonKey(
    
    name: r'count',
    required: false,
    includeIfNull: false,
  )


  final int? count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TimeSeriesPoint &&
      other.date == date &&
      other.count == count;

    @override
    int get hashCode =>
        date.hashCode +
        count.hashCode;

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) => _$TimeSeriesPointFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSeriesPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

