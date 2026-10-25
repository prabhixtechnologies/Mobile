import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import 'group_members_sheet.dart';
import '../state/app_state.dart';
import '../widgets/live_api_list.dart';
import '../widgets/pending_compatibility_requests.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

/// Shared parts catalog: pick a part type, then a brand, then search models.
///
/// `/commons?category=CODE&brands=ID` opens straight on that step, the same address the web uses.
/// A brand without a part type has no phone list here, so it opens on the part-type grid.
class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key, this.initialCategory, this.initialBrandId});

  final String? initialCategory;
  final String? initialBrandId;

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _query = TextEditingController();
  AppState? _app;
  int _seenRevision = -1;
  FitmentCategory? _category;
  String? _brand;
  String? _brandId;
  List<Map<String, dynamic>> _brands = const [];
  List<Map<String, dynamic>> _categoryBrands = const [];
  List<Map<String, dynamic>> _models = const [];
  String? _requestedGroup;
  String? _pendingBrandId;
  bool _routeApplied = false;
  bool _loadingCatalog = false;
  bool _brandsLoaded = false;
  bool _hideModelSpecific = true;
  bool _hideLoaded = false;
  String? _catalogError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (!identical(_app, state)) {
      _app?.removeListener(_onCatalogInstalled);
      _app = state;
      state.addListener(_onCatalogInstalled);
      _seenRevision = state.catalogRevision;
    }
    // build() already listens to AppState, so a group change reaches this method. watch()
    // is only legal during build and fails the catalog widget tests.
    final id = state.fitmentGroupId ?? '';
    if (id != _requestedGroup) {
      _requestedGroup = id;
      _loadCatalog(id);
    }
    if (!_routeApplied) {
      _routeApplied = true;
      _applyRoute(widget.initialCategory, widget.initialBrandId);
    }
    if (!_hideLoaded) {
      _hideLoaded = true;
      _loadHidePreference();
    }
  }

  @override
  void didUpdateWidget(CompatibilityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory ||
        oldWidget.initialBrandId != widget.initialBrandId) {
      _applyRoute(widget.initialCategory, widget.initialBrandId);
    }
  }

  Future<void> _loadHidePreference() async {
    try {
      final saved = await _app?.sync.hideModelSpecific();
      if (!mounted || saved == null || saved == _hideModelSpecific) return;
      setState(() => _hideModelSpecific = saved);
    } catch (e) {
      debugPrint('hide model-specific preference unread: $e');
    }
  }

  Future<void> _setHideModelSpecific(bool value) async {
    setState(() => _hideModelSpecific = value);
    try {
      await _app?.sync.saveHideModelSpecific(value);
    } catch (e) {
      debugPrint('hide model-specific preference unsaved: $e');
    }
  }

  void _applyRoute(String? categoryCode, String? brandId) {
    final code = categoryCode?.trim().toUpperCase() ?? '';
    final brand = brandId?.trim() ?? '';
    FitmentCategory? picked;
    for (final category in fitmentCategories) {
      if (category.code.toUpperCase() == code) picked = category;
    }
    if (picked == null) {
      if (_category == null) return;
      setState(() {
        _category = null;
        _brand = null;
        _brandId = null;
        _models = const [];
        _pendingBrandId = null;
        _query.clear();
      });
      return;
    }
    if (picked.code == _category?.code && (brand.isEmpty || brand == _brandId)) return;
    _openCategory(picked, pendingBrand: brand.isEmpty ? null : brand);
  }

  void _openCategory(FitmentCategory picked, {String? pendingBrand}) {
    final ready = context.read<AppState>().sync.peekCatalogList('commons/brands', {'categoryCode': picked.code});
    setState(() {
      _category = picked;
      _brand = null;
      _brandId = null;
      _models = const [];
      _categoryBrands = ready ?? const [];
      _loadingCatalog = ready == null;
      _pendingBrandId = pendingBrand;
      _query.clear();
      _catalogError = null;
    });
    _loadCategoryBrands(picked.code);
  }

  void _pickBrand(Map<String, dynamic> brand) {
    final id = '${brand['id'] ?? ''}';
    final query = <String, dynamic>{'brandId': id};
    final code = _category?.code;
    if (code != null) query['categoryCode'] = code;
    final ready = id.isEmpty ? null : context.read<AppState>().sync.peekCatalogList('commons/devices', query);
    setState(() {
      _brand = '${brand['name'] ?? ''}';
      _brandId = id;
      _query.clear();
      if (ready != null) {
        _models = ready;
        _loadingCatalog = false;
      } else if (id.isNotEmpty) {
        _loadingCatalog = true;
      }
    });
    if (id.isNotEmpty) _loadModels(id);
  }

  Future<void> _loadCatalog(String groupId) async {
    if (groupId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _brands = const [];
        _brandsLoaded = false;
        _categoryBrands = const [];
        _models = const [];
        _loadingCatalog = false;
        // The part types are on the phone. A missing group is not an empty catalog,
        // so the grid stays and does not claim "0 brands".
        _catalogError = null;
      });
      return;
    }
    final cached = await context.read<AppState>().sync.readCatalogList('commons/brands', const {});
    if (!mounted || _requestedGroup != groupId) return;
    if (cached != null) {
      setState(() {
        _brands = cached;
        _brandsLoaded = true;
        _loadingCatalog = false;
        _catalogError = null;
      });
    } else {
      setState(() {
        _loadingCatalog = true;
        _catalogError = null;
        _brand = null;
        _brandId = null;
        _models = const [];
      });
    }
    try {
      final brands = await _pages('commons/brands', const {});
      if (!mounted || _requestedGroup != groupId) return;
      setState(() {
        _brands = brands;
        _brandsLoaded = true;
        // A part type opened from the address is loading its own brands; that load ends the spinner.
        if (_category == null) _loadingCatalog = false;
        _catalogError = null;
      });
    } catch (_) {
      if (!mounted || _requestedGroup != groupId) return;
      setState(() {
        _loadingCatalog = false;
        if (_brands.isEmpty) {
          _catalogError = 'Could not load this group\'s phones.';
        }
      });
    }
  }

  Future<void> _loadCategoryBrands(String code) async {
    final cached = await context.read<AppState>().sync.readCatalogList('commons/brands', {'categoryCode': code});
    if (!mounted || _category?.code != code) return;
    if (cached != null) {
      setState(() {
        _categoryBrands = cached;
        _loadingCatalog = false;
        _catalogError = null;
      });
    } else {
      setState(() => _loadingCatalog = true);
    }
    try {
      final brands = await _pages('commons/brands', {'categoryCode': code});
      if (!mounted || _category?.code != code) return;
      setState(() {
        _categoryBrands = brands;
        _loadingCatalog = false;
        _catalogError = null;
      });
      final pending = _pendingBrandId;
      _pendingBrandId = null;
      if (pending != null) {
        for (final brand in brands) {
          if ('${brand['id'] ?? ''}' == pending) {
            _pickBrand(brand);
            break;
          }
        }
      }
    } catch (_) {
      if (!mounted || _category?.code != code) return;
      setState(() {
        _loadingCatalog = false;
        if (_categoryBrands.isEmpty) {
          _catalogError = 'Could not load brands for this spare.';
        }
      });
    }
  }

  Future<void> _loadModels(String brandId) async {
    final query = <String, dynamic>{'brandId': brandId};
    final code = _category?.code;
    if (code != null) query['categoryCode'] = code;
    final cached = await context.read<AppState>().sync.readCatalogList('commons/devices', query);
    if (!mounted || _brandId != brandId) return;
    if (cached != null) {
      final models = await _withLocalPhones(brandId, cached);
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = models;
        _loadingCatalog = false;
        _catalogError = null;
      });
    } else {
      setState(() => _loadingCatalog = true);
    }
    try {
      final models = await _pages('commons/devices', query);
      if (!mounted || _brandId != brandId) return;
      final shown = await _withLocalPhones(brandId, models);
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = shown;
        _loadingCatalog = false;
        _catalogError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCatalog = false);
    }
  }

  /// Keeps a phone this device just saved visible until the shared snapshot includes it.
  Future<List<Map<String, dynamic>>> _withLocalPhones(String brandId, List<Map<String, dynamic>> rows) async {
    final group = _requestedGroup ?? '';
    if (group.isEmpty) return rows;
    final sync = context.read<AppState>().sync;
    final added = await sync.addedCatalogDevices(group);
    if (added.isEmpty) return rows;
    final present = {for (final row in rows) '${row['id']}'};
    await sync.forgetAddedCatalogDevices(group, present);
    return [
      ...rows,
      for (final row in added)
        if (!present.contains('${row['id']}') && '${row['brandId']}' == brandId) row,
    ];
  }

  Future<List<Map<String, dynamic>>> _pages(String path, Map<String, dynamic> query) async {
    final state = context.read<AppState>();
    final cached = await state.sync.readCatalogList(path, query);
    if (cached != null) return cached;
    if (!state.online) throw StateError('offline');
    // The snapshot is one request. Paging the same lists is what made a good
    // connection feel slower than offline, so try that install before crawling.
    try {
      await state.catalogMirror.warm();
    } catch (e) {
      debugPrint('catalog warm before list failed: $e');
    }
    if (!mounted) {
      final installed = await state.sync.readCatalogList(path, query);
      if (installed != null) return installed;
      throw StateError('unmounted');
    }
    final installed = await state.sync.readCatalogList(path, query);
    if (installed != null) return installed;
    try {
      final rows = <Map<String, dynamic>>[];
      for (var page = 0; page < 40; page++) {
        final res = await state.api.dio.get<dynamic>(
          path,
          queryParameters: {...query, 'page': page, 'size': 100},
        );
        final batch = pageRows(res.data);
        rows.addAll(batch);
        final last = res.data is Map && (res.data as Map)['last'] == true;
        if (last || batch.length < 100) break;
      }
      await state.sync.saveCatalogList(path, query, rows);
      return rows;
    } catch (e) {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> _addPhone() async {
    final brands = [
      for (final brand in (_categoryBrands.isNotEmpty ? _categoryBrands : _brands))
        {'id': '${brand['id'] ?? ''}', 'name': '${brand['name'] ?? ''}'},
    ].where((brand) => brand['id']!.isNotEmpty && brand['name']!.isNotEmpty).toList();
    final selectedId = _brandId;
    if (selectedId != null &&
        selectedId.isNotEmpty &&
        _brand != null &&
        brands.every((brand) => brand['id'] != selectedId)) {
      brands.insert(0, {'id': selectedId, 'name': _brand!});
    }
    final draft = await showDialog<_PhoneDraft>(
      context: context,
      builder: (dialogContext) => _AddModelDialog(
        brands: brands,
        selectedBrandId: selectedId,
      ),
    );
    if (draft == null || !mounted) return;
    final state = context.read<AppState>();
    try {
      final res = await state.api.dio.post<dynamic>(
        'commons/devices',
        data: {'brand': draft.brand, 'name': draft.model},
      );
      final body = res.data;
      if (body is! Map) return;
      final phone = <String, dynamic>{
        'id': '${body['id'] ?? ''}',
        'brandId': '${body['brandId'] ?? ''}',
        'brandName': draft.brand,
        'name': '${body['name'] ?? draft.model}',
        'modelCode': '${body['modelCode'] ?? ''}',
        'shared': false,
      };
      final groupId = _requestedGroup ?? '';
      await state.sync.rememberAddedCatalogDevice(groupId, phone);
      if (!mounted) return;
      final sameBrand = _brandId != null && _brandId == phone['brandId'];
      if (sameBrand) {
        setState(() {
          _models = [
            phone,
            for (final row in _models)
              if ('${row['id']}' != phone['id']) row,
          ];
        });
      }
      final hidden = sameBrand && _hideModelSpecific;
      final where = sameBrand ? '' : ' under ${draft.brand}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hidden
                ? 'Saved$where. It stays hidden while Hide model-specific is on.'
                : 'Saved$where.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add that phone. Only a group admin can add phones.')),
      );
    }
  }

  @override
  void dispose() {
    _app?.removeListener(_onCatalogInstalled);
    _query.dispose();
    super.dispose();
  }

  void _onCatalogInstalled() {
    final state = _app;
    if (state == null || state.catalogRevision == _seenRevision) return;
    _seenRevision = state.catalogRevision;
    final group = _requestedGroup ?? '';
    _loadCatalog(group);
    final code = _category?.code;
    if (code != null) _loadCategoryBrands(code);
    final brandId = _brandId;
    if (brandId != null && brandId.isNotEmpty) _loadModels(brandId);
  }

  Future<void> _newGroup(BuildContext context) async {
    final name = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New fitment group'),
        content: TextField(
          controller: name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Group name'),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Create')),
        ],
      ),
    );
    final value = name.text;
    name.dispose();
    if (created != true || !context.mounted) return;
    final state = context.read<AppState>();
    final error = await state.createFitmentGroup(value);
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final code = state.issuedJoinCode;
    if (code == null || code.isEmpty) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join ID'),
        content: Text('Forward $code to anyone who should see this group\'s phones and parts.'),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Done')),
        ],
      ),
    );
  }

  void _back() {
    setState(() {
      _query.clear();
      if (_brand != null) {
        _brand = null;
        _brandId = null;
        _models = const [];
      } else {
        _category = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final needsBilling = state.me?.paymentRequired == true;
    final category = _category;
    final title = _brand ?? category?.label ?? 'Parts';
    final subtitle = _brand != null
        ? '${category?.label ?? 'Parts'} · search a model'
        : 'Choose a brand';

    return _StepBack(
      onBack: () {
        if (_category == null || ModalRoute.of(context)?.isCurrent != true) return false;
        _back();
        return true;
      },
      child: Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopHeroHeader(
                title: category == null ? 'Fitment catalog' : title,
                subtitle: category == null
                    ? (state.selectedFitmentGroup == null
                        ? 'Choose a fitment group'
                        : _brandsLoaded
                            ? '${state.selectedFitmentGroup!.name} · ${_brands.length} brands'
                            : state.selectedFitmentGroup!.name)
                    : subtitle,
                actions: [
                  if (category == null)
                    IconButton(
                      tooltip: 'New group',
                      onPressed: () => _newGroup(context),
                      icon: Icon(Icons.add_rounded, color: Px.ink),
                    ),
                  if (_brand != null)
                    SizedBox(
                      width: 40,
                      height: 48,
                      child: Tooltip(
                        message: 'Hide model-specific',
                        child: Checkbox(
                          value: _hideModelSpecific,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) => _setHideModelSpecific(value ?? false),
                        ),
                      ),
                    ),
                  if (category != null && (state.selectedFitmentGroup?.canManage ?? false))
                    IconButton(
                      tooltip: 'Add a phone',
                      onPressed: _addPhone,
                      icon: Icon(Icons.phone_android_rounded, color: Px.ink),
                    ),
                  if (category == null && (state.selectedFitmentGroup?.canManage ?? false))
                    IconButton(
                      tooltip: 'Members',
                      onPressed: () => showGroupMembersSheet(context),
                      icon: Icon(Icons.group_outlined, color: Px.ink),
                    ),
                  if (category != null)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: _back,
                      icon: Icon(Icons.arrow_back_rounded, color: Px.ink),
                    ),
                ],
              ),
              if (needsBilling)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Material(
                    color: Px.warningSubtle,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/billing'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.payments_rounded, color: Px.warningSubtleInk),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No active plan on this shop. Open Billing.',
                                style: TextStyle(color: Px.warningSubtleInk),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Px.warningSubtleInk),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (category == null)
                const PendingCompatibilityRequests(generation: 0, bounded: true),
              if (category == null && state.fitmentGroups.length > 1)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    children: [
                      for (final group in state.fitmentGroups)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(group.name),
                            selected: group.id == state.fitmentGroupId,
                            onSelected: (_) => state.selectFitmentGroup(group.id),
                          ),
                        ),
                    ],
                  ),
                ),
              if (category != null)
                ShopSearchField(
                  controller: _query,
                  hint: _brand == null ? 'Filter brands…' : 'Search model or code…',
                  onChanged: (_) => setState(() {}),
                ),
              Expanded(
                child: category == null
                    ? _CategoryList(onPick: _openCategory)
                    : _loadingCatalog
                        ? Center(child: CircularProgressIndicator(color: Px.accent))
                        : _catalogError != null
                            ? ShopEmpty(title: _catalogError!, icon: Icons.cloud_off_rounded)
                            : _brand == null
                                ? _BrandList(
                                    brands: _categoryBrands,
                                    query: _query.text,
                                    onPick: _pickBrand,
                                  )
                                : _PhoneList(
                                    phones: _visibleModels(),
                                    category: category,
                                    emptyTitle: _hideModelSpecific && _query.text.trim().isEmpty
                                        ? 'Every phone here is model-specific'
                                        : 'No model matches',
                                    onOpen: (phone) {
                                      final id = '${phone['id'] ?? ''}';
                                      if (id.isEmpty) return;
                                      context.push('/commons/devices/$id?category=${category.code}');
                                    },
                                  ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  List<Map<String, dynamic>> _visibleModels() {
    final q = _query.text.trim().toLowerCase();
    return [
      for (final phone in _models)
        if ((!_hideModelSpecific || phone['shared'] == true) &&
            (q.isEmpty || '${phone['name'] ?? ''} ${phone['modelCode'] ?? ''}'.toLowerCase().contains(q)))
          phone,
    ];
  }
}

class _PhoneDraft {
  const _PhoneDraft({required this.brand, required this.model});

  final String brand;
  final String model;
}

class _AddModelDialog extends StatefulWidget {
  const _AddModelDialog({required this.brands, this.selectedBrandId});

  final List<Map<String, String>> brands;
  final String? selectedBrandId;

  @override
  State<_AddModelDialog> createState() => _AddModelDialogState();
}

class _AddModelDialogState extends State<_AddModelDialog> {
  static const _newBrand = '__new__';
  late String _choice;
  late final TextEditingController _brand;
  late final TextEditingController _model;
  final _modelFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final selected = widget.selectedBrandId;
    final known = selected != null && widget.brands.any((brand) => brand['id'] == selected);
    _choice = known ? selected : (widget.brands.isEmpty ? _newBrand : widget.brands.first['id']!);
    _brand = TextEditingController();
    _model = TextEditingController();
    if (known) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _modelFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _brand.dispose();
    _model.dispose();
    _modelFocus.dispose();
    super.dispose();
  }

  void _save() {
    final model = _model.text.trim();
    var brand = _brand.text.trim();
    if (_choice != _newBrand) {
      brand = '';
      for (final row in widget.brands) {
        if (row['id'] == _choice) brand = row['name'] ?? '';
      }
    }
    if (brand.isEmpty || model.isEmpty) return;
    Navigator.pop(context, _PhoneDraft(brand: brand, model: model));
  }

  @override
  Widget build(BuildContext context) {
    final creating = _choice == _newBrand;
    final onABrand = widget.selectedBrandId != null && widget.selectedBrandId!.isNotEmpty;
    return AlertDialog(
      title: Text(onABrand ? 'Add a model' : 'Add a phone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.brands.isNotEmpty)
            DropdownButtonFormField<String>(
              initialValue: _choice,
              decoration: const InputDecoration(labelText: 'Brand'),
              items: [
                for (final brand in widget.brands)
                  DropdownMenuItem(value: brand['id'], child: Text(brand['name'] ?? '')),
                const DropdownMenuItem(value: _newBrand, child: Text('New brand')),
              ],
              onChanged: (value) => setState(() => _choice = value ?? _newBrand),
            ),
          if (creating)
            TextField(
              controller: _brand,
              autofocus: widget.brands.isEmpty,
              decoration: const InputDecoration(labelText: 'New brand'),
              textInputAction: TextInputAction.next,
            ),
          TextField(
            controller: _model,
            focusNode: _modelFocus,
            autofocus: onABrand,
            decoration: const InputDecoration(labelText: 'Model'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

/// Brand and category are steps inside the catalog, so system Back walks them first.
/// A PopScope would also fire the shell's own handler, which sends the shop to Home.
class _StepBack extends StatelessWidget {
  const _StepBack({required this.onBack, required this.child});

  final bool Function() onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Router.maybeOf(context) == null) return child;
    return BackButtonListener(
      onBackButtonPressed: () async => onBack(),
      child: child,
    );
  }
}

/// Every spare type on this screen. The old cards were tall enough that a phone
/// showed eight of thirteen and hid the rest under the dock.
class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.onPick});

  final ValueChanged<FitmentCategory> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = fitmentCategories.length;
          // A second line needs about 44px. Shorter windows keep the name only.
          final showBlurb = constraints.maxHeight / count >= 44;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Px.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Px.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: _CategoryRow(
                        category: fitmentCategories[i],
                        showBlurb: showBlurb,
                        divider: i < count - 1,
                        onTap: () => onPick(fitmentCategories[i]),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.showBlurb,
    required this.divider,
    required this.onTap,
  });

  final FitmentCategory category;
  final bool showBlurb;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: divider ? Border(bottom: BorderSide(color: Px.line)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(_iconFor(category.code), color: Px.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: showBlurb
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: Px.ink,
                              ),
                            ),
                            Text(
                              category.blurb,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, height: 1.15, color: Px.muted),
                            ),
                          ],
                        )
                      : Text(
                          category.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: Px.ink,
                          ),
                        ),
                ),
                Icon(Icons.chevron_right_rounded, color: Px.faint, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandList extends StatelessWidget {
  const _BrandList({
    required this.brands,
    required this.query,
    required this.onPick,
  });

  final List<Map<String, dynamic>> brands;
  final String query;
  final ValueChanged<Map<String, dynamic>> onPick;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final shown = brands.where((brand) => q.isEmpty || '${brand['name'] ?? ''}'.toLowerCase().contains(q)).toList();
    if (shown.isEmpty) {
      return ShopEmpty(
        title: q.isEmpty ? 'This group has no phones yet' : 'No brand matches',
        icon: Icons.search_off_rounded,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: _CatalogSheet(
        children: [
          for (var i = 0; i < shown.length; i += 2)
            Expanded(
              child: _BrandPair(
                left: shown[i],
                right: i + 1 < shown.length ? shown[i + 1] : null,
                divider: i + 2 < shown.length,
                onPick: onPick,
              ),
            ),
        ],
      ),
    );
  }
}

class _BrandPair extends StatelessWidget {
  const _BrandPair({
    required this.left,
    required this.right,
    required this.divider,
    required this.onPick,
  });

  final Map<String, dynamic> left;
  final Map<String, dynamic>? right;
  final bool divider;
  final ValueChanged<Map<String, dynamic>> onPick;

  @override
  Widget build(BuildContext context) {
    final other = right;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: divider ? Border(bottom: BorderSide(color: Px.line)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _BrandCell(brand: left, onPick: onPick)),
          if (other != null) ...[
            Container(width: 1, color: Px.line),
            Expanded(child: _BrandCell(brand: other, onPick: onPick)),
          ],
        ],
      ),
    );
  }
}

