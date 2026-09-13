import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = <_Item>[
      _Item('Workspaces', Icons.apartment_rounded, '/workspaces'),
      if (state.hasFeature('CUSTOMERS'))
        _Item('Customers', Icons.people_outline_rounded, '/customers'),
      if (state.hasFeature('SUPPLIERS'))
        _Item('Suppliers', Icons.local_shipping_outlined, '/suppliers'),
      if (state.hasFeature('PURCHASES'))
        _Item('Purchases', Icons.shopping_bag_outlined, '/purchases'),
      if (state.hasFeature('MEMBERS'))
        _Item('Members', Icons.group_outlined, '/members'),
      if (state.hasFeature('REPORTS'))
        _Item('Reports', Icons.bar_chart_rounded, '/reports'),
      if (state.hasFeature('INVENTORY'))
        _Item('Movements', Icons.swap_horiz_rounded, '/movements'),
      _Item('Billing', Icons.credit_card_rounded, '/billing'),
      _Item('Inbox', Icons.inbox_outlined, '/inbox'),
      _Item('Support', Icons.help_outline_rounded, '/support'),
      if (state.hasFeature('COMPATIBILITY'))
        _Item('Compatibility', Icons.phone_android_rounded, '/compatibility'),
      _Item('Settings', Icons.settings_outlined, '/settings'),
      _Item('Profile', Icons.person_outline_rounded, '/profile'),
    ];

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              ShopHeroHeader(
                title: 'More',
                subtitle: state.me?.email ?? 'Shop tools',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    ...items.map(
                      (item) => ShopListTile(
                        leading: Icon(item.icon, color: Px.accent),
                        title: item.label,
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: Px.faint),
                        onTap: () => context.push(item.route),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ShopListTile(
                      leading: const Icon(Icons.logout_rounded, color: Px.danger),
                      title: 'Sign out',
                      onTap: () => state.signOut(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item {
  _Item(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
