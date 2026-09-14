//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'effective_flags.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EffectiveFlags {
  /// Returns a new [EffectiveFlags] instance.
  EffectiveFlags({

     this.flags,
  });

  @JsonKey(
    
    name: r'flags',
    required: false,
    includeIfNull: false,
  )


  final Map<String, bool>? flags;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EffectiveFlags &&
      other.flags == flags;

    @override
    int get hashCode =>
        flags.hashCode;

  factory EffectiveFlags.fromJson(Map<String, dynamic> json) => _$EffectiveFlagsFromJson(json);

  Map<String, dynamic> toJson() => _$EffectiveFlagsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

