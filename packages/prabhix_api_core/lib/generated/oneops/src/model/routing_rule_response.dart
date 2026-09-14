//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'routing_rule_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RoutingRuleResponse {
  /// Returns a new [RoutingRuleResponse] instance.
  RoutingRuleResponse({

     this.id,

     this.name,

     this.priority,

     this.conditions,

     this.match,

     this.actions,

     this.continueAfterMatch,

     this.enabled,
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
    
    name: r'priority',
    required: false,
    includeIfNull: false,
  )


  final int? priority;



  @JsonKey(
    
    name: r'conditions',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object?>>? conditions;



  @JsonKey(
    
    name: r'match',
    required: false,
    includeIfNull: false,
  )


  final String? match;



  @JsonKey(
    
    name: r'actions',
    required: false,
    includeIfNull: false,
  )


  final List<Map<String, Object?>>? actions;



  @JsonKey(
    
    name: r'continueAfterMatch',
    required: false,
    includeIfNull: false,
  )


  final bool? continueAfterMatch;



  @JsonKey(
    
    name: r'enabled',
    required: false,
    includeIfNull: false,
  )


  final bool? enabled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RoutingRuleResponse &&
      other.id == id &&
      other.name == name &&
      other.priority == priority &&
      other.conditions == conditions &&
      other.match == match &&
      other.actions == actions &&
      other.continueAfterMatch == continueAfterMatch &&
      other.enabled == enabled;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        priority.hashCode +
        conditions.hashCode +
        match.hashCode +
        actions.hashCode +
        continueAfterMatch.hashCode +
        enabled.hashCode;

  factory RoutingRuleResponse.fromJson(Map<String, dynamic> json) => _$RoutingRuleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoutingRuleResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

