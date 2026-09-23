import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
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
      emptySubtitle: 'Add a supplier from the button.',
      emptyIcon: Icons.local_shipping_outlined,
      onTap: (row) {
        final bits = [
          if ('${row['phone'] ?? ''}'.isNotEmpty) 'Phone ${row['phone']}',
          if ('${row['city'] ?? ''}'.isNotEmpty) row['city'],
          if ('${row['gstNumber'] ?? ''}'.isNotEmpty) 'GST ${row['gstNumber']}',
          'Owes ${row['outstandingAmount'] ?? 0}',
        ].join('\n');
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${row['name'] ?? 'Supplier'}'),
            content: Text(bits),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
        );
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final values = await askCounterFields(
            context,
            title: 'New supplier',
            labels: const ['Name', 'Phone'],
          );
          if (values == null || values.first.isEmpty || !context.mounted) return;
          final error = await context.read<AppState>().onlinePost('suppliers', {
            'name': values[0],
            if (values.length > 1 && values[1].isNotEmpty) 'phone': values[1],
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Supplier saved')),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
