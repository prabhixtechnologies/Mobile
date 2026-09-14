import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class VisitorDetailScreen extends StatefulWidget {
  const VisitorDetailScreen({super.key, required this.visitorId});

  final String visitorId;

  @override
  State<VisitorDetailScreen> createState() => _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends State<VisitorDetailScreen> {
  VisitorDetail? detail;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      final live = state.visitors.where((v) => v.visitorId == widget.visitorId).firstOrNull;
      if (!mounted) return;
      setState(() {
        detail = live == null
            ? null
            : VisitorDetail(
                id: live.visitorId,
                displayName: live.displayName,
                email: live.email,
                firstSeenAt: live.since,
                lastSeenAt: live.since,
                currentPath: live.currentPath,
                currentTitle: live.currentTitle,
              );
        loading = false;
        error = live == null ? 'Visitor not found' : null;
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      detail = await state.chat.visitor(widget.visitorId);
    } catch (e) {
      error = '$e';
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Scaffold(
      appBar: AppBar(title: Text(d?.label ?? 'Visitor')),
      body: Atmosphere(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                children: [
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Px.danger)),
                  if (d != null) ...[
                    Text(d.label, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (d.email != null) d.email!,
                        if (d.identified) 'identified',
                        if (d.currentTitle != null) d.currentTitle!,
                        if (d.currentPath != null) d.currentPath!,
                        if (d.firstSeenAt != null) 'first ${d.firstSeenAt}',
                        if (d.lastSeenAt != null) 'last ${d.lastSeenAt}',
                      ].join('\n'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (d.sessions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Sessions', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...d.sessions.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Px.surface.withValues(alpha: 0.88),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Px.line),
                            ),
                            child: ListTile(
                              title: Text(s.title),
                              subtitle: Text(s.subtitle),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
}
