//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/business_hours_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_mailbox_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateMailboxRequest {
  /// Returns a new [UpdateMailboxRequest] instance.
  UpdateMailboxRequest({

     this.name,

     this.description,

     this.signature,

     this.businessHours,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'signature',
    required: false,
    includeIfNull: false,
  )


  final String? signature;



  @JsonKey(
    
    name: r'businessHours',
    required: false,
    includeIfNull: false,
  )


  final BusinessHoursResponse? businessHours;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UpdateMailboxRequest &&
      other.name == name &&
      other.description == description &&
      other.signature == signature &&
      other.businessHours == businessHours;

    @override
    int get hashCode =>
        name.hashCode +
        description.hashCode +
        signature.hashCode +
        businessHours.hashCode;

  factory UpdateMailboxRequest.fromJson(Map<String, dynamic> json) => _$UpdateMailboxRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMailboxRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

