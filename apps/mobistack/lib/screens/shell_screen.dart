import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

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
    var selected = routes.indexWhere((r) => loc.startsWith(r));
    if (selected < 0) selected = 0;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
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
                      color: Colors.black.withValues(alpha: 0.45),
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
    );
  }
}
