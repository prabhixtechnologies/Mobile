//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'magic_link_verify_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MagicLinkVerifyRequest {
  /// Returns a new [MagicLinkVerifyRequest] instance.
  MagicLinkVerifyRequest({

    required  this.token,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MagicLinkVerifyRequest &&
      other.token == token;

    @override
    int get hashCode =>
        token.hashCode;

  factory MagicLinkVerifyRequest.fromJson(Map<String, dynamic> json) => _$MagicLinkVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MagicLinkVerifyRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

