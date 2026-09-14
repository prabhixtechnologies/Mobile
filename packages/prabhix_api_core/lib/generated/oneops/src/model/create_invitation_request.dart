//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_invitation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateInvitationRequest {
  /// Returns a new [CreateInvitationRequest] instance.
  CreateInvitationRequest({

    required  this.email,

    required  this.roleId,

     this.teamId,

     this.message,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'roleId',
    required: true,
    includeIfNull: false,
  )


  final String roleId;



  @JsonKey(
    
    name: r'teamId',
    required: false,
    includeIfNull: false,
  )


  final String? teamId;



  @JsonKey(
    
    name: r'message',
    required: false,
    includeIfNull: false,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateInvitationRequest &&
      other.email == email &&
      other.roleId == roleId &&
      other.teamId == teamId &&
      other.message == message;

    @override
    int get hashCode =>
        email.hashCode +
        roleId.hashCode +
        teamId.hashCode +
        message.hashCode;

  factory CreateInvitationRequest.fromJson(Map<String, dynamic> json) => _$CreateInvitationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateInvitationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

