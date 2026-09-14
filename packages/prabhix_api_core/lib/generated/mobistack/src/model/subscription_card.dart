//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_card.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscriptionCard {
  /// Returns a new [SubscriptionCard] instance.
  SubscriptionCard({

     this.planCode,

     this.planName,

     this.status,

     this.periodEnd,

     this.features,
  });

  @JsonKey(
    
    name: r'planCode',
    required: false,
    includeIfNull: false,
  )


  final String? planCode;



  @JsonKey(
    
    name: r'planName',
    required: false,
    includeIfNull: false,
  )


  final String? planName;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'periodEnd',
    required: false,
    includeIfNull: false,
  )


  final DateTime? periodEnd;



  @JsonKey(
    
    name: r'features',
    required: false,
    includeIfNull: false,
  )


  final List<String>? features;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SubscriptionCard &&
      other.planCode == planCode &&
      other.planName == planName &&
      other.status == status &&
      other.periodEnd == periodEnd &&
      other.features == features;

    @override
    int get hashCode =>
        planCode.hashCode +
        planName.hashCode +
        status.hashCode +
        periodEnd.hashCode +
        features.hashCode;

  factory SubscriptionCard.fromJson(Map<String, dynamic> json) => _$SubscriptionCardFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionCardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

