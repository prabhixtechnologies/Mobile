import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/shop_ui.dart';

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
                const SizedBox(height: 4),
                Text('User id: ${me.id}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 20),
                Text('Features', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: me.features.map((f) => Chip(label: Text(f))).toList(),
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
