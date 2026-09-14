//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'email_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EmailRequest {
  /// Returns a new [EmailRequest] instance.
  EmailRequest({

    required  this.email,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EmailRequest &&
      other.email == email;

    @override
    int get hashCode =>
        email.hashCode;

  factory EmailRequest.fromJson(Map<String, dynamic> json) => _$EmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

