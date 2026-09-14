//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/variant_view.dart';
import 'package:prabhix_oneops_api/src/model/product_status.dart';
import 'package:prabhix_oneops_api/src/model/product_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductDetail {
  /// Returns a new [ProductDetail] instance.
  ProductDetail({

     this.id,

     this.slug,

     this.name,

     this.tagline,

     this.description,

     this.productType,

     this.status,

     this.featured,

     this.heroImageFileId,

     this.heroImageUrl,

     this.galleryFileIds,

     this.galleryImageUrls,

     this.seoTitle,

     this.seoDescription,

     this.hsnCode,

     this.attributes,

     this.variants,

     this.categoryIds,

     this.publishedAt,
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
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'productType',
    required: false,
    includeIfNull: false,
  )


  final ProductType? productType;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final ProductStatus? status;



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
    
    name: r'galleryFileIds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? galleryFileIds;



  @JsonKey(
    
    name: r'galleryImageUrls',
    required: false,
    includeIfNull: false,
  )


  final List<String>? galleryImageUrls;



  @JsonKey(
    
    name: r'seoTitle',
    required: false,
    includeIfNull: false,
  )


  final String? seoTitle;



  @JsonKey(
    
    name: r'seoDescription',
    required: false,
    includeIfNull: false,
  )


  final String? seoDescription;



  @JsonKey(
    
    name: r'hsnCode',
    required: false,
    includeIfNull: false,
  )


  final String? hsnCode;



  @JsonKey(
    
    name: r'attributes',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? attributes;



  @JsonKey(
    
    name: r'variants',
    required: false,
    includeIfNull: false,
  )


  final List<VariantView>? variants;



  @JsonKey(
    
    name: r'categoryIds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? categoryIds;



  @JsonKey(
    
    name: r'publishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? publishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProductDetail &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.tagline == tagline &&
      other.description == description &&
      other.productType == productType &&
      other.status == status &&
      other.featured == featured &&
      other.heroImageFileId == heroImageFileId &&
      other.heroImageUrl == heroImageUrl &&
      other.galleryFileIds == galleryFileIds &&
      other.galleryImageUrls == galleryImageUrls &&
      other.seoTitle == seoTitle &&
      other.seoDescription == seoDescription &&
      other.hsnCode == hsnCode &&
      other.attributes == attributes &&
      other.variants == variants &&
      other.categoryIds == categoryIds &&
      other.publishedAt == publishedAt;

    @override
    int get hashCode =>
        id.hashCode +
        slug.hashCode +
        name.hashCode +
        tagline.hashCode +
        description.hashCode +
        productType.hashCode +
        status.hashCode +
        featured.hashCode +
        heroImageFileId.hashCode +
        heroImageUrl.hashCode +
        galleryFileIds.hashCode +
        galleryImageUrls.hashCode +
        seoTitle.hashCode +
        seoDescription.hashCode +
        hsnCode.hashCode +
        attributes.hashCode +
        variants.hashCode +
        categoryIds.hashCode +
        publishedAt.hashCode;

  factory ProductDetail.fromJson(Map<String, dynamic> json) => _$ProductDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

