//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_domain_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateDomainRequest {
  /// Returns a new [CreateDomainRequest] instance.
  CreateDomainRequest({

    required  this.domain,

     this.mode,
  });

  @JsonKey(
    
    name: r'domain',
    required: true,
    includeIfNull: false,
  )


  final String domain;



  @JsonKey(
    
    name: r'mode',
    required: false,
    includeIfNull: false,
  )


  final CreateDomainRequestModeEnum? mode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateDomainRequest &&
      other.domain == domain &&
      other.mode == mode;

    @override
    int get hashCode =>
        domain.hashCode +
        mode.hashCode;

  factory CreateDomainRequest.fromJson(Map<String, dynamic> json) => _$CreateDomainRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDomainRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CreateDomainRequestModeEnum {
@JsonValue(r'SELF_HOSTED')
SELF_HOSTED(r'SELF_HOSTED'),
@JsonValue(r'EXTERNAL_IMAP')
EXTERNAL_IMAP(r'EXTERNAL_IMAP'),
@JsonValue(r'RELAY_ONLY')
RELAY_ONLY(r'RELAY_ONLY');

const CreateDomainRequestModeEnum(this.value);

final String value;

@override
String toString() => value;
}


