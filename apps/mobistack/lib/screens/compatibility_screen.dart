import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import '../catalog/spare_group.dart';
import 'group_members_sheet.dart';
import 'spare_phone_page.dart';
import '../state/app_state.dart';
import '../widgets/live_api_list.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/shop_ui.dart';

/// Shared parts catalog: pick a part type, then a brand, then search models.
class CompatibilityScreen extends StatefulWidget {
  const CompatibilityScreen({super.key});

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _query = TextEditingController();
  FitmentLibrary? _library;
  FitmentBook _book = const FitmentBook([]);
  FitmentCategory? _category;
  String? _brand;
  String? _brandId;
  List<Map<String, dynamic>> _brands = const [];
  List<Map<String, dynamic>> _models = const [];
  String? _requestedGroup;
  bool _loadingCatalog = false;
  String? _catalogError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBook());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = context.read<AppState>().fitmentGroupId ?? '';
    if (id == _requestedGroup) return;
    _requestedGroup = id;
    _loadCatalog(id);
  }

  Future<void> _loadCatalog(String groupId) async {
    if (groupId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _brands = const [];
        _models = const [];
        _loadingCatalog = false;
        _catalogError = null;
      });
      return;
    }
    setState(() {
      _loadingCatalog = true;
      _catalogError = null;
      _brand = null;
      _brandId = null;
      _models = const [];
    });
    try {
      final brands = await _pages('commons/brands', const {});
      if (!mounted || _requestedGroup != groupId) return;
      setState(() {
        _brands = brands;
        _loadingCatalog = false;
      });
    } catch (_) {
      if (!mounted || _requestedGroup != groupId) return;
      setState(() {
        _loadingCatalog = false;
        _catalogError = 'Could not load this group\'s phones.';
      });
    }
  }

  Future<void> _loadModels(String brandId) async {
    setState(() => _loadingCatalog = true);
    try {
      final models = await _pages('commons/devices', {'brandId': brandId});
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = models;
        _loadingCatalog = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCatalog = false);
    }
  }

  Future<List<Map<String, dynamic>>> _pages(String path, Map<String, dynamic> query) async {
    final state = context.read<AppState>();
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
    return rows;
  }

  Future<void> _addPhone() async {
    final brand = TextEditingController(text: _brand ?? '');
    final model = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a phone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: brand, decoration: const InputDecoration(labelText: 'Brand')),
            TextField(controller: model, decoration: const InputDecoration(labelText: 'Model')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save')),
        ],
      ),
    );
    final brandName = brand.text.trim();
    final modelName = model.text.trim();
    brand.dispose();
    model.dispose();
    if (created != true || !mounted || brandName.isEmpty || modelName.isEmpty) return;
    try {
      await context.read<AppState>().api.dio.post<dynamic>(
        'commons/devices',
        data: {'brand': brandName, 'name': modelName},
      );
      final groupId = _requestedGroup ?? '';
      await _loadCatalog(groupId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add that phone. Only a group admin can add phones.')),
      );
    }
  }

  Future<void> _loadBook() async {
    try {
      final book = await FitmentBook.load(context.read<AppState>().sync);
      if (!mounted) return;
      setState(() => _book = book);
    } catch (_) {}
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
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
        : category != null
            ? 'Choose a brand'
            : '${_brands.length} brands · ${_book.groups.length} saved spares';

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
                        : '${state.selectedFitmentGroup!.name} · ${_brands.length} brands')
                    : subtitle,
                actions: [
                  if (category == null)
                    IconButton(
                      tooltip: 'New group',
                      onPressed: () => _newGroup(context),
                      icon: Icon(Icons.add_rounded, color: Px.ink),
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
                    ? _CategoryGrid(
                        count: _brands.length,
                        saved: _book.groups.length,
                        onPick: (picked) => setState(() {
                          _category = picked;
                          _brand = null;
                          _brandId = null;
                          _query.clear();
                        }),
                        onSaved: () async {
                          final library = _library ?? await FitmentLibrary.load();
                          if (!context.mounted) return;
                          _library = library;
                          await Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (_) => SavedSparesPage(library: library),
                          ));
                          await _loadBook();
                        },
                      )
                    : _loadingCatalog
                        ? Center(child: CircularProgressIndicator(color: Px.accent))
                        : _catalogError != null
                            ? ShopEmpty(title: _catalogError!, icon: Icons.cloud_off_rounded)
                            : _brand == null
                                ? _BrandList(
                                    brands: _brands,
                                    query: _query.text,
                                    onPick: (brand) {
                                      final id = '${brand['id'] ?? ''}';
                                      setState(() {
                                        _brand = '${brand['name'] ?? ''}';
                                        _brandId = id;
                                        _query.clear();
                                      });
                                      if (id.isNotEmpty) _loadModels(id);
                                    },
                                  )
                                : _PhoneList(
                                    phones: _visibleModels(),
                                    category: category,
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
    if (q.isEmpty) return _models;
    return _models.where((phone) {
      return '${phone['name'] ?? ''} ${phone['modelCode'] ?? ''}'.toLowerCase().contains(q);
    }).toList();
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.count,
    required this.saved,
    required this.onPick,
    required this.onSaved,
  });

  final int? count;
  final int saved;
  final ValueChanged<FitmentCategory> onPick;
  final VoidCallback? onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShopListTile(
          title: 'Saved spares',
          subtitle: saved == 0 ? 'Groups you record stay on this phone' : '$saved groups',
          leading: Icon(Icons.bookmark_rounded, color: Px.accent),
          onTap: onSaved,
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: fitmentCategories.length,
            itemBuilder: (context, index) {
              final category = fitmentCategories[index];
              return _CategoryCard(
                category: category,
                count: count,
                onTap: () => onPick(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  final FitmentCategory category;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Px.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconFor(category.code), color: Px.accent, size: 26),
              const Spacer(),
              Text(
                category.label,
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Px.ink,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count == null ? 'This group' : '$count brands',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 28),
      itemCount: shown.length,
      itemBuilder: (context, index) {
        final brand = shown[index];
        final name = '${brand['name'] ?? ''}';
        return ShopListTile(
          title: name,
          leading: _Mark(letter: name.isEmpty ? '?' : name[0].toUpperCase()),
          trailing: Icon(Icons.chevron_right_rounded, color: Px.faint),
          onTap: () => onPick(brand),
        );
      },
    );
  }
}

class _PhoneList extends StatelessWidget {
  const _PhoneList({
    required this.phones,
    required this.category,
    required this.onOpen,
  });

  final List<Map<String, dynamic>> phones;
  final FitmentCategory category;
  final ValueChanged<Map<String, dynamic>> onOpen;

  @override
  Widget build(BuildContext context) {
    if (phones.isEmpty) {
      return const ShopEmpty(title: 'No model matches', icon: Icons.search_off_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 28),
      itemCount: phones.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              category.blurb,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        final phone = phones[index - 1];
        final name = '${phone['name'] ?? ''}';
        final code = '${phone['modelCode'] ?? ''}'.trim();
        return ShopListTile(
          title: name,
          subtitle: code.isEmpty ? category.label : '$code · ${category.label}',
          leading: _Mark(letter: name.isEmpty ? '?' : name[0].toUpperCase()),
          onTap: () => onOpen(phone),
        );
      },
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Px.accent, Px.accentStrong]),
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
    );
  }
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
