//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commerce_settings_view.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CommerceSettingsView {
  /// Returns a new [CommerceSettingsView] instance.
  CommerceSettingsView({

     this.sellerState,

     this.sellerName,

     this.sellerGstin,

     this.sellerAddress,

     this.orderNumberPrefix,

     this.gstPercent,

     this.flatShippingPaise,

     this.freeShippingAbovePaise,
  });

  @JsonKey(
    
    name: r'sellerState',
    required: false,
    includeIfNull: false,
  )


  final String? sellerState;



  @JsonKey(
    
    name: r'sellerName',
    required: false,
    includeIfNull: false,
  )


  final String? sellerName;



  @JsonKey(
    
    name: r'sellerGstin',
    required: false,
    includeIfNull: false,
  )


  final String? sellerGstin;



  @JsonKey(
    
    name: r'sellerAddress',
    required: false,
    includeIfNull: false,
  )


  final String? sellerAddress;



  @JsonKey(
    
    name: r'orderNumberPrefix',
    required: false,
    includeIfNull: false,
  )


  final String? orderNumberPrefix;



  @JsonKey(
    
    name: r'gstPercent',
    required: false,
    includeIfNull: false,
  )


  final int? gstPercent;



  @JsonKey(
    
    name: r'flatShippingPaise',
    required: false,
    includeIfNull: false,
  )


  final int? flatShippingPaise;



  @JsonKey(
    
    name: r'freeShippingAbovePaise',
    required: false,
    includeIfNull: false,
  )


  final int? freeShippingAbovePaise;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CommerceSettingsView &&
      other.sellerState == sellerState &&
      other.sellerName == sellerName &&
      other.sellerGstin == sellerGstin &&
      other.sellerAddress == sellerAddress &&
      other.orderNumberPrefix == orderNumberPrefix &&
      other.gstPercent == gstPercent &&
      other.flatShippingPaise == flatShippingPaise &&
      other.freeShippingAbovePaise == freeShippingAbovePaise;

    @override
    int get hashCode =>
        sellerState.hashCode +
        sellerName.hashCode +
        sellerGstin.hashCode +
        sellerAddress.hashCode +
        orderNumberPrefix.hashCode +
        gstPercent.hashCode +
        flatShippingPaise.hashCode +
        freeShippingAbovePaise.hashCode;

  factory CommerceSettingsView.fromJson(Map<String, dynamic> json) => _$CommerceSettingsViewFromJson(json);

  Map<String, dynamic> toJson() => _$CommerceSettingsViewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

