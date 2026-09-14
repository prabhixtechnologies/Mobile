import 'package:flutter/material.dart';

import '../widgets/live_api_list.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Inbox',
      path: 'inbox',
      titleOf: (row) => '${row['title'] ?? row['eventType'] ?? 'Notice'}',
      subtitleOf: (row) => '${row['body'] ?? ''}',
      emptyTitle: 'Inbox is empty',
      emptySubtitle: 'Shop notices land here when something needs a person.',
      emptyIcon: Icons.inbox_outlined,
    );
  }
}
