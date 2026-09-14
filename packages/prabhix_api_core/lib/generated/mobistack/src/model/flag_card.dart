//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'flag_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FlagCard {
  /// Returns a new [FlagCard] instance.
  FlagCard({

     this.code,

     this.enabled,
  });

  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is FlagCard &&
      other.code == code &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        code.hashCode +
        enabled.hashCode;

  factory FlagCard.fromJson(Map<String, dynamic> json) => _$FlagCardFromJson(json);

  Map<String, dynamic> toJson() => _$FlagCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

