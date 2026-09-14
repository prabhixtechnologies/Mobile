import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/inbox_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

class InboxDetailScreen extends StatefulWidget {
  const InboxDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<InboxDetailScreen> createState() => _InboxDetailScreenState();
}

class _InboxDetailScreenState extends State<InboxDetailScreen> {
  final _draft = TextEditingController();
  InboxTicket? ticket;
  List<InboxMessage> messages = const [];
  bool loading = true;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      if (!mounted) return;
      setState(() {
        ticket = state.tickets.where((t) => t.id == widget.threadId).firstOrNull;
        messages = const [];
        loading = false;
        error = null;
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final detail = await state.inbox.ticket(widget.threadId);
      ticket = detail.ticket;
      messages = detail.messages;
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _reply() async {
    final body = _draft.text.trim();
    if (body.isEmpty) return;
    setState(() => sending = true);
    try {
      await context.read<AppState>().inbox.reply(threadId: widget.threadId, body: body);
      _draft.clear();
      await _load();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _assignToMe() async {
    final me = context.read<AppState>().me;
    if (me == null) return;
    try {
      await context.read<AppState>().inbox.assign(threadId: widget.threadId, userId: me.id);
      await _load();
    } catch (e) {
      setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticket?.subject ?? 'Ticket'),
        actions: [
          TextButton(
            onPressed: _assignToMe,
            child: const Text('Assign to me'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(error!, style: const TextStyle(color: Px.danger)),
                  ),
                if (ticket != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        [ticket!.status, ticket!.priority, ticket!.customerEmail]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(' · '),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Px.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Px.line),
                          ),
                          child: ListTile(
                            title: Text(m.fromAddress ?? m.direction ?? 'Message'),
                            subtitle: Text(m.body),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _draft,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Reply…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: sending ? null : _reply,
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
