import 'package:flutter/material.dart';

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
      emptySubtitle: 'Invite people from Access control on the web app.',
      emptyIcon: Icons.group_outlined,
    );
  }
}
