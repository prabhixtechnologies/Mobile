import '../models/shop_models.dart';

/// Result of queueing a counter action.
class CounterResult {
  const CounterResult.synced()
      : queued = false,
        message = null;

  const CounterResult.queued()
      : queued = true,
        message = null;

  const CounterResult.failed(this.message) : queued = false;

  final bool queued;
  final String? message;

  bool get ok => message == null;
}

/// Body of `SyncOperation.sale`. The server requires `items`, not a flat SKU.
Map<String, dynamic> salePayload(CachedVariant variant) {
  final price = variant.retailPrice;
  return {
    'items': [
      {
        'variantId': variant.id,
        'quantity': 1,
        'unitPrice': price,
      },
    ],
    if (price > 0)
      'payments': [
        {'method': 'CASH', 'amount': price},
      ],
  };
}

String counterMessage(CounterResult result, {required String synced, required String queued}) {
  if (result.message != null) return result.message!;
  return result.queued ? queued : synced;
}
