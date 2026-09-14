//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chart_point.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChartPoint {
  /// Returns a new [ChartPoint] instance.
  ChartPoint({

     this.date,

     this.value,
  });

  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final String? date;



  @JsonKey(
    
    name: r'value',
    required: false,
    includeIfNull: false,
  )


  final double? value;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChartPoint &&
      other.date == date &&
      other.value == value;

    @override
    int get hashCode =>
        date.hashCode +
        value.hashCode;

  factory ChartPoint.fromJson(Map<String, dynamic> json) => _$ChartPointFromJson(json);

  Map<String, dynamic> toJson() => _$ChartPointToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

