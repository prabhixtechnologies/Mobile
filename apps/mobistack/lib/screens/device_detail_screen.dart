import 'dart:async';

import 'package:prabhix_api_core/prabhix_api_core.dart' show describeError;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import '../services/catalog_projection.dart';
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
  Map<String, dynamic>? _proposal;
  final Map<String, String> _myVotes = {};
  String? _brandLogo;

  String get _cacheKey => 'device.${widget.deviceId}.${widget.categoryCode ?? 'all'}';

  String? get _categoryCode {
    final code = widget.categoryCode?.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  bool _listsAnotherPhone(Map<String, dynamic> family) {
    for (final member in pageRows(family['members'])) {
      final id = '${member['id'] ?? member['deviceId'] ?? ''}';
      if (id.isNotEmpty && id != widget.deviceId) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _loadProposal();
    });
  }

  String get _proposalKey => 'catalog.proposal.${widget.deviceId}.${_categoryCode ?? 'all'}';

  Future<void> _loadProposal() async {
    final saved = await context.read<AppState>().sync.readJson(_proposalKey);
    if (!mounted || saved == null) return;
    setState(() => _proposal = saved);
  }

  /// True when the installed snapshot already has this phone, so the screen can paint without waiting.
  Future<bool> _applyCache(AppState state) async {
    var fromSnapshot = false;
    final cached = await state.sync.commonsPage(_cacheKey);
    if (!mounted) return false;
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
    if (groupId == null || groupId.isEmpty) {
      unawaited(_loadBrandMark(state));
      return false;
    }
    final snapshot = await state.sync.catalogDetail(groupId, widget.deviceId, _categoryCode ?? '');
    if (!mounted || snapshot == null) {
      unawaited(_loadBrandMark(state));
      return false;
    }
    fromSnapshot = true;
    final device = snapshot['device'];
    setState(() {
      _device = device is Map ? Map<String, dynamic>.from(device) : _device;
      _fits = pageRows(snapshot['fits']);
      _families = pageRows(snapshot['families']);
      _loading = false;
    });
    unawaited(_loadBrandMark(state));
    return fromSnapshot;
  }

  Future<void> _loadBrandMark(AppState state) async {
    final brandId = '${_device?['brandId'] ?? ''}';
    final brandName = '${_device?['brandName'] ?? ''}'.trim().toLowerCase();
    if (brandId.isEmpty && brandName.isEmpty) return;
    final rows = await state.sync.readCatalogList('commons/brands', const {});
    if (!mounted || rows == null) return;
    Map<String, dynamic>? match;
    for (final row in rows) {
      if (brandId.isNotEmpty && '${row['id'] ?? ''}' == brandId) {
        match = row;
        break;
      }
      if (match == null && brandName.isNotEmpty && '${row['name'] ?? ''}'.trim().toLowerCase() == brandName) {
        match = row;
      }
    }
    final logo = _brandSvg(match?['logo']);
    if (logo == _brandLogo) return;
    setState(() => _brandLogo = logo);
  }

  Future<void> _load({bool forceNetwork = false}) async {
    final state = context.read<AppState>();
    final fromSnapshot = await _applyCache(state);
    if (!mounted) return;
    if (!forceNetwork && fromSnapshot) {
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = null;
      });
      if (state.hasFeature('INVENTORY')) unawaited(_refreshStock(state));
      return;
    }
    setState(() {
      _refreshing = true;
      _error = null;
      if (_device == null) _loading = true;
    });
    final failure = await _loadFromNetwork(state);
    if (!mounted || failure == null) return;
    setState(() {
      _loading = false;
      _refreshing = false;
      _error = _device == null
          ? (state.online ? failure : 'Offline · this phone has not been saved yet')
          : null;
    });
  }

  /// Null when the phone page was stored. A thrown request becomes the message.
  Future<String?> _loadFromNetwork(AppState state) async {
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
      if (!mounted) return null;
      setState(() {
        _device = device;
        _fits = fits;
        _stock = stock;
        _families = families;
        _loading = false;
        _refreshing = false;
      });
      unawaited(_loadBrandMark(state));
      return null;
    } catch (e) {
      return describeError(e);
    }
  }

  Future<void> _refreshStock(AppState state) async {
    try {
      final stockRes = await state.api.dio.get<dynamic>(
        'inventory/catalog-links/devices/stock',
        queryParameters: {'catalogDeviceId': widget.deviceId},
      );
      if (!mounted) return;
      setState(() => _stock = pageRows(stockRes.data));
    } catch (_) {}
  }

  Future<void> _confirm(String fitmentId, String label) async {
    final state = context.read<AppState>();
    await state.api.dio.post<dynamic>(
      'commons/contributions',
      data: {'kind': 'CONFIRM_FITMENT', 'targetId': fitmentId},
    );
    if (!mounted) return;
    setState(() => _myVotes[fitmentId] = 'confirm');
    await _load(forceNetwork: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Confirmed $label for the community catalog.')),
    );
  }

  Future<void> _dispute(String fitmentId, String label) async {
    final reason = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Report $label'),
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
    if (!mounted) return;
    setState(() => _myVotes[fitmentId] = 'dispute');
    await _load(forceNetwork: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report for $label is in review.')),
    );
  }

  Future<void> _propose() async {
    final code = _categoryCode;
    final category = code == null ? null : categoryByCode(code);
    final state = context.read<AppState>();
    if (code == null || category == null) return;
    if (!state.online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to send a proposal.')),
      );
      return;
    }
    final groupId = state.fitmentGroupId;
    if (groupId == null || groupId.isEmpty) return;
    final draft = await showDialog<_ProposalDraft>(
      context: context,
      builder: (dialogContext) => _ProposeCompatibilityDialog(
        spare: category.label,
        loadBrands: () async {
          final rows = await state.sync.readCatalogList('commons/brands', {'categoryCode': code});
          return rows ?? const [];
        },
        loadModels: (brandId) async {
          final rows = await state.sync.readCatalogList('commons/devices', {
            'brandId': brandId,
            'categoryCode': code,
          });
          final known = rows ?? const <Map<String, dynamic>>[];
          final flagged = known.any((row) => row.containsKey('shared'));
          final already = <String>{
            widget.deviceId,
            for (final family in _families)
              for (final member in pageRows(family['members'])) '${member['id'] ?? ''}',
          }..remove('');
          return [
            for (final row in known)
              if (!already.contains('${row['id']}') && (!flagged || row['shared'] == true)) row,
          ];
        },
      ),
    );
    if (draft == null || !mounted) return;
    final detail = await state.sync.catalogDetail(groupId, draft.modelId, code);
    final families = pageRows(detail?['families']);
    if (!mounted) return;
    if (families.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That model has no shared spare for this part.')),
      );
      return;
    }
    var family = families.first;
    if (families.length > 1) {
      final picked = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text('Which ${category.label}?'),
          children: [
            for (final row in families)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, row),
                child: Text('${row['name'] ?? category.label}'),
              ),
          ],
        ),
      );
      if (picked == null || !mounted) return;
      family = picked;
    }
    final componentId = '${family['id'] ?? ''}';
    if (componentId.isEmpty) return;
    try {
      final res = await state.api.dio.post<dynamic>(
        'commons/contributions',
        data: {
          'kind': 'ADD_FITMENT',
          'reason': 'Same ${category.label} as ${draft.brand} ${draft.model}',
          'payload': {
            'componentId': componentId,
            'deviceId': widget.deviceId,
            'fit': 'COMPATIBLE',
          },
        },
      );
      final status = res.data is Map ? '${(res.data as Map)['status'] ?? 'PENDING'}' : 'PENDING';
      final proposal = {
        'status': status,
        'label': '${draft.brand} ${draft.model}',
        'spare': category.label,
      };
      await state.sync.saveJson(_proposalKey, proposal);
      if (!mounted) return;
      setState(() => _proposal = proposal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'APPLIED'
                ? 'Accepted. Other phones see it when the catalog snapshot refreshes.'
                : 'Sent for admin review.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(error))));
    }
  }

  Widget _proposalStatus(String spare) {
    final proposal = _proposal;
    if (proposal == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        proposal['status'] == 'APPLIED'
            ? 'Accepted. Same $spare as ${proposal['label']}. Other phones see it when the catalog snapshot refreshes.'
            : 'Pending review. Same $spare as ${proposal['label']}.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, height: 1.3, color: Px.ink),
      ),
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
    final families = mergeOverlappingFamilies(_canonicalFamilyRows(categoryCode == null
            ? _families
            : _families.where((group) {
                final code = '${group['categoryCode'] ?? ''}'.toUpperCase();
                return code.isEmpty || code == categoryCode.toUpperCase();
              }).toList())
        .where((group) => _listsAnotherPhone(group))
        .toList());
    final partIds = {
      for (final family in families)
        for (final id in familyComponentIds(family)) id,
    };
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
                      logo: _brandLogo,
                    ),
                    const SizedBox(height: 14),
                    if (families.isEmpty) ...[
                      ShopEmpty(
                        title: category == null ? 'No compatibility data yet' : 'No other model shares this ${category.label}',
                        subtitle: 'This phone stays in the catalog. A shared spare can be proposed for review.',
                        icon: Icons.phone_android_rounded,
                      ),
                      if (category != null) ...[
                        const SizedBox(height: 8),
                        _proposalStatus(category.label),
                        Center(
                          child: FilledButton(
                            onPressed: _refreshing ? null : _propose,
                            child: const Text('Propose a compatibility'),
                          ),
                        ),
                      ],
                    ]
                    else ...[
                      Text(
                        _coverageLine(category?.label, families.length, compatibleIds.length),
                        style: TextStyle(fontSize: 15, height: 1.3, fontWeight: FontWeight.w600, color: Px.ink),
                      ),
                      const SizedBox(height: 12),
                      for (final family in families) ...[
                        _FitmentFamilyCard(
                          family: family,
                          fit: fitByComponent['${family['id'] ?? ''}'],
                          deviceId: widget.deviceId,
                          categoryCode: categoryCode,
                          stock: stock
                              .where((row) => familyComponentIds(family).contains('${row['componentId'] ?? ''}'))
                              .toList(),
                          showInventory: context.watch<AppState>().hasFeature('INVENTORY'),
                          busy: _refreshing,
                          myVotes: _myVotes,
                          onConfirm: _confirm,
                          onDispute: _dispute,
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (category != null) ...[
                        _proposalStatus(category.label),
                        OutlinedButton(
                          onPressed: _refreshing ? null : _propose,
                          child: const Text('Propose another'),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

String? _brandSvg(Object? raw) {
  final logo = '${raw ?? ''}'.trim();
  if (!logo.startsWith('<svg') || logo.contains('<script') || logo.length > 4096) return null;
  return logo;
}

String _coverageLine(String? spare, int families, int models) {
  final part = spare == null || spare.isEmpty ? 'spare' : spare;
  if (families == 0 || models == 0) return '$part is model-specific for now';
  final modelWord = models == 1 ? 'model shares' : 'models share';
  final familyWord = families == 1 ? '' : ' · $families families';
  return '$models $modelWord this $part$familyWord';
}

class _DeviceCatalogHero extends StatelessWidget {
  const _DeviceCatalogHero({
    required this.name,
    required this.brand,
    required this.category,
    required this.modelCode,
    required this.logo,
  });

  final String name;
  final String brand;
  final String? category;
  final String modelCode;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    final code = modelCode.trim();
    final caption = [
      if (brand.isNotEmpty) brand,
      if (category != null) category!,
      if (code.isNotEmpty && code.toLowerCase() != name.trim().toLowerCase()) code,
    ].join(' · ');
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Px.accent, Px.accentStrong],
        ),
        boxShadow: Px.lift,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _BrandOrPhoneMark(name: brand.isEmpty ? name : brand, logo: logo),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fraunces(
                    color: Px.accentInk,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                if (caption.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Px.accentInk.withValues(alpha: 0.86), fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandOrPhoneMark extends StatelessWidget {
  const _BrandOrPhoneMark({required this.name, required this.logo});

  final String name;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    final mark = logo;
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Px.accentInk.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: mark == null
          ? Icon(Icons.phone_android_rounded, color: Px.accentInk, size: 24)
          : SvgPicture.string(
              mark,
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Px.accentInk, BlendMode.srcIn),
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.phone_android_rounded, color: Px.accentInk, size: 24),
              semanticsLabel: name,
            ),
    );
  }
}

class _FitmentFamilyCard extends StatelessWidget {
  const _FitmentFamilyCard({
    required this.family,
    required this.fit,
    required this.deviceId,
    required this.categoryCode,
    required this.stock,
    required this.showInventory,
    required this.busy,
    required this.myVotes,
    required this.onConfirm,
    required this.onDispute,
  });

  final Map<String, dynamic> family;
  final Map<String, dynamic>? fit;
  final String deviceId;
  final String? categoryCode;
  final List<Map<String, dynamic>> stock;
  final bool showInventory;
  final bool busy;
  final Map<String, String> myVotes;
  final Future<void> Function(String fitmentId, String label) onConfirm;
  final Future<void> Function(String fitmentId, String label) onDispute;

  String? _voteFor(Map<String, dynamic> member) {
    final fitmentId = '${member['fitmentId'] ?? ''}';
    if (fitmentId.isEmpty) return null;
    final local = myVotes[fitmentId];
    if (local != null) return local;
    if (fit != null && '${fit!['fitmentId'] ?? ''}' == fitmentId) {
      if (fit!['confirmedByMe'] == true) return 'confirm';
      if (fit!['disputedByMe'] == true) return 'dispute';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final members = pageRows(family['members']);
    final others = members.where((member) => '${member['id'] ?? ''}' != deviceId).toList();

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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${family['name'] ?? 'Same part'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  others.isEmpty
                      ? 'Dedicated to this phone'
                      : 'Shared with ${others.length} ${others.length == 1 ? 'model' : 'models'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 18, color: Px.accent),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Only this phone uses the spare in the current catalog group.')),
                      ],
                    ),
                  )
                else
                  for (final member in members)
                    _CompatiblePhoneRow(
                      member: member,
                      current: '${member['id'] ?? ''}' == deviceId,
                      busy: busy,
                      vote: _voteFor(member),
                      onOpen: () {
                        final memberId = '${member['id'] ?? ''}';
                        if (memberId.isEmpty || memberId == deviceId) return;
                        final scope = categoryCode == null
                            ? ''
                            : '?category=${Uri.encodeQueryComponent(categoryCode!)}';
                        context.push('/commons/devices/$memberId$scope');
                      },
                      onConfirm: onConfirm,
                      onDispute: onDispute,
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

class _CompatiblePhoneRow extends StatelessWidget {
  const _CompatiblePhoneRow({
    required this.member,
    required this.current,
    required this.busy,
    required this.vote,
    required this.onOpen,
    required this.onConfirm,
    required this.onDispute,
  });

  final Map<String, dynamic> member;
  final bool current;
  final bool busy;
  final String? vote;
  final VoidCallback onOpen;
  final Future<void> Function(String fitmentId, String label) onConfirm;
  final Future<void> Function(String fitmentId, String label) onDispute;

  @override
  Widget build(BuildContext context) {
    final name = '${member['brandName'] ?? ''} ${member['name'] ?? ''}'.trim();
    final label = name.isEmpty ? 'Phone' : name;
    final modelCode = '${member['modelCode'] ?? ''}'.trim();
    final fitmentId = '${member['fitmentId'] ?? ''}';
    final disputed = member['disputed'] == true || vote == 'dispute';
    final subtitle = [
      if (modelCode.isNotEmpty) modelCode,
      if (current) 'This phone',
      if (disputed) 'Disputed',
      if (vote == 'confirm') 'Confirmed by you',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: current ? null : onOpen,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 18, color: current ? Px.accent : Px.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (subtitle.isNotEmpty)
                            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (!current) Icon(Icons.chevron_right_rounded, size: 20, color: Px.faint),
                  ],
                ),
              ),
            ),
          ),
          if (fitmentId.isNotEmpty)
            PopupMenuButton<String>(
              tooltip: 'Confirm or report',
              icon: Icon(Icons.more_horiz_rounded, color: Px.faint),
              onSelected: (value) {
                if (value == 'confirm') onConfirm(fitmentId, label);
                if (value == 'report') onDispute(fitmentId, label);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'confirm',
                  enabled: !busy && vote != 'confirm',
                  child: Text(vote == 'confirm' ? 'You confirmed this model' : 'Confirm this model'),
                ),
                PopupMenuItem(
                  value: 'report',
                  enabled: !busy && vote != 'dispute',
                  child: Text(vote == 'dispute' ? 'You reported this model' : 'Report this model'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProposalDraft {
  const _ProposalDraft({required this.brand, required this.model, required this.modelId});

  final String brand;
  final String model;
  final String modelId;
}

class _ProposeCompatibilityDialog extends StatefulWidget {
  const _ProposeCompatibilityDialog({
    required this.spare,
    required this.loadBrands,
    required this.loadModels,
  });

  final String spare;
  final Future<List<Map<String, dynamic>>> Function() loadBrands;
  final Future<List<Map<String, dynamic>>> Function(String brandId) loadModels;

  @override
  State<_ProposeCompatibilityDialog> createState() => _ProposeCompatibilityDialogState();
}

class _ProposeCompatibilityDialogState extends State<_ProposeCompatibilityDialog> {
  List<Map<String, dynamic>> _brands = const [];
  List<Map<String, dynamic>> _models = const [];
  String? _brandId;
  String? _modelId;
  String _query = '';
  bool _loading = true;
  String? _problem;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await widget.loadBrands();
      if (!mounted) return;
      setState(() {
        _brands = brands;
        _loading = false;
        _problem = brands.isEmpty ? 'No shared ${widget.spare} is in the catalog yet.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _problem = 'Could not read the saved catalog.';
      });
    }
  }

  Future<void> _pickBrand(String? brandId) async {
    setState(() {
      _brandId = brandId;
      _modelId = null;
      _models = const [];
      _query = '';
      _loading = brandId != null;
    });
    if (brandId == null) return;
    try {
      final models = await widget.loadModels(brandId);
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = models;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = [
      for (final model in _models)
        if (_query.isEmpty || '${model['name'] ?? ''} ${model['modelCode'] ?? ''}'.toLowerCase().contains(_query))
          model,
    ];
    final brandName = _brands.cast<Map<String, dynamic>?>().where((row) => '${row?['id']}' == _brandId);
    return AlertDialog(
      title: Text('Propose a ${widget.spare}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_problem != null)
              Text(_problem!, style: TextStyle(color: Px.muted))
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _brandId,
                decoration: const InputDecoration(labelText: 'Existing brand'),
                items: [
                  for (final brand in _brands)
                    DropdownMenuItem(value: '${brand['id']}', child: Text('${brand['name'] ?? ''}')),
                ],
                onChanged: _pickBrand,
              ),
              if (_brandId != null) ...[
                TextField(
                  decoration: const InputDecoration(labelText: 'Existing model'),
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : shown.isEmpty
                          ? const Center(child: Text('No shared model matches'))
                          : ListView(
                              children: [
                                for (final model in shown)
                                  ListTile(
                                    dense: true,
                                    selected: _modelId == '${model['id']}',
                                    title: Text('${model['name'] ?? ''}'),
                                    subtitle: '${model['modelCode'] ?? ''}'.trim().isEmpty
                                        ? null
                                        : Text('${model['modelCode']}'),
                                    onTap: () => setState(() => _modelId = '${model['id']}'),
                                  ),
                              ],
                            ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _modelId == null
              ? null
              : () {
                  final model = _models.cast<Map<String, dynamic>?>().firstWhere(
                        (row) => '${row?['id']}' == _modelId,
                        orElse: () => null,
                      );
                  final brand = brandName.isEmpty ? null : brandName.first;
                  if (model == null || brand == null) return;
                  Navigator.pop(
                    context,
                    _ProposalDraft(
                      brand: '${brand['name'] ?? ''}',
                      model: '${model['name'] ?? ''}',
                      modelId: _modelId!,
                    ),
                  );
                },
          child: const Text('Send for review'),
        ),
      ],
    );
  }
}
