import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/shop_ui.dart';

class WorkspacesScreen extends StatelessWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orgs = context.watch<AppState>().me?.organizations ?? const [];
    return ShopPage(
      title: 'Workspaces',
      subtitle: orgs.isEmpty ? 'No other shops on this login' : '${orgs.length} shops',
      child: orgs.isEmpty
          ? const ShopEmpty(
              title: 'One shop on this login',
              subtitle: 'Extra workspaces show up here when the account has them.',
              icon: Icons.apartment_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: orgs.length,
              itemBuilder: (context, i) {
                final o = orgs[i];
                return ShopListTile(
                  title: o.name,
                  subtitle: o.slug ?? o.id,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await context.read<AppState>().api.selectOrganization(o.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Switched to ${o.name}')),
                      );
                      await context.read<AppState>().refreshAll();
                    }
                  },
                );
              },
            ),
    );
  }
}
