import 'dart:convert';

import '../catalog/fitment_library.dart';

/// Android reads one database value through a 2MB window. A whole fitment graph
/// is larger than that, so it is stored in pieces this size.
const catalogGraphChunkChars = 350000;

/// Splits a catalog graph into pieces a phone can read back.
List<String> splitCatalogGraph(String graph) {
  if (graph.isEmpty) return const [];
  final chunks = <String>[];
  for (var start = 0; start < graph.length; start += catalogGraphChunkChars) {
    final end = start + catalogGraphChunkChars > graph.length ? graph.length : start + catalogGraphChunkChars;
    chunks.add(graph.substring(start, end));
  }
  return chunks;
}

/// Storage key for one catalog list. Sorted query names keep the same address
/// for the same arguments no matter which map order the caller used.
String catalogListStorageKey(String path, Map<String, dynamic> query, {String? groupId}) {
  final group = (groupId == null || groupId.isEmpty) ? 'unselected' : groupId;
  final names = query.keys.toList()..sort();
  final parts = [
    for (final name in names)
      if (query[name] != null && '${query[name]}'.isNotEmpty) '$name=${query[name]}',
  ];
  return 'catalog.list.$group.$path?${parts.join('&')}';
}

/// Pulls the graph out of a snapshot download. List pages are not built here,
/// so the phone can show the one list on screen before the rest are saved.
Map<String, String>? stageCatalogSnapshot(Map<String, String> message) {
  final staged = _stagedSnapshot(message);
  if (staged == null) return null;
  return {'version': staged.version, 'graph': jsonEncode(staged.catalog)};
}

/// Encodes every brand and phone list for the offline database.
Map<String, String> encodeCatalogLists(Map<String, String> message) {
  final group = message['group'] ?? '';
  final graph = message['graph'] ?? '';
  final decoded = jsonDecode(graph);
  if (group.isEmpty || decoded is! Map) return const {};
  final lists = projectCatalogLists(group, Map<String, dynamic>.from(decoded));
  return {for (final entry in lists.entries) entry.key: jsonEncode(entry.value)};
}

/// Decodes a snapshot download and builds the brand and phone lists.
///
/// Runs in a background isolate. It does not build a page for every phone:
/// a shared part used by N phones used to be copied into N pages, which is
/// N² map entries, and that work ran on the UI isolate after a fast download.
/// One phone's page is built later, when that phone is opened.
Map<String, String>? prepareCatalogInstall(Map<String, String> message) {
  final group = message['group'] ?? '';
  final staged = _stagedSnapshot(message);
  if (staged == null) return null;
  final lists = projectCatalogLists(group, staged.catalog);
  return {
    'version': staged.version,
    'graph': jsonEncode(staged.catalog),
    for (final entry in lists.entries) entry.key: jsonEncode(entry.value),
  };
}

({String version, Map<String, dynamic> catalog})? _stagedSnapshot(Map<String, String> message) {
  final raw = message['raw'] ?? '';
  if ((message['group'] ?? '').isEmpty || raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) return null;
  final body = Map<String, dynamic>.from(decoded);
  if (body['unchanged'] == true) return null;
  final version = '${body['version'] ?? ''}';
  final catalogRaw = body['catalog'];
  if (version.isEmpty || catalogRaw is! Map) {
    throw const FormatException('Catalog snapshot is incomplete');
  }
  return (version: version, catalog: Map<String, dynamic>.from(catalogRaw));
}

