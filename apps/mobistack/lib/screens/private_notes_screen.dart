import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class PrivateNotesScreen extends StatelessWidget {
  const PrivateNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Private fitment notes',
      path: 'compatibility-groups',
      titleOf: (row) => '${row['name'] ?? 'Note'}',
      subtitleOf: (row) =>
          '${row['categoryName'] ?? 'Unfiled'} · ${(row['devices'] is List) ? (row['devices'] as List).length : 0} phones',
      emptyTitle: 'No private notes',
      emptySubtitle: 'These stay in this shop until you propose them to the shared catalog.',
      emptyIcon: Icons.lock_outline_rounded,
    );
  }
}
