//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_template_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateTemplateRequest {
  /// Returns a new [UpdateTemplateRequest] instance.
  UpdateTemplateRequest({

     this.name,

     this.subject,

     this.htmlBody,

     this.textBody,
  });

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





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateTemplateRequest &&
      other.name == name &&
      other.subject == subject &&
      other.htmlBody == htmlBody &&
      other.textBody == textBody;

    @override
    int get hashCode =>
        name.hashCode +
        subject.hashCode +
        htmlBody.hashCode +
        textBody.hashCode;

  factory UpdateTemplateRequest.fromJson(Map<String, dynamic> json) => _$UpdateTemplateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTemplateRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

