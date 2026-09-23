import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/shop_models.dart';
import '../services/counter_payloads.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/counter_sheet.dart';
import '../widgets/shop_ui.dart';

class RepairsScreen extends StatelessWidget {
  const RepairsScreen({super.key});

  static const _statuses = [
    'RECEIVED',
    'DIAGNOSING',
    'WAITING_FOR_PART',
    'IN_REPAIR',
    'READY',
    'DELIVERED',
    'CANCELLED',
  ];

  Future<void> _newJob(BuildContext context) async {
    final values = await askCounterFields(
      context,
      title: 'New repair',
      labels: const ['Problem', 'IMEI', 'Estimate'],
    );
    if (values == null || !context.mounted) return;
    if (values[0].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the problem')),
      );
      return;
    }
    final state = context.read<AppState>();
    final customer = state.customers.isEmpty ? null : state.customers.first;
    final result = await state.submitOp(
      type: 'REPAIR',
      body: {
        'repair': {
          'problem': values[0],
          if (values.length > 1 && values[1].isNotEmpty) 'imei': values[1],
          if (values.length > 2 && values[2].isNotEmpty) 'estimatedCost': double.tryParse(values[2]) ?? 0,
          if (customer != null) 'customerId': customer.id,
        },
      },
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(counterMessage(
          result,
          synced: 'Repair saved',
          queued: 'Repair queued — will sync when online',
        )),
      ),
    );
  }

  Future<void> _jobActions(BuildContext context, CachedRepair job) async {
    String detail = job.problem ?? 'Repair';
    final state = context.read<AppState>();
    if (state.online) {
      try {
        final res = await state.api.dio.get<dynamic>('repairs/${job.id}');
        if (res.data is Map) {
          final row = res.data as Map;
          detail = [
            row['status'],
            if ('${row['imei'] ?? ''}'.isNotEmpty) 'IMEI ${row['imei']}',
            if ('${row['deviceName'] ?? ''}'.isNotEmpty) row['deviceName'],
            row['problem'],
            'Unpaid ${row['outstanding'] ?? job.outstanding}',
          ].where((part) => part != null && '$part'.isNotEmpty).join('\n');
        }
      } catch (_) {}
    }
    if (!context.mounted) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Px.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(job.jobNumber), subtitle: Text(detail)),
            ListTile(title: const Text('Status'), onTap: () => Navigator.pop(context, 'status')),
            ListTile(title: const Text('Add scanned part'), onTap: () => Navigator.pop(context, 'part')),
            ListTile(title: const Text('Labor'), onTap: () => Navigator.pop(context, 'labor')),
            ListTile(title: const Text('Take payment'), onTap: () => Navigator.pop(context, 'pay')),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'status') {
      await _setStatus(context, job);
      return;
    }
    if (action == 'part') {
      final variant = state.matchCode(state.lastScan ?? '');
      if (variant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan a part first, then add it to the job')),
        );
        return;
      }
      final error = await state.onlinePost('repairs/${job.id}/parts', {
        'variantId': variant.id,
        'quantity': 1,
        'unitPrice': variant.retailPrice,
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Part added to ${job.jobNumber}')));
      return;
    }
    if (action == 'labor') {
      final values = await askCounterFields(context, title: 'Labor', labels: const ['Charge']);
      if (values == null || !context.mounted) return;
      final error = await state.onlinePut('repairs/${job.id}', {
        'laborCharge': double.tryParse(values.first) ?? 0,
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Labor saved')));
      return;
    }
    final values = await askCounterFields(context, title: 'Payment', labels: const ['Amount']);
    if (values == null || !context.mounted) return;
    final amount = double.tryParse(values.first) ?? 0;
    if (amount <= 0) return;
    final error = await state.onlinePost('repairs/${job.id}/payments', {
      'payments': [
        {'method': 'CASH', 'amount': amount},
      ],
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Payment taken')));
  }

  Future<void> _setStatus(BuildContext context, CachedRepair job) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(job.jobNumber),
        children: [
          for (final value in _statuses)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Text(value.replaceAll('_', ' ')),
            ),
        ],
      ),
    );
    if (status == null || !context.mounted) return;
    final result = await context.read<AppState>().submitOp(
      type: 'REPAIR_STATUS',
      body: {
        'repairStatus': {
          'repairId': job.id,
          'status': status,
        },
      },
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(counterMessage(
          result,
          synced: 'Status updated',
          queued: 'Status queued — will sync when online',
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hasFeature('REPAIRS')) {
      return const Atmosphere(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShopEmpty(
            title: 'Repairs locked',
            subtitle: 'This feature is not on your plan.',
            icon: Icons.build_outlined,
          ),
        ),
      );
    }

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              ShopHeroHeader(
                title: 'Repairs',
                subtitle: state.online
                    ? '${state.repairs.length} jobs'
                    : 'Cached jobs · sync when online',
                actions: [
                  IconButton(
                    tooltip: 'New repair',
                    onPressed: () => _newJob(context),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              Expanded(
                child: state.repairs.isEmpty
                    ? const ShopEmpty(
                        title: 'No repair jobs',
                        subtitle: 'Jobs appear here after a successful sync',
                        icon: Icons.build_circle_outlined,
                      )
                    : RefreshIndicator(
                        color: Px.accent,
                        onRefresh: () => state.refreshAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: state.repairs.length,
                          itemBuilder: (context, i) {
                            final r = state.repairs[i];
                            final meta = [
                              if (r.status != null) r.status!,
                              if (r.problem != null) r.problem!,
                            ].join(' · ');
                            return ShopListTile(
                              onTap: () => _jobActions(context, r),
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Px.warning.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.build_rounded,
                                    color: Px.warning, size: 20),
                              ),
                              title: r.jobNumber,
                              subtitle: meta.isEmpty ? 'Repair job' : meta,
                              trailing: Text(
                                r.outstanding.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
