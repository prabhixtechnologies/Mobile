import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('API base'),
            subtitle: Text(state.config.product.apiBaseUrl),
          ),
          ListTile(
            title: const Text('Identity issuer'),
            subtitle: Text(state.config.identity.issuer),
          ),
          SwitchListTile(
            title: const Text('Allow create-account prompt'),
            value: state.allowCreateAccount,
            onChanged: (v) => state.setAllowCreateAccount(v),
          ),
          ListTile(
            title: const Text('Flush outbox'),
            trailing: Text('${state.pendingOps}'),
            onTap: () => state.refreshAll(),
          ),
        ],
      ),
    );
  }
}
