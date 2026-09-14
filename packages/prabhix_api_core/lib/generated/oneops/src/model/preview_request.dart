//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'preview_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PreviewRequest {
  /// Returns a new [PreviewRequest] instance.
  PreviewRequest({

     this.variables,
  });

  @JsonKey(
    
    name: r'variables',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? variables;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PreviewRequest &&
      other.variables == variables;

    @override
    int get hashCode =>
        variables.hashCode;

  factory PreviewRequest.fromJson(Map<String, dynamic> json) => _$PreviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