class _BrandCell extends StatelessWidget {
  const _BrandCell({required this.brand, required this.onPick});

  final Map<String, dynamic> brand;
  final ValueChanged<Map<String, dynamic>> onPick;

  @override
  Widget build(BuildContext context) {
    final name = '${brand['name'] ?? ''}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPick(brand),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _BrandGlyph(name: name, logo: _brandLogo(brand)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: Px.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneList extends StatelessWidget {
  const _PhoneList({
    required this.phones,
    required this.category,
    required this.onOpen,
    required this.emptyTitle,
  });

  final List<Map<String, dynamic>> phones;
  final FitmentCategory category;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    if (phones.isEmpty) {
      return ShopEmpty(title: emptyTitle, icon: Icons.search_off_rounded);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            '${category.blurb} Every phone is listed; an unmapped phone is treated as model-specific until shared compatibility is confirmed.',
            style: TextStyle(fontSize: 12, height: 1.25, color: Px.muted),
          ),
        ),
        _CatalogSheet(
          children: [
            for (var i = 0; i < phones.length; i++)
              _CatalogLine(
                title: '${phones[i]['name'] ?? ''}',
                subtitle: _modelLine(phones[i], category.label),
                divider: i < phones.length - 1,
                onTap: () => onOpen(phones[i]),
              ),
          ],
        ),
      ],
    );
  }
}

