import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.environment.containsKey('FLUTTER_TEST')) return;
      final state = context.read<AppState>();
      if (state.members.isEmpty) {
        state.refreshMembers();
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Atmosphere(
        child: RefreshIndicator(
          color: Px.accent,
          onRefresh: () => state.refreshMembers(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Invite email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          await state.inviteMember(_email.text.trim());
                          _email.clear();
                        },
                  child: const Text('Invite'),
                ),
              ),
              const SizedBox(height: 16),
              if (state.members.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: Text('No members yet.')),
                )
              else
                ...state.members.map(
                  (m) => ListTile(
                    title: Text(m.label),
                    subtitle: Text([m.email, m.role].whereType<String>().join(' · ')),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
