import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/counter_sheet.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Audit',
      path: 'audit',
      titleOf: (row) => '${row['action'] ?? row['eventType'] ?? 'Event'}',
      subtitleOf: (row) => '${row['actorName'] ?? row['createdAt'] ?? ''}',
      emptyTitle: 'No audit rows',
      emptySubtitle: 'Shop changes land here.',
      emptyIcon: Icons.history_rounded,
    );
  }
}

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  String _status = 'Loading…';
  List<String> _parts = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('system/health');
      final data = res.data;
      if (!mounted || data is! Map) return;
      final components = data['components'];
      setState(() {
        _status = '${data['status'] ?? 'unknown'}';
        _parts = components is List
            ? [
                for (final row in components)
                  if (row is Map) '${row['name']}: ${row['status']}',
              ]
            : const [];
      });
    } catch (e) {
      if (mounted) setState(() => _status = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: 'Health',
      subtitle: _status,
      child: ListView(
        children: [
          for (final part in _parts) ShopListTile(title: part),
        ],
      ),
    );
  }
}

class StandingScreen extends StatefulWidget {
  const StandingScreen({super.key});

  @override
  State<StandingScreen> createState() => _StandingScreenState();
}

class _StandingScreenState extends State<StandingScreen> {
  String _text = 'Loading…';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('commons/standing');
      if (!mounted) return;
      setState(() => _text = '${res.data}');
    } catch (e) {
      if (mounted) setState(() => _text = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: 'Standing',
      child: Padding(padding: const EdgeInsets.all(20), child: Text(_text)),
    );
  }
}

class NotificationPrefsScreen extends StatefulWidget {
  const NotificationPrefsScreen({super.key});

  @override
  State<NotificationPrefsScreen> createState() => _NotificationPrefsScreenState();
}

class _NotificationPrefsScreenState extends State<NotificationPrefsScreen> {
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('notifications/preferences');
      final data = res.data;
      if (!mounted || data is! List) return;
      setState(() {
        _rows = [for (final row in data) if (row is Map) Map<String, dynamic>.from(row)];
      });
    } catch (_) {}
  }

  Future<void> _toggle(Map<String, dynamic> row, String key, bool value) async {
    row[key] = value;
    setState(() {});
    await context.read<AppState>().api.dio.put<dynamic>(
      'notifications/preferences',
      data: [
        {
          'eventType': row['eventType'],
          'email': row['email'] == true,
          'whatsapp': row['whatsapp'] == true,
          'push': row['push'] == true,
          'sms': row['sms'] == true,
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: 'Notifications',
      child: ListView(
        children: [
          for (final row in _rows)
            SwitchListTile(
              title: Text('${row['eventType']}'),
              subtitle: const Text('Push'),
              value: row['push'] == true,
              onChanged: (value) => _toggle(row, 'push', value),
            ),
        ],
      ),
    );
  }
}

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiveApiListScreen(
      title: 'Catalog import',
      path: 'imports',
      titleOf: (row) => '${row['sourceName'] ?? row['status'] ?? 'Import'}',
      subtitleOf: (row) => '${row['status'] ?? ''} · ${row['message'] ?? ''}',
      emptyTitle: 'No imports yet',
      emptySubtitle: 'Paste a brand and fitment text to start one.',
      emptyIcon: Icons.upload_file_rounded,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final values = await askCounterFields(
            context,
            title: 'Import fitments',
            labels: const ['Brand', 'Text'],
          );
          if (values == null || values.first.isEmpty || !context.mounted) return;
          final error = await context.read<AppState>().onlinePost('imports/compatibility', {
            'brand': values[0],
            'text': values.length > 1 ? values[1] : '',
            'sourceName': 'phone',
          });
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Import started')));
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
