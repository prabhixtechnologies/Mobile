//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/cart_item_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CartView {
  /// Returns a new [CartView] instance.
  CartView({

     this.cartToken,

     this.currency,

     this.items,

     this.subtotalPaise,

     this.discountPaise,

     this.taxPaise,

     this.shippingPaise,

     this.totalPaise,

     this.discountCode,

     this.expiresAt,
  });

  @JsonKey(
    
    name: r'cartToken',
    required: false,
    includeIfNull: false,
  )


  final String? cartToken;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<CartItemView>? items;



  @JsonKey(
    
    name: r'subtotalPaise',
    required: false,
    includeIfNull: false,
  )


  final int? subtotalPaise;



  @JsonKey(
    
    name: r'discountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? discountPaise;



  @JsonKey(
    
    name: r'taxPaise',
    required: false,
    includeIfNull: false,
  )


  final int? taxPaise;



  @JsonKey(
    
    name: r'shippingPaise',
    required: false,
    includeIfNull: false,
  )


  final int? shippingPaise;



  @JsonKey(
    
    name: r'totalPaise',
    required: false,
    includeIfNull: false,
  )


  final int? totalPaise;



  @JsonKey(
    
    name: r'discountCode',
    required: false,
    includeIfNull: false,
  )


  final String? discountCode;



  @JsonKey(
    
    name: r'expiresAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? expiresAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CartView &&
      other.cartToken == cartToken &&
      other.currency == currency &&
      other.items == items &&
      other.subtotalPaise == subtotalPaise &&
      other.discountPaise == discountPaise &&
      other.taxPaise == taxPaise &&
      other.shippingPaise == shippingPaise &&
      other.totalPaise == totalPaise &&
      other.discountCode == discountCode &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        cartToken.hashCode +
        currency.hashCode +
        items.hashCode +
        subtotalPaise.hashCode +
        discountPaise.hashCode +
        taxPaise.hashCode +
        shippingPaise.hashCode +
        totalPaise.hashCode +
        discountCode.hashCode +
        expiresAt.hashCode;

  factory CartView.fromJson(Map<String, dynamic> json) => _$CartViewFromJson(json);

  Map<String, dynamic> toJson() => _$CartViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

