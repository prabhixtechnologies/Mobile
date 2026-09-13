import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class OrgSelectScreen extends StatelessWidget {
  const OrgSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select organization'),
        actions: [
          IconButton(onPressed: () => state.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView.separated(
        itemCount: state.organizations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final org = state.organizations[i];
          return ListTile(
            title: Text(org.name),
            onTap: () => state.selectOrg(org),
          );
        },
      ),
    );
  }
}
