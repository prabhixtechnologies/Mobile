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
  String? _payingPlan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    final cached = await state.sync.readJson('cache.billing');
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        _overview = BillingOverview.fromJson(cached);
        _loading = false;
        _error = null;
      });
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    if (!state.online) {
      setState(() {
        _loading = false;
        _error = _overview == null ? 'Offline · billing is not saved on this phone yet' : null;
      });
      return;
    }
    try {
      final res = await state.api.dio.get<dynamic>('billing');
      if (res.data is! Map) {
        throw StateError('Billing response was empty');
      }
      final map = Map<String, dynamic>.from(res.data as Map);
      await state.sync.saveJson('cache.billing', map);
      if (!mounted) return;
      setState(() {
        _overview = BillingOverview.fromJson(map);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _overview == null ? describeError(e) : null;
        _loading = false;
      });
    }
  }

  Future<void> _startPay(String planCode, String planName) async {
    final app = context.read<AppState>();
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
      _payingPlan = planName;
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
        _notice = '${_payingPlan ?? 'The plan'} is active on this shop.';
        _busy = false;
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeError(e);
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
        _notice =
            'Paid ${formatPaise(order.amount)}. ${_payingPlan ?? 'The plan'} is active — paying again extends the end date.';
        _busy = false;
      });
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeError(e);
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final me = state.me;
    final overview = _overview;
    final sub = overview?.subscription;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Billing is a tab for an unpaid shop; there is nothing under it to go back to.
          automaticallyImplyLeading: false,
          leading: context.canPop()
              ? IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                )
              : null,
          title: Text(
            'Billing',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh billing',
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
                onError: (message) => setState(() {
                  _pay = null;
                  _error = message;
                }),
                onPaid: _onPaid,
              )
            : _loading
                ? Center(child: CircularProgressIndicator(color: Px.accent))
                : RefreshIndicator(
                    color: Px.accent,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        if (me?.paymentRequired == true)
                          _Banner(
                            tone: Px.warning,
                            text: sub == null
                                ? 'This shop has no active plan yet.'
                                : '${sub.planName ?? sub.planCode ?? 'Plan'} ended ${_formatDay(sub.periodEnd)}. Renew or choose another plan below.',
                          ),
                        if (_error != null)
                          _Banner(tone: Px.danger, text: _error!),
                        if (_notice != null)
                          _Banner(tone: Px.success, text: _notice!),
                        if (overview?.razorpayEnabled == false)
                          _Banner(
                            tone: Px.focus,
                            text:
                                'Online payment is not switched on yet. Write to Support and we will activate your plan.',
                          ),
                        if (sub != null) ...[
                          _SectionTitle('Current plan'),
                          _PlanCard(
                            title: sub.planName ?? sub.planCode ?? 'Plan',
                            subtitle: [
                              if (sub.status != null) _statusLabel(sub.status!),
                              if (sub.periodEnd != null)
                                sub.status == 'ACTIVE'
                                    ? 'paid until ${_formatDay(sub.periodEnd)}'
                                    : 'ended ${_formatDay(sub.periodEnd)}',
                              'Pay again while active to add another month from that date.',
                            ].join('\n'),
                            trailing: null,
                          ),
                        ],
                        _SectionTitle('Plans'),
                        if ((overview?.plans ?? []).isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'No sellable plans returned. Check billing API / permissions.',
                              style: TextStyle(color: Px.muted),
                            ),
                          ),
                        for (final plan in (overview?.plans ?? const <BillingPlan>[]))
                          _PlanCard(
                            title: plan.name,
                            subtitle: [
                              if ((plan.description ?? '').isNotEmpty) plan.description!,
                              '${formatInr(plan.amount)} / ${(plan.interval ?? 'MONTHLY').toLowerCase()}',
                              if (_isRecordedPlan(sub, plan.code) && sub?.periodEnd != null)
                                sub!.status == 'ACTIVE'
                                    ? 'Verified until ${_formatDay(sub.periodEnd)}'
                                    : 'Last verified until ${_formatDay(sub.periodEnd)}',
                            ].join('\n'),
                            trailing: FilledButton(
                              onPressed: _busy
                                  ? null
                                  : () => _startPay(plan.code, plan.name),
                              style: FilledButton.styleFrom(
                                backgroundColor: Px.accent,
                                foregroundColor: Px.accentInk,
                              ),
                              child: Text(_actionLabel(sub, plan.code)),
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
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: CircularProgressIndicator(color: Px.accent),
                            ),
                          ),
                        // Catalog-only and unpaid docks have no Home; keep sign-out reachable here too.
                        if (state.catalogOnlyMode || state.unpaidShop) ...[
                          _SectionTitle('Account'),
                          _PlanCard(
                            title: me?.displayName ?? 'Signed in',
                            subtitle: me?.email ?? '',
                            trailing: OutlinedButton(
                              onPressed: state.busy ? null : () => state.signOut(),
                              child: const Text('Sign out'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}

bool _isRecordedPlan(BillingSubscription? sub, String code) =>
    sub != null && sub.planCode == code;

String _actionLabel(BillingSubscription? sub, String code) {
  if (_isRecordedPlan(sub, code)) {
    return 'Renew';
  }
  if (sub?.status == 'ACTIVE') {
    return 'Switch';
  }
  return 'Activate';
}

String _statusLabel(String status) {
  switch (status) {
    case 'ACTIVE':
      return 'Active';
    case 'PAST_DUE':
      return 'Ended';
    default:
      return status;
  }
}

String _formatDay(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final parsed = DateTime.tryParse(iso)?.toLocal();
  if (parsed == null) {
    return iso.length >= 10 ? iso.substring(0, 10) : iso;
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
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
