//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewResponse {
  /// Returns a new [PreviewResponse] instance.
  PreviewResponse({

     this.subject,

     this.bodyHtml,

     this.bodyText,
  });

  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'bodyHtml',
    required: false,
    includeIfNull: false,
  )


  final String? bodyHtml;



  @JsonKey(
    
    name: r'bodyText',
    required: false,
    includeIfNull: false,
  )


  final String? bodyText;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreviewResponse &&
      other.subject == subject &&
      other.bodyHtml == bodyHtml &&
      other.bodyText == bodyText;

    @override
    int get hashCode =>
        subject.hashCode +
        bodyHtml.hashCode +
        bodyText.hashCode;

  factory PreviewResponse.fromJson(Map<String, dynamic> json) => _$PreviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

