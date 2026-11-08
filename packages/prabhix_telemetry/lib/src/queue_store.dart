import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class QueuedEvent {
  QueuedEvent({
    required this.id,
    required this.name,
    required this.occurredAt,
    required this.sessionId,
    required this.props,
  });

  final String id;
  final String name;
  final DateTime occurredAt;
  final String sessionId;
  final Map<String, Object?> props;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'sessionId': sessionId,
        'props': props,
      };
}

class TelemetryMeta {
  TelemetryMeta({
    required this.installId,
    required this.sessionId,
    this.lastSuccessAt,
    this.lastFailureAt,
    this.lastAttemptAt,
  });

  final String installId;
  final String sessionId;
  DateTime? lastSuccessAt;
  DateTime? lastFailureAt;
  DateTime? lastAttemptAt;

  factory TelemetryMeta.fresh() => TelemetryMeta(
        installId: const Uuid().v4(),
        sessionId: const Uuid().v4(),
      );
}

class TelemetryQueueStore {
  TelemetryQueueStore(this.dbName);

  final String dbName;
  Database? _db;

  Future<Database> _open() async {
    if (_db != null) {
      return _db!;
    }
    final path = p.join(await getDatabasesPath(), dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE events (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            occurred_at TEXT NOT NULL,
            session_id TEXT NOT NULL,
            props TEXT NOT NULL
          )
        ''');
        await db.execute(
          'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  Future<TelemetryMeta> loadMeta() async {
    final db = await _open();
    final rows = await db.query('meta');
    final map = {for (final r in rows) '${r['key']}': '${r['value']}'};
    if (!map.containsKey('installId')) {
      final fresh = TelemetryMeta.fresh();
      await saveMeta(fresh);
      return fresh;
    }
    return TelemetryMeta(
      installId: map['installId']!,
      sessionId: map['sessionId'] ?? const Uuid().v4(),
      lastSuccessAt: _parseMs(map['lastSuccessAt']),
      lastFailureAt: _parseMs(map['lastFailureAt']),
      lastAttemptAt: _parseMs(map['lastAttemptAt']),
    );
  }

  Future<void> saveMeta(TelemetryMeta meta) async {
    final db = await _open();
    Future<void> put(String key, String value) => db.insert(
          'meta',
          {'key': key, 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
    await put('installId', meta.installId);
    await put('sessionId', meta.sessionId);
    await put(
      'lastSuccessAt',
      meta.lastSuccessAt?.millisecondsSinceEpoch.toString() ?? '',
    );
    await put(
      'lastFailureAt',
      meta.lastFailureAt?.millisecondsSinceEpoch.toString() ?? '',
    );
    await put(
      'lastAttemptAt',
      meta.lastAttemptAt?.millisecondsSinceEpoch.toString() ?? '',
    );
  }

  Future<void> enqueue(QueuedEvent event, int maxQueue) async {
    final db = await _open();
    await db.insert(
      'events',
      {
        'id': event.id,
        'name': event.name,
        'occurred_at': event.occurredAt.toUtc().toIso8601String(),
        'session_id': event.sessionId,
        'props': jsonEncode(event.props),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) AS c FROM events'),
        ) ??
        0;
    if (count > maxQueue) {
      final drop = count - maxQueue;
      await db.rawDelete('''
        DELETE FROM events WHERE id IN (
          SELECT id FROM events ORDER BY occurred_at ASC LIMIT ?
        )
      ''', [drop]);
    }
  }

  Future<List<QueuedEvent>> peek(int limit) async {
    final db = await _open();
    final rows = await db.query(
      'events',
      orderBy: 'occurred_at ASC',
      limit: limit,
    );
    return rows
        .map(
          (r) => QueuedEvent(
            id: '${r['id']}',
            name: '${r['name']}',
            occurredAt: DateTime.parse('${r['occurred_at']}'),
            sessionId: '${r['session_id']}',
            props: Map<String, Object?>.from(
              jsonDecode('${r['props']}') as Map,
            ),
          ),
        )
        .toList();
  }

  Future<void> remove(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final db = await _open();
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawDelete(
      'DELETE FROM events WHERE id IN ($placeholders)',
      ids,
    );
  }

  DateTime? _parseMs(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final ms = int.tryParse(raw);
    if (ms == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
