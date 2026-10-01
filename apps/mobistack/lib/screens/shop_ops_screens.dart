import 'package:prabhix_api_core/prabhix_api_core.dart' show describeError;
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
      titleOf: (row) => _sentence(row['action'] ?? row['eventType'] ?? 'Event'),
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
        _status = data['status'] == 'UP' ? 'Everything is running' : _sentence(data['status'] ?? 'unknown');
        _parts = components is List
            ? [
                for (final row in components)
                  if (row is Map) '${_sentence(row['name'])}: ${row['status'] == 'UP' ? 'OK' : _sentence(row['status'])}',
              ]
            : const [];
      });
    } catch (e) {
      if (mounted) setState(() => _status = describeError(e));
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
  Map<String, dynamic>? _standing;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('commons/standing');
      if (!mounted) return;
      final data = res.data;
      setState(() {
        _standing = data is Map ? Map<String, dynamic>.from(data) : const {};
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _standing;
    final banned = s?['banned'] == true;
    final trusted = s?['trusted'] == true;
    return ShopPage(
      title: 'Standing',
      subtitle: 'Your record in the shared catalog',
      child: _error != null
          ? ShopEmpty(title: 'Could not load', subtitle: _error!, icon: Icons.cloud_off_rounded)
          : s == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    KpiTile(
                      label: 'Status',
                      value: banned ? 'Blocked' : trusted ? 'Trusted' : 'Contributor',
                      tone: banned ? KpiTone.danger : trusted ? KpiTone.accent : KpiTone.neutral,
                    ),
                    const SizedBox(height: 10),
                    KpiTile(label: 'Accepted spares', value: '${s['accepted'] ?? 0}', tone: KpiTone.accent),
                    const SizedBox(height: 10),
                    KpiTile(label: 'Rejected spares', value: '${s['rejected'] ?? 0}', tone: KpiTone.warning),
                    const SizedBox(height: 14),
                    Text(
                      banned
                          ? 'New spares from this account are not accepted into the shared catalog.'
                          : trusted
                              ? 'Spares you share go live without waiting for review.'
                              : 'Spares you share are reviewed before every shop sees them. Accepted ones build trust.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
    );
  }
}

/// `JOIN_REQUEST_APPROVED` → `Join request approved`.
String _sentence(Object? code) {
  final words = '${code ?? ''}'.toLowerCase().replaceAll('_', ' ').trim();
  if (words.isEmpty) return '';
  return words[0].toUpperCase() + words.substring(1);
}

const Map<String, String> _eventLabels = {
  'PASSWORD_RESET': 'Password reset',
  'PHONE_OTP': 'Phone sign-in code',
  'EMAIL_OTP': 'Email sign-in code',
  'WHATSAPP_OTP': 'WhatsApp sign-in code',
  'MAGIC_LINK': 'Sign-in link',
  'USER_INVITED': 'Someone invited you',
  'JOIN_REQUEST': 'Someone asks to join the shop',
  'JOIN_REQUEST_APPROVED': 'Your join request is approved',
  'JOIN_REQUEST_CANCELLED': 'A join request is cancelled',
  'SALE_COMPLETED': 'Sale completed',
  'REPAIR_READY': 'Repair ready for pickup',
  'LOW_STOCK': 'Stock running low',
};

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
              title: Text(_eventLabels[row['eventType']] ?? _sentence(row['eventType'])),
              subtitle: const Text('Phone notification'),
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
