import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// MobiStack revenue, shops, plans, flags — live against mobistack admin APIs.
class CommercePane extends StatefulWidget {
  const CommercePane({super.key, required this.state});

  final AppState state;

  @override
  State<CommercePane> createState() => _CommercePaneState();
}

class _CommercePaneState extends State<CommercePane> {
  int section = 0;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return RefreshIndicator(
      color: Px.accent,
      onRefresh: state.refreshCommerce,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _PaneHeader(
            title: 'Commerce',
            subtitle: 'MobiStack revenue · shops · plans',
            loading: state.commerceLoading,
            onRefresh: state.refreshCommerce,
            onSignOut: state.signOut,
            busy: state.busy,
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(state.error!, style: const TextStyle(color: Px.danger, fontSize: 13)),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text('REVENUE', style: _label(context)),
          ),
          _MetricRow(values: [
            ('Received', _inr.format(state.revenue.capturedTotal)),
            ('Pending', _inr.format(state.revenue.pendingTotal)),
            ('Shops', '${state.activeShops}/${state.workspaces.length}'),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatBlock(
                    label: 'Captured',
                    value: '${state.revenue.capturedCount}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBlock(
                    label: 'Open / other',
                    value: '${state.revenue.pendingCount}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatBlock(
                    label: 'Failed',
                    value: '${state.revenue.failedCount}',
                    hot: state.revenue.failedCount > 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SegmentBar(
            labels: const ['Payments', 'Shops', 'Plans', 'Flags'],
            index: section,
            onChanged: (i) => setState(() => section = i),
          ),
          const SizedBox(height: 12),
          if (section == 0) _PaymentsList(state: state),
          if (section == 1) _ShopsList(state: state),
          if (section == 2) _PlansList(state: state),
          if (section == 3) _FlagsList(state: state),
        ],
      ),
    );
  }
}

class OpsMorePane extends StatefulWidget {
  const OpsMorePane({super.key, required this.state});

  final AppState state;

  @override
  State<OpsMorePane> createState() => _OpsMorePaneState();
}

class _OpsMorePaneState extends State<OpsMorePane> {
  int section = 0;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return RefreshIndicator(
      color: Px.accent,
      onRefresh: state.refreshAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _PaneHeader(
            title: 'Operations',
            subtitle: 'Logs · live · support · staff · infra',
            loading: state.hubLoading || state.commerceLoading,
            onRefresh: state.refreshAll,
            onSignOut: state.signOut,
            busy: state.busy,
          ),
          const SizedBox(height: 12),
          _SegmentBar(
            labels: const ['Logs', 'Live', 'Support', 'Staff', 'Infra'],
            index: section,
            onChanged: (i) => setState(() => section = i),
          ),
          const SizedBox(height: 12),
          if (section == 0) _LogsBody(state: state),
          if (section == 1) _LiveBody(state: state),
          if (section == 2) _SupportBody(state: state),
          if (section == 3) _StaffBody(state: state),
          if (section == 4) const _InfraBody(),
        ],
      ),
    );
  }
}

class _PaneHeader extends StatelessWidget {
  const _PaneHeader({
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onRefresh,
    required this.onSignOut,
    required this.busy,
  });

  final String title;
  final String subtitle;
  final bool loading;
  final Future<void> Function() onRefresh;
  final VoidCallback onSignOut;
  final bool busy;

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
            onPressed: loading ? null : () => onRefresh(),
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: busy ? null : onSignOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }
}

