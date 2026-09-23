import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/counter_payloads.dart';
import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
import '../widgets/shop_ui.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final values = await askCounterFields(
      context,
      title: 'New customer',
      labels: const ['Name', 'Phone'],
      keyboards: const [TextInputType.name, TextInputType.phone],
      action: 'Save',
    );
    if (values == null || !context.mounted) return;
    if (values[0].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }
    final result = await context.read<AppState>().submitOp(
      type: 'CUSTOMER',
      body: {
        'customer': {
          'name': values[0],
          if (values[1].isNotEmpty) 'phone': values[1],
        },
      },
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(counterMessage(
          result,
          synced: 'Customer saved',
          queued: 'Customer queued — will sync when online',
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<AppState>().customers;
    return ShopPage(
      title: 'Customers',
      subtitle: customers.isEmpty ? 'No one on the book yet' : '${customers.length} on the book',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      child: customers.isEmpty
          ? const ShopEmpty(
              title: 'No customers yet',
              subtitle: 'Add a name from the button. It queues if you are offline.',
              icon: Icons.people_outline_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: customers.length,
              itemBuilder: (context, i) {
                final c = customers[i];
                return ShopListTile(
                  title: c.name,
                  subtitle: '${c.phone ?? ''} · owes ${c.outstandingAmount.toStringAsFixed(2)}',
                  trailing: Text(c.outstandingAmount.toStringAsFixed(2)),
                  onTap: () {
                    context.read<AppState>().setBillCustomer(c);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${c.name} is on the open bill')),
                    );
                  },
                );
              },
            ),
    );
  }
}
