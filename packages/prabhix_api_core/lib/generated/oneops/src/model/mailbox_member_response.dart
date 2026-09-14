//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mailbox_member_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MailboxMemberResponse {
  /// Returns a new [MailboxMemberResponse] instance.
  MailboxMemberResponse({

     this.userId,

     this.name,

     this.email,
  });

  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MailboxMemberResponse &&
      other.userId == userId &&
      other.name == name &&
      other.email == email;

    @override
    int get hashCode =>
        userId.hashCode +
        name.hashCode +
        email.hashCode;

  factory MailboxMemberResponse.fromJson(Map<String, dynamic> json) => _$MailboxMemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MailboxMemberResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

