import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<AppState>().customers;
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: ListView.separated(
        itemCount: customers.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final c = customers[i];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone ?? ''),
            trailing: Text(c.outstandingAmount.toStringAsFixed(2)),
          );
        },
      ),
    );
  }
}
