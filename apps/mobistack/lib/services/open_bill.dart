import '../models/shop_models.dart';

class BillLine {
  BillLine({required this.variant, this.quantity = 1, double? unitPrice})
      : unitPrice = unitPrice ?? variant.retailPrice;

  final CachedVariant variant;
  int quantity;
  double unitPrice;

  double get lineTotal => unitPrice * quantity;
}

/// Scans collect here until the counter takes payment.
class OpenBill {
  final List<BillLine> lines = [];
  String? customerId;
  String? customerName;
  double discount = 0;
  String method = 'CASH';

  bool get isEmpty => lines.isEmpty;

  void add(CachedVariant variant) {
    for (final line in lines) {
      if (line.variant.id == variant.id) {
        line.quantity += 1;
        return;
      }
    }
    lines.add(BillLine(variant: variant));
  }

  void removeAt(int index) {
    if (index >= 0 && index < lines.length) lines.removeAt(index);
  }

  double get subtotal => lines.fold(0, (sum, line) => sum + line.lineTotal);

  double get total {
    final due = subtotal - discount;
    return due < 0 ? 0 : due;
  }

  void clear() {
    lines.clear();
    customerId = null;
    customerName = null;
    discount = 0;
    method = 'CASH';
  }

  Map<String, dynamic> toSaleBody() {
    return {
      if (customerId != null) 'customerId': customerId,
      if (discount > 0) 'discount': discount,
      'items': [
        for (final line in lines)
          {
            'variantId': line.variant.id,
            'quantity': line.quantity,
            'unitPrice': line.unitPrice,
          },
      ],
      if (total > 0)
        'payments': [
          {'method': method, 'amount': total},
        ],
    };
  }
}

class SaleOutcome {
  const SaleOutcome.done({this.saleId, this.invoiceNumber, this.queued = false}) : message = null;

  const SaleOutcome.failed(this.message)
      : saleId = null,
        invoiceNumber = null,
        queued = false;

  final String? saleId;
  final String? invoiceNumber;
  final bool queued;
  final String? message;

  bool get ok => message == null;
}
