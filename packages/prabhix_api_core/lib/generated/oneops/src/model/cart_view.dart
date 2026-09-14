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

     this.subtotalMinor,

     this.discountMinor,

     this.taxMinor,

     this.shippingMinor,

     this.totalMinor,

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
    
    name: r'subtotalMinor',
    required: false,
    includeIfNull: false,
  )


  final int? subtotalMinor;



  @JsonKey(
    
    name: r'discountMinor',
    required: false,
    includeIfNull: false,
  )


  final int? discountMinor;



  @JsonKey(
    
    name: r'taxMinor',
    required: false,
    includeIfNull: false,
  )


  final int? taxMinor;



  @JsonKey(
    
    name: r'shippingMinor',
    required: false,
    includeIfNull: false,
  )


  final int? shippingMinor;



  @JsonKey(
    
    name: r'totalMinor',
    required: false,
    includeIfNull: false,
  )


  final int? totalMinor;



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
      other.subtotalMinor == subtotalMinor &&
      other.discountMinor == discountMinor &&
      other.taxMinor == taxMinor &&
      other.shippingMinor == shippingMinor &&
      other.totalMinor == totalMinor &&
      other.discountCode == discountCode &&
      other.expiresAt == expiresAt;

    @override
    int get hashCode =>
        cartToken.hashCode +
        currency.hashCode +
        items.hashCode +
        subtotalMinor.hashCode +
        discountMinor.hashCode +
        taxMinor.hashCode +
        shippingMinor.hashCode +
        totalMinor.hashCode +
        discountCode.hashCode +
        expiresAt.hashCode;

  factory CartView.fromJson(Map<String, dynamic> json) => _$CartViewFromJson(json);

  Map<String, dynamic> toJson() => _$CartViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

