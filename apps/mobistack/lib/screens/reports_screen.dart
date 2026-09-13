import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().dashboard;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: const Text('Today sales'), trailing: Text(d.todaySales.toStringAsFixed(2))),
          ListTile(title: const Text('Today transactions'), trailing: Text('${d.todayTransactions}')),
          ListTile(title: const Text('Pending repairs'), trailing: Text('${d.pendingRepairs}')),
          ListTile(title: const Text('Low stock SKUs'), trailing: Text('${d.lowStockCount}')),
        ],
      ),
    );
  }
}
