import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  int _indexFor(String loc) {
    if (loc.startsWith('/home/inbox')) return 1;
    if (loc.startsWith('/home/chat')) return 2;
    if (loc.startsWith('/home/visitors')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final state = context.watch<AppState>();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(loc),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home/dashboard');
            case 1:
              context.go('/home/inbox');
            case 2:
              context.go('/home/chat');
            case 3:
              context.go('/home/visitors');
          }
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          const NavigationDestination(icon: Icon(Icons.inbox_outlined), label: 'Inbox'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: state.pendingOutbound > 0,
              label: Text('${state.pendingOutbound}'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            label: 'Chat',
          ),
          const NavigationDestination(icon: Icon(Icons.people_outline), label: 'Live'),
        ],
      ),
    );
  }
}
