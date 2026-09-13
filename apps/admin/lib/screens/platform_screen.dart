import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import 'commerce_ops.dart';

/// Staff control plane: oneOps hub + MobiStack commerce + ops tooling.
class PlatformScreen extends StatefulWidget {
  const PlatformScreen({super.key});

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Atmosphere(
        child: IndexedStack(
          index: tab,
          children: [
            _OverviewTab(state: state),
            _TenantsTab(state: state),
            _PipelineTab(state: state),
            CommercePane(state: state),
            OpsMorePane(state: state),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        backgroundColor: Px.surface.withValues(alpha: 0.94),
        indicatorColor: Px.bgAccent,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_rounded),
            label: 'Tenants',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_rounded),
            label: 'Pipeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_rounded),
            label: 'Commerce',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, top + 12, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: FadeSlide(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(compact: true),
                  const SizedBox(height: 18),
                  Text(title, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: (state.hubLoading || state.commerceLoading)
                ? null
                : () => state.refreshAll(),
            icon: (state.hubLoading || state.commerceLoading)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: state.busy ? null : () => state.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final o = state.overview;
    final rev = state.revenue;
    return RefreshIndicator(
      color: Px.accent,
      onRefresh: () => state.refreshAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _HubHeader(
            title: 'Control',
            subtitle: state.me?.email ?? 'Platform control tower',
            state: state,
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(state.error!, style: const TextStyle(color: Px.danger)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text('ONEOPS TENANTS', style: _sectionLabel(context)),
          ),
          _MetricRow(values: [
            ('Total', '${o?.tenants.total ?? '—'}'),
            ('Active', '${o?.tenants.active ?? '—'}'),
            ('Trial', '${o?.tenants.trial ?? '—'}'),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('MOBISTACK REVENUE', style: _sectionLabel(context)),
          ),
          _MetricRow(values: [
            ('Received', '₹${rev.capturedTotal.toStringAsFixed(0)}'),
            ('Pending', '₹${rev.pendingTotal.toStringAsFixed(0)}'),
            ('Shops', '${state.activeShops}'),
          ]),
          if (state.commerceAuthError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(state.commerceAuthError!, style: const TextStyle(color: Px.danger)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('ONEOPS SAAS · AWS', style: _sectionLabel(context)),
          ),
          _MetricRow(values: [
            ('oneOps ₹', '₹${state.oneopsRevenue.capturedTotal.toStringAsFixed(0)}'),
            ('AWS \$', '\$${(state.awsSummary?.mtdUsd ?? 0).toStringAsFixed(0)}'),
            ('EC2', '${state.awsSummary?.running ?? '—'}'),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('ACCOUNTS', style: _sectionLabel(context)),
          ),
          _MetricRow(values: [
            ('Total', '${o?.accounts.total ?? '—'}'),
            ('Admins', '${o?.accounts.platformAdmins ?? '—'}'),
            ('Locked', '${o?.accounts.lockedOut ?? '—'}'),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('QUEUES & ACTIVITY', style: _sectionLabel(context)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Mail pending',
                    value: o?.queues.mailPending,
                    hot: (o?.queues.mailPending ?? 0) > 0,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBlock(
                    label: 'Mail failed',
                    value: o?.queues.mailFailed,
                    hot: (o?.queues.mailFailed ?? 0) > 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Active sessions',
                    value: o?.queues.activeSessions,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBlock(
                    label: 'Errors 24h',
                    value: o?.activity.errorsLast24h,
                    hot: (o?.activity.errorsLast24h ?? 0) > 0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Text(
              'Commerce tab manages MobiStack shops and payments. '
              'More → Infra covers APK distribution and AWS boundaries.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantsTab extends StatelessWidget {
  const _TenantsTab({required this.state});
  final AppState state;

  static const filters = <(String?, String)>[
    (null, 'All'),
    ('ACTIVE', 'Active'),
    ('TRIAL', 'Trial'),
    ('SUSPENDED', 'Suspended'),
    ('CANCELLED', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Px.accent,
      onRefresh: () => state.refreshHub(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ignore: prefer_const_constructors
          SliverToBoxAdapter(
            child: _HubHeader(
              title: 'Tenants',
              subtitle: '${state.tenants.length} loaded',
              state: state,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (value, label) = filters[i];
                  final selected = state.tenantStatusFilter == value;
                  return GestureDetector(
                    onTap: () => state.refreshHub(
                      tenantStatus: value,
                      updateTenantFilter: true,
                    ),
                    child: AnimatedContainer(
                      duration: 220.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Px.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: selected ? Px.ink : Px.line),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? Px.accentInk : Px.muted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (state.tenants.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No tenants for this filter.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList.separated(
                itemCount: state.tenants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final t = state.tenants[index];
                  return _TenantTile(tenant: t);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TenantTile extends StatelessWidget {
  const _TenantTile({required this.tenant});
  final TenantSummary tenant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Px.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Px.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tenant.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  [
                    if (tenant.slug != null) tenant.slug!,
                    if (tenant.memberCount != null) '${tenant.memberCount}/${tenant.seatLimit ?? '—'} seats',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (tenant.status != null) StatusPill(status: tenant.status!),
        ],
      ),
    );
  }
}

class _PipelineTab extends StatelessWidget {
  const _PipelineTab({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Px.accent,
      onRefresh: () => state.refreshHub(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _HubHeader(
            title: 'Pipeline',
            subtitle: 'Leads · subscribers · applications',
            state: state,
          ),
          _PipelineSection(
            title: 'Leads',
            count: state.leads.length,
            children: state.leads
                .map(
                  (l) => _ActionRow(
                    title: l.name,
                    subtitle: [l.email, l.company, l.status].whereType<String>().join(' · '),
                    trailing: l.status,
                    actions: const [
                      'NEW',
                      'CONTACTED',
                      'QUALIFIED',
                      'DEMO_BOOKED',
                      'WON',
                      'LOST',
                    ],
                    onAction: (s) => state.updateLeadStatus(l, s),
                  ),
                )
                .toList(),
          ),
          _PipelineSection(
            title: 'Subscribers',
            count: state.subscribers.length,
            children: state.subscribers
                .map(
                  (s) => _ActionRow(
                    title: s.email,
                    subtitle: [s.status, s.createdAt].whereType<String>().join(' · '),
                    trailing: s.status,
                  ),
                )
                .toList(),
          ),
          _PipelineSection(
            title: 'Applications',
            count: state.applications.length,
            children: state.applications
                .map(
                  (a) => _ActionRow(
                    title: a.name,
                    subtitle: [a.email, a.status].whereType<String>().join(' · '),
                    trailing: a.status,
                    actions: const [
                      'RECEIVED',
                      'SCREENING',
                      'INTERVIEWING',
                      'OFFERED',
                      'HIRED',
                      'REJECTED',
                    ],
                    onAction: (s) => state.updateApplicationStatus(a, s),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PipelineSection extends StatelessWidget {
  const _PipelineSection({
    required this.title,
    required this.count,
    required this.children,
  });

  final String title;
  final int count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title · $count', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (children.isEmpty)
            Text('Nothing here yet.', style: Theme.of(context).textTheme.bodySmall)
          else
            ...children.map(
              (c) => Padding(padding: const EdgeInsets.only(bottom: 8), child: c),
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.actions = const [],
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? trailing;
  final List<String> actions;
  final ValueChanged<String>? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Px.line),
        color: Px.surface.withValues(alpha: 0.82),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.titleSmall),
              ),
              if (trailing != null) StatusPill(status: trailing!),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
          if (onAction != null && actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: actions
                  .map(
                    (a) => ActionChip(
                      label: Text(a, style: const TextStyle(fontSize: 11)),
                      onPressed: () => onAction!(a),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.values});
  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Px.line.withValues(alpha: 0.95)),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1, color: Px.line),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        values[i].$2,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        values[i].$1.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Px.faint,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, this.value, this.hot = false});
  final String label;
  final int? value;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Px.line),
        color: hot ? Px.bgAccent.withValues(alpha: 0.55) : Px.surface.withValues(alpha: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            '${value ?? '—'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: hot ? Px.accentStrong : Px.ink,
                ),
          ),
        ],
      ),
    );
  }
}

TextStyle? _sectionLabel(BuildContext context) =>
    Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Px.muted,
          letterSpacing: 1.4,
          fontSize: 11,
        );
