import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/mail_ui.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final _search = TextEditingController();

  static const statuses = <(String, String)>[
    ('OPEN', 'Open'),
    ('PENDING_CUSTOMER', 'Waiting'),
    ('ON_HOLD', 'On hold'),
    ('RESOLVED', 'Resolved'),
    ('CLOSED', 'Closed'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshQueue(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, top + 12, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Queue',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 34),
                        ),
                      ),
                      IconButton(
                        onPressed: state.busy ? null : () => state.refreshQueue(),
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Text(
                    '${state.queue.length} tickets · helpdesk work',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search subject or customer…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Px.surface.withValues(alpha: 0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Px.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Px.line),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) => state.setQueueFilters(query: q),
                  ),
                ),
              ),
              ContainedSliver(
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      FilterChip(
                        label: Text(state.queueMineOnly ? 'Mine' : 'All'),
                        selected: state.queueMineOnly,
                        onSelected: (v) => state.setQueueFilters(mineOnly: v),
                      ),
                      const SizedBox(width: 8),
                      ...statuses.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(s.$2),
                            selected: state.queueStatus == s.$1,
                            onSelected: (_) =>
                                state.setQueueFilters(status: s.$1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(state.error!, style: const TextStyle(color: Px.danger)),
                  ),
                ),
              if (state.queue.isEmpty)
                const ContainedSliver(
                  fill: true,
                  child: EmptyState(
                    title: 'Queue is clear',
                    subtitle: 'No tickets match these filters.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: state.queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final t = state.queue[i];
                      return _TicketCard(
                        ticket: t,
                        onTap: () => context.push('/ticket/${t.id}'),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper so EmptyState can sit in a sliver without awkward fill APIs.
class ContainedSliver extends StatelessWidget {
  const ContainedSliver({super.key, required this.child, this.fill = false});

  final Widget child;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    if (fill) {
      return SliverFillRemaining(hasScrollBody: true, child: child);
    }
    return SliverToBoxAdapter(child: child);
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onTap});

  final HelpdeskTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Px.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ticket.isBreached
                  ? Px.danger.withValues(alpha: 0.45)
                  : Px.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (ticket.referenceKey != null)
                      Text(
                        ticket.referenceKey!,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Px.accent,
                              letterSpacing: 0.6,
                            ),
                      ),
                    const Spacer(),
                    Text(
                      relativeTime(ticket.lastMessageAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: ticket.unreadCount > 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                ),
                if (ticket.preview != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    ticket.preview!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (ticket.status != null)
                      StatusChip(
                        label: ticket.status!,
                        tone: statusTone(ticket.status),
                      ),
                    if (ticket.priority != null)
                      StatusChip(
                        label: ticket.priority!,
                        tone: priorityTone(ticket.priority),
                      ),
                    if (ticket.isBreached)
                      const StatusChip(label: 'SLA BREACH', tone: ChipTone.danger),
                    if (ticket.customerEmail != null)
                      StatusChip(label: ticket.customerEmail!),
                    if (ticket.assigneeName != null ||
                        ticket.assigneeUserId != null)
                      StatusChip(
                        label: ticket.assigneeName ?? 'Assigned',
                        tone: ChipTone.accent,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
