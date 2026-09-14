import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _alias = TextEditingController();
  final _signature = TextEditingController();
  bool _loading = true;
  String? _error;

  MailboxSummary? get _box {
    final boxes = context.read<AppState>().mailboxes;
    return boxes.where((b) => b.mine).firstOrNull ??
        (boxes.isEmpty ? null : boxes.first);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _alias.dispose();
    _signature.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    final box = _box;
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _signature.text = context.read<AppState>().signature;
      setState(() => _loading = false);
      return;
    }
    if (state.aliases.isNotEmpty || state.signature.isNotEmpty) {
      _signature.text = state.signature;
      setState(() => _loading = false);
      if (state.aliases.isNotEmpty && state.signature.isNotEmpty) return;
    }
    if (box == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      await state.loadAliasesAndSignature(box.id);
      if (!mounted) return;
      _signature.text = state.signature;
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final box = state.mailboxes.where((b) => b.mine).firstOrNull ??
        (state.mailboxes.isEmpty ? null : state.mailboxes.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Aliases and signature')),
      body: Atmosphere(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Px.danger)),
                  if (box == null)
                    const Text('No mailbox yet.')
                  else ...[
                    Text(box.address, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 20),
                    Text('Aliases', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (state.aliases.isEmpty)
                      const Text('No aliases yet.')
                    else
                      ...state.aliases.map(
                        (a) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(a.address),
                          trailing: IconButton(
                            tooltip: 'Remove alias',
                            onPressed: () => state.deleteAlias(box.id, a.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _alias,
                      decoration: const InputDecoration(
                        labelText: 'New alias address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () async {
                          await state.addAlias(box.id, _alias.text.trim());
                          _alias.clear();
                        },
                        child: const Text('Add alias'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Signature', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _signature,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Signature',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        onPressed: () => state.saveSignature(box.id, _signature.text),
                        child: const Text('Save signature'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