class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = index == i;
          return GestureDetector(
            onTap: () => onChanged(i),
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
                labels[i],
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
    );
  }
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.payments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No platform payments yet.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final p in state.payments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: p.shopName ?? 'Shop',
                subtitle: [
                  if (p.priceCode != null) p.priceCode!.replaceAll('_', ' '),
                  p.paidAt ?? p.createdAt,
                  if (p.gateway != null) p.gateway!,
                ].join(' · '),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_inr.format(p.amount), style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    StatusPill(status: p.status),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopsList extends StatelessWidget {
  const _ShopsList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.workspaces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No shops yet.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final w in state.workspaces)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: w.name,
                subtitle: [
                  if (w.city != null && w.city!.isNotEmpty) w.city!,
                  '${w.members} members',
                  if (w.extraScreens > 0) '+${w.extraScreens} screens',
                ].join(' · '),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusPill(status: w.active ? 'ACTIVE' : 'SUSPENDED'),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: w.active ? 'Suspend' : 'Activate',
                      onPressed: () => state.toggleWorkspace(w),
                      icon: Icon(
                        w.active ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        color: w.active ? Px.warning : Px.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlansList extends StatelessWidget {
  const _PlansList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final rows = state.plans;
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No plans configured.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final p in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: '${p.name} · ${_inr.format(p.amount)}',
                subtitle: '${p.code} · ${p.interval} · ${p.features.join(', ').toLowerCase()}',
                trailing: StatusPill(status: p.active ? 'ON' : 'OFF'),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlagsList extends StatelessWidget {
  const _FlagsList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.featureFlags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No feature flags.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final f in state.featureFlags)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: f.code,
                subtitle: f.enabled ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: f.enabled,
                  onChanged: (_) => state.toggleFeatureFlag(f),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LogsBody extends StatelessWidget {
  const _LogsBody({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.eventLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No recent events.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final e in state.eventLogs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: e.message,
                subtitle: [e.createdAt, e.correlationId].whereType<String>().join(' · '),
                trailing: e.level == null ? null : StatusPill(status: e.level!),
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveBody extends StatelessWidget {
  const _LiveBody({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.liveUsers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No live MobiStack sessions.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final u in state.liveUsers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: u.fullName.isEmpty ? u.email : u.fullName,
                subtitle: [
                  if (u.shopName != null) u.shopName!,
                  u.platform,
                  if (u.appVersion != null) u.appVersion!,
                  u.seenAt,
                ].join(' · '),
              ),
            ),
        ],
      ),
    );
  }
}

class _SupportBody extends StatelessWidget {
  const _SupportBody({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    if (state.supportTickets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No support conversations.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (final t in state.supportTickets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(
                title: t.subject,
                subtitle: [
                  if (t.userName != null) t.userName!,
                  t.status,
                  t.lastMessageAt,
                ].join(' · '),
                trailing: t.status.toUpperCase() == 'OPEN'
                    ? TextButton(
                        onPressed: () => state.resolveTicket(t),
                        child: const Text('Resolve'),
                      )
                    : StatusPill(status: t.status),
              ),
            ),
        ],
      ),
    );
  }
}

