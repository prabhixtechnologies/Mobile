import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kpis = state.dashboard;
    return Scaffold(
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshHome(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.paddingOf(context).top + 16,
              24,
              32,
            ),
            children: [
              Row(
                children: [
                  const Expanded(child: BrandMark(compact: true)),
                  IconButton(
                    tooltip: 'Account',
                    onPressed: () => context.push('/account'),
                    icon: const Icon(Icons.manage_accounts_rounded),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: state.busy ? null : () => state.refreshHome(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: state.busy ? null : () => state.signOut(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 6),
              Text(
                state.me?.email ?? 'Operator console',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Px.danger)),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text('Orders'),
                    onPressed: () => context.push('/orders'),
                  ),
                  ActionChip(
                    label: const Text('Members'),
                    onPressed: () => context.push('/members'),
                  ),
                  ActionChip(
                    label: const Text('Notifications'),
                    onPressed: () => context.push('/notifications'),
                  ),
                  ActionChip(
                    label: const Text('Account'),
                    onPressed: () => context.push('/account'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _Tile(label: 'Open chats', value: '${kpis?.openConversations ?? '—'}'),
                  _Tile(label: 'Unassigned', value: '${kpis?.unassignedConversations ?? '—'}'),
                  _Tile(label: 'Visitors today', value: '${kpis?.visitorsToday ?? '—'}'),
                  _Tile(label: 'Live now', value: '${state.visitors.length}'),
                  _Tile(label: 'Queued sends', value: '${state.pendingOutbound}'),
                  if (kpis != null)
                    _Tile(
                      label: 'Seats',
                      value: '${kpis.seatsUsed}/${kpis.seatsLimit}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Px.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Px.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
