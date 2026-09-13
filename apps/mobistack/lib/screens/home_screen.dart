import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final d = state.dashboard;
    final shop = state.me?.displayName ?? 'Shop floor';

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              Expanded(
                child: RefreshIndicator(
                  color: Px.accent,
                  onRefresh: () => state.refreshAll(),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 28),
                    children: [
                      ShopHeroHeader(
                        title: 'MobiStack',
                        subtitle: state.online
                            ? shop
                            : 'Offline · last good snapshot',
                        actions: [
                          IconButton(
                            tooltip: state.online ? 'Sync now' : 'Offline',
                            onPressed:
                                state.busy ? null : () => state.refreshAll(),
                            icon: Icon(
                              state.online
                                  ? Icons.cloud_sync_rounded
                                  : Icons.cloud_off_rounded,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Scan',
                            onPressed: () => context.push('/scan'),
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                          ),
                        ],
                      ),
                      if (state.me?.paymentRequired == true)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Material(
                            color: Px.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => context.push('/billing'),
                              child: const Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.credit_card_rounded,
                                        color: Px.danger),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Payment required — choose a plan to unlock shop features.',
                                        style: TextStyle(color: Px.danger),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        color: Px.danger),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Text(
                          'Today',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.35,
                          children: [
                            FadeSlide(
                              child: KpiTile(
                                label: 'Sales',
                                value: d.todaySales.toStringAsFixed(0),
                                tone: KpiTone.accent,
                              ),
                            ),
                            FadeSlide(
                              delay: 40.ms,
                              child: KpiTile(
                                label: 'Tickets',
                                value: '${d.todayTransactions}',
                                tone: KpiTone.neutral,
                              ),
                            ),
                            FadeSlide(
                              delay: 80.ms,
                              child: KpiTile(
                                label: 'Repairs',
                                value: '${d.pendingRepairs}',
                                tone: KpiTone.warning,
                              ),
                            ),
                            FadeSlide(
                              delay: 120.ms,
                              child: KpiTile(
                                label: 'Low stock',
                                value: '${d.lowStockCount}',
                                tone: d.lowStockCount > 0
                                    ? KpiTone.danger
                                    : KpiTone.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                        child: Text(
                          'Quick actions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            QuickActionChip(
                              label: 'Scan barcode',
                              icon: Icons.qr_code_scanner_rounded,
                              onTap: () => context.push('/scan'),
                            ),
                            if (state.hasFeature('COMPATIBILITY'))
                              QuickActionChip(
                                label: 'Compatibility',
                                icon: Icons.phone_android_rounded,
                                onTap: () => context.push('/compatibility'),
                              ),
                            if (state.hasFeature('SALES'))
                              QuickActionChip(
                                label: 'New sale',
                                icon: Icons.point_of_sale_rounded,
                                onTap: () => context.go('/sales'),
                              ),
                            if (state.pendingOps > 0)
                              QuickActionChip(
                                label: 'Flush ${state.pendingOps}',
                                icon: Icons.upload_rounded,
                                onTap: () => state.refreshAll(),
                              ),
                          ],
                        ),
                      ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Text(
                            state.error!,
                            style: const TextStyle(color: Px.muted, fontSize: 13),
                          ),
                        ),
                    ],
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
