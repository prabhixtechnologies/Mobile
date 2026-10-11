import 'package:prabhix_api_core/prabhix_api_core.dart' show describeError;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key, required this.deviceId, this.categoryCode});

  final String deviceId;

  /// Part type chosen before this phone. When set, this screen stays on that spare.
  final String? categoryCode;

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  Map<String, dynamic>? _device;
  List<Map<String, dynamic>> _fits = const [];
  List<Map<String, dynamic>> _stock = const [];
  List<Map<String, dynamic>> _families = const [];
  String? _error;
  bool _loading = true;
  bool _refreshing = false;

  String get _cacheKey => 'device.${widget.deviceId}.${widget.categoryCode ?? 'all'}';

  String? get _categoryCode {
    final code = widget.categoryCode?.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _applyCache(AppState state) async {
    final cached = await state.sync.commonsPage(_cacheKey);
    if (!mounted || cached == null) return;
    final device = cached['device'];
    setState(() {
      _device = device is Map ? Map<String, dynamic>.from(device) : _device;
      _fits = pageRows(cached['fits']);
      _stock = pageRows(cached['stock']);
      _families = pageRows(cached['families']);
      _loading = false;
    });
  }

  Future<void> _load() async {
    final state = context.read<AppState>();
    await _applyCache(state);
    if (!mounted) return;
    if (!state.online) {
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = _device == null ? 'Offline · this phone is not cached yet' : null;
      });
      return;
    }
    setState(() {
      _refreshing = true;
      _error = null;
      if (_device == null) _loading = true;
    });
    try {
      final deviceFuture = state.api.dio.get<dynamic>(
        'commons/devices',
        queryParameters: {'deviceId': widget.deviceId},
      );
      final fitsFuture = state.api.dio.get<dynamic>(
        'commons/devices/fits',
        queryParameters: {'deviceId': widget.deviceId},
      );
      final familyQuery = <String, dynamic>{'deviceId': widget.deviceId};
      final categoryCode = _categoryCode;
      if (categoryCode != null) familyQuery['categoryCode'] = categoryCode;
      final familyFuture = state.api.dio.get<dynamic>(
        'commons/devices/family',
        queryParameters: familyQuery,
      );
      final usesInventory = state.hasFeature('INVENTORY');
      final stockFuture = () async {
        if (!usesInventory) return null;
        try {
          return await state.api.dio.get<dynamic>(
            'inventory/catalog-links/devices/stock',
            queryParameters: {'catalogDeviceId': widget.deviceId},
          );
        } catch (_) {
          return null;
        }
      }();
      final deviceRes = await deviceFuture;
      final fitsRes = await fitsFuture;
      final stockRes = await stockFuture;
      final familyRes = await familyFuture;
      final device = deviceRes.data is Map
          ? Map<String, dynamic>.from(deviceRes.data as Map)
          : null;
      final fits = pageRows(fitsRes.data);
      final stock = !usesInventory ? const <Map<String, dynamic>>[] : stockRes == null ? _stock : pageRows(stockRes.data);
      final families = pageRows(familyRes.data);
      await state.sync.saveCommonsPage(_cacheKey, {
        'device': device,
        'fits': fits,
        'stock': stock,
        'families': families,
      });
      if (!mounted) return;
      setState(() {
        _device = device;
        _fits = fits;
        _stock = stock;
        _families = families;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _device == null ? describeError(e) : null;
        _loading = false;
        _refreshing = false;
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
    final categoryCode = _categoryCode;
    final category = categoryCode == null ? null : categoryByCode(categoryCode);
    final families = categoryCode == null
        ? _families
        : _families.where((group) {
            final code = '${group['categoryCode'] ?? ''}'.toUpperCase();
            return code.isEmpty || code == categoryCode.toUpperCase();
          }).toList();
    final partIds = families.map((group) => '${group['id'] ?? ''}').where((id) => id.isNotEmpty).toSet();
    final fits = categoryCode == null
        ? _fits
        : _fits.where((fit) => '${fit['categoryCode'] ?? ''}'.toUpperCase() == categoryCode.toUpperCase()).toList();
    final stock = categoryCode == null
        ? _stock
        : _stock.where((row) => partIds.contains('${row['componentId'] ?? ''}')).toList();

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
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
                    if (_refreshing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: TextStyle(color: Px.muted)),
                      ),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
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
                              if (category != null) category.label,
                              if (_device?['modelCode'] != null) '${_device!['modelCode']}',
                            ].join(' · '),
                            style: TextStyle(color: Px.accentInk, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    for (final group in families) ...[
                      const SizedBox(height: 18),
                      Text(
                        '${group['name'] ?? category?.label ?? 'Same part'}'.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 8),
                      ...pageRows(group['members']).map(
                        (member) => ShopListTile(
                          title: '${member['name'] ?? ''}',
                          subtitle: '${member['brandName'] ?? ''}',
                          onTap: () {
                            final id = '${member['id'] ?? ''}';
                            if (id.isNotEmpty && id != widget.deviceId) {
                              final scope = categoryCode == null
                                  ? ''
                                  : '?category=${Uri.encodeQueryComponent(categoryCode)}';
                              context.push('/commons/devices/$id$scope');
                            }
                          },
                        ),
                      ),
                    ],
                    if (context.watch<AppState>().hasFeature('INVENTORY')) ...[
                      const SizedBox(height: 18),
                      Text('THIS SHOP’S STOCK', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      if (stock.isEmpty)
                        Text(category == null
                            ? 'No linked stock for this phone or the models that share its parts.'
                            : 'No linked stock for this ${category.label.toLowerCase()}.')
                      else
                        ...stock.map(
                          (row) => ShopListTile(
                            title: '${row['name'] ?? row['sku']}',
                            subtitle: '${row['sku'] ?? ''} · ${row['available'] ?? 0} on hand',
                          ),
                        ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      category == null ? 'WHAT FITS' : category.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    if (fits.isEmpty)
                      Text(category == null
                          ? 'Nothing linked in the shared catalog yet.'
                          : 'No ${category.label.toLowerCase()} linked for this phone yet.')
                    else
                      ...fits.map((fit) {
                        final id = '${fit['fitmentId'] ?? ''}';
                        return ShopListTile(
                          title: '${fit['componentName'] ?? 'Part'}',
                          subtitle:
                              '${fit['fit'] ?? ''} · ${fit['confirmations'] ?? 0} confirm · ${fit['disputes'] ?? 0} dispute',
                          trailing: IconButton(
                            tooltip: 'Confirm this part fits',
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
