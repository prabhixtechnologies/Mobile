//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/cart_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_cart_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateCartResponse {
  /// Returns a new [CreateCartResponse] instance.
  CreateCartResponse({

     this.cartToken,

     this.cart,
  });

  @JsonKey(
    
    name: r'cartToken',
    required: false,
    includeIfNull: false,
  )


  final String? cartToken;



  @JsonKey(
    
    name: r'cart',
    required: false,
    includeIfNull: false,
  )


  final CartView? cart;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CreateCartResponse &&
      other.cartToken == cartToken &&
      other.cart == cart;

    @override
    int get hashCode =>
        cartToken.hashCode +
        cart.hashCode;

  factory CreateCartResponse.fromJson(Map<String, dynamic> json) => _$CreateCartResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreateCartResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

