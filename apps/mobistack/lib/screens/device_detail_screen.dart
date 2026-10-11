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

List<Map<String, dynamic>> _canonicalFamilyRows(List<Map<String, dynamic>> rows) {
  final dropped = <String>{};
  final imported = rows.where(
    (row) => '${row['description'] ?? ''}'.toLowerCase().contains('combo support'),
  );
  for (final family in rows) {
    final members = pageRows(family['members']);
    if (members.length != 1) continue;
    final member = members.first;
    final expectedName = [
      member['brandName'],
      member['name'],
      member['variant'],
      family['categoryName'],
    ].where((value) => value != null && '$value'.trim().isNotEmpty).join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if ('${family['name'] ?? ''}'.toLowerCase() != expectedName.toLowerCase()) continue;
    final memberId = '${member['id'] ?? ''}';
    final covered = imported.any((candidate) {
      if ('${candidate['categoryCode'] ?? ''}'.toUpperCase() !=
          '${family['categoryCode'] ?? ''}'.toUpperCase()) {
        return false;
      }
      return pageRows(candidate['members']).any(
        (candidateMember) => '${candidateMember['id'] ?? ''}' == memberId,
      );
    });
    if (covered) {
      dropped.add('${family['id'] ?? ''}');
    }
  }
  return rows.where((row) => !dropped.contains('${row['id'] ?? ''}')).toList();
}

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
    if (!mounted) return;
    if (cached != null) {
      final device = cached['device'];
      setState(() {
        _device = device is Map ? Map<String, dynamic>.from(device) : _device;
        _fits = pageRows(cached['fits']);
        _stock = pageRows(cached['stock']);
        _families = pageRows(cached['families']);
        _loading = false;
      });
    }
    final groupId = state.fitmentGroupId;
    final category = _categoryCode;
    if (groupId == null || category == null) return;
    final snapshot = await state.sync.catalogDetail(groupId, widget.deviceId, category);
    if (!mounted || snapshot == null) return;
    final device = snapshot['device'];
    setState(() {
      _device = device is Map ? Map<String, dynamic>.from(device) : _device;
      _fits = pageRows(snapshot['fits']);
      _families = pageRows(snapshot['families']);
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
        _error = _device == null ? 'Offline · this phone has not been saved yet' : null;
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitment confirmed for the community catalog.')),
    );
  }

  Future<void> _dispute(String fitmentId) async {
    final reason = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report a fitment issue'),
        content: TextField(
          controller: reason,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'What did not fit?',
            hintText: 'Describe what you found on the bench',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Submit')),
        ],
      ),
    );
    final note = reason.text.trim();
    reason.dispose();
    if (submitted != true || note.isEmpty || !mounted) return;
    await context.read<AppState>().api.dio.post<dynamic>(
      'commons/contributions',
      data: {'kind': 'DISPUTE_FITMENT', 'targetId': fitmentId, 'reason': note},
    );
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitment issue submitted for review.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cached = context.watch<AppState>().commonsDevices.where((d) => d.id == widget.deviceId);
    final fallback = cached.isEmpty ? null : cached.first;
    final name = '${_device?['name'] ?? fallback?.name ?? 'Device'}';
    final brand = '${_device?['brandName'] ?? fallback?.brandName ?? ''}';
    final categoryCode = _categoryCode;
    final category = categoryCode == null ? null : categoryByCode(categoryCode);
    final families = _canonicalFamilyRows(categoryCode == null
        ? _families
        : _families.where((group) {
            final code = '${group['categoryCode'] ?? ''}'.toUpperCase();
            return code.isEmpty || code == categoryCode.toUpperCase();
          }).toList());
    final partIds = families.map((group) => '${group['id'] ?? ''}').where((id) => id.isNotEmpty).toSet();
    final fits = _fits.where((fit) => partIds.contains('${fit['componentId'] ?? ''}')).toList();
    final fitByComponent = <String, Map<String, dynamic>>{
      for (final fit in fits) '${fit['componentId'] ?? ''}': fit,
    };
    final stock = categoryCode == null
        ? _stock
        : _stock.where((row) => partIds.contains('${row['componentId'] ?? ''}')).toList();
    final compatibleIds = <String>{
      for (final family in families)
        for (final member in pageRows(family['members']))
          if ('${member['id'] ?? ''}' != widget.deviceId) '${member['id'] ?? ''}',
    }..remove('');

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
                    _DeviceCatalogHero(
                      name: name,
                      brand: brand,
                      category: category?.label,
                      modelCode: '${_device?['modelCode'] ?? ''}',
                      familyCount: families.length,
                      compatibleCount: compatibleIds.length,
                    ),
                    const SizedBox(height: 22),
                    _SectionLead(
                      title: category?.label ?? 'Available spares',
                      subtitle: families.length == 1
                          ? 'One spare family covers this phone.'
                          : '${families.length} distinct spare families cover this phone.',
                    ),
                    const SizedBox(height: 12),
                    if (families.isEmpty)
                      ShopEmpty(
                        title: category == null
                            ? 'No compatibility data yet'
                            : '${category.label} is model-specific for now',
                        subtitle: category == null
                            ? 'The phone is listed, but no shared spare families have been confirmed yet.'
                            : 'No shared models are confirmed for this spare yet. The phone remains available in the catalog.',
                        icon: Icons.phone_android_rounded,
                      )
                    else
                      for (var index = 0; index < families.length; index++) ...[
                        _FitmentFamilyCard(
                          index: index,
                          family: families[index],
                          fit: fitByComponent['${families[index]['id'] ?? ''}'],
                          deviceId: widget.deviceId,
                          categoryCode: categoryCode,
                          stock: stock
                              .where((row) => '${row['componentId'] ?? ''}' == '${families[index]['id'] ?? ''}')
                              .toList(),
                          showInventory: context.watch<AppState>().hasFeature('INVENTORY'),
                          busy: _refreshing,
                          onConfirm: _confirm,
                          onDispute: _dispute,
                        ),
                        const SizedBox(height: 14),
                      ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _DeviceCatalogHero extends StatelessWidget {
  const _DeviceCatalogHero({
    required this.name,
    required this.brand,
    required this.category,
    required this.modelCode,
    required this.familyCount,
    required this.compatibleCount,
  });

  final String name;
  final String brand;
  final String? category;
  final String modelCode;
  final int familyCount;
  final int compatibleCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Px.accent, Px.accentStrong],
        ),
        boxShadow: Px.lift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Px.accentInk.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    brand.isEmpty ? 'PH' : brand.substring(0, brand.length >= 2 ? 2 : 1).toUpperCase(),
                    style: TextStyle(color: Px.accentInk, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.fraunces(
                          color: Px.accentInk,
                          fontSize: 29,
                          fontWeight: FontWeight.w600,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        [
                          if (brand.isNotEmpty) brand,
                          if (category != null) category!,
                          if (modelCode.isNotEmpty) modelCode,
                        ].join(' · '),
                        style: TextStyle(color: Px.accentInk.withValues(alpha: 0.86), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Px.scrim.withValues(alpha: 0.12),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              children: [
                Expanded(child: _HeroFact(icon: Icons.inventory_2_outlined, value: '$familyCount', label: 'spares')),
                Container(width: 1, height: 28, color: Px.accentInk.withValues(alpha: 0.22)),
                Expanded(child: _HeroFact(icon: Icons.link_rounded, value: '$compatibleCount', label: 'models')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  const _HeroFact({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: Px.accentInk),
        const SizedBox(width: 7),
        Text('$value $label', style: TextStyle(color: Px.accentInk, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SectionLead extends StatelessWidget {
  const _SectionLead({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('COMPATIBILITY RESULTS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Px.accent)),
              const SizedBox(height: 3),
              Text(title, style: GoogleFonts.fraunces(fontSize: 23, fontWeight: FontWeight.w600, color: Px.ink)),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _FitmentFamilyCard extends StatelessWidget {
  const _FitmentFamilyCard({
    required this.index,
    required this.family,
    required this.fit,
    required this.deviceId,
    required this.categoryCode,
    required this.stock,
    required this.showInventory,
    required this.busy,
    required this.onConfirm,
    required this.onDispute,
  });

  final int index;
  final Map<String, dynamic> family;
  final Map<String, dynamic>? fit;
  final String deviceId;
  final String? categoryCode;
  final List<Map<String, dynamic>> stock;
  final bool showInventory;
  final bool busy;
  final Future<void> Function(String) onConfirm;
  final Future<void> Function(String) onDispute;

  @override
  Widget build(BuildContext context) {
    final members = pageRows(family['members']);
    final self = members.where((member) => '${member['id'] ?? ''}' == deviceId);
    final own = self.isEmpty ? null : self.first;
    final others = members.where((member) => '${member['id'] ?? ''}' != deviceId).toList();
    final fitmentId = '${fit?['fitmentId'] ?? own?['fitmentId'] ?? ''}';
    final confirmedByMe = fit?['confirmedByMe'] == true;
    final disputedByMe = fit?['disputedByMe'] == true;
    final quality = '${fit?['fit'] ?? own?['fit'] ?? 'COMPATIBLE'}'.replaceAll('_', ' ');
    final disputed = fit?['disputed'] == true || own?['disputed'] == true;
    final verified = fit?['verified'] == true || own?['verified'] == true;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Px.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Px.line),
        boxShadow: Px.lift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Px.accentSubtle,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Px.accentSubtleBorder),
                  ),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: TextStyle(color: Px.accentSubtleInk, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${family['categoryName'] ?? family['categoryCode'] ?? 'Spare'}'.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Px.accent, letterSpacing: .8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${family['name'] ?? 'Same part'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        others.isEmpty ? 'Dedicated to this phone' : 'Shared with ${others.length} other models',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Spare details',
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => context.push('/commons/components/${family['id']}'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: BoxDecoration(
              color: disputed ? Px.warningSubtle : Px.surfaceSunken,
              border: Border(top: BorderSide(color: Px.line)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: disputed ? Px.warningSubtle : Px.accentSubtle,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    quality,
                    style: TextStyle(
                      color: disputed ? Px.warningSubtleInk : Px.accentSubtleInk,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      if (fit != null) '${fit!['confirmations'] ?? 0} confirm',
                      if (fit != null) '${fit!['disputes'] ?? 0} dispute',
                      if (verified) 'Verified',
                      if (disputed) 'Disputed',
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: confirmedByMe ? 'You confirmed this fitment' : 'Confirm this fitment',
                  icon: Icon(confirmedByMe ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
                  onPressed: busy || fitmentId.isEmpty || confirmedByMe ? null : () => onConfirm(fitmentId),
                ),
                IconButton(
                  tooltip: disputedByMe ? 'You reported this fitment' : 'Report an issue',
                  icon: Icon(disputedByMe ? Icons.flag_rounded : Icons.flag_outlined),
                  onPressed: busy || fitmentId.isEmpty || disputedByMe ? null : () => onDispute(fitmentId),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COMPATIBLE PHONE MODELS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Px.muted)),
                const SizedBox(height: 9),
                if (others.isEmpty)
                  Row(
                    children: [
                      Icon(Icons.verified_user_outlined, size: 18, color: Px.accent),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Only this phone uses the spare in the current catalog group.')),
                    ],
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final member in others)
                        ActionChip(
                          avatar: const Icon(Icons.phone_android_rounded, size: 16),
                          label: Text('${member['brandName'] ?? ''} ${member['name'] ?? ''}'.trim()),
                          onPressed: () {
                            final memberId = '${member['id'] ?? ''}';
                            if (memberId.isEmpty) return;
                            final scope = categoryCode == null
                                ? ''
                                : '?category=${Uri.encodeQueryComponent(categoryCode!)}';
                            context.push('/commons/devices/$memberId$scope');
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
          if (showInventory)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Px.surfaceSunken.withValues(alpha: 0.62),
                border: Border(top: BorderSide(color: Px.line)),
              ),
              child: stock.isEmpty
                  ? Row(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 18, color: Px.faint),
                        const SizedBox(width: 8),
                        Expanded(child: Text('No shop SKU linked yet.', style: TextStyle(color: Px.muted))),
                      ],
                    )
                  : Column(
                      children: [
                        for (final row in stock)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text('${row['name'] ?? row['sku']}'),
                            subtitle: Text('${row['sku'] ?? ''}'),
                            trailing: Text('${row['available'] ?? 0} on hand'),
                          ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}
