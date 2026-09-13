import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  final _subject = TextEditingController();
  final _body = TextEditingController();
  String? mailboxId;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final boxes = context.read<AppState>().mailboxes;
    mailboxId = boxes.where((b) => b.mine).firstOrNull?.id ??
        boxes.firstOrNull?.id;
  }

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
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
      final recipients = _to.text
          .split(RegExp(r'[,;\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final cc = _cc.text
          .split(RegExp(r'[,;\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (recipients.isEmpty) {
        throw Exception('Add at least one recipient.');
      }
      await state.mail.compose(
        mailboxId: id,
        to: recipients,
        cc: cc,
        subject: _subject.text.trim(),
        body: _body.text,
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
                        style: const TextStyle(
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
                      child: Text(error!, style: const TextStyle(color: Px.danger)),
                    ),
                  if (boxes.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: mailboxId,
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
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cc,
                    decoration: const InputDecoration(
                      labelText: 'Cc (optional)',
                      border: OutlineInputBorder(),
                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
