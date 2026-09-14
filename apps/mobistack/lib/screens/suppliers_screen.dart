import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Suppliers',
      path: 'suppliers',
      titleOf: (row) => '${row['name'] ?? 'Supplier'}',
      subtitleOf: (row) => '${row['phone'] ?? row['city'] ?? ''}',
      emptyTitle: 'No suppliers yet',
      emptySubtitle: 'Add a supplier from the shop web app, or they appear after sync.',
      emptyIcon: Icons.local_shipping_outlined,
    );
  }
}
