import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../catalog/fitment_library.dart';
import '../catalog/spare_group.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/live_api_list.dart';
import '../widgets/shop_ui.dart';

class SparePhonePage extends StatefulWidget {
  const SparePhonePage({
    super.key,
    required this.phone,
    required this.category,
    required this.library,
  });

  final FitmentPhone phone;
  final FitmentCategory category;
  final FitmentLibrary library;

  @override
  State<SparePhonePage> createState() => _SparePhonePageState();
}

class _SharedPart {
  const _SharedPart({
    required this.fitmentId,
    required this.name,
    required this.fit,
    required this.others,
  });

  final String fitmentId;
  final String name;
  final String fit;
  final List<String> others;
}

class _SparePhonePageState extends State<SparePhonePage> {
  FitmentBook _book = const FitmentBook([]);
  List<_SharedPart> _shared = const [];
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _reload();
    _loadShared();
  }

  Future<void> _loadShared() async {
    final phone = widget.phone;
    try {
      final api = context.read<AppState>().api;
      final search = await api.dio.get<dynamic>(
        'commons/devices',
        queryParameters: {'q': phone.name, 'size': 30},
      );
      Map<String, dynamic>? match;
      for (final row in pageRows(search.data)) {
        final brand = '${row['brandName'] ?? ''}'.toLowerCase();
        final name = '${row['name'] ?? ''}'.toLowerCase();
        if (brand == phone.brand.toLowerCase() && name == phone.name.toLowerCase()) {
          match = row;
          break;
        }
      }
      final id = match == null ? '' : '${match['id'] ?? ''}';
      if (id.isEmpty || !mounted) return;
      final fitsRes = await api.dio.get<dynamic>('commons/devices/$id/fits');
      final shared = <_SharedPart>[];
      for (final fit in pageRows(fitsRes.data)) {
        final code = '${fit['categoryCode'] ?? ''}';
        if (code.isNotEmpty && code != widget.category.code) continue;
        final componentId = '${fit['componentId'] ?? ''}';
        if (componentId.isEmpty) continue;
        final devicesRes = await api.dio.get<dynamic>('commons/components/$componentId/devices');
        final self = '${phone.brand} ${phone.name}'.toLowerCase();
        final others = pageRows(devicesRes.data)
            .map((row) => '${row['brandName'] ?? ''} ${row['name'] ?? ''}'.trim())
            .where((label) => label.isNotEmpty && label.toLowerCase() != self)
            .toList();
        shared.add(_SharedPart(
          fitmentId: '${fit['fitmentId'] ?? ''}',
          name: '${fit['componentName'] ?? 'Part'}',
          fit: spareQualityLabel('${fit['fit'] ?? 'EXACT'}'),
          others: others,
        ));
      }
      if (!mounted) return;
      setState(() => _shared = shared);
    } catch (_) {}
  }

  Future<void> _reload() async {
    final book = await FitmentBook.load(context.read<AppState>().sync);
    if (!mounted) return;
    setState(() => _book = book);
  }

  Future<void> _save(FitmentBook book) async {
    await book.persist(context.read<AppState>().sync);
    if (!mounted) return;
    setState(() => _book = book);
  }

  List<SpareGroup> get _groups =>
      _book.forPhone(widget.category.code, widget.phone.brand, widget.phone.name);

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone;
    final spec = fitmentSpec(phone, widget.category.code);
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopHeroHeader(
                title: phone.name,
                subtitle: '${phone.brand} · ${widget.category.label}',
                actions: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: Px.ink),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _SpecCard(phone: phone, spec: spec),
                    if (_shared.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        'Shared catalog',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Px.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final part in _shared) ...[
                        Text(part.name, style: Theme.of(context).textTheme.titleMedium),
                        Text(part.fit, style: Theme.of(context).textTheme.bodySmall),
                        if (part.others.isEmpty)
                          Text('Only this phone so far', style: Theme.of(context).textTheme.bodyMedium)
                        else
                          for (final other in part.others)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(other),
                            ),
                        if (part.fitmentId.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () => _confirm(part.fitmentId),
                              child: const Text('Confirm'),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'Same spare',
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Px.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Group the phones that take this ${widget.category.label.toLowerCase()}. Sharing sends the group for every shop.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    if (_groups.isEmpty)
                      const ShopEmpty(
                        title: 'No spare recorded yet',
                        icon: Icons.link_off_rounded,
                      )
                    else
                      for (final group in _groups) ...[
                        _GroupCard(
                          group: group,
                          sharing: _sharing,
                          onOpen: (member) {
                            final match = widget.library.findPhone(member.brand, member.name);
                            if (match == null || (match.brand == phone.brand && match.name == phone.name)) {
                              return;
                            }
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (_) => SparePhonePage(
                                phone: match,
                                category: widget.category,
                                library: widget.library,
                              ),
                            ));
                          },
                          onEdit: () => _edit(group),
                          onShare: () => _share(group),
                          onDelete: () => _save(_book.remove(group.id)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => _edit(null),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Record a spare'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(SpareGroup? existing) async {
    final saved = await Navigator.of(context).push<SpareGroup>(MaterialPageRoute(
      builder: (_) => SpareEditorPage(
        library: widget.library,
        category: widget.category,
        seed: widget.phone,
        existing: existing,
      ),
    ));
    if (saved == null) return;
    await _save(_book.upsert(saved));
  }

  Future<void> _confirm(String fitmentId) async {
    try {
      await context.read<AppState>().api.dio.post<dynamic>(
        'commons/contributions',
        data: {'kind': 'CONFIRM_FITMENT', 'targetId': fitmentId},
      );
      await _loadShared();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Confirmed. That spare stays in the shared catalog.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not confirm that from here.')),
      );
    }
  }

  Future<void> _share(SpareGroup group) async {
    setState(() => _sharing = true);
    final result = await shareSpareGroup(
      (body) => context.read<AppState>().api.dio.post<dynamic>('commons/contributions', data: body),
      group,
      widget.category.label,
    );
    if (!mounted) return;
    final next = result.status == 'failed' ? group : group.copyWith(shareStatus: result.status);
    await _save(_book.upsert(next));
    if (!mounted) return;
    setState(() => _sharing = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
  }
}

