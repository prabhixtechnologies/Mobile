import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Per-app key/value JSON cache (survives days offline).
class KvStore {
  KvStore(this.dbName);

  final String dbName;
  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE kv (key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at INTEGER NOT NULL)',
        );
        await db.execute('''
          CREATE TABLE outbox (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
          )
        ''');
        await db.execute(
          'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  Future<void> putJson(String key, Object value) async {
    final db = await _open();
    await db.insert(
      'kv',
      {
        'key': key,
        'value': jsonEncode(value),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> getJson(String key) async {
    final db = await _open();
    final rows = await db.query('kv', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return jsonDecode('${rows.first['value']}');
  }

  Future<DateTime?> updatedAt(String key) async {
    final db = await _open();
    final rows = await db.query(
      'kv',
      columns: ['updated_at'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final ms = rows.first['updated_at'] as int?;
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> putMeta(String key, String value) async {
    final db = await _open();
    await db.insert(
      'meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMeta(String key) async {
    final db = await _open();
    final rows =
        await db.query('meta', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value']?.toString();
  }

  Future<Database> database() => _open();

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
