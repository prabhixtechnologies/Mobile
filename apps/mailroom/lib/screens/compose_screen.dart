import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _to = TextEditingController();
  final _cc = TextEditingController();
  final _bcc = TextEditingController();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String? mailboxId;
  String? draftId;
  bool sending = false;
  String? error;
  String? saveStatus;
  final List<PendingAttachment> _files = [];
  Timer? _autosave;

  @override
  void initState() {
    super.initState();
    final boxes = context.read<AppState>().mailboxes;
    mailboxId = boxes.where((b) => b.mine).firstOrNull?.id ??
        boxes.firstOrNull?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _autosave = Timer.periodic(const Duration(seconds: 8), (_) => _saveDraft());
    }
  }

  Future<void> _loadDraft() async {
    String? id;
    try {
      id = GoRouterState.of(context).uri.queryParameters['draft'];
    } catch (_) {
      id = null;
    }
    if (id == null || id.isEmpty) return;
    try {
      final draft = await context.read<AppState>().mail.draft(id);
      if (!mounted) return;
      setState(() {
        draftId = draft.id;
        mailboxId = draft.mailboxId ?? mailboxId;
        _to.text = draft.to.join(', ');
        _cc.text = draft.cc.join(', ');
        _bcc.text = draft.bcc.join(', ');
        _subject.text = draft.subject ?? '';
        _body.text = draft.preview;
      });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  List<String> _split(String raw) => raw
      .split(RegExp(r'[,;\s]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _saveDraft() async {
    final id = mailboxId;
    if (id == null || sending) return;
    if (_subject.text.trim().isEmpty && _body.text.trim().isEmpty) return;
    try {
      final saved = await context.read<AppState>().mail.saveDraft(
            mailboxId: id,
            to: _split(_to.text),
            cc: _split(_cc.text),
            bcc: _split(_bcc.text),
            subject: _subject.text.trim(),
            bodyHtml: _body.text,
            attachmentIds: _files.map((f) => f.fileId).toList(),
          );
      if (!mounted) return;
      setState(() {
        draftId = saved.id;
        saveStatus = 'Draft saved';
      });
    } catch (_) {
      if (mounted) setState(() => saveStatus = 'Draft not saved');
    }
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles();
    final file = picked?.files.single;
    final path = file?.path;
    if (file == null || path == null) return;
    try {
      final uploaded = await context.read<AppState>().mail.uploadAttachment(path, file.name);
      if (mounted) setState(() => _files.add(uploaded));
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final state = context.read<AppState>();
    final id = mailboxId;
    if (id == null) {
      setState(() => error = 'No mailbox available to send from.');
      return;
    }
    setState(() {
      sending = true;
      error = null;
    });
    try {
      final recipients = _split(_to.text);
      final cc = _split(_cc.text);
      final bcc = _split(_bcc.text);
      if (recipients.isEmpty) {
        throw Exception('Add at least one recipient.');
      }
      final signature = state.signature.trim();
      final body = signature.isEmpty || _body.text.contains(signature)
          ? _body.text
          : '${_body.text.trim()}\n\n$signature';
      await state.mail.compose(
        mailboxId: id,
        to: recipients,
        cc: cc,
        bcc: bcc,
        subject: _subject.text.trim(),
        body: body,
        attachmentIds: _files.map((f) => f.fileId).toList(),
        draftId: draftId,
      );
      await state.loadMailbox();
      if (mounted) context.pop();
    } catch (e) {
      setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boxes = context.watch<AppState>().mailboxes;

    return Scaffold(
      body: Atmosphere(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                      IconButton(
                        tooltip: 'Discard and close',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    Expanded(
                      child: Text(
                        'Compose',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: sending ? null : _send,
                      child: Text(
                        sending ? 'Sending…' : 'Send',
                        style: TextStyle(
                          color: Px.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(error!, style: TextStyle(color: Px.danger)),
                    ),
                  if (boxes.isNotEmpty)
                    DropdownButtonFormField<String>(
                        initialValue: mailboxId,
                      decoration: const InputDecoration(
                        labelText: 'From mailbox',
                        border: OutlineInputBorder(),
                      ),
                      items: boxes
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.id,
                              child: Text('${b.name} · ${b.address}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => mailboxId = v),
                    ),
                  const SizedBox(height: 12),
                    TextField(
                      controller: _to,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    if (saveStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(saveStatus!, style: Theme.of(context).textTheme.bodySmall),
                      ),
                    TextField(
                      controller: _cc,
                      decoration: const InputDecoration(
                        labelText: 'Cc (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bcc,
                      decoration: const InputDecoration(
                        labelText: 'Bcc (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _body,
                    minLines: 12,
                    maxLines: 24,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: const Text('Attach a file'),
                  ),
                  for (final file in _files)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(file.filename),
                      trailing: IconButton(
                        tooltip: 'Remove attachment',
                        onPressed: () => setState(() => _files.remove(file)),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
