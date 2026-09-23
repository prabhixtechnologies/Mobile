import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
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
      onTap: (row) async {
        final id = '${row['id'] ?? ''}';
        if (id.isEmpty) return;
        final error = await context.read<AppState>().onlinePost('purchases/$id/cancel', {'reason': 'Cancelled on the counter'});
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Purchase cancelled')));
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final state = context.read<AppState>();
          final variant = state.matchCode(state.lastScan ?? '') ?? (state.variants.isEmpty ? null : state.variants.first);
          if (variant == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add a part first, then scan it before a purchase')),
            );
            return;
          }
          final values = await askCounterFields(
            context,
            title: 'Receive purchase',
            labels: const ['Quantity', 'Unit cost'],
          );
          if (values == null || !context.mounted) return;
          final listed = await state.api.dio.get<dynamic>('suppliers');
          String? supplierId;
          final data = listed.data;
          final rows = data is Map && data['content'] is List ? data['content'] as List : data;
          if (rows is List) {
            for (final row in rows) {
              if (row is Map && '${row['id'] ?? ''}'.isNotEmpty) {
                supplierId = '${row['id']}';
                break;
              }
            }
          }
          final error = await state.onlinePost('purchases', {
            if (supplierId != null) 'supplierId': supplierId,
            'items': [
              {
                'variantId': variant.id,
                'quantity': int.tryParse(values[0]) ?? 1,
                'unitCost': double.tryParse(values.length > 1 ? values[1] : '') ?? variant.retailPrice,
              },
            ],
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Purchase received')));
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
