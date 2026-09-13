import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AppState>().me;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: me == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(me.displayName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(me.email),
                Text('User id: ${me.id}'),
                const SizedBox(height: 16),
                Text('Features', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: me.features.map((f) => Chip(label: Text(f))).toList(),
                ),
              ],
            ),
    );
  }
}
