//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dimension_count.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DimensionCount {
  /// Returns a new [DimensionCount] instance.
  DimensionCount({

     this.dimension,

     this.count,
  });

  @JsonKey(
    
    name: r'dimension',
    required: false,
    includeIfNull: false,
  )


  final String? dimension;



  @JsonKey(
    
    name: r'count',
    required: false,
    includeIfNull: false,
  )


  final int? count;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DimensionCount &&
      other.dimension == dimension &&
      other.count == count;

    @override
    int get hashCode =>
        dimension.hashCode +
        count.hashCode;

  factory DimensionCount.fromJson(Map<String, dynamic> json) => _$DimensionCountFromJson(json);

  Map<String, dynamic> toJson() => _$DimensionCountToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

