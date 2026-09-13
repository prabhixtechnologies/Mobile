import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/mail_ui.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _composer = TextEditingController();
  HelpdeskDetail? detail;
  bool loading = true;
  bool sending = false;
  String? error;
  bool noteMode = false;
  String? cannedId;

  static const statuses = [
    'OPEN',
    'PENDING_CUSTOMER',
    'ON_HOLD',
    'RESOLVED',
    'CLOSED',
  ];
  static const priorities = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      detail = await context.read<AppState>().mail.helpdeskThread(widget.threadId);
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _send() async {
    if (_composer.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      final mail = context.read<AppState>().mail;
      if (noteMode) {
        await mail.addNote(
          threadId: widget.threadId,
          body: _composer.text.trim(),
        );
      } else {
        await mail.reply(
          threadId: widget.threadId,
          body: _composer.text.trim(),
          cannedReplyId: cannedId,
        );
      }
      _composer.clear();
      cannedId = null;
      await _load();
      if (!mounted) return;
      await context.read<AppState>().refreshQueue(silent: true);
      context.read<AppState>().bump();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _patch({String? status, String? priority}) async {
    setState(() => sending = true);
    try {
      final ticket = await context.read<AppState>().mail.patchTicket(
            threadId: widget.threadId,
            status: status,
            priority: priority,
          );
      setState(() {
        detail = HelpdeskDetail(
          ticket: ticket,
          messages: detail?.messages ?? const [],
          notes: detail?.notes ?? const [],
        );
      });
      if (!mounted) return;
      await context.read<AppState>().refreshQueue(silent: true);
      context.read<AppState>().bump();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _assignToMe() async {
    final state = context.read<AppState>();
    final me = state.me;
    if (me == null) return;
    setState(() => sending = true);
    try {
      await state.mail.assign(
        threadId: widget.threadId,
        userId: me.id,
      );
      await _load();
      if (!mounted) return;
      await state.refreshQueue(silent: true);
      state.bump();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ticket = detail?.ticket;

    return Scaffold(
      body: Atmosphere(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        ticket?.subject ?? 'Ticket',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(error!, style: const TextStyle(color: Px.danger)),
              ),
            if (ticket != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Px.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Px.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (ticket.referenceKey != null)
                              StatusChip(
                                label: ticket.referenceKey!,
                                tone: ChipTone.accent,
                              ),
                            if (ticket.isBreached)
                              const StatusChip(
                                label: 'SLA BREACH',
                                tone: ChipTone.danger,
                              ),
                            if (ticket.customerEmail != null)
                              StatusChip(label: ticket.customerEmail!),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: statuses.contains(ticket.status)
                                    ? ticket.status
                                    : 'OPEN',
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: statuses
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: sending
                                    ? null
                                    : (v) {
                                        if (v != null) _patch(status: v);
                                      },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: priorities.contains(ticket.priority)
                                    ? ticket.priority
                                    : 'NORMAL',
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: priorities
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: sending
                                    ? null
                                    : (v) {
                                        if (v != null) _patch(priority: v);
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: sending ? null : _assignToMe,
                            icon: const Icon(Icons.person_add_alt_1_rounded),
                            label: Text(
                              ticket.assigneeUserId == state.me?.id
                                  ? 'Assigned to you'
                                  : 'Assign to me',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      children: [
                        ...?detail?.messages.map(
                          (m) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _Bubble(
                              title: m.fromName ??
                                  m.fromAddress ??
                                  (m.isOutbound ? 'Agent' : 'Customer'),
                              body: m.body,
                              time: relativeTime(m.occurredAt),
                              outbound: m.isOutbound,
                            ),
                          ),
                        ),
                        ...?detail?.notes.map(
                          (n) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _Bubble(
                              title: 'Internal note',
                              body: n.body,
                              time: relativeTime(n.createdAt),
                              outbound: false,
                              note: true,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (state.canned.isNotEmpty && !noteMode)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.canned.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = state.canned[i];
                    return ActionChip(
                      label: Text(c.title),
                      onPressed: () {
                        setState(() {
                          cannedId = c.id;
                          _composer.text = c.bodyText;
                        });
                      },
                    );
                  },
                ),
              ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: Px.surface.withValues(alpha: 0.96),
                  border: const Border(top: BorderSide(color: Px.line)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Reply'),
                          selected: !noteMode,
                          onSelected: (_) => setState(() => noteMode = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Internal note'),
                          selected: noteMode,
                          onSelected: (_) => setState(() => noteMode = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _composer,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: noteMode
                                  ? 'Add an internal note…'
                                  : 'Reply to customer…',
                              filled: true,
                              fillColor: Px.bg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: sending ? null : _send,
                          style: IconButton.styleFrom(
                            backgroundColor: Px.accent,
                          ),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.title,
    required this.body,
    required this.time,
    required this.outbound,
    this.note = false,
  });

  final String title;
  final String body;
  final String time;
  final bool outbound;
  final bool note;

  @override
  Widget build(BuildContext context) {
    final bg = note
        ? Px.warning.withValues(alpha: 0.1)
        : outbound
            ? Px.bgAccent.withValues(alpha: 0.55)
            : Px.surface.withValues(alpha: 0.92);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: note ? Px.warning.withValues(alpha: 0.35) : Px.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.labelLarge),
                ),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              body.isEmpty ? '(empty)' : body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Px.ink),
            ),
          ],
        ),
      ),
    );
  }
}
