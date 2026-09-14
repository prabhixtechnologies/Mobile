//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cancel_subscription_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CancelSubscriptionRequest {
  /// Returns a new [CancelSubscriptionRequest] instance.
  CancelSubscriptionRequest({

     this.atPeriodEnd,

     this.reason,
  });

  @JsonKey(
    
    name: r'atPeriodEnd',
    required: false,
    includeIfNull: false,
  )


  final bool? atPeriodEnd;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CancelSubscriptionRequest &&
      other.atPeriodEnd == atPeriodEnd &&
      other.reason == reason;

    @override
    int get hashCode =>
        atPeriodEnd.hashCode +
        reason.hashCode;

  factory CancelSubscriptionRequest.fromJson(Map<String, dynamic> json) => _$CancelSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