/// Brand grids and per-brand phone lists, in the same shape the catalog screen already reads.
Map<String, List<Map<String, dynamic>>> projectCatalogLists(String group, Map<String, dynamic> catalog) {
  final brands = catalogRows(catalog['brands']);
  final devices = catalogRows(catalog['devices']);
  final components = catalogRows(catalog['components']);
  final fitments = catalogRows(catalog['fitments']);
  final brandsById = {for (final row in brands) '${row['id']}': row};
  final devicesById = {for (final row in devices) '${row['id']}': row};

  final deviceViews = <Map<String, dynamic>>[
    for (final device in devices)
      {
        ...device,
        'brandName': brandsById['${device['brandId']}']?['name'],
      },
  ];
  final devicesByBrand = <String, List<Map<String, dynamic>>>{};
  final deviceCount = <String, int>{};
  for (final device in deviceViews) {
    final brandId = '${device['brandId']}';
    deviceCount[brandId] = (deviceCount[brandId] ?? 0) + 1;
    (devicesByBrand[brandId] ??= []).add(device);
  }

  Map<String, int> mappedBrandCounts(Iterable<String> deviceIds) {
    final counts = <String, int>{};
    for (final id in deviceIds) {
      final brandId = '${devicesById[id]?['brandId'] ?? ''}';
      if (brandId.isEmpty) continue;
      counts[brandId] = (counts[brandId] ?? 0) + 1;
    }
    return counts;
  }

  List<Map<String, dynamic>> brandViews(Map<String, int> mappedCounts, {required bool mappedOnly}) {
    return [
      for (final brand in brands)
        if (!mappedOnly || (mappedCounts['${brand['id']}'] ?? 0) > 0)
          {
            ...brand,
            'deviceCount': deviceCount['${brand['id']}'] ?? 0,
            'mappedDeviceCount': mappedCounts['${brand['id']}'] ?? 0,
          },
    ];
  }

  final lists = <String, List<Map<String, dynamic>>>{};
  final allMapped = fitments.map((fitment) => '${fitment['deviceId']}').toSet();
  lists[catalogListStorageKey('commons/brands', const {}, groupId: group)] =
      brandViews(mappedBrandCounts(allMapped), mappedOnly: false);

  final fitmentsByComponent = <String, List<Map<String, dynamic>>>{};
  for (final fitment in fitments) {
    (fitmentsByComponent['${fitment['componentId']}'] ??= []).add(fitment);
  }
  for (final category in fitmentCategories) {
    final wanted = category.code.trim().toUpperCase();
    final componentIds = components
        .where((component) => '${component['categoryCode']}'.trim().toUpperCase() == wanted)
        .map((component) => '${component['id']}')
        .toSet();
    final mappedDevices = <String>{};
    final sharedDevices = <String>{};
    for (final componentId in componentIds) {
      final members = <String>{};
      for (final fitment in fitmentsByComponent[componentId] ?? const []) {
        final id = '${fitment['deviceId']}';
        // A fitment that points at no phone cannot be opened, so it is not compatibility.
        if (id.isEmpty || !devicesById.containsKey(id)) continue;
        members.add(id);
        mappedDevices.add(id);
      }
      // A spare that names only its own phone is model-specific, not shared.
      if (members.length > 1) sharedDevices.addAll(members);
    }
    final categoryBrands = brandViews(mappedBrandCounts(mappedDevices), mappedOnly: true);
    lists[catalogListStorageKey(
      'commons/brands',
      {'categoryCode': category.code},
      groupId: group,
    )] = categoryBrands;
    for (final brand in categoryBrands) {
      final brandId = '${brand['id']}';
      lists[catalogListStorageKey(
        'commons/devices',
        {'brandId': brandId, 'categoryCode': category.code},
        groupId: group,
      )] = [
        for (final device in devicesByBrand[brandId] ?? const <Map<String, dynamic>>[])
          {
            ...device,
            'shared': sharedDevices.contains('${device['id']}'),
          },
      ];
    }
  }
  return lists;
}

/// One group's catalog kept in memory so opening a phone does not decode it again.
class CatalogIndex {
  CatalogIndex(Map<String, dynamic> catalog)
      : brands = catalogRows(catalog['brands']),
        brandsById = {for (final row in catalogRows(catalog['brands'])) '${row['id']}': row},
        devicesById = {for (final row in catalogRows(catalog['devices'])) '${row['id']}': row},
        componentsById = {for (final row in catalogRows(catalog['components'])) '${row['id']}': row} {
    final deviceCount = <String, int>{};
    for (final device in devicesById.values) {
      final view = {
        ...device,
        'brandName': brandsById['${device['brandId']}']?['name'],
      };
      final brandId = '${device['brandId']}';
      deviceCount[brandId] = (deviceCount[brandId] ?? 0) + 1;
      (devicesByBrand[brandId] ??= []).add(view);
    }
    _deviceCount = deviceCount;
    for (final component in componentsById.values) {
      final code = '${component['categoryCode']}'.trim().toUpperCase();
      if (code.isEmpty) continue;
      (componentsByCategory[code] ??= []).add('${component['id']}');
    }
    final mappedDevices = <String>{};
    for (final fitment in catalogRows(catalog['fitments'])) {
      (fitmentsByComponent['${fitment['componentId']}'] ??= []).add(fitment);
      (fitmentsByDevice['${fitment['deviceId']}'] ??= []).add(fitment);
      final deviceId = '${fitment['deviceId']}';
      if (!mappedDevices.add(deviceId)) continue;
      final brandId = '${devicesById[deviceId]?['brandId'] ?? ''}';
      if (brandId.isEmpty) continue;
      _allMappedCounts[brandId] = (_allMappedCounts[brandId] ?? 0) + 1;
    }
  }

