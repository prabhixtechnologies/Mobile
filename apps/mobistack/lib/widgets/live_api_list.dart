import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/shop_ui.dart';

List<Map<String, dynamic>> pageRows(dynamic data) {
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['content', 'items', 'rows']) {
      final value = map[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }
    }
  }
  if (data is List) {
    return data
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
  return const [];
}

/// Simple authenticated list against a live `/api/v1` path.
class LiveApiListScreen extends StatefulWidget {
  const LiveApiListScreen({
    super.key,
    required this.title,
    required this.path,
    required this.titleOf,
    this.subtitleOf,
    this.emptyTitle = 'Nothing here yet',
    this.emptySubtitle = 'The list fills when the shop has rows.',
    this.emptyIcon = Icons.inbox_outlined,
    this.onTap,
    this.floatingActionButton,
  });

  final String title;
  final String path;
  final String Function(Map<String, dynamic> row) titleOf;
  final String Function(Map<String, dynamic> row)? subtitleOf;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final void Function(Map<String, dynamic> row)? onTap;
  final Widget? floatingActionButton;

  @override
  State<LiveApiListScreen> createState() => _LiveApiListScreenState();
}

class _LiveApiListScreenState extends State<LiveApiListScreen> {
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  List<Map<String, dynamic>> _rows = const [];

  @override
  void initState() {
    super.initState();
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _loading = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant LiveApiListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) _load();
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    final cached = await state.sync.cachedList(widget.path);
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        _rows = cached;
        _loading = false;
        _error = null;
      });
    }
    if (!state.online) {
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = _rows.isEmpty ? 'Offline · nothing saved for this list yet' : null;
      });
      return;
    }
    setState(() {
      _refreshing = _rows.isNotEmpty;
      _loading = _rows.isEmpty;
      _error = null;
    });
    try {
      final res = await state.api.dio.get<dynamic>(widget.path);
      final rows = pageRows(res.data);
      await state.sync.saveList(widget.path, rows);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _rows.isEmpty ? '$e' : null;
        _loading = false;
        _refreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      title: widget.title,
      floatingActionButton: widget.floatingActionButton,
      child: RefreshIndicator(
          onRefresh: _load,
          child: _loading && _rows.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _rows.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        ShopEmpty(
                          title: 'Could not load',
                          subtitle: _error!,
                          icon: Icons.wifi_off_rounded,
                        ),
                      ],
                    )
                  : _rows.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            ShopEmpty(
                              title: widget.emptyTitle,
                              subtitle: widget.emptySubtitle,
                              icon: widget.emptyIcon,
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _rows.length + (_refreshing ? 1 : 0),
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            if (_refreshing && i == 0) {
                              return const LinearProgressIndicator(minHeight: 2);
                            }
                            final row = _rows[_refreshing ? i - 1 : i];
                            return ShopListTile(
                              title: widget.titleOf(row),
                              subtitle: widget.subtitleOf?.call(row),
                              onTap: widget.onTap == null ? null : () => widget.onTap!(row),
                            );
                          },
                        ),
      ),
    );
  }
}
