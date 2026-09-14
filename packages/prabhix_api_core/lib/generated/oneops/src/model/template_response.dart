//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TemplateResponse {
  /// Returns a new [TemplateResponse] instance.
  TemplateResponse({

     this.id,

     this.templateKey,

     this.locale,

     this.name,

     this.subject,

     this.category,

     this.enabled,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'templateKey',
    required: false,
    includeIfNull: false,
  )


  final String? templateKey;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'category',
    required: false,
    includeIfNull: false,
  )


  final TemplateResponseCategoryEnum? category;



  @JsonKey(
    
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TemplateResponse &&
      other.id == id &&
      other.templateKey == templateKey &&
      other.locale == locale &&
      other.name == name &&
      other.subject == subject &&
      other.category == category &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        id.hashCode +
        templateKey.hashCode +
        locale.hashCode +
        name.hashCode +
        subject.hashCode +
        category.hashCode +
        enabled.hashCode;

  factory TemplateResponse.fromJson(Map<String, dynamic> json) => _$TemplateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum TemplateResponseCategoryEnum {
@JsonValue(r'TRANSACTIONAL')
TRANSACTIONAL(r'TRANSACTIONAL'),
@JsonValue(r'NOTIFICATION')
NOTIFICATION(r'NOTIFICATION'),
@JsonValue(r'MARKETING')
MARKETING(r'MARKETING');

const TemplateResponseCategoryEnum(this.value);

final String value;

@override
String toString() => value;
}


