import 'package:flutter/foundation.dart';

import '../catalog/fitment_library.dart';
import 'sync_store.dart';

typedef CatalogGet = Future<dynamic> Function(String path, Map<String, dynamic> query);

/// Installs the backend's one immutable catalog snapshot on the phone.
///
/// One HTTP request, one SQLite transaction. This deliberately does not crawl
/// brands or phones: the backend has already published an internally consistent
/// graph in Redis, and that exact graph is what the phone keeps offline.
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

  Future<void> warm() async {
    if (_running || !online()) return;
    final group = groupId();
    if (group == null || group.isEmpty) return;
    _running = true;
    try {
      final installed = await sync.catalogVersion(group);
      final body = await get('commons/snapshot', {
        if (installed != null) 'version': installed,
      });
      if (body is! Map || body['unchanged'] == true) return;
      final version = '${body['version'] ?? ''}';
      final catalog = body['catalog'];
      if (version.isEmpty || catalog is! Map) {
        throw const FormatException('Catalog snapshot is incomplete');
      }
      final projection = _project(group, Map<String, dynamic>.from(catalog));
      await sync.installCatalogSnapshot(
        groupId: group,
        version: version,
        lists: projection.lists,
        details: projection.details,
      );
    } catch (e, st) {
      debugPrint('catalog snapshot unchanged: $e\n$st');
    } finally {
      _running = false;
    }
  }

  _Projection _project(String group, Map<String, dynamic> catalog) {
    final brands = _rows(catalog['brands']);
    final devices = _rows(catalog['devices']);
    final components = _rows(catalog['components']);
    final fitments = _rows(catalog['fitments']);
    final brandsById = {for (final row in brands) '${row['id']}': row};
    final devicesById = {for (final row in devices) '${row['id']}': row};
    final componentsById = {for (final row in components) '${row['id']}': row};
    final fitmentsByComponent = <String, List<Map<String, dynamic>>>{};
    final fitmentsByDevice = <String, List<Map<String, dynamic>>>{};
    for (final fitment in fitments) {
      fitmentsByComponent.putIfAbsent('${fitment['componentId']}', () => []).add(fitment);
      fitmentsByDevice.putIfAbsent('${fitment['deviceId']}', () => []).add(fitment);
    }

    Map<String, dynamic> deviceView(Map<String, dynamic> device) => {
          ...device,
          'brandName': brandsById['${device['brandId']}']?['name'],
        };

    final allDeviceViews = [for (final device in devices) deviceView(device)];
    List<Map<String, dynamic>> brandViews(Set<String> mappedDevices, {required bool mappedOnly}) {
      return [
        for (final brand in brands)
          if (!mappedOnly ||
              mappedDevices.any((id) => '${devicesById[id]?['brandId']}' == '${brand['id']}'))
            {
              ...brand,
              'deviceCount': devices.where((device) => '${device['brandId']}' == '${brand['id']}').length,
              'mappedDeviceCount': mappedDevices
                  .where((id) => '${devicesById[id]?['brandId']}' == '${brand['id']}')
                  .length,
            },
      ];
    }

    final lists = <String, List<Map<String, dynamic>>>{};
    final allMapped = fitments.map((fitment) => '${fitment['deviceId']}').toSet();
    lists[sync.catalogListKey('commons/brands', const {}, groupId: group)] =
        brandViews(allMapped, mappedOnly: false);

    final details = <String, Map<String, dynamic>>{};
    for (final category in fitmentCategories) {
      final componentIds = components
          .where((component) => '${component['categoryCode']}' == category.code)
          .map((component) => '${component['id']}')
          .toSet();
      final categoryFitments =
          fitments.where((fitment) => componentIds.contains('${fitment['componentId']}')).toList();
      final mappedDevices = categoryFitments.map((fitment) => '${fitment['deviceId']}').toSet();
      final categoryBrands = brandViews(mappedDevices, mappedOnly: true);
      lists[sync.catalogListKey(
        'commons/brands',
        {'categoryCode': category.code},
        groupId: group,
      )] = categoryBrands;
      for (final brand in categoryBrands) {
        final brandId = '${brand['id']}';
        lists[sync.catalogListKey(
          'commons/devices',
          {'brandId': brandId, 'categoryCode': category.code},
          groupId: group,
        )] = allDeviceViews.where((device) => '${device['brandId']}' == brandId).toList();
      }
      for (final device in devices) {
        final deviceId = '${device['id']}';
        details['catalog.detail.$group.$deviceId.${category.code}'] = _detail(
          deviceView(device),
          category.code,
          category.label,
          fitmentsByDevice[deviceId] ?? const [],
          fitmentsByComponent,
          componentsById,
          devicesById,
          brandsById,
        );
      }
    }
    return _Projection(lists, details);
  }
}

Map<String, dynamic> _detail(
  Map<String, dynamic> device,
  String categoryCode,
  String categoryName,
  List<Map<String, dynamic>> deviceFitments,
  Map<String, List<Map<String, dynamic>>> fitmentsByComponent,
  Map<String, Map<String, dynamic>> componentsById,
  Map<String, Map<String, dynamic>> devicesById,
  Map<String, Map<String, dynamic>> brandsById,
) {
  final fits = <Map<String, dynamic>>[];
  final families = <Map<String, dynamic>>[];
  for (final fitment in deviceFitments) {
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
      'categoryName': categoryName,
      'name': component['name'],
      'description': component['description'],
      'members': members,
    });
  }
  return {'device': device, 'fits': fits, 'families': families};
}

class _Projection {
  const _Projection(this.lists, this.details);

  final Map<String, List<Map<String, dynamic>>> lists;
  final Map<String, Map<String, dynamic>> details;
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
