import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'kv_store.dart';

class OutboxItem {
  OutboxItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
}

typedef OutboxHandler = Future<void> Function(OutboxItem item);

/// Durable mutation queue — flush when the network window opens.
class Outbox {
  Outbox(this.store);

  final KvStore store;
  static const _uuid = Uuid();

  Future<String> enqueue({
    required String type,
    required Map<String, dynamic> payload,
    String? id,
  }) async {
    final db = await store.database();
    final key = id ?? _uuid.v4();
    await db.insert(
      'outbox',
      {
        'id': key,
        'type': type,
        'payload': jsonEncode(payload),
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'attempts': 0,
        'last_error': null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return key;
  }

  Future<List<OutboxItem>> pending() async {
    final db = await store.database();
    final rows = await db.query('outbox', orderBy: 'created_at ASC');
    return rows.map(_row).toList();
  }

  Future<int> pendingCount() async {
    final db = await store.database();
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM outbox');
    return (result.first['c'] as int?) ?? 0;
  }

  Future<void> remove(String id) async {
    final db = await store.database();
    await db.delete('outbox', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markFailed(String id, Object error) async {
    final db = await store.database();
    await db.rawUpdate(
      'UPDATE outbox SET attempts = attempts + 1, last_error = ? WHERE id = ?',
      ['$error', id],
    );
  }

  /// Drain FIFO. Stops on first hard failure so order is preserved.
  Future<int> flush(OutboxHandler handler) async {
    final items = await pending();
    var done = 0;
    for (final item in items) {
      try {
        await handler(item);
        await remove(item.id);
        done++;
      } catch (e) {
        await markFailed(item.id, e);
        rethrow;
      }
    }
    return done;
  }

  OutboxItem _row(Map<String, Object?> row) {
    final raw = jsonDecode('${row['payload']}');
    return OutboxItem(
      id: '${row['id']}',
      type: '${row['type']}',
      payload: raw is Map
          ? Map<String, dynamic>.from(raw)
          : <String, dynamic>{},
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      attempts: (row['attempts'] as int?) ?? 0,
      lastError: row['last_error']?.toString(),
    );
  }
}
