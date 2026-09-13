import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class OutboundMessage {
  OutboundMessage({
    required this.id,
    required this.conversationId,
    required this.body,
    required this.note,
    required this.createdAtMs,
  });

  final String id;
  final String conversationId;
  final String body;
  final bool note;
  final int createdAtMs;
}

/// Local SQLite queue for offline chat sends; flush when connectivity returns.
class OutboundQueue {
  Database? _db;
  static const _uuid = Uuid();

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'prabhix_operator.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE outbound_messages (
            id TEXT PRIMARY KEY,
            conversation_id TEXT NOT NULL,
            body TEXT NOT NULL,
            note INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<String> enqueue({
    required String conversationId,
    required String body,
    bool note = false,
  }) async {
    final db = await _open();
    final id = _uuid.v4();
    await db.insert('outbound_messages', {
      'id': id,
      'conversation_id': conversationId,
      'body': body,
      'note': note ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  Future<List<OutboundMessage>> peek() async {
    final db = await _open();
    final rows = await db.query('outbound_messages', orderBy: 'created_at ASC');
    return rows
        .map(
          (r) => OutboundMessage(
            id: '${r['id']}',
            conversationId: '${r['conversation_id']}',
            body: '${r['body']}',
            note: (r['note'] as int? ?? 0) == 1,
            createdAtMs: r['created_at'] as int? ?? 0,
          ),
        )
        .toList();
  }

  Future<int> pendingCount() async {
    final db = await _open();
    final result = await db.rawQuery('SELECT COUNT(*) AS n FROM outbound_messages');
    return (result.first['n'] as int?) ?? 0;
  }

  Future<void> remove(String id) async {
    final db = await _open();
    await db.delete('outbound_messages', where: 'id = ?', whereArgs: [id]);
  }
}
