import 'package:prabhix_api_core/prabhix_api_core.dart' show describeError;
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

const Map<String, String> _ranges = {
  'today': 'Today',
  '7d': 'Last 7 days',
  'this_month': 'This month',
};

String _rupees(Object? value) {
  final n = value is num ? value : num.tryParse('${value ?? 0}') ?? 0;
  return '₹${n.toStringAsFixed(n == n.roundToDouble() ? 0 : 2)}';
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _range = 'today';
  String? _summary;
  Map<String, dynamic>? _sales;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(_range));
  }

  Future<void> _load(String range) async {
    setState(() => _range = range);
    final state = context.read<AppState>();
    if (!state.online) {
      setState(() {
        _summary = 'Offline · showing the counters saved on this phone';
        _sales = null;
      });
      return;
    }
    try {
      final res = await state.api.dio.get<dynamic>('reports', queryParameters: {'range': range});
      final data = res.data;
      final sales = data is Map ? data['sales'] : null;
      if (!mounted) return;
      setState(() {
        _sales = sales is Map ? Map<String, dynamic>.from(sales) : null;
        _summary = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = describeError(e);
          _sales = null;
        });
      }
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<AppState>().dashboard;
    final s = _sales;
    return ShopPage(
      title: 'Reports',
      subtitle: '${_ranges[_range]} on the counter',
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
              for (final range in _ranges.keys)
                ChoiceChip(
                  label: Text(_ranges[range]!),
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
          if (s != null) ...[
            KpiTile(label: 'Sales', value: _rupees(s['sales']), tone: KpiTone.accent),
            const SizedBox(height: 10),
            KpiTile(label: 'Profit', value: _rupees(s['profit']), tone: KpiTone.success),
            const SizedBox(height: 10),
            KpiTile(label: 'Bills', value: '${s['transactions'] ?? 0}', tone: KpiTone.neutral),
          ] else ...[
            KpiTile(label: 'Today sales', value: _rupees(d.todaySales), tone: KpiTone.accent),
            const SizedBox(height: 10),
            KpiTile(label: 'Today bills', value: '${d.todayTransactions}', tone: KpiTone.neutral),
          ],
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
                trailing: Text(_rupees(sale.total)),
              ),
        ],
      ),
    );
  }
}
