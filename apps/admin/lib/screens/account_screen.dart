import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Atmosphere(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            Text(
              state.me?.displayName ?? 'Staff',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(state.me?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Text(
              'Password, passkeys, email and sessions live on Identity. '
              'This app does not collect a password.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            PxPrimaryButton(
              label: 'Manage account',
              icon: Icons.open_in_new_rounded,
              onPressed: state.busy ? null : () => state.openAccount(),
            ),
          ],
        ),
      ),
    );
  }
}
