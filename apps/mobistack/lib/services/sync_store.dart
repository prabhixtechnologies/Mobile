import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/shop_models.dart';

class SyncStore {
  SyncStore(this.api);

  final ApiClient api;
  Database? _db;
  static const _uuid = Uuid();

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'mobistack.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE kv (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
        await db.execute('''
          CREATE TABLE outbox (
            idempotency_key TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> _put(String key, Object value) async {
    final db = await _open();
    await db.insert(
      'kv',
      {'key': key, 'value': jsonEncode(value)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> _get(String key) async {
    final db = await _open();
    final rows = await db.query('kv', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return jsonDecode('${rows.first['value']}');
  }

  Future<void> pullSnapshot() async {
    try {
      final res = await api.dio.get<Map<String, dynamic>>('sync/snapshot');
      final data = res.data ?? {};
      await _put('snapshot.variants', data['variants'] ?? []);
      await _put('snapshot.sales', data['sales'] ?? []);
      await _put('snapshot.repairs', data['repairs'] ?? []);
      await _put('snapshot.customers', data['customers'] ?? []);
      await _put('snapshot.devices', data['devices'] ?? []);
      final commons = data['commons'];
      if (commons is Map) {
        await _put('snapshot.commons.devices', commons['devices'] ?? []);
        await _put('snapshot.commons.brands', commons['brands'] ?? []);
      }
      await _put('snapshot.dashboard', data['dashboard'] ?? {});
      await _put('snapshot.pulledAt', data['pulledAt'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      // Keep last good local snapshot when offline.
    }
  }

  Future<List<CachedVariant>> variants() async {
    final raw = await _get('snapshot.variants');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedVariant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CachedSale>> sales() async {
    final raw = await _get('snapshot.sales');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedSale.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CachedRepair>> repairs() async {
    final raw = await _get('snapshot.repairs');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedRepair.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CachedCustomer>> customers() async {
    final raw = await _get('snapshot.customers');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedCustomer.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<CachedDevice>> commonsDevices() async {
    final raw = await _get('snapshot.commons.devices');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedDevice.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Last fitment page opened for this phone or part. The snapshot only stores
  /// popular device names; these pages are what make a repeat tap instant.
  Future<Map<String, dynamic>?> commonsPage(String key) async {
    final raw = await _get('commons.page.$key');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> saveCommonsPage(String key, Map<String, dynamic> value) async {
    await _put('commons.page.$key', value);
  }

  /// Lists the counter opens that are not part of the shop snapshot.
  static const offlineListPaths = <String>[
    'purchases',
    'suppliers',
    'users',
    'inventory/transactions',
    'inbox',
    'compatibility-groups',
  ];

  String catalogListKey(String path, Map<String, dynamic> query, {String? groupId}) {
    final group = groupId ?? api.fitmentGroupId ?? 'unselected';
    final names = query.keys.toList()..sort();
    final parts = [
      for (final name in names)
        if (query[name] != null && '${query[name]}'.isNotEmpty) '$name=${query[name]}',
    ];
    return 'catalog.list.$group.$path?${parts.join('&')}';
  }

  Future<List<Map<String, dynamic>>?> readCatalogList(
    String path,
    Map<String, dynamic> query, {
    String? groupId,
  }) async {
    try {
      final raw = await _get(catalogListKey(path, query, groupId: groupId));
      if (raw is! List) return null;
      return raw.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (e) {
      // No saved catalog yet, including a widget test where the database is not opened.
      debugPrint('catalog list unreadable: $e');
      return null;
    }
  }

  Future<void> saveCatalogList(
    String path,
    Map<String, dynamic> query,
    List<Map<String, dynamic>> rows, {
    String? groupId,
  }) async {
    await _put(catalogListKey(path, query, groupId: groupId), rows);
  }

  Future<String?> catalogVersion(String groupId) async {
    final raw = await _get('catalog.snapshot.version.$groupId');
    return raw is String && raw.isNotEmpty ? raw : null;
  }

  Future<Map<String, dynamic>?> catalogDetail(String groupId, String deviceId, String categoryCode) async {
    try {
      final raw = await _get('catalog.detail.$groupId.$deviceId.$categoryCode');
      return raw is Map ? Map<String, dynamic>.from(raw) : null;
    } catch (e) {
      debugPrint('catalog detail unreadable: $e');
      return null;
    }
  }

  /// Replaces one group's complete offline catalog in one SQLite transaction.
  ///
  /// Readers see either the previous version or the new one. A killed process, full disk, or malformed
  /// download cannot leave half the brands on one version and half the fitments on another.
  Future<void> installCatalogSnapshot({
    required String groupId,
    required String version,
    required Map<String, List<Map<String, dynamic>>> lists,
    required Map<String, Map<String, dynamic>> details,
  }) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.delete('kv', where: 'key LIKE ?', whereArgs: ['catalog.list.$groupId.%']);
      await txn.delete('kv', where: 'key LIKE ?', whereArgs: ['catalog.detail.$groupId.%']);
      final batch = txn.batch();
      for (final entry in lists.entries) {
        batch.insert(
          'kv',
          {'key': entry.key, 'value': jsonEncode(entry.value)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final entry in details.entries) {
        batch.insert(
          'kv',
          {'key': entry.key, 'value': jsonEncode(entry.value)},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      batch.insert(
        'kv',
        {'key': 'catalog.snapshot.version.$groupId', 'value': jsonEncode(version)},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await batch.commit(noResult: true);
    });
  }

  Future<void> saveFitmentGroups(List<Map<String, dynamic>> groups, String? selectedId) async {
    await _put('fitment.groups', {
      'selectedId': selectedId,
      'groups': groups,
    });
  }

  /// The last groups this phone loaded. A failed Identity refresh must not look like an empty catalog.
  Future<({List<Map<String, dynamic>> groups, String? selectedId})?> fitmentGroups() async {
    final raw = await _get('fitment.groups');
    if (raw is! Map) return null;
    final rows = raw['groups'];
    if (rows is! List) return null;
    final groups = [
      for (final row in rows)
        if (row is Map) Map<String, dynamic>.from(row),
    ];
    final selected = raw['selectedId'];
    return (groups: groups, selectedId: selected == null || '$selected'.isEmpty ? null : '$selected');
  }

  Future<void> saveSession(Map<String, dynamic> me) async {
    await _put('session.me', me);
  }

  Future<Map<String, dynamic>?> sessionProfile() async {
    final raw = await _get('session.me');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> saveList(String path, List<Map<String, dynamic>> rows) async {
    await _put('list.$path', rows);
  }

  Future<List<Map<String, dynamic>>?> cachedList(String path) async {
    final raw = await _get('list.$path');
    if (raw is! List) return null;
    return raw
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _put(key, value);
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await _get(key);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// Refresh the screens that are not in `/sync/snapshot`. A failed path keeps
  /// the previous copy.
  Future<void> pullOfflineLists() async {
    await Future.wait([
      for (final path in offlineListPaths) _pullList(path),
      _pullBilling(),
    ]);
  }

  Future<void> _pullList(String path) async {
    try {
      final res = await api.dio.get<dynamic>(path);
      await saveList(path, _pageRows(res.data));
    } catch (e) {
      debugPrint('list $path unchanged: $e');
    }
  }

  Future<void> _pullBilling() async {
    try {
      final res = await api.dio.get<dynamic>('billing');
      if (res.data is Map) {
        await saveJson('cache.billing', Map<String, dynamic>.from(res.data as Map));
      }
    } catch (e) {
      debugPrint('billing cache unchanged: $e');
    }
  }

  Future<void> clearLocal() async {
    final theme = await _get('ui.theme');
    final db = await _open();
    await db.delete('kv');
    await db.delete('outbox');
    if (theme is String && theme.isNotEmpty) {
      await _put('ui.theme', theme);
    }
  }

  Future<String?> appearance() async {
    final raw = await _get('ui.theme');
    return raw is String ? raw : null;
  }

  Future<void> saveAppearance(String mode) => _put('ui.theme', mode);

  Future<List<CachedDevice>> devices() async {
    final raw = await _get('snapshot.devices');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CachedDevice.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CachedDashboard> dashboard() async {
    final raw = await _get('snapshot.dashboard');
    if (raw is Map) {
      return CachedDashboard.fromJson(Map<String, dynamic>.from(raw));
    }
    return CachedDashboard();
  }

  Future<String> enqueue({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _open();
    final key = _uuid.v4();
    await db.insert(
      'outbox',
      {
        'idempotency_key': key,
        'type': type,
        'payload': jsonEncode({
          'type': type,
          'idempotencyKey': key,
          ...payload,
        }),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return key;
  }

  Future<int> pendingCount() async {
    final db = await _open();
    final rows = await db.rawQuery('SELECT COUNT(*) AS n FROM outbox');
    return (rows.first['n'] as int?) ?? 0;
  }

  /// Why the last send left changes behind, in words for the person at the counter.
  /// Null when the outbox emptied or has not been tried.
  String? lastFlushError;

  Future<void> discardOutbox() async {
    final db = await _open();
    await db.delete('outbox');
    lastFlushError = null;
  }

  Future<List<Map<String, dynamic>>> flush() async {
    final db = await _open();
    final rows = await db.query('outbox', orderBy: 'created_at ASC');
    if (rows.isEmpty) {
      lastFlushError = null;
      return const [];
    }
    final operations = rows
        .map((r) => jsonDecode('${r['payload']}') as Map<String, dynamic>)
        .toList();
    try {
      final res = await api.dio.post<dynamic>('sync', data: {'operations': operations});
      final results = res.data is List
          ? res.data as List
          : (res.data is Map && res.data['results'] is List)
              ? res.data['results'] as List
              : const [];
      final rejected = <String>{};
      String? firstReason;
      for (final row in results.whereType<Map>()) {
        final status = '${row['status'] ?? ''}';
        final key = '${row['idempotencyKey'] ?? ''}';
        if (status != 'SYNCED' && key.isNotEmpty) {
          rejected.add(key);
          firstReason ??= '${row['message'] ?? 'The server refused the change'}';
        }
      }
      lastFlushError = firstReason;
      for (final op in operations) {
        final key = '${op['idempotencyKey']}';
        if (!rejected.contains(key)) {
          await db.delete('outbox', where: 'idempotency_key = ?', whereArgs: [key]);
        }
      }
      return results.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      lastFlushError = describeError(e);
      return [
        for (final op in operations)
          {'idempotencyKey': op['idempotencyKey'], 'status': 'FAILED', 'message': lastFlushError},
      ];
    }
  }

  Future<List<Map<String, dynamic>>> spareGroups() async {
    final raw = await _get('catalog.spareGroups');
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> saveSpareGroups(List<Map<String, dynamic>> groups) async {
    await _put('catalog.spareGroups', groups);
  }
}

List<Map<String, dynamic>> _pageRows(dynamic data) {
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['content', 'items', 'rows']) {
      final value = map[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
      }
    }
  }
  if (data is List) {
    return data
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
  return const [];
}
