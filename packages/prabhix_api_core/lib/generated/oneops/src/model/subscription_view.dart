//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SubscriptionView {
  /// Returns a new [SubscriptionView] instance.
  SubscriptionView({

     this.id,

     this.planId,

     this.planName,

     this.status,

     this.seats,

     this.currentPeriodStart,

     this.currentPeriodEnd,

     this.trialEndsAt,

     this.cancelAtPeriodEnd,

     this.nextBillingAt,

     this.lockedAmountPaise,

     this.lockedPerSeatPaise,

     this.pendingPlanId,

     this.pendingSeats,

     this.pendingChangeAt,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'planId',
    required: false,
    includeIfNull: false,
  )


  final String? planId;



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


  final SubscriptionViewStatusEnum? status;



  @JsonKey(
    
    name: r'seats',
    required: false,
    includeIfNull: false,
  )


  final int? seats;



  @JsonKey(
    
    name: r'currentPeriodStart',
    required: false,
    includeIfNull: false,
  )


  final DateTime? currentPeriodStart;



  @JsonKey(
    
    name: r'currentPeriodEnd',
    required: false,
    includeIfNull: false,
  )


  final DateTime? currentPeriodEnd;



  @JsonKey(
    
    name: r'trialEndsAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trialEndsAt;



  @JsonKey(
    
    name: r'cancelAtPeriodEnd',
    required: false,
    includeIfNull: false,
  )


  final bool? cancelAtPeriodEnd;



  @JsonKey(
    
    name: r'nextBillingAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? nextBillingAt;



  @JsonKey(
    
    name: r'lockedAmountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? lockedAmountPaise;



  @JsonKey(
    
    name: r'lockedPerSeatPaise',
    required: false,
    includeIfNull: false,
  )


  final int? lockedPerSeatPaise;



  @JsonKey(
    
    name: r'pendingPlanId',
    required: false,
    includeIfNull: false,
  )


  final String? pendingPlanId;



  @JsonKey(
    
    name: r'pendingSeats',
    required: false,
    includeIfNull: false,
  )


  final int? pendingSeats;



  @JsonKey(
    
    name: r'pendingChangeAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? pendingChangeAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SubscriptionView &&
      other.id == id &&
      other.planId == planId &&
      other.planName == planName &&
      other.status == status &&
      other.seats == seats &&
      other.currentPeriodStart == currentPeriodStart &&
      other.currentPeriodEnd == currentPeriodEnd &&
      other.trialEndsAt == trialEndsAt &&
      other.cancelAtPeriodEnd == cancelAtPeriodEnd &&
      other.nextBillingAt == nextBillingAt &&
      other.lockedAmountPaise == lockedAmountPaise &&
      other.lockedPerSeatPaise == lockedPerSeatPaise &&
      other.pendingPlanId == pendingPlanId &&
      other.pendingSeats == pendingSeats &&
      other.pendingChangeAt == pendingChangeAt;

    @override
    int get hashCode =>
        id.hashCode +
        planId.hashCode +
        planName.hashCode +
        status.hashCode +
        seats.hashCode +
        currentPeriodStart.hashCode +
        currentPeriodEnd.hashCode +
        trialEndsAt.hashCode +
        cancelAtPeriodEnd.hashCode +
        nextBillingAt.hashCode +
        lockedAmountPaise.hashCode +
        lockedPerSeatPaise.hashCode +
        pendingPlanId.hashCode +
        pendingSeats.hashCode +
        pendingChangeAt.hashCode;

  factory SubscriptionView.fromJson(Map<String, dynamic> json) => _$SubscriptionViewFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

enum SubscriptionViewStatusEnum {
@JsonValue(r'TRIALING')
TRIALING(r'TRIALING'),
@JsonValue(r'ACTIVE')
ACTIVE(r'ACTIVE'),
@JsonValue(r'PAST_DUE')
PAST_DUE(r'PAST_DUE'),
@JsonValue(r'PAUSED')
PAUSED(r'PAUSED'),
@JsonValue(r'CANCELLED')
CANCELLED(r'CANCELLED'),
@JsonValue(r'EXPIRED')
EXPIRED(r'EXPIRED');

const SubscriptionViewStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