class SavedSparesPage extends StatefulWidget {
  const SavedSparesPage({super.key, required this.library});

  final FitmentLibrary library;

  @override
  State<SavedSparesPage> createState() => _SavedSparesPageState();
}

class _SavedSparesPageState extends State<SavedSparesPage> {
  FitmentBook _book = const FitmentBook([]);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final book = await FitmentBook.load(context.read<AppState>().sync);
    if (!mounted) return;
    setState(() => _book = book);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _book.groups;
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopHeroHeader(
                title: 'Saved spares',
                subtitle: groups.isEmpty ? 'Nothing recorded yet' : '${groups.length} groups on this phone',
                actions: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: Px.ink),
                  ),
                ],
              ),
              Expanded(
                child: groups.isEmpty
                    ? const ShopEmpty(title: 'Record a spare from a phone', icon: Icons.bookmark_border_rounded)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 28),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final first = group.members.isEmpty ? null : group.members.first;
                          return ShopListTile(
                            title: group.note.trim().isEmpty
                                ? categoryLabel(group.categoryCode)
                                : group.note.trim(),
                            subtitle:
                                '${categoryLabel(group.categoryCode)} · ${spareQualityLabel(group.quality)} · ${group.members.length} phones · ${spareShareLabel(group.shareStatus)}',
                            onTap: first == null
                                ? null
                                : () async {
                                    final phone = widget.library.findPhone(first.brand, first.name);
                                    final category = categoryByCode(group.categoryCode);
                                    if (phone == null || category == null) return;
                                    await Navigator.of(context).push(MaterialPageRoute<void>(
                                      builder: (_) => SparePhonePage(
                                        phone: phone,
                                        category: category,
                                        library: widget.library,
                                      ),
                                    ));
                                    await _reload();
                                  },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpareEditorPage extends StatefulWidget {
  const SpareEditorPage({
    super.key,
    required this.library,
    required this.category,
    required this.seed,
    this.existing,
  });

  final FitmentLibrary library;
  final FitmentCategory category;
  final FitmentPhone seed;
  final SpareGroup? existing;

  @override
  State<SpareEditorPage> createState() => _SpareEditorPageState();
}

class _SpareEditorPageState extends State<SpareEditorPage> {
  final _query = TextEditingController();
  final _note = TextEditingController();
  late String _quality;
  late final List<SpareMember> _members;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _quality = existing?.quality ?? 'EXACT';
    _note.text = existing?.note ?? '';
    _members = [
      ...?existing?.members,
    ];
    if (!_members.any((member) => member.brand == widget.seed.brand && member.name == widget.seed.name)) {
      _members.insert(0, SpareMember(brand: widget.seed.brand, name: widget.seed.name));
    }
  }

  @override
  void dispose() {
    _query.dispose();
    _note.dispose();
    super.dispose();
  }

  void _toggle(FitmentPhone phone) {
    final seed = phone.brand == widget.seed.brand && phone.name == widget.seed.name;
    if (seed) return;
    setState(() {
      final index = _members.indexWhere((member) => member.brand == phone.brand && member.name == phone.name);
      if (index >= 0) {
        _members.removeAt(index);
      } else {
        _members.add(SpareMember(brand: phone.brand, name: phone.name));
      }
    });
  }

  void _save() {
    final existing = widget.existing;
    final group = existing == null
        ? newSpareGroup(
            categoryCode: widget.category.code,
            quality: _quality,
            note: _note.text,
            members: List<SpareMember>.from(_members),
          )
        : existing.copyWith(
            quality: _quality,
            note: _note.text.trim(),
            members: List<SpareMember>.from(_members),
            shareStatus: 'local',
          );
    Navigator.of(context).pop(group);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.text.trim().toLowerCase();
    final results = q.length < 2
        ? const <FitmentPhone>[]
        : widget.library.search(_query.text).take(40).toList();
    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              ShopHeroHeader(
                title: widget.existing == null ? 'Record a spare' : 'Edit spare',
                subtitle: widget.category.label,
                actions: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: Px.ink),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final quality in ['EXACT', 'COMPATIBLE', 'REQUIRES_MODIFICATION'])
                      ChoiceChip(
                        label: Text(spareQualityLabel(quality)),
                        selected: _quality == quality,
                        onSelected: (_) => setState(() => _quality = quality),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: TextField(
                  controller: _note,
                  decoration: const InputDecoration(
                    labelText: 'Part name or code',
                    hintText: 'Optional, for example a service-pack code',
                  ),
                ),
              ),
              ShopSearchField(
                controller: _query,
                hint: 'Search any brand or model…',
                onChanged: (_) => setState(() {}),
              ),
              if (_members.isNotEmpty)
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (final member in _members)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(label: Text(member.name)),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: q.length < 2
                    ? const ShopEmpty(title: 'Type two letters to search', icon: Icons.search_rounded)
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final phone = results[index];
                          final selected = _members.any(
                            (member) => member.brand == phone.brand && member.name == phone.name,
                          );
                          return ShopListTile(
                            title: phone.name,
                            subtitle: '${phone.brand} · ${fitmentSpec(phone, widget.category.code)}',
                            trailing: Icon(
                              selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                              color: selected ? Px.accent : Px.faint,
                            ),
                            onTap: () => _toggle(phone),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _members.length < 2 ? null : _save,
                    child: Text(_members.length < 2 ? 'Pick another phone' : 'Save ${_members.length} phones'),
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

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.phone, required this.spec});

  final FitmentPhone phone;
  final String spec;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if (phone.modelCode.isNotEmpty) ('Model code', phone.modelCode),
      if (phone.year != null) ('Year', '${phone.year}'),
      if (phone.batteryMah != null) ('Battery', '${phone.batteryMah} mAh'),
      if (phone.inches != null) ('Display', '${phone.inches} in'),
      if (phone.resolution.isNotEmpty) ('Resolution', phone.resolution),
      if (spec.isNotEmpty) ('For this part', spec),
    ];
    return Material(
      color: Px.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(width: 110, child: Text(row.$1, style: Theme.of(context).textTheme.bodySmall)),
                    Expanded(child: Text(row.$2)),
                  ],
                ),
              ),
            Text(
              'Public specification. The same size or the same mAh is not a confirmed spare.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.sharing,
    required this.onOpen,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  final SpareGroup group;
  final bool sharing;
  final ValueChanged<SpareMember> onOpen;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Px.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.note.trim().isEmpty ? spareQualityLabel(group.quality) : group.note.trim(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${spareQualityLabel(group.quality)} · ${spareShareLabel(group.shareStatus)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final member in group.members)
              InkWell(
                onTap: () => onOpen(member),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(member.label),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton(onPressed: onEdit, child: const Text('Edit')),
                TextButton(
                  onPressed: sharing || group.shareStatus == 'shared' ? null : onShare,
                  child: Text(sharing ? 'Sharing…' : 'Share'),
                ),
                TextButton(onPressed: onDelete, child: const Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
