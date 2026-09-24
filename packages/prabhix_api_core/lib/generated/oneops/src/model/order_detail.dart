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

     this.subtotalPaise,

     this.discountPaise,

     this.cgstPaise,

     this.sgstPaise,

     this.igstPaise,

     this.shippingPaise,

     this.totalPaise,

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
    
    name: r'subtotalPaise',
    required: false,
    includeIfNull: false,
  )


  final int? subtotalPaise;



  @JsonKey(
    
    name: r'discountPaise',
    required: false,
    includeIfNull: false,
  )


  final int? discountPaise;



  @JsonKey(
    
    name: r'cgstPaise',
    required: false,
    includeIfNull: false,
  )


  final int? cgstPaise;



  @JsonKey(
    
    name: r'sgstPaise',
    required: false,
    includeIfNull: false,
  )


  final int? sgstPaise;



  @JsonKey(
    
    name: r'igstPaise',
    required: false,
    includeIfNull: false,
  )


  final int? igstPaise;



  @JsonKey(
    
    name: r'shippingPaise',
    required: false,
    includeIfNull: false,
  )


  final int? shippingPaise;



  @JsonKey(
    
    name: r'totalPaise',
    required: false,
    includeIfNull: false,
  )


  final int? totalPaise;



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
      other.subtotalPaise == subtotalPaise &&
      other.discountPaise == discountPaise &&
      other.cgstPaise == cgstPaise &&
      other.sgstPaise == sgstPaise &&
      other.igstPaise == igstPaise &&
      other.shippingPaise == shippingPaise &&
      other.totalPaise == totalPaise &&
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
        subtotalPaise.hashCode +
        discountPaise.hashCode +
        cgstPaise.hashCode +
        sgstPaise.hashCode +
        igstPaise.hashCode +
        shippingPaise.hashCode +
        totalPaise.hashCode +
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

