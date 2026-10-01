import 'package:prabhix_api_core/prabhix_api_core.dart' show describeError;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prabhix_ui/prabhix_ui.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

/// One hit, flattened from whichever bucket the API returned it in.
class _Hit {
  const _Hit({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.icon,
    this.route,
  });

  final String title;
  final String subtitle;
  final String kind;
  final IconData icon;

  /// Where tapping goes. `null` for a hit with nowhere to open yet, which is rendered as
  /// a non-tappable row rather than a row that silently does nothing.
  final String? route;
}

/// Shop-wide search.
///
/// This replaces a snackbar. The old "More" tab ran the same query and dumped up to eight
/// newline-joined names into a toast that vanished after four seconds and could not be
/// tapped, scrolled or copied — the results were visible but unreachable.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _field =
      TextEditingController(text: widget.initialQuery ?? '');
  final FocusNode _focus = FocusNode();

  PxViewState _state = PxViewState.empty;
  String _error = '';
  List<_Hit> _hits = const [];

  @override
  void initState() {
    super.initState();
    if ((widget.initialQuery ?? '').trim().length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run(widget.initialQuery!));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    }
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _run(String raw) async {
    final term = raw.trim();
    if (term.length < 2) return;
    setState(() => _state = PxViewState.loading);
    try {
      final res = await context.read<AppState>().api.dio.get<dynamic>(
            'search',
            queryParameters: {'q': term},
          );
      if (!mounted) return;
      final hits = _parse(res.data);
      setState(() {
        _hits = hits;
        _state = hits.isEmpty ? PxViewState.empty : PxViewState.ready;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeError(e);
        _state = PxViewState.error;
      });
    }
  }

  /// Flattens the API's buckets into one ranked list.
  ///
  /// The response shape is loose, so every field access is defensive: a search that throws
  /// on an unexpected null is worse than one that shows a row with a thin subtitle.
  List<_Hit> _parse(dynamic data) {
    if (data is! Map) return const [];
    String text(Map row, List<String> keys) {
      for (final k in keys) {
        final v = row[k];
        if (v != null && '$v'.isNotEmpty) return '$v';
      }
      return '';
    }

    final out = <_Hit>[];
    void bucket(String key, String kind, IconData icon, String? Function(Map) route) {
      final rows = data[key];
      if (rows is! List) return;
      for (final row in rows) {
        if (row is! Map) continue;
        final title = text(row, const ['name', 'variantName', 'sku', 'label', 'title']);
        if (title.isEmpty) continue;
        out.add(_Hit(
          title: title,
          subtitle: text(row, const ['sku', 'brand', 'status', 'phone', 'code']),
          kind: kind,
          icon: icon,
          route: route(row),
        ));
      }
    }

    bucket('parts', 'Part', Icons.memory_rounded,
        (r) => r['variantId'] == null ? null : '/movements?variant=${r['variantId']}');
    bucket('devices', 'Device', Icons.smartphone_rounded,
        (r) => r['id'] == null ? null : '/devices/${r['id']}');
    bucket('customers', 'Customer', Icons.person_outline_rounded, (_) => '/customers');
    bucket('sales', 'Sale', Icons.receipt_long_outlined,
        (r) => r['id'] == null ? null : '/invoice/${r['id']}');
    bucket('repairs', 'Repair', Icons.build_outlined, (_) => '/repairs');
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _field,
          focusNode: _focus,
          autofocus: false,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search parts, devices, customers, sales',
            border: InputBorder.none,
            suffixIcon: _field.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _field.clear();
                      setState(() {
                        _hits = const [];
                        _state = PxViewState.empty;
                      });
                      _focus.requestFocus();
                    },
                  ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: _run,
        ),
        actions: [
          IconButton(
            tooltip: 'Scan a barcode',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/scan'),
          ),
        ],
      ),
      body: Atmosphere(
        child: PxStateView(
          state: _state,
          error: (_) => PxError(message: _error, onRetry: () => _run(_field.text)),
          empty: (_) => _field.text.trim().length < 2
              ? const PxEmpty(
                  title: 'Search the shop',
                  message: 'Type at least two characters, or scan a barcode to jump '
                      'straight to a part.',
                  icon: Icons.search_rounded,
                )
              : PxEmpty(
                  title: 'Nothing matched “${_field.text.trim()}”',
                  message: 'Check the spelling, or try a SKU or phone number instead.',
                  icon: Icons.search_off_rounded,
                  actionLabel: 'Scan instead',
                  onAction: () => context.push('/scan'),
                ),
          ready: (_) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            itemCount: _hits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final hit = _hits[i];
              final swatch = pxTagFor(hit.kind, dark: Px.isDark);
              return Material(
                color: Px.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: hit.route == null ? null : () => context.push(hit.route!),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: swatch.bg,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: swatch.border),
                          ),
                          child: Icon(hit.icon, size: 19, color: swatch.ink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hit.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                hit.subtitle.isEmpty ? hit.kind : '${hit.kind} · ${hit.subtitle}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.5, color: Px.muted),
                              ),
                            ],
                          ),
                        ),
                        if (hit.route != null)
                          Icon(Icons.chevron_right_rounded, color: Px.faint),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