  final List<Map<String, dynamic>> brands;
  final Map<String, Map<String, dynamic>> brandsById;
  final Map<String, Map<String, dynamic>> devicesById;
  final Map<String, Map<String, dynamic>> componentsById;
  final devicesByBrand = <String, List<Map<String, dynamic>>>{};
  final componentsByCategory = <String, List<String>>{};
  final fitmentsByComponent = <String, List<Map<String, dynamic>>>{};
  final fitmentsByDevice = <String, List<Map<String, dynamic>>>{};
  final _categoryBrandCounts = <String, Map<String, int>>{};
  final _mappedDeviceIds = <String, Set<String>>{};
  final _sharedDeviceIds = <String, Set<String>>{};
  final _allMappedCounts = <String, int>{};
  late final Map<String, int> _deviceCount;

  /// The one list the screen is asking for. Other categories stay unbuilt until opened.
  List<Map<String, dynamic>>? list(String path, Map<String, dynamic> query) {
    if (path == 'commons/brands') {
      final code = '${query['categoryCode'] ?? ''}'.trim().toUpperCase();
      return code.isEmpty ? _brandViews(_allMappedCounts, mappedOnly: false) : _brandViews(_countsFor(code), mappedOnly: true);
    }
    if (path == 'commons/devices') {
      final brandId = '${query['brandId'] ?? ''}';
      if (brandId.isEmpty) return null;
      final phones = devicesByBrand[brandId] ?? const <Map<String, dynamic>>[];
      final code = '${query['categoryCode'] ?? ''}'.trim().toUpperCase();
      if (code.isEmpty) return phones;
      final shared = _sharedDevices(code);
      return [
        for (final phone in phones)
          {
            ...phone,
            'shared': shared.contains('${phone['id']}'),
          },
      ];
    }
    return null;
  }

  Set<String> _mappedDevices(String categoryCode) {
    final code = categoryCode.trim().toUpperCase();
    final cached = _mappedDeviceIds[code];
    if (cached != null) return cached;
    final ids = <String>{};
    for (final componentId in componentsByCategory[code] ?? const []) {
      for (final fitment in fitmentsByComponent[componentId] ?? const []) {
        final id = '${fitment['deviceId']}';
        if (id.isNotEmpty && devicesById.containsKey(id)) ids.add(id);
      }
    }
    _mappedDeviceIds[code] = ids;
    return ids;
  }

  /// Phones that share this spare with at least one other phone the page can open.
  Set<String> _sharedDevices(String categoryCode) {
    final code = categoryCode.trim().toUpperCase();
    final cached = _sharedDeviceIds[code];
    if (cached != null) return cached;
    final ids = <String>{};
    for (final componentId in componentsByCategory[code] ?? const []) {
      final members = <String>{
        for (final fitment in fitmentsByComponent[componentId] ?? const [])
          if (devicesById.containsKey('${fitment['deviceId']}')) '${fitment['deviceId']}',
      };
      if (members.length > 1) ids.addAll(members);
    }
    _sharedDeviceIds[code] = ids;
    return ids;
  }

  Map<String, int> _countsFor(String categoryCode) {
    final code = categoryCode.trim().toUpperCase();
    final cached = _categoryBrandCounts[code];
    if (cached != null) return cached;
    final counts = <String, int>{};
    for (final deviceId in _mappedDevices(code)) {
      final brandId = '${devicesById[deviceId]?['brandId'] ?? ''}';
      if (brandId.isEmpty) continue;
      counts[brandId] = (counts[brandId] ?? 0) + 1;
    }
    _categoryBrandCounts[code] = counts;
    return counts;
  }

  List<Map<String, dynamic>> _brandViews(Map<String, int> mappedCounts, {required bool mappedOnly}) {
    return [
      for (final brand in brands)
        if (!mappedOnly || (mappedCounts['${brand['id']}'] ?? 0) > 0)
          {
            ...brand,
            'deviceCount': _deviceCount['${brand['id']}'] ?? 0,
            'mappedDeviceCount': mappedCounts['${brand['id']}'] ?? 0,
          },
    ];
  }

