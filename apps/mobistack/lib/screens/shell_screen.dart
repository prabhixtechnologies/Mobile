import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

/// Which tab owns a route that is not itself a tab.
///
/// The shell hosts more screens than it has tabs. `indexWhere` alone returns `-1` for those
/// and the old code clamped `-1` to `0`, so standing on `/inventory`, `/sales` or `/repairs`
/// lit up **Home** — the nav said the user was somewhere they were not.
///
/// Declaring the ownership makes the answer deliberate, and anything absent from both this
/// map and the tab list highlights nothing, which is the honest result for a screen that
/// does not belong to a tab.
const Map<String, String> _tabOwner = {
  '/inventory': '/home',
  '/sales': '/home',
  '/repairs': '/home',
  '/invoice': '/home',
  '/devices': '/home',
  '/scan': '/home',
};

int _selectedTab(List<String> tabs, String location) {
  final direct = tabs.indexWhere((t) => location.startsWith(t));
  if (direct >= 0) return direct;
  for (final entry in _tabOwner.entries) {
    if (location.startsWith(entry.key)) {
      final owner = tabs.indexOf(entry.value);
      if (owner >= 0) return owner;
    }
  }
  // No tab claims this route. -1 leaves every tab unselected, which is what a
  // NavigationBar renders for "you are not in any of these".
  return -1;
}

/// Primary shop chrome. Unpaid shops see Catalog + Billing; paid shops get Home + Catalog + More.
class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final catalogOnly = state.catalogOnlyMode;
    final routes = catalogOnly
        ? const ['/commons', '/billing']
        : const ['/home', '/commons', '/more'];
    final labels = catalogOnly
        ? const ['Catalog', 'Billing']
        : const ['Home', 'Catalog', 'More'];
    final icons = catalogOnly
        ? const [Icons.public_outlined, Icons.credit_card_outlined]
        : const [Icons.home_outlined, Icons.public_outlined, Icons.more_horiz_outlined];
    final activeIcons = catalogOnly
        ? const [Icons.public_rounded, Icons.credit_card_rounded]
        : const [Icons.home_rounded, Icons.public_rounded, Icons.more_horiz_rounded];

    final loc = GoRouterState.of(context).uri.toString();
    final selected = _selectedTab(routes, loc);
    final bottom = MediaQuery.paddingOf(context).bottom;

    // Shell screens are reached with `go`, which leaves nothing beneath them, so the system
    // Back would close the app from Stock or Catalog. Only the first tab may exit.
    return PopScope(
      canPop: loc == routes.first,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(routes.first);
      },
      child: Scaffold(
      backgroundColor: Px.bg,
      body: child,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottom),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Px.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Px.line),
            boxShadow: Px.isDark
                ? [
                    BoxShadow(
                      color: Px.scrim.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : Px.lift,
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var i = 0; i < routes.length; i++)
                  _DockItem(
                    selected: selected == i,
                    icon: icons[i],
                    activeIcon: activeIcons[i],
                    label: labels[i],
                    onTap: () => context.go(routes[i]),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.selected,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Px.accentInk : Px.muted;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            // The filled pill is the only thing that says "you are here", and a screen
            // reader cannot see a filled pill.
            selected: selected,
            button: true,
            label: label,
            child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Px.curve,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? Px.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? activeIcon : icon, color: color, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: color,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
