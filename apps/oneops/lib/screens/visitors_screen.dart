import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class VisitorsScreen extends StatelessWidget {
  const VisitorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshVisitors(),
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
                  Expanded(
                    child: Text(
                      'Live visitors',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
                    ),
                  ),
                  IconButton(
                    onPressed: () => state.refreshVisitors(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${state.visitors.length} on your site right now',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Px.danger)),
              ],
              const SizedBox(height: 20),
              if (state.visitors.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: Text('No live visitors right now.')),
                )
              else
                ...state.visitors.map((v) {
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(v.label, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(
                          [
                            if (v.currentTitle != null) v.currentTitle!,
                            if (v.currentPath != null) v.currentPath!,
                            if (v.since != null) 'since ${v.since}',
                          ].join('\n'),
                        ),
                        isThreeLine: true,
                        onTap: () => context.push('/visitors/${v.visitorId}'),
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
