import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/shop_ui.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  List<Map<String, dynamic>> _threads = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    if (!state.online) return;
    try {
      final res = await state.api.dio.get<dynamic>('support/conversations');
      final data = res.data;
      if (!mounted || data is! List) return;
      setState(() {
        _threads = [
          for (final row in data)
            if (row is Map) Map<String, dynamic>.from(row),
        ];
      });
    } catch (_) {}
  }

  Future<void> _reply(String id) async {
    final values = await showDialog<String>(
      context: context,
      builder: (context) {
        final field = TextEditingController();
        return AlertDialog(
          title: const Text('Reply'),
          content: TextField(controller: field, decoration: const InputDecoration(labelText: 'Message')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, field.text.trim()), child: const Text('Send')),
          ],
        );
      },
    );
    if (values == null || values.isEmpty || !mounted) return;
    final error = await context.read<AppState>().onlinePost('support/conversations/$id/messages', {
      'message': values,
      'channel': 'MOBILE',
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Reply sent')));
    await _load();
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final subject = _subject.text.trim();
    final message = _message.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a subject and a message')),
      );
      return;
    }
    final state = context.read<AppState>();
    if (!state.online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline · connect to send support')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await state.api.dio.post<dynamic>(
        'support/conversations',
        data: {
          'subject': subject,
          'message': message,
          'channel': 'MOBILE',
        },
      );
      if (!mounted) return;
      _subject.clear();
      _message.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: 'Support',
      subtitle: 'A note for the MobiStack team',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          for (final thread in _threads)
            ShopListTile(
              title: '${thread['subject'] ?? 'Support'}',
              subtitle: '${thread['status'] ?? ''}',
              onTap: () => _reply('${thread['id']}'),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Subject'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            decoration: const InputDecoration(labelText: 'Message'),
            minLines: 4,
            maxLines: 8,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(_sending ? 'Sending…' : 'Send'),
          ),
        ],
      ),
    );
  }
}
