//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_mailbox_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMailboxRequest {
  /// Returns a new [CreateMailboxRequest] instance.
  CreateMailboxRequest({

    required  this.address,

    required  this.name,

     this.kind,

     this.description,
  });

  @JsonKey(
    
    name: r'address',
    required: true,
    includeIfNull: false,
  )


  final String address;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final CreateMailboxRequestKindEnum? kind;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateMailboxRequest &&
      other.address == address &&
      other.name == name &&
      other.kind == kind &&
      other.description == description;

    @override
    int get hashCode =>
        address.hashCode +
        name.hashCode +
        kind.hashCode +
        description.hashCode;

  factory CreateMailboxRequest.fromJson(Map<String, dynamic> json) => _$CreateMailboxRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMailboxRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum CreateMailboxRequestKindEnum {
@JsonValue(r'SHARED')
SHARED(r'SHARED'),
@JsonValue(r'PERSONAL')
PERSONAL(r'PERSONAL'),
@JsonValue(r'SYSTEM')
SYSTEM(r'SYSTEM');

const CreateMailboxRequestKindEnum(this.value);

final String value;

@override
String toString() => value;
}


