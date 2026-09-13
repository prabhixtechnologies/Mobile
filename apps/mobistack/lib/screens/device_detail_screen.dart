import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<AppState>().devices;
    final match = devices.where((d) => d.id == deviceId);
    final device = match.isEmpty ? null : match.first;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(
            device?.name ?? 'Device',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600),
          ),
        ),
        body: device == null
            ? const ShopEmpty(
                title: 'Not in local snapshot',
                subtitle: 'Sync while online to load this device',
                icon: Icons.phone_disabled_outlined,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Px.accent, Px.accentStrong],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: GoogleFonts.fraunces(
                            color: Px.accentInk,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          [
                            if (device.brandName != null) device.brandName!,
                            if (device.modelCode != null) device.modelCode!,
                          ].join(' · '),
                          style: const TextStyle(
                            color: Px.accentInk,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Fact(label: 'Brand', value: device.brandName ?? '—'),
                  _Fact(label: 'Model', value: device.modelCode ?? '—'),
                  _Fact(label: 'Device id', value: device.id),
                  const SizedBox(height: 20),
                  Text(
                    'Fitment lives with your shop catalog. Open Stock to match parts after you confirm the phone.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Px.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Px.faint,
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
