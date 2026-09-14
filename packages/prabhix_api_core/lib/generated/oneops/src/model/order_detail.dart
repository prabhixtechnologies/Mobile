//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:prabhix_oneops_api/src/model/order_item_view.dart';
import 'package:prabhix_oneops_api/src/model/order_event_view.dart';
import 'package:prabhix_oneops_api/src/model/order_address_view.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_detail.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderDetail {
  /// Returns a new [OrderDetail] instance.
  OrderDetail({

     this.id,

     this.orderNumber,

     this.status,

     this.accessToken,

     this.subtotalMinor,

     this.discountMinor,

     this.cgstMinor,

     this.sgstMinor,

     this.igstMinor,

     this.shippingMinor,

     this.totalMinor,

     this.currency,

     this.customerEmail,

     this.customerName,

     this.items,

     this.addresses,

     this.events,

     this.invoiceId,

     this.paidAt,

     this.fulfilledAt,

     this.internalNote,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'orderNumber',
    required: false,
    includeIfNull: false,
  )


  final String? orderNumber;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final String? status;



  @JsonKey(
    
    name: r'accessToken',
    required: false,
    includeIfNull: false,
  )


  final String? accessToken;



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
    
    name: r'cgstMinor',
    required: false,
    includeIfNull: false,
  )


  final int? cgstMinor;



  @JsonKey(
    
    name: r'sgstMinor',
    required: false,
    includeIfNull: false,
  )


  final int? sgstMinor;



  @JsonKey(
    
    name: r'igstMinor',
    required: false,
    includeIfNull: false,
  )


  final int? igstMinor;



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
    
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'customerEmail',
    required: false,
    includeIfNull: false,
  )


  final String? customerEmail;



  @JsonKey(
    
    name: r'customerName',
    required: false,
    includeIfNull: false,
  )


  final String? customerName;



  @JsonKey(
    
    name: r'items',
    required: false,
    includeIfNull: false,
  )


  final List<OrderItemView>? items;



  @JsonKey(
    
    name: r'addresses',
    required: false,
    includeIfNull: false,
  )


  final List<OrderAddressView>? addresses;



  @JsonKey(
    
    name: r'events',
    required: false,
    includeIfNull: false,
  )


  final List<OrderEventView>? events;



  @JsonKey(
    
    name: r'invoiceId',
    required: false,
    includeIfNull: false,
  )


  final String? invoiceId;



  @JsonKey(
    
    name: r'paidAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? paidAt;



  @JsonKey(
    
    name: r'fulfilledAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? fulfilledAt;



  @JsonKey(
    
    name: r'internalNote',
    required: false,
    includeIfNull: false,
  )


  final String? internalNote;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderDetail &&
      other.id == id &&
      other.orderNumber == orderNumber &&
      other.status == status &&
      other.accessToken == accessToken &&
      other.subtotalMinor == subtotalMinor &&
      other.discountMinor == discountMinor &&
      other.cgstMinor == cgstMinor &&
      other.sgstMinor == sgstMinor &&
      other.igstMinor == igstMinor &&
      other.shippingMinor == shippingMinor &&
      other.totalMinor == totalMinor &&
      other.currency == currency &&
      other.customerEmail == customerEmail &&
      other.customerName == customerName &&
      other.items == items &&
      other.addresses == addresses &&
      other.events == events &&
      other.invoiceId == invoiceId &&
      other.paidAt == paidAt &&
      other.fulfilledAt == fulfilledAt &&
      other.internalNote == internalNote;

    @override
    int get hashCode =>
        id.hashCode +
        orderNumber.hashCode +
        status.hashCode +
        accessToken.hashCode +
        subtotalMinor.hashCode +
        discountMinor.hashCode +
        cgstMinor.hashCode +
        sgstMinor.hashCode +
        igstMinor.hashCode +
        shippingMinor.hashCode +
        totalMinor.hashCode +
        currency.hashCode +
        customerEmail.hashCode +
        customerName.hashCode +
        items.hashCode +
        addresses.hashCode +
        events.hashCode +
        invoiceId.hashCode +
        paidAt.hashCode +
        fulfilledAt.hashCode +
        internalNote.hashCode;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => _$OrderDetailFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

