import 'package:flutter/foundation.dart';

import 'connectivity_monitor.dart';
import 'outbox.dart';

typedef PullFn = Future<void> Function();

/// Pull when online + flush outbox. Safe to call often (sync windows).
class SyncEngine extends ChangeNotifier {
  SyncEngine({
    required this.connectivity,
    required this.outbox,
    required this.pull,
    required this.flushHandler,
  });

  final ConnectivityMonitor connectivity;
  final Outbox outbox;
  final PullFn pull;
  final OutboxHandler flushHandler;

  bool syncing = false;
  String? lastError;
  DateTime? lastSyncAt;
  int lastFlushed = 0;

  Future<void> sync({bool force = false}) async {
    if (syncing) return;
    if (!force && connectivity.offline) {
      lastError = 'Offline — using cached data. Changes queue until online.';
      notifyListeners();
      return;
    }
    syncing = true;
    lastError = null;
    notifyListeners();
    try {
      lastFlushed = await outbox.flush(flushHandler);
      await pull();
      lastSyncAt = DateTime.now();
      debugPrint(
        'SyncEngine ok flushed=$lastFlushed at=${lastSyncAt!.toIso8601String()}',
      );
    } catch (e, st) {
      lastError = '$e';
      debugPrint('SyncEngine failed: $e\n$st');
    } finally {
      syncing = false;
      notifyListeners();
    }
  }
}
