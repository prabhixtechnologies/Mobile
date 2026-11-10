import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

enum ProductivityTab { contacts, tasks, scheduled, attachments, templates }

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
  List<MailAttachmentLibraryItem> _attachments = const [];
  List<MailTemplateItem> _templates = const [];

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
      final attachments = await mail.attachmentLibrary();
      final templates = await mail.personalTemplates();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _tasks = tasks;
        _scheduled = scheduled;
        _attachments = attachments;
        _templates = templates;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeTask(MailTaskItem task) async {
    try {
      await context.read<AppState>().mail.updateTaskStatus(task.id, 'DONE');
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
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
          ProductivityTab.attachments => 'Attachments',
          ProductivityTab.templates => 'Templates',
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<ProductivityTab>(
                segments: const [
                  ButtonSegment(value: ProductivityTab.contacts, label: Text('Contacts')),
                  ButtonSegment(value: ProductivityTab.tasks, label: Text('Tasks')),
                  ButtonSegment(value: ProductivityTab.scheduled, label: Text('Scheduled')),
                  ButtonSegment(value: ProductivityTab.attachments, label: Text('Files')),
                  ButtonSegment(value: ProductivityTab.templates, label: Text('Templates')),
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
                      ProductivityTab.tasks => _TasksList(
                          tasks: _tasks,
                          onComplete: _completeTask,
                        ),
                      ProductivityTab.scheduled => _ScheduledList(
                          drafts: _scheduled,
                          onChanged: _load,
                        ),
                      ProductivityTab.attachments => _AttachmentsList(items: _attachments),
                      ProductivityTab.templates => _TemplatesList(items: _templates),
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
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final email = contact.emails.isEmpty ? '' : contact.emails.first;
        return ListTile(
          title: Text(contact.displayName),
          subtitle: email.isEmpty ? null : Text(email),
        );
      },
    );
  }
}

class _TasksList extends StatelessWidget {
  const _TasksList({required this.tasks, required this.onComplete});

  final List<MailTaskItem> tasks;
  final Future<void> Function(MailTaskItem task) onComplete;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No open tasks.'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text('${task.status} · ${task.priority}'),
          trailing: IconButton(
            tooltip: 'Mark done',
            onPressed: () => onComplete(task),
            icon: const Icon(Icons.check_circle_outline),
          ),
        );
      },
    );
  }
}

class _AttachmentsList extends StatelessWidget {
  const _AttachmentsList({required this.items});

  final List<MailAttachmentLibraryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No attachments in your mailboxes yet.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: const Icon(Icons.attach_file),
          title: Text(item.filename),
          subtitle: Text(
            [
              if (item.contentType != null) item.contentType!,
              if (item.sizeBytes > 0) '${(item.sizeBytes / 1024).toStringAsFixed(0)} KB',
            ].join(' · '),
          ),
        );
      },
    );
  }
}

class _TemplatesList extends StatelessWidget {
  const _TemplatesList({required this.items});

  final List<MailTemplateItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No personal templates yet. Create them on web Settings.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.subject?.isNotEmpty == true ? item.subject! : 'No subject'),
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
    return ListView.builder(
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return ListTile(
          title: Text(draft.subject?.isNotEmpty == true ? draft.subject! : '(no subject)'),
          subtitle: Text(draft.scheduledSendAt ?? 'Scheduled'),
          trailing: IconButton(
            tooltip: 'Cancel schedule',
            onPressed: () async {
              await context.read<AppState>().mail.discardDraft(draft.id);
              await onChanged();
            },
            icon: const Icon(Icons.cancel_outlined),
          ),
        );
      },
    );
  }
}
