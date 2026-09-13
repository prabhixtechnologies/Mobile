import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/pay_sheet.dart';

/// Live MobiStack billing — plans, Razorpay checkout, refresh entitlements.
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  BillingOverview? _overview;
  String? _error;
  String? _notice;
  bool _loading = true;
  bool _busy = false;
  CheckoutOrder? _pay;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final overview = await context.read<AppState>().api.billingOverview();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _startPay(String planCode) async {
    final app = context.read<AppState>();
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      final order = await app.api.createBillingOrder(planCode);
      if (!mounted) return;
      if (order.needsRazorpay) {
        setState(() {
          _pay = order;
          _busy = false;
        });
        return;
      }
      await app.api.confirmBillingOrder(order.id);
      await app.refreshMe();
      if (!mounted) return;
      setState(() {
        _notice = 'Plan is active on this shop.';
        _busy = false;
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _busy = false;
      });
    }
  }

  Future<void> _onPaid(RazorpaySlip slip) async {
    final app = context.read<AppState>();
    final order = _pay;
    setState(() => _pay = null);
    if (order == null) return;
    setState(() => _busy = true);
    try {
      await app.api.verifyBillingPayment(slip);
      await app.refreshMe();
      if (!mounted) return;
      setState(() {
        _notice = 'Paid ${formatPaise(order.amount)}. Shop features unlocked.';
        _busy = false;
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.me;
    final overview = _overview;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Billing',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: _pay != null
            ? PaySheet(
                order: _pay!,
                description: 'MobiStack shop plan',
                onCancel: () => setState(() => _pay = null),
                onPaid: _onPaid,
              )
            : _loading
                ? const Center(child: CircularProgressIndicator(color: Px.accent))
                : RefreshIndicator(
                    color: Px.accent,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        if (me?.paymentRequired == true)
                          _Banner(
                            tone: Px.warning,
                            text:
                                'This shop needs an active plan. Pay below to unlock inventory, sales, and repairs.',
                          ),
                        if (_error != null)
                          _Banner(tone: Px.danger, text: _error!),
                        if (_notice != null)
                          _Banner(tone: Px.success, text: _notice!),
                        if (overview?.razorpayEnabled == false)
                          _Banner(
                            tone: Px.focus,
                            text:
                                'Razorpay is not configured on the server yet — DEV confirm may still activate a plan.',
                          ),
                        if (overview?.subscription != null) ...[
                          _SectionTitle('Current plan'),
                          _PlanCard(
                            title: overview!.subscription!.planName ??
                                overview.subscription!.planCode ??
                                'Plan',
                            subtitle: [
                              if (overview.subscription!.status != null)
                                overview.subscription!.status!,
                              if (overview.subscription!.periodEnd != null)
                                'until ${overview.subscription!.periodEnd!.substring(0, overview.subscription!.periodEnd!.length.clamp(0, 10))}',
                            ].join(' · '),
                            trailing: null,
                          ),
                        ],
                        if (overview?.screens != null) ...[
                          _SectionTitle('Screens'),
                          _PlanCard(
                            title: 'Device seats',
                            subtitle:
                                '${overview!.screens!.inUse} in use · ${overview.screens!.seats} seats · ${overview.screens!.extra} extra',
                            trailing: FilledButton(
                              onPressed:
                                  _busy ? null : () => _startPay('EXTRA_SCREEN'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Px.accent,
                                foregroundColor: Px.accentInk,
                              ),
                              child: const Text('Add screen'),
                            ),
                          ),
                        ],
                        _SectionTitle('Plans'),
                        if ((overview?.plans ?? []).isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text(
                              'No sellable plans returned. Check billing API / permissions.',
                              style: TextStyle(color: Px.muted),
                            ),
                          ),
                        for (final plan in overview?.plans ?? const <BillingPlan>[])
                          _PlanCard(
                            title: plan.name,
                            subtitle:
                                '${plan.description ?? ''}\n${formatInr(plan.amount)} / ${(plan.interval ?? 'MONTHLY').toLowerCase()}',
                            trailing: FilledButton(
                              onPressed: _busy || me?.planCode == plan.code
                                  ? null
                                  : () => _startPay(plan.code),
                              style: FilledButton.styleFrom(
                                backgroundColor: Px.accent,
                                foregroundColor: Px.accentInk,
                              ),
                              child: Text(
                                me?.planCode == plan.code
                                    ? 'Current'
                                    : 'Activate',
                              ),
                            ),
                          ),
                        if ((overview?.recentPayments ?? []).isNotEmpty) ...[
                          _SectionTitle('Recent payments'),
                          for (final p in overview!.recentPayments)
                            _PlanCard(
                              title: p.planName ?? 'Payment',
                              subtitle:
                                  '${p.status ?? ''} · ${formatInr(p.amount)}',
                              trailing: null,
                            ),
                        ],
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Center(
                              child: CircularProgressIndicator(color: Px.accent),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Text(
        label,
        style: GoogleFonts.fraunces(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Px.ink,
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.tone, required this.text});
  final Color tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: TextStyle(color: tone, height: 1.35)),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Px.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ],
      ),
    );
  }
}
