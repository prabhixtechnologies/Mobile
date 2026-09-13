import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  int _index(String location) {
    if (location.startsWith('/queue')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final index = _index(loc);
    final state = context.watch<AppState>();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: index,
        backgroundColor: Px.surface.withValues(alpha: 0.94),
        indicatorColor: Px.bgAccent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) {
          if (i == 0) {
            context.go('/mail');
          } else {
            context.go('/queue');
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.mail_outline_rounded),
            selectedIcon: const Icon(Icons.mail_rounded),
            label: state.offlineMode ? 'Mail · offline' : 'Mail',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: state.pendingOutbox > 0,
              label: Text('${state.pendingOutbox}'),
              child: const Icon(Icons.forum_outlined),
            ),
            selectedIcon: const Icon(Icons.forum_rounded),
            label: 'Queue',
          ),
        ],
      ),
    );
  }
}
