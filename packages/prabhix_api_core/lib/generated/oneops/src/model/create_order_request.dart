//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_order_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateOrderRequest {
  /// Returns a new [CreateOrderRequest] instance.
  CreateOrderRequest({

    required  this.planKey,

    required  this.seats,
  });

  @JsonKey(
    
    name: r'planKey',
    required: true,
    includeIfNull: false,
  )


  final String planKey;



          // minimum: 1
          // maximum: 10000
  @JsonKey(
    
    name: r'seats',
    required: true,
    includeIfNull: false,
  )


  final int seats;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateOrderRequest &&
      other.planKey == planKey &&
      other.seats == seats;

    @override
    int get hashCode =>
        planKey.hashCode +
        seats.hashCode;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

