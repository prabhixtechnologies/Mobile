//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accept_invitation_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AcceptInvitationRequest {
  /// Returns a new [AcceptInvitationRequest] instance.
  AcceptInvitationRequest({

    required  this.token,

     this.fullName,

     this.password,
  });

  @JsonKey(
    
    name: r'token',
    required: true,
    includeIfNull: false,
  )


  final String token;



  @JsonKey(
    
    name: r'fullName',
    required: false,
    includeIfNull: false,
  )


  final String? fullName;



  @JsonKey(
    
    name: r'password',
    required: false,
    includeIfNull: false,
  )


  final String? password;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AcceptInvitationRequest &&
      other.token == token &&
      other.fullName == fullName &&
      other.password == password;

    @override
    int get hashCode =>
        token.hashCode +
        fullName.hashCode +
        password.hashCode;

  factory AcceptInvitationRequest.fromJson(Map<String, dynamic> json) => _$AcceptInvitationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptInvitationRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

