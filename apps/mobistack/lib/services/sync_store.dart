import 'dart:convert';

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

  Future<List<Map<String, dynamic>>> flush() async {
    final db = await _open();
    final rows = await db.query('outbox', orderBy: 'created_at ASC');
    if (rows.isEmpty) return const [];
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
      for (final row in results.whereType<Map>()) {
        final status = '${row['status'] ?? ''}';
        final key = '${row['idempotencyKey'] ?? ''}';
        if (status != 'SYNCED' && key.isNotEmpty) rejected.add(key);
      }
      for (final op in operations) {
        final key = '${op['idempotencyKey']}';
        if (!rejected.contains(key)) {
          await db.delete('outbox', where: 'idempotency_key = ?', whereArgs: [key]);
        }
      }
      return results.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return const [];
    }
  }
}
