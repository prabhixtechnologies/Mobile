import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class MovementsScreen extends StatelessWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Stock movements',
      path: 'inventory/transactions',
      titleOf: (row) => '${row['type'] ?? 'Movement'} · ${row['quantity'] ?? ''}',
      subtitleOf: (row) =>
          '${row['reason'] ?? row['referenceLabel'] ?? row['createdByName'] ?? ''}',
      emptyTitle: 'No movements yet',
      emptySubtitle: 'Sales, receipts and adjustments post here.',
      emptyIcon: Icons.swap_horiz_rounded,
    );
  }
}
