import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

/// Central links for account, team, and inboxes — including support view-as exit.
class SettingsHubScreen extends StatelessWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Atmosphere(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text('Workspace', style: textTheme.titleSmall?.copyWith(color: Px.muted)),
            const SizedBox(height: 8),
            _HubTile(
              icon: Icons.manage_accounts_rounded,
              title: 'Account',
              subtitle: 'Password, passkeys, and sessions on Identity',
              onTap: () => context.push('/account'),
            ),
            _HubTile(
              icon: Icons.group_outlined,
              title: 'Members',
              subtitle: 'Invite and manage the team',
              onTap: () => context.push('/members'),
            ),
            const SizedBox(height: 20),
            Text('Inboxes', style: textTheme.titleSmall?.copyWith(color: Px.muted)),
            const SizedBox(height: 8),
            _HubTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Chat inbox',
              subtitle: 'Live conversations',
              onTap: () => context.go('/home/chat'),
            ),
            _HubTile(
              icon: Icons.mail_outline_rounded,
              title: 'Mail inbox',
              subtitle: 'Helpdesk threads',
              onTap: () => context.go('/home/inbox'),
            ),
            if (state.viewingOrgId != null) ...[
              const SizedBox(height: 20),
              Text('Support access', style: textTheme.titleSmall?.copyWith(color: Px.muted)),
              const SizedBox(height: 8),
              Text(
                'API calls send X-Prabhix-Org for ${state.viewingOrgId}. '
                'The server still decides whether you may access that organization.',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: state.busy
                    ? null
                    : () {
                        state.clearViewingOrg();
                        state.refreshHome();
                      },
                icon: const Icon(Icons.exit_to_app_rounded),
                label: const Text('Stop viewing as support'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Px.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Px.line),
      ),
      child: ListTile(
        leading: Icon(icon, color: Px.accent),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(color: Px.muted)),
        trailing: Icon(Icons.chevron_right_rounded, color: Px.faint),
        onTap: onTap,
      ),
    );
  }
}
