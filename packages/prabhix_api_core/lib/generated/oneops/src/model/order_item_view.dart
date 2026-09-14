//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/product_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderItemView {
  /// Returns a new [OrderItemView] instance.
  OrderItemView({

     this.id,

     this.productName,

     this.variantName,

     this.sku,

     this.productType,

     this.quantity,

     this.unitPriceMinor,

     this.lineSubtotalMinor,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



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
    
    name: r'productType',
    required: false,
    includeIfNull: false,
  )


  final ProductType? productType;



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
    
    name: r'lineSubtotalMinor',
    required: false,
    includeIfNull: false,
  )


  final int? lineSubtotalMinor;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderItemView &&
      other.id == id &&
      other.productName == productName &&
      other.variantName == variantName &&
      other.sku == sku &&
      other.productType == productType &&
      other.quantity == quantity &&
      other.unitPriceMinor == unitPriceMinor &&
      other.lineSubtotalMinor == lineSubtotalMinor;

    @override
    int get hashCode =>
        id.hashCode +
        productName.hashCode +
        variantName.hashCode +
        sku.hashCode +
        productType.hashCode +
        quantity.hashCode +
        unitPriceMinor.hashCode +
        lineSubtotalMinor.hashCode;

  factory OrderItemView.fromJson(Map<String, dynamic> json) => _$OrderItemViewFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

