import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/mail_ui.dart';

class ThreadDetailScreen extends StatefulWidget {
  const ThreadDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  MailThreadSummary? summary;
  List<MailMessage> messages = const [];
  final _reply = TextEditingController();
  String replyMode = 'REPLY';
  String? error;
  bool loading = true;
  bool sending = false;
  final Set<String> collapsed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final mail = context.read<AppState>().mail;
      summary = await mail.threadSummary(widget.threadId);
      messages = await mail.threadMessages(widget.threadId);
      // Gmail-style: collapse older messages, keep newest open.
      if (messages.length > 1) {
        collapsed
          ..clear()
          ..addAll(messages.take(messages.length - 1).map((m) => m.id));
      }
      if (!mounted) return;
      final state = context.read<AppState>();
      await state.markRead(
        summary ??
            MailThreadSummary(
              id: widget.threadId,
              subject: 'Thread',
              unread: true,
            ),
        read: true,
      );
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _send() async {
    if (_reply.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      await context.read<AppState>().mail.reply(
            threadId: widget.threadId,
            body: _reply.text.trim(),
            replyMode: replyMode,
          );
      _reply.clear();
      await _load();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _quoteLatest() {
    if (messages.isEmpty) return;
    final last = messages.last;
    final quoted = last.body
        .split('\n')
        .map((l) => '> $l')
        .join('\n');
    _reply.text =
        '${_reply.text.isEmpty ? '' : '${_reply.text}\n\n'}On ${last.occurredAt ?? 'earlier'}, ${last.fromAddress ?? 'sender'} wrote:\n$quoted\n\n';
    _reply.selection = TextSelection.collapsed(offset: 0);
  }

  Future<void> _showMoveSheet() async {
    final state = context.read<AppState>();
    final folder = await showModalBottomSheet<MailFolder>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(title: Text('Move to…')),
              ...state.folders.map(
                (f) => ListTile(
                  leading: Icon(folderIcon(f.iconHint)),
                  title: Text(f.name),
                  onTap: () => Navigator.pop(context, f),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (folder == null || !mounted) return;
    try {
      await state.mail.moveThreads(
        folderId: folder.id,
        threadIds: [widget.threadId],
      );
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final starred = summary?.starred ?? false;

    return Scaffold(
      backgroundColor: Px.surface,
      appBar: AppBar(
        backgroundColor: Px.surface,
        actions: [
          IconButton(
            tooltip: starred ? 'Unstar' : 'Star',
            onPressed: summary == null
                ? null
                : () async {
                    await state.toggleStar(summary!);
                    setState(() => summary = summary!.copyWith(starred: !starred));
                  },
            icon: Icon(
              starred ? Icons.star_rounded : Icons.star_outline_rounded,
              color: starred ? Px.warning : null,
            ),
          ),
          IconButton(
            tooltip: 'Archive',
            onPressed: () async {
              final undo = await state.moveWithUndo(
                threadIds: [widget.threadId],
                targetKind: 'ARCHIVE',
              );
              // The `context` here is build()'s parameter, which shadows
              // State.context, so `mounted` does not vouch for it.
              if (!context.mounted) return;
              if (undo != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversation ${undo.label}'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => state.undoLastMove(),
                    ),
                  ),
                );
                Navigator.of(context).maybePop();
              }
            },
            icon: const Icon(Icons.archive_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () async {
              final undo = await state.moveWithUndo(
                threadIds: [widget.threadId],
                targetKind: 'TRASH',
              );
              if (!context.mounted) return;
              if (undo != null) Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'unread' && summary != null) {
                await state.markRead(summary!, read: false);
              } else if (v == 'snooze') {
                final tomorrow = DateTime.now().add(const Duration(days: 1));
                final morning = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8);
                await state.snoozeThreads([widget.threadId], morning);
                if (context.mounted) Navigator.of(context).maybePop();
              } else if (v == 'move') {
                await _showMoveSheet();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'unread', child: Text('Mark unread')),
              PopupMenuItem(value: 'snooze', child: Text('Snooze until tomorrow')),
              PopupMenuItem(value: 'move', child: Text('Move to…')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                summary?.subject ?? 'Thread',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      height: 1.25,
                    ),
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(error!, style: TextStyle(color: Px.danger)),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final open = !collapsed.contains(m.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MessageCard(
                          message: m,
                          expanded: open,
                          onToggle: () {
                            setState(() {
                              if (open) {
                                collapsed.add(m.id);
                              } else {
                                collapsed.remove(m.id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          _ComposerBar(
            controller: _reply,
            replyMode: replyMode,
            sending: sending,
            onModeChanged: (m) {
              setState(() => replyMode = m);
              if (m == 'FORWARD') _quoteLatest();
            },
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.expanded,
    required this.onToggle,
  });

  final MailMessage message;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final name = message.fromName?.isNotEmpty == true
        ? message.fromName!
        : (message.fromAddress ?? (message.isOutbound ? 'You' : 'Sender'));

    return Material(
      color: Px.surface,
      elevation: expanded ? 0.5 : 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onToggle,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Px.line.withValues(alpha: 0.8)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    PersonAvatar(label: name, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                              ),
                              Text(
                                relativeTime(message.occurredAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Icon(
                                expanded
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: Px.faint,
                              ),
                            ],
                          ),
                          if (message.fromAddress != null)
                            Text(
                              message.fromAddress!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (expanded) ...[
                  if (message.toAddresses.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'to ${message.toAddresses.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 12),
                  HtmlMailBody(message: message),
                  if (message.attachmentCount > 0) ...[
                    const SizedBox(height: 12),
                    _AttachmentList(messageId: message.id),
                  ],
                ] else if (message.body.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    message.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentList extends StatefulWidget {
  const _AttachmentList({required this.messageId});

  final String messageId;

  @override
  State<_AttachmentList> createState() => _AttachmentListState();
}

class _AttachmentListState extends State<_AttachmentList> {
  List<MailAttachment> files = const [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = await context.read<AppState>().mail.attachmentsForMessage(widget.messageId);
      if (mounted) setState(() => files = loaded);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> _save(MailAttachment file) async {
    try {
      final bytes = await context.read<AppState>().mail.downloadAttachment(file.id);
      final dir = await getApplicationDocumentsDirectory();
      final safe = file.filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final out = File('${dir.path}${Platform.pathSeparator}$safe');
      await out.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${out.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save ${file.filename}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Text(error!, style: TextStyle(color: Px.danger));
    }
    if (files.isEmpty) {
      return const Text('Loading attachments…');
    }
    return Column(
      children: [
        for (final file in files)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.attach_file_rounded),
            title: Text(file.filename),
            subtitle: Text(file.contentType ?? ''),
            onTap: () => _save(file),
          ),
      ],
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.replyMode,
    required this.sending,
    required this.onModeChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final String replyMode;
  final bool sending;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: Px.surface,
          border: Border(top: BorderSide(color: Px.line)),
          boxShadow: [
            BoxShadow(
              color: Px.scrim.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                for (final mode in const [
                  ('REPLY', 'Reply'),
                  ('REPLY_ALL', 'Reply all'),
                  ('FORWARD', 'Forward'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(mode.$2),
                      selected: replyMode == mode.$1,
                      onSelected: (_) => onModeChanged(mode.$1),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: switch (replyMode) {
                        'FORWARD' => 'Add a message…',
                        'REPLY_ALL' => 'Reply to all…',
                        _ => 'Reply…',
                      },
                      filled: true,
                      fillColor: Px.bg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sending ? null : onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: Px.accent,
                    foregroundColor: Px.accentInk,
                  ),
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
