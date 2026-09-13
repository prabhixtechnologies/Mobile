import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

/// Primary shop chrome: Home · Compatibility · More.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  static const _routes = ['/home', '/compatibility', '/more'];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final state = context.watch<AppState>();
    var selected = _routes.indexWhere((r) => loc.startsWith(r));
    if (selected < 0) selected = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Px.surface.withValues(alpha: 0.96),
        indicatorColor: Px.bgAccent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selected,
        onDestinationSelected: (i) => context.go(_routes[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: state.online ? 'Home' : 'Offline',
          ),
          NavigationDestination(
            icon: const Icon(Icons.phone_android_outlined),
            selectedIcon: const Icon(Icons.phone_android_rounded),
            label: 'Compat',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: state.pendingOps > 0,
              label: Text('${state.pendingOps}'),
              child: const Icon(Icons.grid_view_outlined),
            ),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