class _StaffBody extends StatelessWidget {
  const _StaffBody({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your roles', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (state.staffRoles.isEmpty)
            Text(
              'No staff roles returned (ROLE_ADMIN may be required to list grants).',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.staffRoles
                  .map((r) => StatusPill(status: r))
                  .toList(),
            ),
          const SizedBox(height: 20),
          Text('Grants', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (state.staffGrants.isEmpty)
            Text('No grants loaded.', style: Theme.of(context).textTheme.bodySmall)
          else
            for (final g in state.staffGrants)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Tile(
                  title: g.role,
                  subtitle: [
                    g.userId,
                    if (g.note != null && g.note!.isNotEmpty) g.note!,
                    if (g.grantedAt != null) g.grantedAt!,
                  ].join(' · '),
                ),
              ),
          const SizedBox(height: 12),
          Text(
            'Break-glass token revocation stays on the web console — '
            'it requires a typed reason and BREAK_GLASS role.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfraBody extends StatelessWidget {
  const _InfraBody();

  static const stores = [
    ('MobiStack APK', 'https://store.prabhixtechnologies.com/mobistack/android.apk'),
    ('Mailroom APK', 'https://store.prabhixtechnologies.com/mailroom/android.apk'),
    ('OneOps APK', 'https://store.prabhixtechnologies.com/oneops/android.apk'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final aws = state.awsSummary;
        final pnl = state.pnl;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.infraError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(state.infraError!, style: const TextStyle(color: Px.danger, fontSize: 13)),
                ),
              Text('P&L strip', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _MetricRow(values: [
                ('Mobi ₹', _inr.format(state.revenue.capturedTotal)),
                ('oneOps ₹', _inr.format(state.oneopsRevenue.capturedTotal)),
                ('AWS \$', (aws?.mtdUsd ?? pnl?.awsMtd ?? 0).toStringAsFixed(2)),
              ]),
              if (pnl != null) ...[
                const SizedBox(height: 8),
                _Tile(
                  title: 'Contribution (revenue − AWS MTD)',
                  subtitle:
                      'Note: revenue INR vs AWS USD — compare carefully. ${pnl.note ?? ''}',
                  trailing: Text(
                    pnl.contribution.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text('AWS fleet', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Tile(
                title: 'Region ap-south-1',
                subtitle:
                    'Running ${aws?.running ?? '—'} · stopped ${aws?.stopped ?? '—'} · '
                    'MTD \$${aws?.mtdUsd.toStringAsFixed(2) ?? '—'}',
              ),
              const SizedBox(height: 8),
              if (state.ec2Instances.isEmpty)
                Text('No EC2 rows (or Ops Tool unreachable).', style: Theme.of(context).textTheme.bodySmall)
              else
                for (final i in state.ec2Instances.take(20))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _Tile(
                      title: i.name?.isNotEmpty == true ? i.name! : i.id,
                      subtitle: [
                        i.id,
                        i.instanceType,
                        i.state,
                        i.az,
                        if (i.cpuPercent != null) 'CPU ${i.cpuPercent}%',
                      ].whereType<String>().join(' · '),
                      trailing: StatusPill(status: i.state.toUpperCase()),
                    ),
                  ),
              const SizedBox(height: 16),
              Text('Product health', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (state.productHealth.isEmpty)
                Text('No health probes yet.', style: Theme.of(context).textTheme.bodySmall)
              else
                for (final p in state.productHealth)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _Tile(
                      title: p.name,
                      subtitle: [
                        if (p.statusCode != null) 'HTTP ${p.statusCode}',
                        if (p.latencyMs != null) '${p.latencyMs}ms',
                        if (p.error != null) p.error!,
                      ].join(' · '),
                      trailing: StatusPill(status: p.ok ? 'OK' : 'DOWN'),
                    ),
                  ),
              const SizedBox(height: 16),
              Text('CI checks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (state.githubChecks.isEmpty)
                Text(
                  'No GitHub token configured on Ops Tool, or no runs yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                for (final c in state.githubChecks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _Tile(
                      title: c.repo,
                      subtitle: [c.name, c.status, c.conclusion].whereType<String>().join(' · '),
                      trailing: StatusPill(status: (c.conclusion ?? c.status ?? 'UNKNOWN').toUpperCase()),
                    ),
                  ),
              const SizedBox(height: 16),
              Text('Distribution', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final (label, url) in stores)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _Tile(
                    title: label,
                    subtitle: url,
                    trailing: IconButton(
                      tooltip: 'Copy URL',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied $label URL')),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text('App release gates', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (state.releases.isEmpty)
                Text('No release rows from MobiStack.', style: Theme.of(context).textTheme.bodySmall)
              else
                for (final r in state.releases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _Tile(
                      title: r.platform,
                      subtitle:
                          'min ${r.minNativeBuild} · latest ${r.latestNativeBuild} · '
                          'OTA ${r.otaChannel}'
                          '${r.forceNativeUpdate ? ' · FORCE' : ''}',
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Px.line),
        color: Px.surface.withValues(alpha: 0.82),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
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
  const _StatBlock({required this.label, required this.value, this.hot = false});
  final String label;
  final String value;
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
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: hot ? Px.accentStrong : Px.ink,
                  fontSize: 22,
                ),
          ),
        ],
      ),
    );
  }
}

TextStyle? _label(BuildContext context) =>
    Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Px.muted,
          letterSpacing: 1.4,
          fontSize: 11,
        );
