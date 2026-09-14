import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/shop_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _query = TextEditingController();
  List<CachedDevice> _live = const [];
  bool _searching = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search(AppState state) async {
    final q = _query.text.trim();
    if (q.length < 2 || !state.online) {
      setState(() => _live = const []);
      return;
    }
    setState(() => _searching = true);
    try {
      final res = await state.api.dio.get<dynamic>(
        'commons/devices',
        queryParameters: {'q': q, 'size': 40},
      );
      if (!mounted) return;
      setState(() {
        _live = pageRows(res.data)
            .map(CachedDevice.fromJson)
            .toList();
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final q = _query.text.trim().toLowerCase();
    final cached = state.commonsDevices.isNotEmpty
        ? state.commonsDevices
        : state.devices;
    final devices = q.length >= 2 && _live.isNotEmpty
        ? _live
        : cached.where((d) {
            if (q.isEmpty) return true;
            return '${d.name} ${d.brandName ?? ''} ${d.modelCode ?? ''}'
                .toLowerCase()
                .contains(q);
          }).toList();

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopSyncBar(state: state),
              ShopHeroHeader(
                title: 'Fitment Catalog',
                subtitle: state.online
                    ? 'Shared with every shop · free'
                    : 'Cached phones · ${cached.length}',
              ),
              ShopSearchField(
                controller: _query,
                hint: 'Search brand, model, code…',
                onChanged: (_) {
                  setState(() {});
                  _search(state);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Text(
                  'Type a phone. See what fits. Shop stock is private.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: devices.isEmpty
                    ? ShopEmpty(
                        title: _query.text.isEmpty
                            ? 'No phones cached yet'
                            : (_searching ? 'Searching…' : 'No matches'),
                        subtitle: state.online
                            ? 'Pull to refresh the shared catalog'
                            : 'Connect to search the live catalog',
                        icon: Icons.public_outlined,
                      )
                    : RefreshIndicator(
                        color: Px.accent,
                        onRefresh: () => state.refreshAll(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 28),
                          itemCount: devices.length,
                          itemBuilder: (context, i) {
                            final d = devices[i];
                            final meta = [
                              if (d.brandName != null) d.brandName!,
                              if (d.modelCode != null) d.modelCode!,
                            ].join(' · ');
                            final seed = (d.brandName ?? d.name).trim();
                            final letter = seed.isEmpty
                                ? '?'
                                : seed[0].toUpperCase();
                            return FadeSlide(
                              delay: Duration(
                                  milliseconds: (i * 24).clamp(0, 200)),
                              dy: 8,
                              child: ShopListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Px.accent, Px.accentStrong],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    letter,
                                    style: GoogleFonts.fraunces(
                                      color: Px.accentInk,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: d.name,
                                subtitle: meta.isEmpty ? 'Catalog phone' : meta,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Px.faint,
                                ),
                                onTap: () =>
                                    context.push('/commons/devices/${d.id}'),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
