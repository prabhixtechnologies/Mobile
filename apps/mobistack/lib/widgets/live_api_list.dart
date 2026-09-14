import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/chrome.dart';
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
  });

  final String title;
  final String path;
  final String Function(Map<String, dynamic> row) titleOf;
  final String Function(Map<String, dynamic> row)? subtitleOf;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;

  @override
  State<LiveApiListScreen> createState() => _LiveApiListScreenState();
}

class _LiveApiListScreenState extends State<LiveApiListScreen> {
  bool _loading = true;
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

  Future<void> _load() async {
    final state = context.read<AppState>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await state.api.dio.get<dynamic>(widget.path);
      if (!mounted) return;
      setState(() {
        _rows = pageRows(res.data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(widget.title)),
        body: RefreshIndicator(
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
                          itemCount: _rows.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final row = _rows[i];
                            return ShopListTile(
                              title: widget.titleOf(row),
                              subtitle: widget.subtitleOf?.call(row),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}
