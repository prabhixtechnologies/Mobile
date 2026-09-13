import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_models.dart';
import '../state/app_state.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _draft = TextEditingController();
  List<ChatMessage> messages = const [];
  List<CannedReply> canned = const [];
  String title = 'Chat';
  bool loading = true;
  bool sending = false;
  String? error;
  String? queuedHint;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final chat = context.read<AppState>().chat;
      final detail = await chat.conversation(widget.conversationId);
      title = detail['subject']?.toString() ??
          detail['visitorName']?.toString() ??
          'Chat';
      messages = await chat.messages(widget.conversationId);
      canned = await chat.cannedReplies();
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _send({bool note = false}) async {
    final text = _draft.text.trim();
    if (text.isEmpty) return;
    setState(() {
      sending = true;
      error = null;
      queuedHint = null;
    });
    try {
      await context.read<AppState>().sendOrQueue(
            conversationId: widget.conversationId,
            body: text,
            note: note,
          );
      _draft.clear();
      await _load();
    } catch (_) {
      setState(() => queuedHint = 'Queued — will send when online');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _assignToMe() async {
    final me = context.read<AppState>().me;
    if (me == null) return;
    try {
      await context.read<AppState>().chat.assign(widget.conversationId, me.id);
      await _load();
    } catch (e) {
      setState(() => error = '$e');
    }
  }

  Future<void> _suggest() async {
    setState(() => sending = true);
    try {
      final text = await context.read<AppState>().chat.aiSuggest(widget.conversationId);
      if (text.isNotEmpty) _draft.text = text;
    } catch (e) {
      setState(() => error = 'AI suggest: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _rewrite(String mode) async {
    if (_draft.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      final text = await context.read<AppState>().chat.aiRewrite(
            widget.conversationId,
            _draft.text,
            mode: mode,
          );
      _draft.text = text;
    } catch (e) {
      setState(() => error = 'AI rewrite: $e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: _assignToMe, icon: const Icon(Icons.person_add_alt_1)),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'suggest') {
                _suggest();
              } else {
                _rewrite(v);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'suggest', child: Text('AI suggest')),
              PopupMenuItem(value: 'improve', child: Text('Rewrite: improve')),
              PopupMenuItem(value: 'shorten', child: Text('Rewrite: shorten')),
              PopupMenuItem(value: 'translate', child: Text('Rewrite: translate')),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                if (queuedHint != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(queuedHint!),
                  ),
                if (canned.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      children: canned
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(c.title),
                                onPressed: () => _draft.text = c.body,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final align = m.isAgent || m.isNote ? Alignment.centerRight : Alignment.centerLeft;
                      return Align(
                        alignment: align,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
                          decoration: BoxDecoration(
                            color: m.isNote
                                ? Colors.amber.shade100
                                : m.isAgent
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(m.body),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Internal note',
                          onPressed: sending ? null : () => _send(note: true),
                          icon: const Icon(Icons.sticky_note_2_outlined),
                        ),
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
                        IconButton.filled(
                          onPressed: sending ? null : () => _send(),
                          icon: const Icon(Icons.send),
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
