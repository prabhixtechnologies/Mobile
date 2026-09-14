//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audit_log_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuditLogView {
  /// Returns a new [AuditLogView] instance.
  AuditLogView({

     this.id,

     this.createdAt,

     this.organizationId,

     this.actorUserId,

     this.actorEmail,

     this.actorType,

     this.action,

     this.resourceType,

     this.resourceId,

     this.resourceLabel,

     this.changes,

     this.metadata,

     this.outcome,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'createdAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? createdAt;



  @JsonKey(
    
    name: r'organizationId',
    required: false,
    includeIfNull: false,
  )


  final String? organizationId;



  @JsonKey(
    
    name: r'actorUserId',
    required: false,
    includeIfNull: false,
  )


  final String? actorUserId;



  @JsonKey(
    
    name: r'actorEmail',
    required: false,
    includeIfNull: false,
  )


  final String? actorEmail;



  @JsonKey(
    
    name: r'actorType',
    required: false,
    includeIfNull: false,
  )


  final String? actorType;



  @JsonKey(
    
    name: r'action',
    required: false,
    includeIfNull: false,
  )


  final String? action;



  @JsonKey(
    
    name: r'resourceType',
    required: false,
    includeIfNull: false,
  )


  final String? resourceType;



  @JsonKey(
    
    name: r'resourceId',
    required: false,
    includeIfNull: false,
  )


  final String? resourceId;



  @JsonKey(
    
    name: r'resourceLabel',
    required: false,
    includeIfNull: false,
  )


  final String? resourceLabel;



  @JsonKey(
    
    name: r'changes',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? changes;



  @JsonKey(
    
    name: r'metadata',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? metadata;



  @JsonKey(
    
    name: r'outcome',
    required: false,
    includeIfNull: false,
  )


  final String? outcome;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AuditLogView &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.organizationId == organizationId &&
      other.actorUserId == actorUserId &&
      other.actorEmail == actorEmail &&
      other.actorType == actorType &&
      other.action == action &&
      other.resourceType == resourceType &&
      other.resourceId == resourceId &&
      other.resourceLabel == resourceLabel &&
      other.changes == changes &&
      other.metadata == metadata &&
      other.outcome == outcome;

    @override
    int get hashCode =>
        id.hashCode +
        createdAt.hashCode +
        organizationId.hashCode +
        actorUserId.hashCode +
        actorEmail.hashCode +
        actorType.hashCode +
        action.hashCode +
        resourceType.hashCode +
        resourceId.hashCode +
        resourceLabel.hashCode +
        changes.hashCode +
        metadata.hashCode +
        outcome.hashCode;

  factory AuditLogView.fromJson(Map<String, dynamic> json) => _$AuditLogViewFromJson(json);

  Map<String, dynamic> toJson() => _$AuditLogViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

