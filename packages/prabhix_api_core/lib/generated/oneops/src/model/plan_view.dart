//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plan_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanView {
  /// Returns a new [PlanView] instance.
  PlanView({

     this.id,

     this.planKey,

     this.name,

     this.description,

     this.intervalType,

     this.amountPaise,

     this.perSeatPaise,

     this.includedSeats,

     this.maxSeats,

     this.trialDays,

     this.entitlements,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'planKey',
    required: false,
    includeIfNull: false,
  )


  final String? planKey;



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
    
    name: r'intervalType',
    required: false,
    includeIfNull: false,
  )


  final PlanViewIntervalTypeEnum? intervalType;



  @JsonKey(
    
    name: r'amountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? amountPaise;



  @JsonKey(
    
    name: r'perSeatPaise',
    required: false,
    includeIfNull: false,
  )


  final int? perSeatPaise;



  @JsonKey(
    
    name: r'includedSeats',
    required: false,
    includeIfNull: false,
  )


  final int? includedSeats;



  @JsonKey(
    
    name: r'maxSeats',
    required: false,
    includeIfNull: false,
  )


  final int? maxSeats;



  @JsonKey(
    
    name: r'trialDays',
    required: false,
    includeIfNull: false,
  )


  final int? trialDays;



  @JsonKey(
    
    name: r'entitlements',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object?>? entitlements;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlanView &&
      other.id == id &&
      other.planKey == planKey &&
      other.name == name &&
      other.description == description &&
      other.intervalType == intervalType &&
      other.amountPaise == amountPaise &&
      other.perSeatPaise == perSeatPaise &&
      other.includedSeats == includedSeats &&
      other.maxSeats == maxSeats &&
      other.trialDays == trialDays &&
      other.entitlements == entitlements;

    @override
    int get hashCode =>
        id.hashCode +
        planKey.hashCode +
        name.hashCode +
        description.hashCode +
        intervalType.hashCode +
        amountPaise.hashCode +
        perSeatPaise.hashCode +
        includedSeats.hashCode +
        maxSeats.hashCode +
        trialDays.hashCode +
        entitlements.hashCode;

  factory PlanView.fromJson(Map<String, dynamic> json) => _$PlanViewFromJson(json);

  Map<String, dynamic> toJson() => _$PlanViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum PlanViewIntervalTypeEnum {
@JsonValue(r'MONTHLY')
MONTHLY(r'MONTHLY'),
@JsonValue(r'ANNUAL')
ANNUAL(r'ANNUAL'),
@JsonValue(r'ONE_TIME')
ONE_TIME(r'ONE_TIME'),
@JsonValue(r'CUSTOM')
CUSTOM(r'CUSTOM');

const PlanViewIntervalTypeEnum(this.value);

final String value;

@override
String toString() => value;
}


