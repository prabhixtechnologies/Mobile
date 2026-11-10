import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

enum ProductivityTab { contacts, tasks, scheduled }

class ProductivityScreen extends StatefulWidget {
  const ProductivityScreen({super.key, this.initial = ProductivityTab.contacts});

  final ProductivityTab initial;

  @override
  State<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends State<ProductivityScreen> {
  late ProductivityTab _tab = widget.initial;
  bool _loading = true;
  String? _error;
  List<MailContact> _contacts = const [];
  List<MailTaskItem> _tasks = const [];
  List<MailDraft> _scheduled = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final mail = context.read<AppState>().mail;
      final contacts = await mail.contacts();
      final tasks = await mail.tasks(status: 'OPEN');
      final scheduled = await mail.scheduledDrafts();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _tasks = tasks;
        _scheduled = scheduled;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_tab) {
          ProductivityTab.contacts => 'Contacts',
          ProductivityTab.tasks => 'Tasks',
          ProductivityTab.scheduled => 'Scheduled',
        }),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Atmosphere(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<ProductivityTab>(
                segments: const [
                  ButtonSegment(value: ProductivityTab.contacts, label: Text('Contacts')),
                  ButtonSegment(value: ProductivityTab.tasks, label: Text('Tasks')),
                  ButtonSegment(value: ProductivityTab.scheduled, label: Text('Scheduled')),
                ],
                selected: {_tab},
                onSelectionChanged: (next) => setState(() => _tab = next.first),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: TextStyle(color: Px.danger)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : switch (_tab) {
                      ProductivityTab.contacts => _ContactsList(contacts: _contacts),
                      ProductivityTab.tasks => _TasksList(tasks: _tasks),
                      ProductivityTab.scheduled => _ScheduledList(
                          drafts: _scheduled,
                          onChanged: _load,
                        ),
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList({required this.contacts});

  final List<MailContact> contacts;

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const Center(child: Text('No contacts yet.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(contact.displayName),
          subtitle: Text(contact.emails.join(', ')),
        );
      },
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks});

  final List<MailTaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No open tasks.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(task.title),
          subtitle: Text('${task.status} · ${task.priority}'),
        );
      },
    );
  }
}

class _ScheduledList extends StatelessWidget {
  const _ScheduledList({required this.drafts, required this.onChanged});

  final List<MailDraft> drafts;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return const Center(child: Text('Nothing scheduled.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: drafts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(draft.subject?.trim().isNotEmpty == true
              ? draft.subject!
              : 'No subject'),
          subtitle: Text(
            'To ${draft.to.join(', ')} · ${draft.scheduledSendAt}\nNot sent yet — waiting for the server worker.',
          ),
          isThreeLine: true,
          trailing: TextButton(
            onPressed: () async {
              await context.read<AppState>().mail.saveDraft(
                    draftId: draft.id,
                    mailboxId: draft.mailboxId,
                    to: draft.to,
                    cc: draft.cc,
                    bcc: draft.bcc,
                    subject: draft.subject,
                    bodyHtml: draft.bodyHtml,
                    attachmentIds: draft.attachmentIds,
                    clearSchedule: true,
                  );
              await onChanged();
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }
}
