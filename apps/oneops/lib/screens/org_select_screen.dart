import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class OrgSelectScreen extends StatelessWidget {
  const OrgSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.organizations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Organization'),
          actions: [
            IconButton(onPressed: () => state.signOut(), icon: const Icon(Icons.logout)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.apartment_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'No organization yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Create a workspace in the OneOps console, accept an invite from your inbox email, '
                'or ask an admin to add you to an existing organization.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: state.busy ? null : () => state.signIn(),
                child: Text(state.busy ? 'Opening Identity…' : 'Sign in again'),
              ),
              TextButton(
                onPressed: state.busy ? null : () => state.openAccount(),
                child: const Text('Open Identity account'),
              ),
            ],
          ),
        ),
      );
    }

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
