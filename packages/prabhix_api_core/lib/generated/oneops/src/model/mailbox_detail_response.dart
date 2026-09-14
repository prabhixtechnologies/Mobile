//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/routing_rule_response.dart';
import 'package:prabhix_oneops_api/src/model/business_hours_response.dart';
import 'package:prabhix_oneops_api/src/model/mailbox_member_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mailbox_detail_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MailboxDetailResponse {
  /// Returns a new [MailboxDetailResponse] instance.
  MailboxDetailResponse({

     this.id,

     this.name,

     this.email,

     this.description,

     this.memberCount,

     this.openThreadCount,

     this.slaPolicyId,

     this.signature,

     this.createdAt,

     this.members,

     this.routingRules,

     this.businessHours,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



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



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'memberCount',
    required: false,
    includeIfNull: false,
  )


  final int? memberCount;



  @JsonKey(
    
    name: r'openThreadCount',
    required: false,
    includeIfNull: false,
  )


  final int? openThreadCount;



  @JsonKey(
    
    name: r'slaPolicyId',
    required: false,
    includeIfNull: false,
  )


  final String? slaPolicyId;



  @JsonKey(
    
    name: r'signature',
    required: false,
    includeIfNull: false,
  )


  final String? signature;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'members',
    required: false,
    includeIfNull: false,
  )


  final List<MailboxMemberResponse>? members;



  @JsonKey(
    
    name: r'routingRules',
    required: false,
    includeIfNull: false,
  )


  final List<RoutingRuleResponse>? routingRules;



  @JsonKey(
    
    name: r'businessHours',
    required: false,
    includeIfNull: false,
  )


  final BusinessHoursResponse? businessHours;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MailboxDetailResponse &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.description == description &&
      other.memberCount == memberCount &&
      other.openThreadCount == openThreadCount &&
      other.slaPolicyId == slaPolicyId &&
      other.signature == signature &&
      other.createdAt == createdAt &&
      other.members == members &&
      other.routingRules == routingRules &&
      other.businessHours == businessHours;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        email.hashCode +
        description.hashCode +
        memberCount.hashCode +
        openThreadCount.hashCode +
        slaPolicyId.hashCode +
        signature.hashCode +
        createdAt.hashCode +
        members.hashCode +
        routingRules.hashCode +
        businessHours.hashCode;

  factory MailboxDetailResponse.fromJson(Map<String, dynamic> json) => _$MailboxDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MailboxDetailResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

