//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cart_item_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CartItemView {
  /// Returns a new [CartItemView] instance.
  CartItemView({

     this.id,

     this.variantId,

     this.productName,

     this.variantName,

     this.sku,

     this.quantity,

     this.unitPriceMinor,

     this.lineTotalMinor,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'variantId',
    required: false,
    includeIfNull: false,
  )


  final String? variantId;



  @JsonKey(
    
    name: r'productName',
    required: false,
    includeIfNull: false,
  )


  final String? productName;



  @JsonKey(
    
    name: r'variantName',
    required: false,
    includeIfNull: false,
  )


  final String? variantName;



  @JsonKey(
    
    name: r'sku',
    required: false,
    includeIfNull: false,
  )


  final String? sku;



  @JsonKey(
    
    name: r'quantity',
    required: false,
    includeIfNull: false,
  )


  final int? quantity;



  @JsonKey(
    
    name: r'unitPriceMinor',
    required: false,
    includeIfNull: false,
  )


  final int? unitPriceMinor;



  @JsonKey(
    
    name: r'lineTotalMinor',
    required: false,
    includeIfNull: false,
  )


  final int? lineTotalMinor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CartItemView &&
      other.id == id &&
      other.variantId == variantId &&
      other.productName == productName &&
      other.variantName == variantName &&
      other.sku == sku &&
      other.quantity == quantity &&
      other.unitPriceMinor == unitPriceMinor &&
      other.lineTotalMinor == lineTotalMinor;

    @override
    int get hashCode =>
        id.hashCode +
        variantId.hashCode +
        productName.hashCode +
        variantName.hashCode +
        sku.hashCode +
        quantity.hashCode +
        unitPriceMinor.hashCode +
        lineTotalMinor.hashCode;

  factory CartItemView.fromJson(Map<String, dynamic> json) => _$CartItemViewFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

