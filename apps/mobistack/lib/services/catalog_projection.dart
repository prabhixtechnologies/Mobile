import 'dart:convert';

import '../catalog/fitment_library.dart';

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

/// Decodes a snapshot download and builds the brand and phone lists.
///
/// Runs in a background isolate. It does not build a page for every phone:
/// a shared part used by N phones used to be copied into N pages, which is
/// N² map entries, and that work ran on the UI isolate after a fast download.
/// One phone's page is built later, when that phone is opened.
Map<String, String>? prepareCatalogInstall(Map<String, String> message) {
  final group = message['group'] ?? '';
  final raw = message['raw'] ?? '';
  if (group.isEmpty || raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) return null;
  final body = Map<String, dynamic>.from(decoded);
  if (body['unchanged'] == true) return null;
  final version = '${body['version'] ?? ''}';
  final catalogRaw = body['catalog'];
  if (version.isEmpty || catalogRaw is! Map) {
    throw const FormatException('Catalog snapshot is incomplete');
  }
  final catalog = Map<String, dynamic>.from(catalogRaw);
  final lists = projectCatalogLists(group, catalog);
  return {
    'version': version,
    'graph': jsonEncode(catalog),
    for (final entry in lists.entries) entry.key: jsonEncode(entry.value),
  };
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
    final componentIds = components
        .where((component) => '${component['categoryCode']}' == category.code)
        .map((component) => '${component['id']}')
        .toSet();
    final mappedDevices = <String>{};
    for (final componentId in componentIds) {
      for (final fitment in fitmentsByComponent[componentId] ?? const []) {
        mappedDevices.add('${fitment['deviceId']}');
      }
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
      )] = devicesByBrand[brandId] ?? const [];
    }
  }
  return lists;
}

/// One group's catalog kept in memory so opening a phone does not decode it again.
class CatalogIndex {
  CatalogIndex(Map<String, dynamic> catalog)
      : brandsById = {for (final row in catalogRows(catalog['brands'])) '${row['id']}': row},
        devicesById = {for (final row in catalogRows(catalog['devices'])) '${row['id']}': row},
        componentsById = {for (final row in catalogRows(catalog['components'])) '${row['id']}': row} {
    for (final fitment in catalogRows(catalog['fitments'])) {
      (fitmentsByComponent['${fitment['componentId']}'] ??= []).add(fitment);
      (fitmentsByDevice['${fitment['deviceId']}'] ??= []).add(fitment);
    }
  }

  final Map<String, Map<String, dynamic>> brandsById;
  final Map<String, Map<String, dynamic>> devicesById;
  final Map<String, Map<String, dynamic>> componentsById;
  final fitmentsByComponent = <String, List<Map<String, dynamic>>>{};
  final fitmentsByDevice = <String, List<Map<String, dynamic>>>{};

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
      if (component == null || '${component['categoryCode']}' != categoryCode) continue;
      fits.add({
        'fitmentId': fitment['id'],
        'componentId': componentId,
        'componentName': component['name'],
        'categoryCode': categoryCode,
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
      for (final memberFitment in fitmentsByComponent[componentId] ?? const []) {
        final member = devicesById['${memberFitment['deviceId']}'];
        if (member == null) continue;
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
        'categoryCode': categoryCode,
        'categoryName': categoryLabel,
        'name': component['name'],
        'description': component['description'],
        'members': members,
      });
    }
    return {'device': deviceView, 'fits': fits, 'families': families};
  }
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
