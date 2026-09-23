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

    final catalog = <_Item>[
      _Item('Browse catalog', Icons.public_outlined, '/commons'),
      _Item('Private fitment notes', Icons.lock_outline_rounded, '/compatibility'),
      _Item('Standing', Icons.military_tech_outlined, '/standing'),
      _Item('Catalog import', Icons.upload_file_rounded, '/import'),
    ];

    final shop = <_Item>[
      if (state.hasFeature('INVENTORY'))
        _Item('Stock', Icons.inventory_2_rounded, '/inventory'),
      if (state.hasFeature('SALES'))
        _Item('Sales', Icons.point_of_sale_rounded, '/sales'),
      if (state.hasFeature('REPAIRS'))
        _Item('Repairs', Icons.build_rounded, '/repairs'),
      if (state.hasFeature('PURCHASES'))
        _Item('Purchases', Icons.shopping_bag_outlined, '/purchases'),
      if (state.hasFeature('INVENTORY'))
        _Item('Movements', Icons.swap_horiz_rounded, '/movements'),
      if (state.hasFeature('CUSTOMERS'))
        _Item('Customers', Icons.people_outline_rounded, '/customers'),
      if (state.hasFeature('SUPPLIERS'))
        _Item('Suppliers', Icons.local_shipping_outlined, '/suppliers'),
      if (state.hasFeature('MEMBERS'))
        _Item('Members', Icons.group_outlined, '/members'),
      _Item('Workspaces', Icons.apartment_rounded, '/workspaces'),
    ];

    final ops = <_Item>[
      if (state.hasFeature('REPORTS'))
        _Item('Reports', Icons.bar_chart_rounded, '/reports'),
      _Item('Billing', Icons.credit_card_rounded, '/billing'),
      _Item('Inbox', Icons.inbox_outlined, '/inbox'),
      _Item('Notifications', Icons.notifications_outlined, '/notifications'),
      _Item('Audit', Icons.history_rounded, '/audit'),
      _Item('Health', Icons.monitor_heart_outlined, '/health'),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search the shop'),
                  onSubmitted: (value) async {
                    final term = value.trim();
                    if (term.length < 2 || !context.mounted) return;
                    try {
                      final res = await context.read<AppState>().api.dio.get<dynamic>(
                        'search',
                        queryParameters: {'q': term},
                      );
                      final data = res.data;
                      final parts = data is Map && data['parts'] is List ? data['parts'] as List : const [];
                      if (!context.mounted) return;
                      final names = [
                        for (final row in parts)
                          if (row is Map) '${row['name'] ?? row['variantName'] ?? row['sku'] ?? ''}',
                      ].where((name) => name.isNotEmpty).take(8).join('\n');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(names.isEmpty ? 'Nothing matched' : names)),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 28),
                  children: [
                    _Section(
                      title: 'Fitment Catalog',
                      hint: 'shared with every shop',
                      items: catalog,
                    ),
                    _Section(
                      title: 'My Shop',
                      hint: 'private to your shop',
                      items: shop,
                    ),
                    _Section(title: 'Ops', items: ops),
                    const SizedBox(height: 8),
                    ShopListTile(
                      leading: Icon(Icons.logout_rounded, color: Px.danger),
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
  const _Section({required this.title, required this.items, this.hint});

  final String title;
  final String? hint;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
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
        if (hint != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ),
        ...items.map(
          (item) => ShopListTile(
            leading: Icon(item.icon, color: Px.accent),
            title: item.label,
            trailing: Icon(Icons.chevron_right_rounded, color: Px.faint),
            onTap: () {
              if (item.route == '/inventory' ||
                  item.route == '/sales' ||
                  item.route == '/repairs' ||
                  item.route == '/commons') {
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
