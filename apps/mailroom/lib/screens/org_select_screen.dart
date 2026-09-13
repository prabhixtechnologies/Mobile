import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class OrgSelectScreen extends StatelessWidget {
  const OrgSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: Atmosphere(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            children: [
              Row(
                children: [
                  const Expanded(child: BrandMark(compact: true)),
                  IconButton(
                    onPressed: () => state.signOut(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Choose workspace',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 8),
              Text(
                'Mailroom opens the shared inboxes for the org you select.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ...state.organizations.map(
                (org) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Px.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: state.busy ? null : () => state.selectOrg(org),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Px.line),
                        ),
                        child: ListTile(
                          title: Text(org.name),
                          subtitle: org.slug != null ? Text(org.slug!) : null,
                          trailing: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
