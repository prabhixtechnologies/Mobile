//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/discount_type.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discount_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DiscountView {
  /// Returns a new [DiscountView] instance.
  DiscountView({

     this.id,

     this.code,

     this.description,

     this.discountType,

     this.percentage,

     this.amountMinor,

     this.minOrderMinor,

     this.maxUsesTotal,

     this.maxUsesPerCustomer,

     this.usesCount,

     this.validFrom,

     this.validUntil,

     this.productIds,

     this.categoryIds,

     this.active,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'code',
    required: false,
    includeIfNull: false,
  )


  final String? code;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'discountType',
    required: false,
    includeIfNull: false,
  )


  final DiscountType? discountType;



  @JsonKey(
    
    name: r'percentage',
    required: false,
    includeIfNull: false,
  )


  final int? percentage;



  @JsonKey(
    
    name: r'amountMinor',
    required: false,
    includeIfNull: false,
  )


  final int? amountMinor;



  @JsonKey(
    
    name: r'minOrderMinor',
    required: false,
    includeIfNull: false,
  )


  final int? minOrderMinor;



  @JsonKey(
    
    name: r'maxUsesTotal',
    required: false,
    includeIfNull: false,
  )


  final int? maxUsesTotal;



  @JsonKey(
    
    name: r'maxUsesPerCustomer',
    required: false,
    includeIfNull: false,
  )


  final int? maxUsesPerCustomer;



  @JsonKey(
    
    name: r'usesCount',
    required: false,
    includeIfNull: false,
  )


  final int? usesCount;



  @JsonKey(
    
    name: r'validFrom',
    required: false,
    includeIfNull: false,
  )


  final DateTime? validFrom;



  @JsonKey(
    
    name: r'validUntil',
    required: false,
    includeIfNull: false,
  )


  final DateTime? validUntil;



  @JsonKey(
    
    name: r'productIds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? productIds;



  @JsonKey(
    
    name: r'categoryIds',
    required: false,
    includeIfNull: false,
  )


  final List<String>? categoryIds;



  @JsonKey(
    
    name: r'active',
    required: false,
    includeIfNull: false,
  )


  final bool? active;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DiscountView &&
      other.id == id &&
      other.code == code &&
      other.description == description &&
      other.discountType == discountType &&
      other.percentage == percentage &&
      other.amountMinor == amountMinor &&
      other.minOrderMinor == minOrderMinor &&
      other.maxUsesTotal == maxUsesTotal &&
      other.maxUsesPerCustomer == maxUsesPerCustomer &&
      other.usesCount == usesCount &&
      other.validFrom == validFrom &&
      other.validUntil == validUntil &&
      other.productIds == productIds &&
      other.categoryIds == categoryIds &&
      other.active == active;

    @override
    int get hashCode =>
        id.hashCode +
        code.hashCode +
        description.hashCode +
        discountType.hashCode +
        percentage.hashCode +
        amountMinor.hashCode +
        minOrderMinor.hashCode +
        maxUsesTotal.hashCode +
        maxUsesPerCustomer.hashCode +
        usesCount.hashCode +
        validFrom.hashCode +
        validUntil.hashCode +
        productIds.hashCode +
        categoryIds.hashCode +
        active.hashCode;

  factory DiscountView.fromJson(Map<String, dynamic> json) => _$DiscountViewFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

