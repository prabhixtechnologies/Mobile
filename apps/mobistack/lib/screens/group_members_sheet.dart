import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

/// Add or remove a shop or a person, and appoint another admin.
Future<void> showGroupMembersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Px.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _GroupMembersSheet(),
  );
}

class _GroupMembersSheet extends StatefulWidget {
  const _GroupMembersSheet();

  @override
  State<_GroupMembersSheet> createState() => _GroupMembersSheetState();
}

class _GroupMembersSheetState extends State<_GroupMembersSheet> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  List<Map<String, dynamic>> _members = const [];
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('groups/${group.id}');
      final data = res.data;
      final rows = data is Map && data['members'] is List ? data['members'] as List : const [];
      if (!mounted) return;
      setState(() {
        _members = [
          for (final row in rows)
            if (row is Map) Map<String, dynamic>.from(row),
        ];
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _message(e));
    }
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await task();
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object error) {
    final data = (error as dynamic).response?.data;
    if (data is Map && data['message'] != null) return '${data['message']}';
    return 'Could not update the group';
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<AppState>().selectedFitmentGroup;
    final owner = group?.isOwner ?? false;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Px.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(group?.name ?? 'Group', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Shops and people who share this fitment.', style: TextStyle(color: Px.muted)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Px.danger)),
            ],
            const SizedBox(height: 16),
            for (final member in _members)
              _MemberTile(
                member: member,
                owner: owner,
                busy: _busy,
                onRemove: () => _run(() => _remove(member)),
                onDismiss: () => _run(() => _setRole(member, 'MEMBER')),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Person email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : () => _run(() => _addPerson('MEMBER')),
                    child: const Text('Add person'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _run(() => _addPerson('ADMIN')),
                    child: const Text('Add as admin'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Shop join code'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _busy ? null : () => _run(_addShop),
              child: const Text('Add shop'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPerson(String role) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.post<dynamic>(
      'groups/${group.id}/people',
      data: {'email': _email.text.trim(), 'role': role},
    );
    _email.clear();
  }

  Future<void> _addShop() async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.post<dynamic>(
      'groups/${group.id}/shops',
      data: {'joinCode': _code.text.trim()},
    );
    _code.clear();
  }

  Future<void> _remove(Map<String, dynamic> member) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    final id = '${member['subjectId']}';
    final kind = '${member['kind']}';
    final path = kind == 'SHOP'
        ? 'groups/${group.id}/shops/$id'
        : 'groups/${group.id}/people/$id';
    await context.read<AppState>().api.dio.delete<dynamic>(path);
  }

  Future<void> _setRole(Map<String, dynamic> member, String role) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.put<dynamic>(
      'groups/${group.id}/people/${member['subjectId']}',
      data: {'role': role},
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.owner,
    required this.busy,
    required this.onRemove,
    required this.onDismiss,
  });

  final Map<String, dynamic> member;
  final bool owner;
  final bool busy;
  final VoidCallback onRemove;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final role = '${member['role'] ?? 'MEMBER'}';
    final locked = role == 'OWNER' || (role == 'ADMIN' && !owner);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${member['label'] ?? ''}'),
      subtitle: Text('${member['kind'] == 'SHOP' ? 'Shop' : 'Person'} · ${role.toLowerCase()}'),
      trailing: locked
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (role == 'ADMIN' && owner)
                  TextButton(onPressed: busy ? null : onDismiss, child: const Text('Dismiss')),
                TextButton(onPressed: busy ? null : onRemove, child: const Text('Remove')),
              ],
            ),
    );
  }
}
