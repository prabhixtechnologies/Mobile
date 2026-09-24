//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/product_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductSummary {
  /// Returns a new [ProductSummary] instance.
  ProductSummary({

     this.id,

     this.slug,

     this.name,

     this.tagline,

     this.productType,

     this.featured,

     this.heroImageFileId,

     this.heroImageUrl,

     this.fromPricePaise,

     this.currency,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'slug',
    required: false,
    includeIfNull: false,
  )


  final String? slug;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'tagline',
    required: false,
    includeIfNull: false,
  )


  final String? tagline;



  @JsonKey(
    
    name: r'productType',
    required: false,
    includeIfNull: false,
  )


  final ProductType? productType;



  @JsonKey(
    
    name: r'featured',
    required: false,
    includeIfNull: false,
  )


  final bool? featured;



  @JsonKey(
    
    name: r'heroImageFileId',
    required: false,
    includeIfNull: false,
  )


  final String? heroImageFileId;



  @JsonKey(
    
    name: r'heroImageUrl',
    required: false,
    includeIfNull: false,
  )


  final String? heroImageUrl;



  @JsonKey(
    
    name: r'fromPricePaise',
    required: false,
    includeIfNull: false,
  )


  final int? fromPricePaise;



  @JsonKey(
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProductSummary &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.tagline == tagline &&
      other.productType == productType &&
      other.featured == featured &&
      other.heroImageFileId == heroImageFileId &&
      other.heroImageUrl == heroImageUrl &&
      other.fromPricePaise == fromPricePaise &&
      other.currency == currency;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        tagline.hashCode +
        productType.hashCode +
        featured.hashCode +
        heroImageFileId.hashCode +
        heroImageUrl.hashCode +
        fromPricePaise.hashCode +
        currency.hashCode;

  factory ProductSummary.fromJson(Map<String, dynamic> json) => _$ProductSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

