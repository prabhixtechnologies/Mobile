//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template_variable.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TemplateVariable {
  /// Returns a new [TemplateVariable] instance.
  TemplateVariable({

     this.name,

     this.example,

     this.required_,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'example',
    required: false,
    includeIfNull: false,
  )


  final String? example;



  @JsonKey(
    
    name: r'required',
    required: false,
    includeIfNull: false,
  )


  final bool? required_;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TemplateVariable &&
      other.name == name &&
      other.example == example &&
      other.required_ == required_;

    @override
    int get hashCode =>
        name.hashCode +
        example.hashCode +
        required_.hashCode;

  factory TemplateVariable.fromJson(Map<String, dynamic> json) => _$TemplateVariableFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateVariableToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

