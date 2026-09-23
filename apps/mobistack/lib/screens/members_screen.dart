import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
import '../widgets/live_api_list.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Members',
      path: 'users',
      titleOf: (row) => '${row['fullName'] ?? row['email'] ?? 'Member'}',
      subtitleOf: (row) {
        final roles = row['roles'];
        if (roles is List && roles.isNotEmpty) return roles.join(', ');
        return '${row['email'] ?? ''}';
      },
      emptyTitle: 'No members yet',
      emptySubtitle: 'Invite someone from the button.',
      emptyIcon: Icons.group_outlined,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final state = context.read<AppState>();
          final orgId = state.me?.organizations.isNotEmpty == true ? state.me!.organizations.first.id : null;
          if (orgId == null) return;
          final values = await askCounterFields(context, title: 'Invite', labels: const ['Email']);
          if (values == null || values.first.isEmpty || !context.mounted) return;
          final error = await state.onlinePost('workspaces/$orgId/invitations', {
            'email': values.first,
            'role': 'STAFF',
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Invitation sent')));
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
