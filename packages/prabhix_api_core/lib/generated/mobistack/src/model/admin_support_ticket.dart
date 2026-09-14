//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_mobistack_api/src/model/admin_support_message.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_support_ticket.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminSupportTicket {
  /// Returns a new [AdminSupportTicket] instance.
  AdminSupportTicket({

     this.id,

     this.subject,

     this.status,

     this.userName,

     this.lastMessageAt,

     this.messages,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'subject',
    required: false,
    includeIfNull: false,
  )


  final String? subject;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'userName',
    required: false,
    includeIfNull: false,
  )


  final String? userName;



  @JsonKey(
    
    name: r'lastMessageAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? lastMessageAt;



  @JsonKey(
    
    name: r'messages',
    required: false,
    includeIfNull: false,
  )


  final List<AdminSupportMessage>? messages;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdminSupportTicket &&
      other.id == id &&
      other.subject == subject &&
      other.status == status &&
      other.userName == userName &&
      other.lastMessageAt == lastMessageAt &&
      other.messages == messages;

    @override
    int get hashCode =>
        id.hashCode +
        subject.hashCode +
        status.hashCode +
        userName.hashCode +
        lastMessageAt.hashCode +
        messages.hashCode;

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) => _$AdminSupportTicketFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSupportTicketToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

