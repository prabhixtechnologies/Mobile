import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final state = context.read<AppState>();
          if (!state.online) return;
          try {
            await state.api.dio.post<void>('inbox/read-all');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All marked read')),
            );
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
          }
        },
        icon: const Icon(Icons.done_all_rounded),
        label: const Text('Read all'),
      ),
      onTap: (row) async {
        final id = '${row['id'] ?? ''}';
        if (id.isEmpty) return;
        final state = context.read<AppState>();
        if (!state.online) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offline · open this notice when connected')),
          );
          return;
        }
        try {
          await state.api.dio.post<void>('inbox/$id/read');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marked read')),
          );
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        }
      },
    );
  }
}
