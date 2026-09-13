import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class RepairsScreen extends StatelessWidget {
  const RepairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hasFeature('REPAIRS')) {
      return const Atmosphere(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ShopEmpty(
            title: 'Repairs locked',
            subtitle: 'This feature is not on your plan.',
            icon: Icons.build_outlined,
          ),
        ),
      );
    }

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              ShopHeroHeader(
                title: 'Repairs',
                subtitle: state.online
                    ? '${state.repairs.length} jobs'
                    : 'Cached jobs · sync when online',
              ),
              Expanded(
                child: state.repairs.isEmpty
                    ? const ShopEmpty(
                        title: 'No repair jobs',
                        subtitle: 'Jobs appear here after a successful sync',
                        icon: Icons.build_circle_outlined,
                      )
                    : RefreshIndicator(
                        color: Px.accent,
                        onRefresh: () => state.refreshAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: state.repairs.length,
                          itemBuilder: (context, i) {
                            final r = state.repairs[i];
                            final meta = [
                              if (r.status != null) r.status!,
                              if (r.problem != null) r.problem!,
                            ].join(' · ');
                            return ShopListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Px.warning.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.build_rounded,
                                    color: Px.warning, size: 20),
                              ),
                              title: r.jobNumber,
                              subtitle: meta.isEmpty ? 'Repair job' : meta,
                              trailing: Text(
                                r.outstanding.toStringAsFixed(2),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            );
                          },
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
