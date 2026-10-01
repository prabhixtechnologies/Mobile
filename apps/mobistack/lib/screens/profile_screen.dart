import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/shop_ui.dart';

const Map<String, String> _featureLabels = {
  'COMPATIBILITY': 'Fitment catalog',
  'DASHBOARD': 'Home dashboard',
  'SALES': 'Sales',
  'REPAIRS': 'Repairs',
  'INVENTORY': 'Stock',
  'PURCHASES': 'Purchases',
  'CUSTOMERS': 'Customers',
  'SUPPLIERS': 'Suppliers',
  'MEMBERS': 'Team members',
  'IMPORT': 'Catalog import',
  'REPORTS': 'Reports',
  'MOVEMENTS': 'Stock movements',
  'AUDIT': 'Audit',
};

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().me;
    return ShopPage(
      title: 'Profile',
      child: me == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Text(me.displayName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(me.email, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                Text('On your plan', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: me.features.map((f) => Chip(label: Text(_featureLabels[f] ?? f))).toList(),
                ),
                const SizedBox(height: 20),
                ShopListTile(
                  leading: Icon(Icons.manage_accounts_rounded, color: Px.accent),
                  title: 'Manage account',
                  subtitle: 'Password and passkeys on Prabhix Identity',
                  trailing: Icon(Icons.open_in_new_rounded, color: Px.faint),
                  onTap: () => context.read<AppState>().openAccount(),
                ),
              ],
            ),
    );
  }
}
