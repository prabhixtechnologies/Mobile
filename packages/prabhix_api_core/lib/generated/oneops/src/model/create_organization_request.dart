//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_organization_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateOrganizationRequest {
  /// Returns a new [CreateOrganizationRequest] instance.
  CreateOrganizationRequest({

    required  this.name,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateOrganizationRequest &&
      other.name == name;

    @override
    int get hashCode =>
        name.hashCode;

  factory CreateOrganizationRequest.fromJson(Map<String, dynamic> json) => _$CreateOrganizationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrganizationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

