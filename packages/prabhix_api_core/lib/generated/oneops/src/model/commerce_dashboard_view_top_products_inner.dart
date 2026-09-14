//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commerce_dashboard_view_top_products_inner.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommerceDashboardViewTopProductsInner {
  /// Returns a new [CommerceDashboardViewTopProductsInner] instance.
  CommerceDashboardViewTopProductsInner({

     this.productId,

     this.productName,

     this.quantitySold,
  });

  @JsonKey(
    
    name: r'productId',
    required: false,
    includeIfNull: false,
  )


  final String? productId;



  @JsonKey(
    
    name: r'productName',
    required: false,
    includeIfNull: false,
  )


  final String? productName;



  @JsonKey(
    
    name: r'quantitySold',
    required: false,
    includeIfNull: false,
  )


  final int? quantitySold;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommerceDashboardViewTopProductsInner &&
      other.productId == productId &&
      other.productName == productName &&
      other.quantitySold == quantitySold;

    @override
    int get hashCode =>
        productId.hashCode +
        productName.hashCode +
        quantitySold.hashCode;

  factory CommerceDashboardViewTopProductsInner.fromJson(Map<String, dynamic> json) => _$CommerceDashboardViewTopProductsInnerFromJson(json);

  Map<String, dynamic> toJson() => _$CommerceDashboardViewTopProductsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

