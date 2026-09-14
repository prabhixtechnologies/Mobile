//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plan_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlanCard {
  /// Returns a new [PlanCard] instance.
  PlanCard({

     this.id,

     this.code,

     this.name,

     this.description,

     this.amount,

     this.currency,

     this.interval,

     this.sortOrder,

     this.active,

     this.features,

     this.priceCode,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



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
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final num? amount;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'interval',
    required: false,
    includeIfNull: false,
  )


  final String? interval;



  @JsonKey(
    
    name: r'sortOrder',
    required: false,
    includeIfNull: false,
  )


  final int? sortOrder;



  @JsonKey(
    
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;



  @JsonKey(
    
    name: r'features',
    required: false,
    includeIfNull: false,
  )


  final List<String>? features;



  @JsonKey(
    
    name: r'priceCode',
    required: false,
    includeIfNull: false,
  )


  final String? priceCode;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlanCard &&
      other.id == id &&
      other.code == code &&
      other.name == name &&
      other.description == description &&
      other.amount == amount &&
      other.currency == currency &&
      other.interval == interval &&
      other.sortOrder == sortOrder &&
      other.active == active &&
      other.features == features &&
      other.priceCode == priceCode;

    @override
    int get hashCode =>
        id.hashCode +
        code.hashCode +
        name.hashCode +
        description.hashCode +
        amount.hashCode +
        currency.hashCode +
        interval.hashCode +
        sortOrder.hashCode +
        active.hashCode +
        features.hashCode +
        priceCode.hashCode;

  factory PlanCard.fromJson(Map<String, dynamic> json) => _$PlanCardFromJson(json);

  Map<String, dynamic> toJson() => _$PlanCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

