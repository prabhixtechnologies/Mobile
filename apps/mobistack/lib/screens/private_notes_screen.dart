import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
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
      onTap: (row) async {
        final id = '${row['id'] ?? ''}';
        final action = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: const Text('Add a phone'), onTap: () => Navigator.pop(context, 'phone')),
                ListTile(title: const Text('Propose to catalog'), onTap: () => Navigator.pop(context, 'propose')),
              ],
            ),
          ),
        );
        if (action == null || !context.mounted || id.isEmpty) return;
        final state = context.read<AppState>();
        if (action == 'phone') {
          final values = await askCounterFields(context, title: 'Add phone', labels: const ['Model']);
          if (values == null || values.first.isEmpty || !context.mounted) return;
          final found = await state.api.dio.get<dynamic>('commons/devices', queryParameters: {'q': values.first, 'size': 1});
          final page = found.data;
          final content = page is Map && page['content'] is List ? page['content'] as List : const [];
          final deviceId = content.isNotEmpty && content.first is Map ? '${(content.first as Map)['id']}' : '';
          if (deviceId.isEmpty) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No matching phone in the catalog')));
            return;
          }
          final error = await state.onlinePost('compatibility-groups/$id/devices', {'deviceModelId': deviceId});
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Phone added')));
          return;
        }
        final error = await state.onlinePost('commons/contributions', {
          'kind': 'ADD_FITMENT',
          'reason': 'Proposed from ${row['name'] ?? 'a private note'}',
          'payload': {'groupId': id, 'name': row['name'] ?? ''},
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Proposed to the catalog')));
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final values = await askCounterFields(
            context,
            title: 'Private note',
            labels: const ['Name', 'Phone model'],
          );
          if (values == null || values.first.isEmpty || !context.mounted) return;
          final error = await context.read<AppState>().onlinePost('compatibility-groups', {
            'name': values[0],
            if (values.length > 1 && values[1].isNotEmpty) 'deviceTexts': [values[1]],
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Note saved')));
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