  Map<String, dynamic>? detail(String deviceId, String categoryCode, {required String categoryLabel}) {
    final device = devicesById[deviceId];
    if (device == null) return null;
    final deviceView = {
      ...device,
      'brandName': brandsById['${device['brandId']}']?['name'],
    };
    final fits = <Map<String, dynamic>>[];
    final families = <Map<String, dynamic>>[];
    for (final fitment in fitmentsByDevice[deviceId] ?? const []) {
      final componentId = '${fitment['componentId']}';
      final component = componentsById[componentId];
      if (component == null) continue;
      final code = '${component['categoryCode']}'.toUpperCase();
      final wanted = categoryCode.trim().toUpperCase();
      if (wanted.isNotEmpty && code != wanted) continue;
      fits.add({
        'fitmentId': fitment['id'],
        'componentId': componentId,
        'componentName': component['name'],
        'categoryCode': code,
        'deviceId': device['id'],
        'deviceName': device['name'],
        'fit': fitment['fitQuality'],
        'confirmations': fitment['confirmations'],
        'disputes': fitment['disputes'],
        'disputed': fitment['disputed'],
        'verified': fitment['verified'],
        'confirmedByMe': false,
        'disputedByMe': false,
      });
      final members = <Map<String, dynamic>>[];
      final seenMembers = <String>{};
      for (final memberFitment in fitmentsByComponent[componentId] ?? const []) {
        final memberId = '${memberFitment['deviceId']}';
        final member = devicesById[memberId];
        if (member == null || !seenMembers.add('${member['id']}')) continue;
        members.add({
          'id': member['id'],
          'brandName': brandsById['${member['brandId']}']?['name'],
          'name': member['name'],
          'variant': member['variant'],
          'modelCode': member['modelCode'],
          'fit': memberFitment['fitQuality'],
          'verified': memberFitment['verified'],
          'disputed': memberFitment['disputed'],
          'fitmentId': memberFitment['id'],
        });
      }
      families.add({
        'id': componentId,
        'categoryCode': code,
        'categoryName': categoryLabel.isEmpty ? code : categoryLabel,
        'name': component['name'],
        'description': component['description'],
        'members': members,
      });
    }
    return {'device': deviceView, 'fits': fits, 'families': mergeOverlappingFamilies(families)};
  }

  /// Brands whose name contains every word, and phones matched by brand, name, or code.
  ///
  /// "m20" can hit a brand and a phone. "samsung m20" hits the phone, because one
  /// word has to land on the phone itself or a brand name would list every model.
  CatalogSearch search(String categoryCode, String query) {
    final code = categoryCode.trim().toUpperCase();
    final brands = _brandViews(_countsFor(code), mappedOnly: true);
    if (catalogSearchTokens(query).isEmpty) {
      return CatalogSearch(brands: brands, phones: const []);
    }
    final brandHits = [
      for (final brand in brands)
        if (catalogSearchHits(query, ['${brand['name']}'])) brand,
    ];
    final shared = _sharedDevices(code);
    final phones = <Map<String, dynamic>>[];
    for (final brand in brands) {
      final brandName = '${brand['name'] ?? ''}';
      for (final device in devicesByBrand['${brand['id']}'] ?? const <Map<String, dynamic>>[]) {
        final name = '${device['name'] ?? ''}';
        final modelCode = '${device['modelCode'] ?? ''}';
        final variant = '${device['variant'] ?? ''}';
        if (!catalogPhoneSearchHits(
          query,
          fields: [brandName, name, modelCode, variant],
          phoneFields: [name, modelCode, variant],
        )) {
          continue;
        }
        phones.add({
          ...device,
          'brandName': brandName,
          'logo': brand['logo'],
          'shared': shared.contains('${device['id']}'),
        });
      }
    }
    phones.sort((a, b) {
      final byBrand = '${a['brandName']}'.toLowerCase().compareTo('${b['brandName']}'.toLowerCase());
      if (byBrand != 0) return byBrand;
      return '${a['name']}'.toLowerCase().compareTo('${b['name']}'.toLowerCase());
    });
    return CatalogSearch(brands: brandHits, phones: phones);
  }
}

class CatalogSearch {
  const CatalogSearch({required this.brands, required this.phones});

  final List<Map<String, dynamic>> brands;
  final List<Map<String, dynamic>> phones;
}

