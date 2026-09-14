//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'screen_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ScreenCard {
  /// Returns a new [ScreenCard] instance.
  ScreenCard({

     this.included,

     this.extra,

     this.subscribed,

     this.seats,

     this.inUse,

     this.live,

     this.periodEnd,

     this.amount,

     this.renewAmount,

     this.currency,

     this.priceCode,

     this.interval,
  });

  @JsonKey(
    
    name: r'included',
    required: false,
    includeIfNull: false,
  )


  final int? included;



  @JsonKey(
    
    name: r'extra',
    required: false,
    includeIfNull: false,
  )


  final int? extra;



  @JsonKey(
    
    name: r'subscribed',
    required: false,
    includeIfNull: false,
  )


  final int? subscribed;



  @JsonKey(
    
    name: r'seats',
    required: false,
    includeIfNull: false,
  )


  final int? seats;



  @JsonKey(
    
    name: r'inUse',
    required: false,
    includeIfNull: false,
  )


  final int? inUse;



  @JsonKey(
    
    name: r'live',
    required: false,
    includeIfNull: false,
  )


  final bool? live;



  @JsonKey(
    
    name: r'periodEnd',
    required: false,
    includeIfNull: false,
  )


  final DateTime? periodEnd;



  @JsonKey(
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final num? amount;



  @JsonKey(
    
    name: r'renewAmount',
    required: false,
    includeIfNull: false,
  )


  final num? renewAmount;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'priceCode',
    required: false,
    includeIfNull: false,
  )


  final String? priceCode;



  @JsonKey(
    
    name: r'interval',
    required: false,
    includeIfNull: false,
  )


  final String? interval;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ScreenCard &&
      other.included == included &&
      other.extra == extra &&
      other.subscribed == subscribed &&
      other.seats == seats &&
      other.inUse == inUse &&
      other.live == live &&
      other.periodEnd == periodEnd &&
      other.amount == amount &&
      other.renewAmount == renewAmount &&
      other.currency == currency &&
      other.priceCode == priceCode &&
      other.interval == interval;

    @override
    int get hashCode =>
        included.hashCode +
        extra.hashCode +
        subscribed.hashCode +
        seats.hashCode +
        inUse.hashCode +
        live.hashCode +
        periodEnd.hashCode +
        amount.hashCode +
        renewAmount.hashCode +
        currency.hashCode +
        priceCode.hashCode +
        interval.hashCode;

  factory ScreenCard.fromJson(Map<String, dynamic> json) => _$ScreenCardFromJson(json);

  Map<String, dynamic> toJson() => _$ScreenCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

