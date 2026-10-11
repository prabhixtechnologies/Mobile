import 'package:flutter/foundation.dart';

import '../catalog/fitment_library.dart';
import 'sync_store.dart';

typedef CatalogGet = Future<dynamic> Function(String path, Map<String, dynamic> query);

/// Downloads the fitment catalog onto the phone while the network is up.
///
/// Lists and phone pages already saved stay readable when Identity or the shop
/// API is down. A failed request stops the pass; the next connection resumes
/// from the cursor instead of starting over.
class CatalogMirror {
  CatalogMirror({
    required this.sync,
    required this.get,
    required this.online,
    required this.groupId,
  });

  final SyncStore sync;
  final CatalogGet get;
  final bool Function() online;
  final String? Function() groupId;
  bool _running = false;

  Future<void> warm(int generation) async {
    if (_running || !online()) return;
    final group = groupId();
    if (group == null || group.isEmpty) return;
    _running = true;
    try {
      final stored = await sync.catalogWarmCursor() ?? {};
      final sameGeneration = stored['generation'] == generation && stored['groupId'] == group;
      final cursor = sameGeneration ? Map<String, dynamic>.from(stored) : <String, dynamic>{
        'generation': generation,
        'groupId': group,
        'categoryIndex': 0,
        'brandIndex': 0,
        'listsDone': false,
        'familyCategoryIndex': 0,
        'familyBrandIndex': 0,
        'familyDeviceIndex': 0,
      };
      if (!sameGeneration) await sync.saveCatalogWarmCursor(cursor);
      if (cursor['listsDone'] != true) {
        await _brands(const {});
        await _deviceLists(cursor);
      }
      if (cursor['listsDone'] == true) await _families(cursor);
    } catch (e, st) {
      debugPrint('catalog mirror paused: $e\n$st');
    } finally {
      _running = false;
    }
  }

  Future<void> _deviceLists(Map<String, dynamic> cursor) async {
    var categoryIndex = (cursor['categoryIndex'] as num?)?.toInt() ?? 0;
    while (categoryIndex < fitmentCategories.length) {
      if (!online()) return;
      final code = fitmentCategories[categoryIndex].code;
      final brands = await _brands({'categoryCode': code});
      var brandIndex = (cursor['brandIndex'] as num?)?.toInt() ?? 0;
      while (brandIndex < brands.length) {
        if (!online()) return;
        final brandId = '${brands[brandIndex]['id'] ?? ''}';
        if (brandId.isNotEmpty) {
          await _pages('commons/devices', {'brandId': brandId, 'categoryCode': code});
        }
        brandIndex += 1;
        cursor['brandIndex'] = brandIndex;
        await sync.saveCatalogWarmCursor(cursor);
      }
      categoryIndex += 1;
      cursor['categoryIndex'] = categoryIndex;
      cursor['brandIndex'] = 0;
      await sync.saveCatalogWarmCursor(cursor);
    }
    cursor['listsDone'] = true;
    await sync.saveCatalogWarmCursor(cursor);
  }

  Future<void> _families(Map<String, dynamic> cursor) async {
    var categoryIndex = (cursor['familyCategoryIndex'] as num?)?.toInt() ?? 0;
    while (categoryIndex < fitmentCategories.length) {
      if (!online()) return;
      final code = fitmentCategories[categoryIndex].code;
      final brands = await sync.readCatalogList('commons/brands', {'categoryCode': code}) ?? const [];
      var brandIndex = (cursor['familyBrandIndex'] as num?)?.toInt() ?? 0;
      while (brandIndex < brands.length) {
        if (!online()) return;
        final brandId = '${brands[brandIndex]['id'] ?? ''}';
        final devices = brandId.isEmpty
            ? const <Map<String, dynamic>>[]
            : await sync.readCatalogList('commons/devices', {'brandId': brandId, 'categoryCode': code}) ??
                const <Map<String, dynamic>>[];
        var deviceIndex = (cursor['familyDeviceIndex'] as num?)?.toInt() ?? 0;
        while (deviceIndex < devices.length) {
          if (!online()) return;
          await _family(devices[deviceIndex], code);
          deviceIndex += 1;
          cursor['familyDeviceIndex'] = deviceIndex;
          await sync.saveCatalogWarmCursor(cursor);
        }
        brandIndex += 1;
        cursor['familyBrandIndex'] = brandIndex;
        cursor['familyDeviceIndex'] = 0;
        await sync.saveCatalogWarmCursor(cursor);
      }
      categoryIndex += 1;
      cursor['familyCategoryIndex'] = categoryIndex;
      cursor['familyBrandIndex'] = 0;
      cursor['familyDeviceIndex'] = 0;
      await sync.saveCatalogWarmCursor(cursor);
    }
  }

  Future<void> _family(Map<String, dynamic> device, String categoryCode) async {
    final id = '${device['id'] ?? ''}';
    if (id.isEmpty) return;
    final key = 'device.$id.$categoryCode';
    final existing = await sync.commonsPage(key);
    final body = await get('commons/devices/family', {'deviceId': id, 'categoryCode': categoryCode});
    await sync.saveCommonsPage(key, {
      'device': existing?['device'] ?? device,
      'fits': existing?['fits'] ?? const [],
      'stock': existing?['stock'] ?? const [],
      'families': _rows(body),
    });
  }

  Future<List<Map<String, dynamic>>> _brands(Map<String, dynamic> query) {
    return _pages('commons/brands', query);
  }

  Future<List<Map<String, dynamic>>> _pages(String path, Map<String, dynamic> query) async {
    final rows = <Map<String, dynamic>>[];
    for (var page = 0; page < 40; page++) {
      if (!online()) break;
      final body = await get(path, {...query, 'page': page, 'size': 100});
      final batch = _rows(body);
      rows.addAll(batch);
      final last = body is Map && body['last'] == true;
      if (last || batch.length < 100) {
        await sync.saveCatalogList(path, query, rows);
        return rows;
      }
    }
    final saved = await sync.readCatalogList(path, query);
    return saved ?? rows;
  }
}

List<Map<String, dynamic>> _rows(dynamic data) {
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
