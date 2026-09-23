import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/shop_models.dart';
import '../services/counter_payloads.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/counter_sheet.dart';
import '../widgets/shop_ui.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _query = TextEditingController();
  bool _lowOnly = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _newPart() async {
    final values = await askCounterFields(
      context,
      title: 'New part',
      labels: const ['Name', 'SKU', 'Retail price', 'Opening qty'],
      keyboards: const [
        TextInputType.text,
        TextInputType.text,
        TextInputType.numberWithOptions(decimal: true),
        TextInputType.number,
      ],
    );
    if (values == null || !mounted) return;
    if (values[0].isEmpty || values[1].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and SKU are required')),
      );
      return;
    }
    final price = double.tryParse(values[2]) ?? 0;
    final qty = int.tryParse(values[3]) ?? 0;
    final error = await context.read<AppState>().createPart(
          name: values[0],
          sku: values[1],
          price: price,
          qty: qty,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Part added')),
    );
  }

  Future<void> _receive(CachedVariant variant) async {
    final values = await askCounterFields(
      context,
      title: 'Receive ${variant.label}',
      labels: const ['Quantity'],
      keyboards: const [TextInputType.number],
      action: 'Receive',
    );
    if (values == null || !mounted) return;
    final qty = int.tryParse(values[0]) ?? 0;
    if (qty < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be at least 1')),
      );
      return;
    }
    final result = await context.read<AppState>().submitOp(
      type: 'RECEIVE',
      body: {
        'receive': {
          'variantId': variant.id,
          'quantity': qty,
        },
      },
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(counterMessage(
          result,
          synced: 'Stock received',
          queued: 'Receive queued — will sync when online',
        )),
      ),
    );
  }

  Future<void> _stockActions(CachedVariant variant) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Px.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(variant.label), subtitle: Text('qty ${variant.availableQty}')),
            ListTile(title: const Text('Receive'), onTap: () => Navigator.pop(context, 'receive')),
            ListTile(title: const Text('Issue'), onTap: () => Navigator.pop(context, 'issue')),
            ListTile(title: const Text('Count'), onTap: () => Navigator.pop(context, 'adjust')),
            ListTile(title: const Text('Damage'), onTap: () => Navigator.pop(context, 'damage')),
            ListTile(title: const Text('Another variant'), onTap: () => Navigator.pop(context, 'variant')),
            ListTile(title: const Text('Movements'), onTap: () => Navigator.pop(context, 'moves')),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    if (action == 'moves') {
      context.push('/movements?variant=${variant.id}');
      return;
    }
    if (action == 'variant') {
      final values = await askCounterFields(
        context,
        title: 'Another variant',
        labels: const ['Name', 'SKU', 'Price', 'Qty', 'Reorder'],
      );
      if (values == null || !mounted) return;
      final error = await context.read<AppState>().addVariant(
            variantId: variant.id,
            name: values[0].isEmpty ? variant.variantName : values[0],
            sku: values[1].isEmpty ? '${variant.sku}-2' : values[1],
            price: double.tryParse(values[2]) ?? variant.retailPrice,
            qty: int.tryParse(values[3]) ?? 0,
            reorderLevel: int.tryParse(values.length > 4 ? values[4] : '') ?? 0,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Variant added')));
      return;
    }
    if (action == 'receive') {
      await _receive(variant);
      return;
    }
    final qty = await askCounterFields(
      context,
      title: action == 'adjust' ? 'Counted quantity' : action,
      labels: const ['Quantity'],
      keyboards: const [TextInputType.number],
    );
    if (qty == null || !mounted) return;
    final amount = int.tryParse(qty.first) ?? 0;
    final state = context.read<AppState>();
    final String? error = switch (action) {
      'issue' => await state.onlinePost('inventory/issue', {
          'variantId': variant.id,
          'quantity': amount < 1 ? 1 : amount,
          'reason': 'Issued on the counter',
        }),
      'damage' => await state.onlinePost('inventory/damage', {
          'variantId': variant.id,
          'quantity': amount < 1 ? 1 : amount,
          'reason': 'Damaged on the counter',
        }),
      _ => await state.onlinePost('inventory/adjust', {
          'variantId': variant.id,
          'countedQuantity': amount < 0 ? 0 : amount,
          'reason': 'Counted on the counter',
        }),
    };
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Stock updated')));
  }

  Color _stockColor(String status) {
    final s = status.toUpperCase();
    if (s.contains('OUT') || s.contains('ZERO')) return Px.danger;
    if (s.contains('LOW')) return Px.warning;
    return Px.success;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hasFeature('INVENTORY')) {
      return const Atmosphere(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShopEmpty(
            title: 'Inventory locked',
            subtitle: 'This feature is not on your plan.',
          ),
        ),
      );
    }
    final items = state.searchVariants(_query.text).where((variant) {
      if (!_lowOnly) return true;
      return variant.stockStatus.toUpperCase().contains('LOW') || variant.availableQty <= 2;
    }).toList();

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              ShopHeroHeader(
                title: 'Stock',
                subtitle: state.online
                    ? '${items.length} variants'
                    : 'Cached · ${items.length} variants',
                actions: [
                  IconButton(
                    tooltip: 'New part',
                    onPressed: _newPart,
                    icon: const Icon(Icons.add_box_outlined),
                  ),
                  IconButton(
                    tooltip: 'Scan',
                    onPressed: () async {
                      final code = await context.push<String>('/scan');
                      if (code != null && code.isNotEmpty) {
                        setState(() => _query.text = code);
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Low stock'),
                    selected: _lowOnly,
                    onSelected: (value) => setState(() => _lowOnly = value),
                  ),
                ),
              ),
              ShopSearchField(
                controller: _query,
                hint: 'Part, SKU, barcode',
                onChanged: (_) => setState(() {}),
              ),
              if (state.lastScan != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Last scan · ${state.lastScan}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Px.accent,
                          ),
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? ShopEmpty(
                        title: _query.text.isEmpty
                            ? 'No stock cached yet'
                            : 'No matches',
                        subtitle: state.online
                            ? 'Add a part, or scan a barcode'
                            : 'Connect when your window opens to refresh stock',
                        icon: Icons.inventory_2_outlined,
                      )
                    : RefreshIndicator(
                        color: Px.accent,
                        onRefresh: () => state.refreshAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: items.length,
                          itemBuilder: (context, i) {
                            final v = items[i];
                            return ShopListTile(
                              onTap: () => _stockActions(v),
                              title: v.label,
                              subtitle:
                                  '${v.sku} · qty ${v.availableQty} · ${v.stockStatus}',
                              trailing: Text(
                                v.retailPrice.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: _stockColor(v.stockStatus),
                                      fontWeight: FontWeight.w700,
                                    ),
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
