import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  Future<void> _quickSale() async {
    final state = context.read<AppState>();
    final matches = state.searchVariants(_sku.text);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching SKU in cached stock')),
      );
      return;
    }
    final v = matches.first;
    await state.enqueueSale({
      'variantId': v.id,
      'sku': v.sku,
      'qty': 1,
      'unitPrice': v.retailPrice,
    });
    _sku.clear();
    if (!mounted) return;
    final msg = state.online
        ? 'Sale synced'
        : 'Sale queued — will sync when online';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                          onSubmitted: (_) => _quickSale(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _quickSale,
                        style: FilledButton.styleFrom(
                          backgroundColor: Px.accent,
                          foregroundColor: Px.accentInk,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.sell_rounded),
                        label: Text(state.online ? 'Sell' : 'Queue'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.sales.isEmpty
                    ? const ShopEmpty(
                        title: 'No sales yet',
                        subtitle:
                            'Scan or type a SKU — offline sales wait in the outbox',
                        icon: Icons.receipt_long_outlined,
                      )
                    : RefreshIndicator(
                        color: Px.accent,
                        onRefresh: () => state.refreshAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: state.sales.length,
                          itemBuilder: (context, i) {
                            final s = state.sales[i];
                            return ShopListTile(
                              title: s.invoiceNumber,
                              subtitle: s.status ?? 'Sale',
                              trailing: Text(
                                s.total.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Px.accent,
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
