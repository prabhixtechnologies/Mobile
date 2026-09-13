import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class WorkspacesScreen extends StatelessWidget {
  const WorkspacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orgs = context.watch<AppState>().me?.organizations ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Workspaces')),
      body: ListView.separated(
        itemCount: orgs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final o = orgs[i];
          return ListTile(
            title: Text(o.name),
            subtitle: Text(o.slug ?? o.id),
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
