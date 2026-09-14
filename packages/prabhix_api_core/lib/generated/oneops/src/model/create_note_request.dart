//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_note_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateNoteRequest {
  /// Returns a new [CreateNoteRequest] instance.
  CreateNoteRequest({

    required  this.bodyHtml,
  });

  @JsonKey(
    
    name: r'bodyHtml',
    required: true,
    includeIfNull: false,
  )


  final String bodyHtml;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateNoteRequest &&
      other.bodyHtml == bodyHtml;

    @override
    int get hashCode =>
        bodyHtml.hashCode;

  factory CreateNoteRequest.fromJson(Map<String, dynamic> json) => _$CreateNoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateNoteRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

