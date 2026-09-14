import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Purchases',
      path: 'purchases',
      titleOf: (row) => '${row['supplierName'] ?? 'Purchase'}',
      subtitleOf: (row) => '${row['status'] ?? ''} · ${row['total'] ?? ''}'.trim(),
      emptyTitle: 'No purchases yet',
      emptySubtitle: 'Receive a supplier bill and it appears here.',
      emptyIcon: Icons.shopping_bag_outlined,
    );
  }
}
