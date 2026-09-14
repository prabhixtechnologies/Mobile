//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'custom_event_input.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CustomEventInput {
  /// Returns a new [CustomEventInput] instance.
  CustomEventInput({

    required  this.name,

     this.properties,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'properties',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? properties;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CustomEventInput &&
      other.name == name &&
      other.properties == properties;

    @override
    int get hashCode =>
        name.hashCode +
        properties.hashCode;

  factory CustomEventInput.fromJson(Map<String, dynamic> json) => _$CustomEventInputFromJson(json);

  Map<String, dynamic> toJson() => _$CustomEventInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

