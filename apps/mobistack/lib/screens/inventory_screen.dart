import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
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
    final items = state.searchVariants(_query.text);

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
                    onPressed: () => context.push('/scan'),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ],
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
                            ? 'Pull home to sync, or scan a barcode'
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
