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
    final orgs = state.me?.organizations ?? const [];
    final shop = orgs.isNotEmpty && orgs.first.name.isNotEmpty
        ? orgs.first.name
        : (state.me?.displayName ?? 'Shop floor');

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
                                    Icon(Icons.payments_rounded,
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
                                          Text(
                                            'Inventory, sales, and repairs unlock after you pick a plan.',
                                            style: TextStyle(color: Px.ink),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
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
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Text(
                          'Today on the floor',
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Px.ink,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            _FloorStat(
                              label: 'Sales',
                              value: d.todaySales.toStringAsFixed(0),
                              tone: KpiTone.accent,
                            ),
                            _FloorStat(
                              label: 'Tickets',
                              value: '${d.todayTransactions}',
                            ),
                            _FloorStat(
                              label: 'Repairs',
                              value: '${d.pendingRepairs}',
                              tone: KpiTone.warning,
                            ),
                            _FloorStat(
                              label: 'Low',
                              value: '${d.lowStockCount}',
                              tone: d.lowStockCount > 0
                                  ? KpiTone.danger
                                  : KpiTone.success,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
                            style: TextStyle(
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

class _FloorStat extends StatelessWidget {
  const _FloorStat({
    required this.label,
    required this.value,
    this.tone = KpiTone.neutral,
  });

  final String label;
  final String value;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      KpiTone.accent => Px.accent,
      KpiTone.warning => Px.warning,
      KpiTone.danger => Px.danger,
      KpiTone.success => Px.success,
      KpiTone.neutral => Px.focus,
    };
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Px.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Px.line),
            boxShadow: Px.lift,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.fraunces(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Px.ink,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Px.muted,
                        letterSpacing: 0.6,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
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
        color: accent ? Px.bgAccent : Px.surface,
        elevation: Px.isDark ? 0 : 1,
        shadowColor: const Color(0x33087A6E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Px.line),
        ),
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
                Icon(Icons.arrow_forward_ios_rounded,
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
