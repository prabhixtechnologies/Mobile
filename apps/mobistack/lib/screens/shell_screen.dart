import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final state = context.watch<AppState>();
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: state.online ? 'Home' : 'Home · off',
      ),
      if (state.hasFeature('INVENTORY'))
        const NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: 'Stock',
        ),
      if (state.hasFeature('SALES'))
        NavigationDestination(
          icon: Badge(
            isLabelVisible: state.pendingOps > 0,
            label: Text('${state.pendingOps}'),
            child: const Icon(Icons.point_of_sale_outlined),
          ),
          selectedIcon: const Icon(Icons.point_of_sale_rounded),
          label: 'Sales',
        ),
      if (state.hasFeature('REPAIRS'))
        const NavigationDestination(
          icon: Icon(Icons.build_outlined),
          selectedIcon: Icon(Icons.build_rounded),
          label: 'Repairs',
        ),
      const NavigationDestination(
        icon: Icon(Icons.more_horiz_rounded),
        selectedIcon: Icon(Icons.more_horiz_rounded),
        label: 'More',
      ),
    ];

    final routes = <String>[
      '/home',
      if (state.hasFeature('INVENTORY')) '/inventory',
      if (state.hasFeature('SALES')) '/sales',
      if (state.hasFeature('REPAIRS')) '/repairs',
      '/more',
    ];

    var selected = routes.indexWhere((r) => loc.startsWith(r));
    if (selected < 0) selected = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Px.surface.withValues(alpha: 0.94),
        indicatorColor: Px.bgAccent,
        selectedIndex: selected.clamp(0, destinations.length - 1),
        onDestinationSelected: (i) => context.go(routes[i]),
        destinations: destinations,
      ),
    );
  }
}
