import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/shop_ui.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _range = 'today';
  String? _summary;

  Future<void> _load(String range) async {
    setState(() => _range = range);
    final state = context.read<AppState>();
    if (!state.online) {
      setState(() => _summary = 'Offline · showing the cached counters');
      return;
    }
    try {
      final res = await state.api.dio.get<dynamic>('reports', queryParameters: {'range': range});
      final data = res.data;
      final sales = data is Map ? data['sales'] : null;
      if (sales is Map) {
        setState(() => _summary = 'Sales ${sales['sales']} · profit ${sales['profit']} · ${sales['transactions']} bills');
      }
    } catch (e) {
      if (mounted) setState(() => _summary = '$e');
    }
  }

  Future<void> _copy() async {
    final state = context.read<AppState>();
    try {
      final csv = await state.api.getText('reports/export?range=$_range');
      await Clipboard.setData(ClipboardData(text: csv));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report copied')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().dashboard;
    return ShopPage(
      title: 'Reports',
      subtitle: 'Today on the counter',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _copy,
        icon: const Icon(Icons.copy_rounded),
        label: const Text('Copy'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final range in const ['today', '7d', 'this_month'])
                ChoiceChip(
                  label: Text(range),
                  selected: _range == range,
                  onSelected: (_) => _load(range),
                ),
            ],
          ),
          if (_summary != null) ...[
            const SizedBox(height: 8),
            Text(_summary!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          KpiTile(label: 'Today sales', value: d.todaySales.toStringAsFixed(2), tone: KpiTone.accent),
          const SizedBox(height: 10),
          KpiTile(label: 'Today transactions', value: '${d.todayTransactions}', tone: KpiTone.neutral),
          const SizedBox(height: 10),
          KpiTile(label: 'Pending repairs', value: '${d.pendingRepairs}', tone: KpiTone.warning),
          const SizedBox(height: 10),
          KpiTile(label: 'Low stock SKUs', value: '${d.lowStockCount}', tone: KpiTone.danger),
          const SizedBox(height: 18),
          Text('Recent sales', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (context.watch<AppState>().sales.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('No sales on this phone yet', style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            for (final sale in context.watch<AppState>().sales)
              ShopListTile(
                title: sale.invoiceNumber,
                subtitle: sale.status ?? 'Sale',
                trailing: Text(sale.total.toStringAsFixed(2)),
              ),
        ],
      ),
    );
  }
}
