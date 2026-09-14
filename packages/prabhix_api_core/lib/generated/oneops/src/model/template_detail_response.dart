//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/template_variable.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'template_detail_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TemplateDetailResponse {
  /// Returns a new [TemplateDetailResponse] instance.
  TemplateDetailResponse({

     this.key,

     this.name,

     this.locale,

     this.subject,

     this.htmlBody,

     this.textBody,

     this.variables,

     this.updatedAt,
  });

  @JsonKey(
    
    name: r'key',
    required: false,
    includeIfNull: false,
  )


  final String? key;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'locale',
    required: false,
    includeIfNull: false,
  )


  final String? locale;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'htmlBody',
    required: false,
    includeIfNull: false,
  )


  final String? htmlBody;



  @JsonKey(
    
    name: r'textBody',
    required: false,
    includeIfNull: false,
  )


  final String? textBody;



  @JsonKey(
    
    name: r'variables',
    required: false,
    includeIfNull: false,
  )


  final List<TemplateVariable>? variables;



  @JsonKey(
    
    name: r'updatedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? updatedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TemplateDetailResponse &&
      other.key == key &&
      other.name == name &&
      other.locale == locale &&
      other.subject == subject &&
      other.htmlBody == htmlBody &&
      other.textBody == textBody &&
      other.variables == variables &&
      other.updatedAt == updatedAt;

    @override
    int get hashCode =>
        key.hashCode +
        name.hashCode +
        locale.hashCode +
        subject.hashCode +
        htmlBody.hashCode +
        textBody.hashCode +
        variables.hashCode +
        updatedAt.hashCode;

  factory TemplateDetailResponse.fromJson(Map<String, dynamic> json) => _$TemplateDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateDetailResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

