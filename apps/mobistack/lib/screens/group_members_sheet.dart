import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<Map<String, dynamic>> _requests = const [];
  String? _joinCode;
  String? _error;
  bool _busy = false;
  Map<String, dynamic>? _open;

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
    final dio = context.read<AppState>().api.dio;
    try {
      final res = await dio.get<dynamic>(
        'groups',
        queryParameters: {'id': group.id},
      );
      final data = res.data;
      final rows = data is Map && data['members'] is List ? data['members'] as List : const [];
      final code = data is Map ? data['joinCode']?.toString() : null;
      final asked = await dio.get<dynamic>(
        'groups/requests',
        queryParameters: {'id': group.id},
      );
      final waiting = asked.data is List ? asked.data as List : const [];
      if (!mounted) return;
      setState(() {
        _members = [
          for (final row in rows)
            if (row is Map) Map<String, dynamic>.from(row),
        ];
        _requests = [
          for (final row in waiting)
            if (row is Map) Map<String, dynamic>.from(row),
        ];
        _joinCode = code == null || code.isEmpty ? null : code;
        _error = null;
        if (_open != null) {
          final id = '${_open!['subjectId']}';
          Map<String, dynamic>? still;
          for (final row in _members) {
            if ('${row['subjectId']}' == id) still = row;
          }
          _open = still;
        }
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
    if (error is FormatException) return error.message;
    final data = (error as dynamic).response?.data;
    if (data is Map) {
      final violations = data['violations'];
      if (violations is List && violations.isNotEmpty && violations.first is Map) {
        final detail = violations.first['message'];
        if (detail != null && '$detail'.trim().isNotEmpty) return '$detail';
      }
      if (data['message'] != null) return '${data['message']}';
    }
    return 'Could not update the group';
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<AppState>().selectedFitmentGroup;
    final owner = group?.isOwner ?? false;
    final media = MediaQuery.of(context);
    final open = _open;
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
          child: open == null
              ? _list(group?.name ?? 'Group', owner)
              : _detail(open, owner),
        ),
      ),
    );
  }

  Widget _list(String name, bool owner) {
    final shops = _members.where((member) => member['kind'] == 'SHOP').length;
    final people = _members.length - shops;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        const _Handle(),
        Text(name, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          _members.isEmpty ? 'No one is in this group yet' : '$shops shops · $people people',
          style: TextStyle(color: Px.muted),
        ),
        if (_joinCode != null) ...[
          const SizedBox(height: 12),
          _CodeChip(code: _joinCode!),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Px.danger)),
        ],
        if (_requests.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Waiting to join', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'These shops paid with the group code. The catalog opens for them when you admit them.',
            style: TextStyle(color: Px.muted),
          ),
          for (final request in _requests)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${request['shopName'] ?? 'Shop'}'),
              subtitle: Text('Asked by ${request['askedBy'] ?? 'the owner'}'),
              trailing: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => _run(() => _decide(request, 'reject')),
                    child: const Text('Refuse'),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : () => _run(() => _decide(request, 'approve')),
                    child: const Text('Admit'),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        _Panel(
          children: [
            for (var i = 0; i < _members.length; i++)
              _MemberRow(
                member: _members[i],
                divider: i < _members.length - 1,
                onTap: () => setState(() => _open = _members[i]),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Text('Invite a person', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
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
        const SizedBox(height: 22),
        Text('Add a shop', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Use the shop\'s own join code.', style: TextStyle(color: Px.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          decoration: const InputDecoration(labelText: 'Shop join code'),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : () => _run(_addShop),
          child: const Text('Add shop'),
        ),
      ],
    );
  }

  Widget _detail(Map<String, dynamic> member, bool owner) {
    final shop = member['kind'] == 'SHOP';
    final role = '${member['role'] ?? 'MEMBER'}';
    final locked = role == 'OWNER' || (role == 'ADMIN' && !owner);
    final label = '${member['label'] ?? ''}';
    final facts = <(String, String)>[
      if (_text(member['email']) != null) ('Email', _text(member['email'])!),
      if (_text(member['phone']) != null) ('Phone', _text(member['phone'])!),
      if (_text(member['place']) != null) ('Place', _text(member['place'])!),
      if (shop && _text(member['planName']) != null) ('Plan', _text(member['planName'])!),
      if (shop) ('Payment', _payment(member)),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      children: [
        const _Handle(),
        Row(
          children: [
            IconButton(
              tooltip: 'Members',
              onPressed: () => setState(() => _open = null),
              icon: Icon(Icons.arrow_back_rounded, color: Px.ink),
            ),
            Text('Members', style: TextStyle(color: Px.muted)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Mark(letter: _initials(label)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(shop ? 'Shop' : _roleLabel(role), style: TextStyle(color: Px.muted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Panel(
          children: [
            if (facts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('No contact or payment is on record.', style: TextStyle(color: Px.muted)),
              )
            else
              for (var i = 0; i < facts.length; i++)
                _Fact(
                  label: facts[i].$1,
                  value: facts[i].$2,
                  divider: i < facts.length - 1,
                  emphasize: facts[i].$1 == 'Payment',
                  ended: facts[i].$1 == 'Payment' && _ended(member),
                ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: Px.danger)),
        ],
        if (role == 'ADMIN' && owner) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _busy ? null : () => _run(() => _setRole(member, 'MEMBER')),
            child: const Text('Dismiss as admin'),
          ),
        ],
        if (!locked) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy ? null : () => _confirmRemove(member),
            child: Text('Remove from the group', style: TextStyle(color: Px.danger)),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmRemove(Map<String, dynamic> member) async {
    final label = '${member['label'] ?? 'This member'}';
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Remove from the group'),
        content: Text('$label will leave this fitment.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Remove')),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    await _run(() => _remove(member));
  }

  Future<void> _addPerson(String role) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    final email = _email.text.trim();
    final at = email.indexOf('@');
    if (at <= 0 || at != email.lastIndexOf('@') || at >= email.length - 1 || email.contains(' ')) {
      throw const FormatException('Enter the person\'s email address.');
    }
    await context.read<AppState>().api.dio.post<dynamic>(
      'groups/people',
      queryParameters: {'id': group.id},
      data: {'email': email, 'role': role},
    );
    _email.clear();
  }

  Future<void> _decide(Map<String, dynamic> request, String action) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.post<dynamic>(
      'groups/requests/$action',
      queryParameters: {'id': group.id, 'requestId': '${request['id']}'},
    );
  }

  Future<void> _addShop() async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.post<dynamic>(
      'groups/shops',
      queryParameters: {'id': group.id},
      data: {'joinCode': _code.text.trim()},
    );
    _code.clear();
  }

  Future<void> _remove(Map<String, dynamic> member) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    final id = '${member['subjectId']}';
    final kind = '${member['kind']}';
    if (kind == 'SHOP') {
      await context.read<AppState>().api.dio.delete<dynamic>(
        'groups/shops',
        queryParameters: {'id': group.id, 'workspaceId': id},
      );
    } else {
      await context.read<AppState>().api.dio.delete<dynamic>(
        'groups/people',
        queryParameters: {'id': group.id, 'userId': id},
      );
    }
  }

  Future<void> _setRole(Map<String, dynamic> member, String role) async {
    final group = context.read<AppState>().selectedFitmentGroup;
    if (group == null) return;
    await context.read<AppState>().api.dio.put<dynamic>(
      'groups/people',
      queryParameters: {'id': group.id, 'userId': '${member['subjectId']}'},
      data: {'role': role},
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Px.line,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Px.surfaceSunken,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: code));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied $code')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group code', style: TextStyle(color: Px.muted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(code, style: TextStyle(color: Px.ink, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(Icons.copy_rounded, color: Px.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Px.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Px.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.divider,
    required this.onTap,
  });

  final Map<String, dynamic> member;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shop = member['kind'] == 'SHOP';
    final label = '${member['label'] ?? ''}';
    final role = _roleLabel('${member['role'] ?? 'MEMBER'}');
    final payment = shop ? _payment(member) : _text(member['email']);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: divider ? Border(bottom: BorderSide(color: Px.line)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                _Mark(letter: _initials(label)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        payment == null ? (shop ? 'Shop' : role) : (shop ? payment : '$role · $payment'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: shop && _ended(member) ? Px.warning : Px.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Px.faint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    required this.divider,
    this.emphasize = false,
    this.ended = false,
  });

  final String label;
  final String value;
  final bool divider;
  final bool emphasize;
  final bool ended;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider ? Border(bottom: BorderSide(color: Px.line)) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(label, style: TextStyle(color: Px.muted)),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: emphasize ? (ended ? Px.warning : Px.ink) : Px.ink,
                  fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Px.accentSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        letter,
        style: TextStyle(color: Px.accentSubtleInk, fontWeight: FontWeight.w700),
      ),
    );
  }
}

String? _text(Object? value) {
  final text = '$value'.trim();
  if (value == null || text.isEmpty || text == 'null') return null;
  return text;
}

String _roleLabel(String role) {
  return switch (role) {
    'OWNER' => 'Owner',
    'ADMIN' => 'Admin',
    _ => 'Person',
  };
}

String _initials(String label) {
  final parts = label.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first.substring(0, 1).toUpperCase();
  if (parts.length == 1) return first;
  return '$first${parts.last.substring(0, 1).toUpperCase()}';
}

String _payment(Map<String, dynamic> member) {
  final when = DateTime.tryParse('${member['paidUntil'] ?? ''}')?.toLocal();
  final status = '${member['planStatus'] ?? ''}'.toUpperCase();
  if (when == null) {
    if (status.isEmpty || status == 'NONE' || status == 'NULL') return 'No payment on record';
    return _statusLabel(status);
  }
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final date = '${when.day} ${months[when.month - 1]} ${when.year}';
  if (_ended(member)) return 'Ended $date';
  return 'Paid until $date';
}

bool _ended(Map<String, dynamic> member) {
  final when = DateTime.tryParse('${member['paidUntil'] ?? ''}')?.toLocal();
  final status = '${member['planStatus'] ?? ''}'.toUpperCase();
  if (status == 'PAST_DUE') return true;
  if (when == null) return false;
  return !when.isAfter(DateTime.now());
}

String _statusLabel(String status) {
  return switch (status) {
    'ACTIVE' => 'Active',
    'PAST_DUE' => 'Past due',
    _ => status,
  };
}
