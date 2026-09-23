import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/shop_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _sku = TextEditingController();

  @override
  void dispose() {
    _sku.dispose();
    super.dispose();
  }

  Future<void> _addSku() async {
    final state = context.read<AppState>();
    final typed = _sku.text.trim();
    final exact = state.matchCode(typed);
    final variant = exact ?? (state.searchVariants(typed).isEmpty ? null : state.searchVariants(typed).first);
    if (variant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching SKU in cached stock')),
      );
      return;
    }
    state.addToBill(variant);
    _sku.clear();
  }

  Future<double?> _askAmount(BuildContext context, String title, double current) async {
    final field = TextEditingController(text: current.toStringAsFixed(2));
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: field,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, double.tryParse(field.text) ?? current),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    field.dispose();
    return value;
  }

  Future<void> _openSale(AppState state, CachedSale sale) async {
    Map data = {};
    if (state.online) {
      try {
        final res = await state.api.dio.get<dynamic>('sales/${sale.id}');
        if (res.data is Map) data = res.data as Map;
      } catch (_) {}
    }
    if (!mounted) return;
    final items = data['items'];
    final lines = items is List
        ? items.whereType<Map>().map((row) => '${row['variantName'] ?? 'Item'} × ${row['quantity']}').join('\n')
        : '';
    final outstanding = data['outstanding'] ?? '';
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Px.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(sale.invoiceNumber, style: Theme.of(context).textTheme.titleLarge),
              Text('Unpaid $outstanding'),
              if (lines.isNotEmpty) Text(lines),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  this.context.push('/invoice/${sale.id}');
                },
                child: const Text('Open invoice'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final html = await state.invoiceHtml(sale.id);
                    await Share.share(html, subject: sale.invoiceNumber);
                  } catch (e) {
                    await Share.share(sale.invoiceNumber, subject: sale.invoiceNumber);
                  }
                },
                child: const Text('Share invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkout() async {
    final outcome = await context.read<AppState>().checkoutBill();
    if (!mounted) return;
    if (!outcome.ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(outcome.message!)));
      return;
    }
    final label = outcome.queued
        ? 'Bill queued — will sync when online'
        : 'Invoice ${outcome.invoiceNumber ?? 'saved'}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
    if (outcome.saleId != null) {
      context.push('/invoice/${outcome.saleId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hasFeature('SALES')) {
      return const Atmosphere(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShopEmpty(
            title: 'Sales locked',
            subtitle: 'This feature is not on your plan.',
            icon: Icons.point_of_sale_outlined,
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
                title: 'Sales',
                subtitle: state.online
                    ? '${state.sales.length} recent'
                    : 'Works offline · queues until sync',
                actions: [
                  IconButton(
                    onPressed: () => context.push('/scan'),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Px.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Px.line),
                        ),
                        child: TextField(
                          controller: _sku,
                          decoration: const InputDecoration(
                            hintText: 'SKU or barcode',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addSku(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _addSku,
                        style: FilledButton.styleFrom(
                          backgroundColor: Px.accent,
                          foregroundColor: Px.accentInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (state.bill.lines.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Text(
                          'Open bill',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (var i = 0; i < state.bill.lines.length; i++)
                        ShopListTile(
                          title: state.bill.lines[i].variant.label,
                          subtitle:
                              '${state.bill.lines[i].quantity} × ${state.bill.lines[i].unitPrice.toStringAsFixed(2)} · tap price',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => state.setBillQuantity(i, state.bill.lines[i].quantity - 1),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              Text('${state.bill.lines[i].quantity}'),
                              IconButton(
                                onPressed: () => state.setBillQuantity(i, state.bill.lines[i].quantity + 1),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final next = await _askAmount(context, 'Unit price', state.bill.lines[i].unitPrice);
                            if (next != null) state.setBillPrice(i, next);
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            for (final method in const ['CASH', 'UPI', 'CARD'])
                              ChoiceChip(
                                label: Text(method),
                                selected: state.bill.method == method,
                                onSelected: (_) => state.setBillMethod(method),
                              ),
                          ],
                        ),
                      ),
                      if (state.customers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: state.bill.customerId,
                            hint: const Text('Walk-in'),
                            items: [
                              const DropdownMenuItem<String?>(value: null, child: Text('Walk-in')),
                              for (final customer in state.customers)
                                DropdownMenuItem(value: customer.id, child: Text(customer.name)),
                            ],
                            onChanged: (id) {
                              CachedCustomer? picked;
                              for (final customer in state.customers) {
                                if (customer.id == id) picked = customer;
                              }
                              state.setBillCustomer(picked);
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Discount'),
                          onSubmitted: (value) => state.setBillDiscount(double.tryParse(value) ?? 0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: FilledButton(
                          onPressed: _checkout,
                          child: Text(
                            state.online
                                ? 'Take ${state.bill.method} · ${state.bill.total.toStringAsFixed(2)}'
                                : 'Queue bill · ${state.bill.total.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ],
                    if (state.sales.isEmpty && state.bill.lines.isEmpty)
                      const ShopEmpty(
                        title: 'No sales yet',
                        subtitle: 'Scan a code to sell, or type a SKU',
                        icon: Icons.receipt_long_outlined,
                      )
                    else
                      for (final sale in state.sales)
                        ShopListTile(
                          title: sale.invoiceNumber,
                          subtitle: sale.status ?? 'Sale',
                          trailing: Text(sale.total.toStringAsFixed(2)),
                          onTap: () => _openSale(state, sale),
                          onLongPress: () async {
                            final error = await state.voidSale(sale.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error ?? 'Sale voided')),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
