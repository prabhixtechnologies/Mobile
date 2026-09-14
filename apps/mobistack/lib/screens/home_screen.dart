import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    padding: const EdgeInsets.only(bottom: 32),
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
                            color: Px.warning.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => context.push('/billing'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.payments_rounded,
                                        color: Px.warning),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Activate shop with Razorpay',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: Px.warning,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Inventory, sales, and repairs unlock after you pick a plan.',
                                            style: TextStyle(color: Px.ink),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Px.warning),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Always offer billing entry even when already paid (manage seats).
                      if (state.me?.paymentRequired != true)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => context.push('/billing'),
                              icon: const Icon(Icons.credit_card_rounded),
                              label: Text(
                                state.me?.planName ?? 'Manage billing',
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                        child: Text(
                          'Today on the floor',
                          style: GoogleFonts.fraunces(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Px.ink,
                          ),
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
                          childAspectRatio: 1.32,
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
                        padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                        child: Text(
                          'Floor modules',
                          style: GoogleFonts.fraunces(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Px.ink,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            if (state.hasFeature('INVENTORY'))
                              _ModuleRow(
                                icon: Icons.inventory_2_rounded,
                                title: 'Stock',
                                subtitle: '${state.variants.length} variants',
                                onTap: () => context.go('/inventory'),
                              ),
                            if (state.hasFeature('SALES'))
                              _ModuleRow(
                                icon: Icons.point_of_sale_rounded,
                                title: 'Sales',
                                subtitle: state.online
                                    ? 'Ring up · sync live'
                                    : 'Queue sales offline',
                                onTap: () => context.go('/sales'),
                              ),
                            if (state.hasFeature('REPAIRS'))
                              _ModuleRow(
                                icon: Icons.build_rounded,
                                title: 'Repairs',
                                subtitle: '${state.repairs.length} open jobs',
                                onTap: () => context.go('/repairs'),
                              ),
                            _ModuleRow(
                              icon: Icons.phone_android_rounded,
                              title: 'Fitment Catalog',
                              subtitle: 'Shared phones · see what fits',
                              onTap: () => context.go('/commons'),
                              accent: true,
                            ),
                            _ModuleRow(
                              icon: Icons.qr_code_scanner_rounded,
                              title: 'Scan barcode',
                              subtitle: 'Lookup SKU on the counter',
                              onTap: () => context.push('/scan'),
                            ),
                          ],
                        ),
                      ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Text(
                            state.error!,
                            style: const TextStyle(
                              color: Px.muted,
                              fontSize: 13,
                            ),
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

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: accent
            ? Px.accent.withValues(alpha: 0.1)
            : Px.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent
                        ? Px.accent
                        : Px.focus.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: accent ? Px.accentInk : Px.focus,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Px.faint),
              ],
            ),
          ),
        ),
      ),
    );
    if (skipMotionForTests) return tile;
    return tile.animate().fadeIn(duration: 320.ms).moveY(begin: 8, end: 0);
  }
}