/// Same type size as the catalog home: 15px name, 12px detail, one shared sheet.
class _CatalogSheet extends StatelessWidget {
  const _CatalogSheet({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Px.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Px.line),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _CatalogLine extends StatelessWidget {
  const _CatalogLine({
    required this.title,
    required this.subtitle,
    required this.divider,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: divider ? Border(bottom: BorderSide(color: Px.line)) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: Px.ink,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, height: 1.15, color: Px.muted),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Px.faint, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initial(String name) => name.isEmpty ? '?' : name[0].toUpperCase();

/// SVG carried on the brand row of the catalog snapshot. Anything else stays a letter.
String? _brandLogo(Map<String, dynamic> brand) {
  final logo = '${brand['logo'] ?? ''}'.trim();
  if (!logo.startsWith('<svg') || logo.contains('<script') || logo.length > 4096) return null;
  return logo;
}

class _BrandGlyph extends StatelessWidget {
  const _BrandGlyph({required this.name, required this.logo});

  final String name;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    final mark = logo;
    if (mark != null) {
      return SvgPicture.string(
        mark,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(Px.ink, BlendMode.srcIn),
        errorBuilder: (context, error, stackTrace) => _LetterMark(name: name),
      );
    }
    return _LetterMark(name: name);
  }
}

class _LetterMark extends StatelessWidget {
  const _LetterMark({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Px.accent, Px.accentStrong]),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _initial(name),
        style: TextStyle(
          color: Px.accentInk,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1,
        ),
      ),
    );
  }
}

String _modelLine(Map<String, dynamic> phone, String category) {
  final code = '${phone['modelCode'] ?? ''}'.trim();
  return code.isEmpty ? category : '$code · $category';
}

IconData _iconFor(String code) {
  return switch (code) {
    'DISPLAY_FOLDER' => Icons.smartphone_rounded,
    'BATTERY' => Icons.battery_charging_full_rounded,
    'TEMPERED_GLASS' => Icons.shield_rounded,
    'TOUCH_OCA' => Icons.touch_app_rounded,
    'BACK_COVER' => Icons.layers_rounded,
    'FRAME' => Icons.crop_square_rounded,
    'POWER_VOLUME_FLEX' => Icons.tune_rounded,
    'CHARGING_BOARD' => Icons.electrical_services_rounded,
    'DISPLAY_CONNECTOR' => Icons.cable_rounded,
    'CAMERA' => Icons.photo_camera_rounded,
    'SPEAKER' => Icons.volume_up_rounded,
    'MICROPHONE' => Icons.mic_rounded,
    'IC_CHIP' => Icons.memory_rounded,
    _ => Icons.category_rounded,
  };
}
