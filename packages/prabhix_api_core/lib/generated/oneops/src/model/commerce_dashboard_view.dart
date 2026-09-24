//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/commerce_dashboard_view_top_products_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commerce_dashboard_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommerceDashboardView {
  /// Returns a new [CommerceDashboardView] instance.
  CommerceDashboardView({

     this.revenuePaise30d,

     this.orderCount30d,

     this.topProducts,

     this.conversionRate,
  });

  @JsonKey(
    
    name: r'revenuePaise30d',
    required: false,
    includeIfNull: false,
  )


  final int? revenuePaise30d;



  @JsonKey(
    
    name: r'orderCount30d',
    required: false,
    includeIfNull: false,
  )


  final int? orderCount30d;



  @JsonKey(
    
    name: r'topProducts',
    required: false,
    includeIfNull: false,
  )


  final List<CommerceDashboardViewTopProductsInner>? topProducts;



  @JsonKey(
    
    name: r'conversionRate',
    required: false,
    includeIfNull: false,
  )


  final double? conversionRate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommerceDashboardView &&
      other.revenuePaise30d == revenuePaise30d &&
      other.orderCount30d == orderCount30d &&
      other.topProducts == topProducts &&
      other.conversionRate == conversionRate;

    @override
    int get hashCode =>
        revenuePaise30d.hashCode +
        orderCount30d.hashCode +
        topProducts.hashCode +
        conversionRate.hashCode;

  factory CommerceDashboardView.fromJson(Map<String, dynamic> json) => _$CommerceDashboardViewFromJson(json);

  Map<String, dynamic> toJson() => _$CommerceDashboardViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

