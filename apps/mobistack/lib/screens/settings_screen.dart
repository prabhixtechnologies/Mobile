import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/shop_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ShopPage(
      title: 'Settings',
      subtitle: 'Account and this phone',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: _AppearanceChoice(
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                    selected: state.themeMode == ThemeMode.light,
                    onTap: () => state.setAppearance(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AppearanceChoice(
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                    selected: state.themeMode != ThemeMode.light,
                    onTap: () => state.setAppearance(ThemeMode.dark),
                  ),
                ),
              ],
            ),
          ),
          ShopListTile(
            leading: Icon(Icons.manage_accounts_rounded, color: Px.accent),
            title: 'Manage account',
            subtitle: 'Password and passkeys on Prabhix Identity',
            trailing: Icon(Icons.open_in_new_rounded, color: Px.faint),
            onTap: () => state.openAccount(),
          ),
          ShopListTile(
            leading: Icon(Icons.dns_rounded, color: Px.focus),
            title: 'API base',
            subtitle: state.config.product.apiBaseUrl,
          ),
          ShopListTile(
            leading: Icon(Icons.verified_user_outlined, color: Px.focus),
            title: 'Identity issuer',
            subtitle: state.config.identity.issuer,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Material(
              color: Px.surface.withValues(alpha: 0.92),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Px.line),
              ),
              child: SwitchListTile(
                title: const Text('Allow create-account prompt'),
                value: state.allowCreateAccount,
                onChanged: (v) => state.setAllowCreateAccount(v),
              ),
            ),
          ),
          ShopListTile(
            leading: Icon(Icons.outbox_rounded, color: Px.warning),
            title: 'Flush outbox',
            trailing: Text('${state.pendingOps}'),
            onTap: () => state.refreshAll(),
          ),
        ],
      ),
    );
  }
}

class _AppearanceChoice extends StatelessWidget {
  const _AppearanceChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Px.accentInk : Px.ink;
    return Material(
      color: selected ? Px.accent : Px.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? Px.accent : Px.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: fg),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