List<String> catalogSearchTokens(String query) {
  return [
    for (final word in query.toLowerCase().split(RegExp(r'\s+')))
      if (word.isNotEmpty) _catalogCompact(word),
  ].where((token) => token.isNotEmpty).toList();
}

String _catalogCompact(String value) => value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Every word appears somewhere in [fields]. An empty query matches everything.
bool catalogSearchHits(String query, Iterable<String> fields) {
  final tokens = catalogSearchTokens(query);
  if (tokens.isEmpty) return true;
  final haystack = _catalogCompact(fields.join(' '));
  return tokens.every(haystack.contains);
}

/// Every word matches the brand or the phone, and one word matches the phone.
bool catalogPhoneSearchHits(
  String query, {
  required Iterable<String> fields,
  required Iterable<String> phoneFields,
}) {
  final tokens = catalogSearchTokens(query);
  if (tokens.isEmpty) return false;
  if (!catalogSearchHits(query, fields)) return false;
  final phone = _catalogCompact(phoneFields.join(' '));
  return tokens.any(phone.contains);
}

/// Spares that share a phone are one compatibility list. If A fits with B and B fits
/// with C, the page shows A, B, and C together.
List<Map<String, dynamic>> mergeOverlappingFamilies(List<Map<String, dynamic>> families) {
  if (families.length < 2) return families;
  final parent = [for (var i = 0; i < families.length; i++) i];
  int find(int index) {
    while (parent[index] != index) {
      parent[index] = parent[parent[index]];
      index = parent[index];
    }
    return index;
  }

  void unite(int left, int right) {
    final a = find(left);
    final b = find(right);
    if (a != b) parent[b] = a;
  }

  final memberIds = [
    for (final family in families) _familyMemberIds(family),
  ];
  for (var i = 0; i < families.length; i++) {
    for (var j = i + 1; j < families.length; j++) {
      final sameCategory = '${families[i]['categoryCode'] ?? ''}'.toUpperCase() ==
          '${families[j]['categoryCode'] ?? ''}'.toUpperCase();
      if (sameCategory && memberIds[i].intersection(memberIds[j]).isNotEmpty) unite(i, j);
    }
  }
  final groups = <int, List<Map<String, dynamic>>>{};
  for (var i = 0; i < families.length; i++) {
    (groups[find(i)] ??= []).add(families[i]);
  }
  return [for (final group in groups.values) _mergeFamilyGroup(group)];
}

Set<String> _familyMemberIds(Map<String, dynamic> family) {
  return {
    for (final member in catalogRows(family['members']))
      if ('${member['id'] ?? member['deviceId'] ?? ''}'.isNotEmpty) '${member['id'] ?? member['deviceId']}',
  };
}

List<String> familyComponentIds(Map<String, dynamic> family) {
  final listed = family['componentIds'];
  if (listed is List) {
    final ids = [for (final id in listed) '$id'].where((id) => id.isNotEmpty).toList();
    if (ids.isNotEmpty) return ids;
  }
  final id = '${family['id'] ?? ''}';
  return id.isEmpty ? const [] : [id];
}

Map<String, dynamic> _mergeFamilyGroup(List<Map<String, dynamic>> families) {
  if (families.length == 1) return families.single;
  final members = <String, Map<String, dynamic>>{};
  final componentIds = <String>[];
  for (final family in families) {
    for (final id in familyComponentIds(family)) {
      if (!componentIds.contains(id)) componentIds.add(id);
    }
    for (final member in catalogRows(family['members'])) {
      final id = '${member['id'] ?? member['deviceId'] ?? ''}';
      if (id.isEmpty) continue;
      members.putIfAbsent(id, () => member);
    }
  }
  final names = [
    for (final family in families)
      if ('${family['name'] ?? ''}'.trim().isNotEmpty) '${family['name']}'.trim(),
  ]..sort((a, b) {
      final aMarked = a.contains('[');
      final bMarked = b.contains('[');
      if (aMarked != bMarked) return aMarked ? 1 : -1;
      return a.length.compareTo(b.length);
    });
  return {
    ...families.first,
    'name': names.isEmpty ? families.first['name'] : names.first,
    'members': members.values.toList(),
    'componentIds': componentIds,
  };
}

List<Map<String, dynamic>> catalogRows(dynamic data) {
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['content', 'items', 'rows']) {
      final value = map[key];
      if (value is List) {
        return value.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
      }
    }
  }
  if (data is List) {
    return data.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
  }
  return const [];
}
