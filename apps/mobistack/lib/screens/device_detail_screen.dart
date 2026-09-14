import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  Map<String, dynamic>? _device;
  List<Map<String, dynamic>> _fits = const [];
  List<Map<String, dynamic>> _stock = const [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final device = await state.api.dio.get<dynamic>('commons/devices/${widget.deviceId}');
      final fits = await state.api.dio.get<dynamic>('commons/devices/${widget.deviceId}/fits');
      List<Map<String, dynamic>> stock = const [];
      try {
        final stockRes = await state.api.dio
            .get<dynamic>('inventory/catalog-links/devices/${widget.deviceId}/stock');
        stock = pageRows(stockRes.data);
      } catch (_) {
        stock = const [];
      }
      if (!mounted) return;
      setState(() {
        _device = device.data is Map
            ? Map<String, dynamic>.from(device.data as Map)
            : null;
        _fits = pageRows(fits.data);
        _stock = stock;
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

  Future<void> _confirm(String fitmentId) async {
    final state = context.read<AppState>();
    await state.api.dio.post<dynamic>(
      'commons/contributions',
      data: {'kind': 'CONFIRM_FITMENT', 'targetId': fitmentId},
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cached = context.watch<AppState>().commonsDevices.where((d) => d.id == widget.deviceId);
    final fallback = cached.isEmpty ? null : cached.first;
    final name = '${_device?['name'] ?? fallback?.name ?? 'Device'}';
    final brand = '${_device?['brandName'] ?? fallback?.brandName ?? ''}';

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(name, style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Px.muted)),
                      ),
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
                            name,
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
                              if (brand.isNotEmpty) brand,
                              if (_device?['modelCode'] != null) '${_device!['modelCode']}',
                            ].join(' · '),
                            style: const TextStyle(color: Px.accentInk, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('THIS SHOP’S STOCK', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    if (_stock.isEmpty)
                      const Text('No linked stock for this phone.')
                    else
                      ..._stock.map(
                        (row) => ShopListTile(
                          title: '${row['name'] ?? row['sku']}',
                          subtitle: '${row['sku'] ?? ''} · ${row['available'] ?? 0} on hand',
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text('WHAT FITS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    if (_fits.isEmpty)
                      const Text('Nothing linked in the shared catalog yet.')
                    else
                      ..._fits.map((fit) {
                        final id = '${fit['fitmentId'] ?? ''}';
                        return ShopListTile(
                          title: '${fit['componentName'] ?? 'Part'}',
                          subtitle:
                              '${fit['fit'] ?? ''} · ${fit['confirmations'] ?? 0} confirm · ${fit['disputes'] ?? 0} dispute',
                          trailing: IconButton(
                            icon: const Icon(Icons.check_rounded),
                            onPressed: id.isEmpty ? null : () => _confirm(id),
                          ),
                          onTap: () {
                            final componentId = '${fit['componentId'] ?? ''}';
                            if (componentId.isNotEmpty) {
                              context.push('/commons/components/$componentId');
                            }
                          },
                        );
                      }),
                  ],
                ),
              ),
      ),
    );
  }
}
