//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'add_cart_item_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AddCartItemRequest {
  /// Returns a new [AddCartItemRequest] instance.
  AddCartItemRequest({

    required  this.variantId,

    required  this.quantity,
  });

  @JsonKey(
    
    name: r'variantId',
    required: true,
    includeIfNull: false,
  )


  final String variantId;



          // minimum: 1
  @JsonKey(
    
    name: r'quantity',
    required: true,
    includeIfNull: false,
  )


  final int quantity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AddCartItemRequest &&
      other.variantId == variantId &&
      other.quantity == quantity;

    @override
    int get hashCode =>
        variantId.hashCode +
        quantity.hashCode;

  factory AddCartItemRequest.fromJson(Map<String, dynamic> json) => _$AddCartItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddCartItemRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

