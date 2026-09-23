import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key, this.variantId});

  final String? variantId;

  @override
  Widget build(BuildContext context) {
    final path = variantId == null || variantId!.isEmpty
        ? 'inventory/transactions'
        : 'inventory/transactions?variantId=$variantId';
    return LiveApiListScreen(
      title: 'Stock movements',
      path: path,
      titleOf: (row) => '${row['type'] ?? 'Movement'} · ${row['quantity'] ?? ''}',
      subtitleOf: (row) => '${row['reason'] ?? row['referenceLabel'] ?? row['createdByName'] ?? ''}',
      emptyTitle: 'No movements yet',
      emptySubtitle: variantId == null
          ? 'Sales, receipts and adjustments post here.'
          : 'Movements for this part.',
      emptyIcon: Icons.swap_horiz_rounded,
    );
  }
}
