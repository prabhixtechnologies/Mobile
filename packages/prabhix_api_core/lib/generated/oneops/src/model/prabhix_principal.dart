//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prabhix_principal.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PrabhixPrincipal {
  /// Returns a new [PrabhixPrincipal] instance.
  PrabhixPrincipal({

     this.userId,

     this.email,

     this.displayName,

     this.organizationId,

     this.permissions,

     this.sessionId,

     this.platformAdmin,
  });

  @JsonKey(
    
    name: r'userId',
    required: false,
    includeIfNull: false,
  )


  final String? userId;



  @JsonKey(
    
    name: r'email',
    required: false,
    includeIfNull: false,
  )


  final String? email;



  @JsonKey(
    
    name: r'displayName',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'organizationId',
    required: false,
    includeIfNull: false,
  )


  final String? organizationId;



  @JsonKey(
    
    name: r'permissions',
    required: false,
    includeIfNull: false,
  )


  final Set<PrabhixPrincipalPermissionsEnum>? permissions;



  @JsonKey(
    
    name: r'sessionId',
    required: false,
    includeIfNull: false,
  )


  final String? sessionId;



  @JsonKey(
    
    name: r'platformAdmin',
    required: false,
    includeIfNull: false,
  )


  final bool? platformAdmin;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PrabhixPrincipal &&
      other.userId == userId &&
      other.email == email &&
      other.displayName == displayName &&
      other.organizationId == organizationId &&
      other.permissions == permissions &&
      other.sessionId == sessionId &&
      other.platformAdmin == platformAdmin;

    @override
    int get hashCode =>
        userId.hashCode +
        email.hashCode +
        displayName.hashCode +
        organizationId.hashCode +
        permissions.hashCode +
        sessionId.hashCode +
        platformAdmin.hashCode;

  factory PrabhixPrincipal.fromJson(Map<String, dynamic> json) => _$PrabhixPrincipalFromJson(json);

  Map<String, dynamic> toJson() => _$PrabhixPrincipalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PrabhixPrincipalPermissionsEnum {
@JsonValue(r'ORG_READ')
ORG_READ(r'ORG_READ'),
@JsonValue(r'ORG_UPDATE')
ORG_UPDATE(r'ORG_UPDATE'),
@JsonValue(r'ORG_DELETE')
ORG_DELETE(r'ORG_DELETE'),
@JsonValue(r'ORG_MEMBER_READ')
ORG_MEMBER_READ(r'ORG_MEMBER_READ'),
@JsonValue(r'ORG_MEMBER_INVITE')
ORG_MEMBER_INVITE(r'ORG_MEMBER_INVITE'),
@JsonValue(r'ORG_MEMBER_UPDATE')
ORG_MEMBER_UPDATE(r'ORG_MEMBER_UPDATE'),
@JsonValue(r'ORG_MEMBER_REMOVE')
ORG_MEMBER_REMOVE(r'ORG_MEMBER_REMOVE'),
@JsonValue(r'ORG_ROLE_READ')
ORG_ROLE_READ(r'ORG_ROLE_READ'),
@JsonValue(r'ORG_ROLE_MANAGE')
ORG_ROLE_MANAGE(r'ORG_ROLE_MANAGE'),
@JsonValue(r'ORG_TEAM_READ')
ORG_TEAM_READ(r'ORG_TEAM_READ'),
@JsonValue(r'ORG_TEAM_MANAGE')
ORG_TEAM_MANAGE(r'ORG_TEAM_MANAGE'),
@JsonValue(r'ORG_API_KEY_MANAGE')
ORG_API_KEY_MANAGE(r'ORG_API_KEY_MANAGE'),
@JsonValue(r'MAIL_READ')
MAIL_READ(r'MAIL_READ'),
@JsonValue(r'MAIL_READ_ALL')
MAIL_READ_ALL(r'MAIL_READ_ALL'),
@JsonValue(r'MAIL_SEND')
MAIL_SEND(r'MAIL_SEND'),
@JsonValue(r'MAIL_ASSIGN')
MAIL_ASSIGN(r'MAIL_ASSIGN'),
@JsonValue(r'MAIL_THREAD_UPDATE')
MAIL_THREAD_UPDATE(r'MAIL_THREAD_UPDATE'),
@JsonValue(r'MAIL_THREAD_DELETE')
MAIL_THREAD_DELETE(r'MAIL_THREAD_DELETE'),
@JsonValue(r'MAIL_NOTE_WRITE')
MAIL_NOTE_WRITE(r'MAIL_NOTE_WRITE'),
@JsonValue(r'MAIL_MAILBOX_READ')
MAIL_MAILBOX_READ(r'MAIL_MAILBOX_READ'),
@JsonValue(r'MAIL_MAILBOX_MANAGE')
MAIL_MAILBOX_MANAGE(r'MAIL_MAILBOX_MANAGE'),
@JsonValue(r'MAIL_DOMAIN_READ')
MAIL_DOMAIN_READ(r'MAIL_DOMAIN_READ'),
@JsonValue(r'MAIL_DOMAIN_MANAGE')
MAIL_DOMAIN_MANAGE(r'MAIL_DOMAIN_MANAGE'),
@JsonValue(r'MAIL_TEMPLATE_READ')
MAIL_TEMPLATE_READ(r'MAIL_TEMPLATE_READ'),
@JsonValue(r'MAIL_TEMPLATE_MANAGE')
MAIL_TEMPLATE_MANAGE(r'MAIL_TEMPLATE_MANAGE'),
@JsonValue(r'MAIL_SUPPRESSION_MANAGE')
MAIL_SUPPRESSION_MANAGE(r'MAIL_SUPPRESSION_MANAGE'),
@JsonValue(r'BILLING_READ')
BILLING_READ(r'BILLING_READ'),
@JsonValue(r'BILLING_MANAGE')
BILLING_MANAGE(r'BILLING_MANAGE'),
@JsonValue(r'BILLING_INVOICE_DOWNLOAD')
BILLING_INVOICE_DOWNLOAD(r'BILLING_INVOICE_DOWNLOAD'),
@JsonValue(r'FILE_READ')
FILE_READ(r'FILE_READ'),
@JsonValue(r'FILE_UPLOAD')
FILE_UPLOAD(r'FILE_UPLOAD'),
@JsonValue(r'FILE_DELETE')
FILE_DELETE(r'FILE_DELETE'),
@JsonValue(r'AUDIT_READ')
AUDIT_READ(r'AUDIT_READ'),
@JsonValue(r'VISITOR_READ')
VISITOR_READ(r'VISITOR_READ'),
@JsonValue(r'VISITOR_ANALYTICS')
VISITOR_ANALYTICS(r'VISITOR_ANALYTICS'),
@JsonValue(r'VISITOR_MANAGE')
VISITOR_MANAGE(r'VISITOR_MANAGE'),
@JsonValue(r'CHAT_READ')
CHAT_READ(r'CHAT_READ'),
@JsonValue(r'CHAT_READ_ALL')
CHAT_READ_ALL(r'CHAT_READ_ALL'),
@JsonValue(r'CHAT_REPLY')
CHAT_REPLY(r'CHAT_REPLY'),
@JsonValue(r'CHAT_ASSIGN')
CHAT_ASSIGN(r'CHAT_ASSIGN'),
@JsonValue(r'CHAT_MANAGE')
CHAT_MANAGE(r'CHAT_MANAGE'),
@JsonValue(r'PLATFORM_ADMIN')
PLATFORM_ADMIN(r'PLATFORM_ADMIN');

const PrabhixPrincipalPermissionsEnum(this.value);

final String value;

@override
String toString() => value;
}


