//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_mailbox_member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddMailboxMemberRequest {
  /// Returns a new [AddMailboxMemberRequest] instance.
  AddMailboxMemberRequest({

    required  this.userId,

     this.accessLevel,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final String userId;



  @JsonKey(
    
    name: r'accessLevel',
    required: false,
    includeIfNull: false,
  )


  final AddMailboxMemberRequestAccessLevelEnum? accessLevel;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddMailboxMemberRequest &&
      other.userId == userId &&
      other.accessLevel == accessLevel;

    @override
    int get hashCode =>
        userId.hashCode +
        accessLevel.hashCode;

  factory AddMailboxMemberRequest.fromJson(Map<String, dynamic> json) => _$AddMailboxMemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddMailboxMemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum AddMailboxMemberRequestAccessLevelEnum {
@JsonValue(r'MEMBER')
MEMBER(r'MEMBER'),
@JsonValue(r'LEAD')
LEAD(r'LEAD');

const AddMailboxMemberRequestAccessLevelEnum(this.value);

final String value;

@override
String toString() => value;
}


