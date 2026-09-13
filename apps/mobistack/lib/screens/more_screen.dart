import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final floor = <_Item>[
      if (state.hasFeature('INVENTORY'))
        _Item('Stock', Icons.inventory_2_rounded, '/inventory'),
      if (state.hasFeature('SALES'))
        _Item('Sales', Icons.point_of_sale_rounded, '/sales'),
      if (state.hasFeature('REPAIRS'))
        _Item('Repairs', Icons.build_rounded, '/repairs'),
      if (state.hasFeature('INVENTORY'))
        _Item('Movements', Icons.swap_horiz_rounded, '/movements'),
    ];

    final people = <_Item>[
      if (state.hasFeature('CUSTOMERS'))
        _Item('Customers', Icons.people_outline_rounded, '/customers'),
      if (state.hasFeature('SUPPLIERS'))
        _Item('Suppliers', Icons.local_shipping_outlined, '/suppliers'),
      if (state.hasFeature('MEMBERS'))
        _Item('Members', Icons.group_outlined, '/members'),
      _Item('Workspaces', Icons.apartment_rounded, '/workspaces'),
    ];

    final ops = <_Item>[
      if (state.hasFeature('PURCHASES'))
        _Item('Purchases', Icons.shopping_bag_outlined, '/purchases'),
      if (state.hasFeature('REPORTS'))
        _Item('Reports', Icons.bar_chart_rounded, '/reports'),
      _Item('Billing', Icons.credit_card_rounded, '/billing'),
      _Item('Inbox', Icons.inbox_outlined, '/inbox'),
      _Item('Support', Icons.help_outline_rounded, '/support'),
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
                subtitle: state.me?.email ?? 'Shop tools & settings',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 28),
                  children: [
                    _Section(title: 'Floor', items: floor),
                    _Section(title: 'People', items: people),
                    _Section(title: 'Ops', items: ops),
                    const SizedBox(height: 8),
                    ShopListTile(
                      leading:
                          const Icon(Icons.logout_rounded, color: Px.danger),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.sourceSans3(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Px.accent,
            ),
          ),
        ),
        ...items.map(
          (item) => ShopListTile(
            leading: Icon(item.icon, color: Px.accent),
            title: item.label,
            trailing: const Icon(Icons.chevron_right_rounded, color: Px.faint),
            onTap: () {
              if (item.route == '/inventory' ||
                  item.route == '/sales' ||
                  item.route == '/repairs') {
                context.go(item.route);
              } else {
                context.push(item.route);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _Item {
  _Item(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}
