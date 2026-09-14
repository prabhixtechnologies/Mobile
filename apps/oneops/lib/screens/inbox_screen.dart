import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      final state = context.read<AppState>();
      if (state.tickets.isEmpty) {
        state.refreshInbox();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshInbox(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.paddingOf(context).top + 16,
              24,
              32,
            ),
            children: [
              Text(
                'Inbox',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 6),
              Text(
                'Read, reply and assign helpdesk mail.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Px.danger)),
              ],
              const SizedBox(height: 20),
              if (state.tickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: Text('No tickets in the inbox.')),
                )
              else
                ...state.tickets.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Px.surface.withValues(alpha: 0.88),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Px.line),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        title: Text(t.subject),
                        subtitle: Text(
                          [t.customerEmail, t.status, t.preview]
                              .where((e) => e != null && e.isNotEmpty)
                              .join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: t.unreadCount > 0
                            ? Badge(label: Text('${t.unreadCount}'))
                            : null,
                        onTap: () => context.push('/inbox/${t.id}'),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
