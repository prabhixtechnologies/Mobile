import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import 'live_api_list.dart';

/// Shop admins approve private-list edits here. Same queue as the web Fitment notes page.
class PendingCompatibilityRequests extends StatefulWidget {
  const PendingCompatibilityRequests({
    super.key,
    required this.generation,
    this.bounded = false,
  });

  final int generation;

  /// Caps the block so it can sit above a grid without pushing the grid off screen.
  final bool bounded;

  @override
  State<PendingCompatibilityRequests> createState() => _PendingCompatibilityRequestsState();
}

class _PendingCompatibilityRequestsState extends State<PendingCompatibilityRequests> {
  List<Map<String, dynamic>> _rows = const [];
  String? _busyId;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant PendingCompatibilityRequests oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.generation != widget.generation) _load();
  }

  bool get _canApprove =>
      context.read<AppState>().me?.hasPermission('COMPATIBILITY_APPROVE') == true;

  Future<void> _load() async {
    if (!_canApprove || !context.read<AppState>().online) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>('compatibility-requests');
      if (!mounted) return;
      setState(() {
        _rows = pageRows(res.data);
        _loaded = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _rows = const [];
          _loaded = true;
        });
      }
    }
  }

  Future<void> _decide(String id, String action) async {
    setState(() => _busyId = id);
    try {
      await context.read<AppState>().api.dio.post<dynamic>(
        'compatibility-requests/$action',
        queryParameters: {'id': id},
      );
      if (!mounted) return;
      setState(() => _rows = _rows.where((row) => '${row['id']}' != id).toList());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update that request')),
      );
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  String _label(String action) {
    return switch (action) {
      'ADD_DEVICE' => 'Add a phone',
      'REMOVE_DEVICE' => 'Remove a phone',
      _ => action.replaceAll('_', ' '),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _rows.isEmpty) return const SizedBox.shrink();
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Pending changes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final row in _rows)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label('${row['action'] ?? ''}')),
                  if ('${row['reason'] ?? ''}'.isNotEmpty)
                    Text('${row['reason']}', style: TextStyle(color: Px.muted)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _busyId == null ? () => _decide('${row['id']}', 'reject') : null,
                        child: const Text('Reject'),
                      ),
                      FilledButton(
                        onPressed: _busyId == null ? () => _decide('${row['id']}', 'approve') : null,
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: widget.bounded
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [body],
              ),
            )
          : body,
    );
  }
}
