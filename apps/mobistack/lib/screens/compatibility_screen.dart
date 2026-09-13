import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locked = !state.hasFeature('COMPATIBILITY') &&
        !(state.me?.systemAdmin == true || state.me?.platformAdmin == true);

    final devices = state.devices.where((d) {
      final q = _query.text.trim().toLowerCase();
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
                title: 'Compatibility',
                subtitle: locked
                    ? 'Not on this plan'
                    : (state.online
                        ? '${devices.length} devices in catalog'
                        : 'Cached devices · ${devices.length}'),
              ),
              if (!locked) ...[
                ShopSearchField(
                  controller: _query,
                  hint: 'Search brand, model, code…',
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Text(
                    'Find which parts fit a phone — works offline from your last sync.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              Expanded(
                child: locked
                    ? ShopEmpty(
                        title: 'Compatibility locked',
                        subtitle: 'Upgrade your plan to browse device fitment.',
                        icon: Icons.lock_outline_rounded,
                      )
                    : devices.isEmpty
                        ? ShopEmpty(
                            title: _query.text.isEmpty
                                ? 'No devices cached yet'
                                : 'No matches',
                            subtitle: state.online
                                ? 'Pull to sync the device catalog'
                                : 'Connect during your window to refresh devices',
                            icon: Icons.phone_android_outlined,
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
                                    subtitle: meta.isEmpty ? 'Device' : meta,
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Px.faint,
                                    ),
                                    onTap: () =>
                                        context.push('/devices/${d.id}'),
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
