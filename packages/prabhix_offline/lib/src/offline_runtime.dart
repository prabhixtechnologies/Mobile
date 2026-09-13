import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'connectivity_monitor.dart';
import 'kv_store.dart';
import 'outbox.dart';
import 'sync_engine.dart';
import 'sync_notifier.dart';

/// App-scoped offline runtime: cache DB + outbox + connectivity + sync + local alerts.
///
/// Background sync uses connectivity + app-resume hooks (no Workmanager — that plugin
/// is incompatible with current Flutter Android embedding). When the OS brings the
/// process up and the network window opens, [syncNow] drains the outbox.
class OfflineRuntime with WidgetsBindingObserver {
  OfflineRuntime({
    required String appId,
    required PullFn pull,
    required OutboxHandler flushHandler,
  })  : store = KvStore('${appId}_offline.db'),
        connectivity = ConnectivityMonitor() {
    outbox = Outbox(store);
    sync = SyncEngine(
      connectivity: connectivity,
      outbox: outbox,
      pull: pull,
      flushHandler: flushHandler,
    );
    notifier = SyncNotifier();
  }

  final KvStore store;
  final ConnectivityMonitor connectivity;
  late final Outbox outbox;
  late final SyncEngine sync;
  late final SyncNotifier notifier;

  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    await connectivity.start();
    await notifier.init();
    connectivity.addListener(_onConnectivity);
  }

  Future<void> syncNow({bool force = false}) async {
    final before = await outbox.pendingCount();
    await sync.sync(force: force);
    final after = await outbox.pendingCount();
    if (sync.lastFlushed > 0) {
      await notifier.showSynced(flushed: sync.lastFlushed);
    } else if (after > 0 && connectivity.offline) {
      await notifier.showPendingOutbox(after);
    } else if (before > 0 && after == 0) {
      await notifier.showSynced(flushed: before);
    }
  }

  void _onConnectivity() {
    if (connectivity.online) {
      unawaited(syncNow());
    } else {
      unawaited(outbox.pendingCount().then(notifier.showPendingOutbox));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncNow());
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    connectivity.removeListener(_onConnectivity);
    connectivity.dispose();
    await store.close();
  }
}
