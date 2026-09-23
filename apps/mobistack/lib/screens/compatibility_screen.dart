import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import '../catalog/spare_group.dart';
import 'group_members_sheet.dart';
import 'spare_phone_page.dart';
import '../state/app_state.dart';
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

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBook());
  }

  Future<void> _load() async {
    try {
      final library = await FitmentLibrary.load();
      if (!mounted) return;
      setState(() => _library = library);
    } catch (_) {}
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
    final error = await context.read<AppState>().createFitmentGroup(value);
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _back() {
    setState(() {
      _query.clear();
      if (_brand != null) {
        _brand = null;
      } else {
        _category = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final library = _library;
    final category = _category;
    final title = _brand ?? category?.label ?? 'Parts';
    final subtitle = _brand != null
        ? '${category?.label ?? 'Parts'} · search a model'
        : category != null
            ? 'Choose a brand'
                : library == null
                    ? 'Public specs'
                    : '${library.phones.length} phones · ${_book.groups.length} saved spares';

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopHeroHeader(
                title: category == null ? 'Fitment catalog' : title,
                subtitle: category == null
                    ? (state.selectedFitmentGroup == null
                        ? (library == null ? 'Phones and the parts that fit them' : '${library.phones.length} phones')
                        : '${state.selectedFitmentGroup!.name} · ${library?.phones.length ?? 0} phones')
                    : subtitle,
                actions: [
                  if (category == null)
                    IconButton(
                      tooltip: 'New group',
                      onPressed: () => _newGroup(context),
                      icon: Icon(Icons.add_rounded, color: Px.ink),
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
                        count: library?.phones.length,
                        saved: _book.groups.length,
                        onPick: (picked) => setState(() {
                          _category = picked;
                          _brand = null;
                          _query.clear();
                        }),
                        onSaved: library == null
                            ? null
                            : () async {
                                await Navigator.of(context).push(MaterialPageRoute<void>(
                                  builder: (_) => SavedSparesPage(library: library),
                                ));
                                await _loadBook();
                              },
                      )
                    : library == null
                        ? Center(child: CircularProgressIndicator(color: Px.accent))
                        : _brand == null
                            ? _BrandList(
                                library: library,
                                query: _query.text,
                                onPick: (brand) => setState(() {
                                  _brand = brand;
                                  _query.clear();
                                }),
                              )
                            : _PhoneList(
                                phones: _phones(library),
                                category: category,
                                onOpen: (phone) async {
                                  await Navigator.of(context).push(MaterialPageRoute<void>(
                                    builder: (_) => SparePhonePage(
                                      phone: phone,
                                      category: category,
                                      library: library,
                                    ),
                                  ));
                                  await _loadBook();
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FitmentPhone> _phones(FitmentLibrary library) {
    final brand = _brand;
    if (brand == null) return const [];
    final q = _query.text.trim().toLowerCase();
    final rows = library.byBrand(brand);
    if (q.isEmpty) return rows;
    return rows.where((phone) {
      return '${phone.name} ${phone.modelCode} ${phone.resolution}'.toLowerCase().contains(q);
    }).toList();
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
                count == null ? 'Phones' : '$count phones',
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
    required this.library,
    required this.query,
    required this.onPick,
  });

  final FitmentLibrary library;
  final String query;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    final brands = library.brands().where((name) => q.isEmpty || name.toLowerCase().contains(q)).toList();
    if (brands.isEmpty) {
      return const ShopEmpty(title: 'No brand matches', icon: Icons.search_off_rounded);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 28),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        final count = library.countBrand(brand);
        return ShopListTile(
          title: brand,
          subtitle: '$count models',
          leading: _Mark(letter: brand.isEmpty ? '?' : brand[0].toUpperCase()),
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

  final List<FitmentPhone> phones;
  final FitmentCategory category;
  final ValueChanged<FitmentPhone> onOpen;

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
        final spec = fitmentSpec(phone, category.code);
        return ShopListTile(
          title: phone.name,
          subtitle: spec.isEmpty ? phone.brand : spec,
          leading: _Mark(letter: phone.name.isEmpty ? '?' : phone.name[0].toUpperCase()),
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
