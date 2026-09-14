//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/billing_interval.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'variant_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VariantView {
  /// Returns a new [VariantView] instance.
  VariantView({

     this.id,

     this.name,

     this.sku,

     this.priceMinor,

     this.compareAtPriceMinor,

     this.currency,

     this.trackInventory,

     this.stockAvailable,

     this.billingInterval,

     this.downloadFileId,

     this.serviceDurationDays,

     this.deliverySlaDays,

     this.active,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'sku',
    required: false,
    includeIfNull: false,
  )


  final String? sku;



  @JsonKey(
    
    name: r'priceMinor',
    required: false,
    includeIfNull: false,
  )


  final int? priceMinor;



  @JsonKey(
    
    name: r'compareAtPriceMinor',
    required: false,
    includeIfNull: false,
  )


  final int? compareAtPriceMinor;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'trackInventory',
    required: false,
    includeIfNull: false,
  )


  final bool? trackInventory;



  @JsonKey(
    
    name: r'stockAvailable',
    required: false,
    includeIfNull: false,
  )


  final int? stockAvailable;



  @JsonKey(
    
    name: r'billingInterval',
    required: false,
    includeIfNull: false,
  )


  final BillingInterval? billingInterval;



  @JsonKey(
    
    name: r'downloadFileId',
    required: false,
    includeIfNull: false,
  )


  final String? downloadFileId;



  @JsonKey(
    
    name: r'serviceDurationDays',
    required: false,
    includeIfNull: false,
  )


  final int? serviceDurationDays;



  @JsonKey(
    
    name: r'deliverySlaDays',
    required: false,
    includeIfNull: false,
  )


  final int? deliverySlaDays;



  @JsonKey(
    
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VariantView &&
      other.id == id &&
      other.name == name &&
      other.sku == sku &&
      other.priceMinor == priceMinor &&
      other.compareAtPriceMinor == compareAtPriceMinor &&
      other.currency == currency &&
      other.trackInventory == trackInventory &&
      other.stockAvailable == stockAvailable &&
      other.billingInterval == billingInterval &&
      other.downloadFileId == downloadFileId &&
      other.serviceDurationDays == serviceDurationDays &&
      other.deliverySlaDays == deliverySlaDays &&
      other.active == active;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        sku.hashCode +
        priceMinor.hashCode +
        compareAtPriceMinor.hashCode +
        currency.hashCode +
        trackInventory.hashCode +
        stockAvailable.hashCode +
        billingInterval.hashCode +
        downloadFileId.hashCode +
        serviceDurationDays.hashCode +
        deliverySlaDays.hashCode +
        active.hashCode;

  factory VariantView.fromJson(Map<String, dynamic> json) => _$VariantViewFromJson(json);

  Map<String, dynamic> toJson() => _$VariantViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

