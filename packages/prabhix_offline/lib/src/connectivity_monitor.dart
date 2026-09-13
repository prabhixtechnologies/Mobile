import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Online / offline signal for intermittent networks.
class ConnectivityMonitor extends ChangeNotifier {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _online = true;
  DateTime? lastOnlineAt;
  DateTime? lastOfflineAt;

  bool get online => _online;
  bool get offline => !_online;

  Future<void> start() async {
    final current = await _connectivity.checkConnectivity();
    _apply(current);
    _sub ??= _connectivity.onConnectivityChanged.listen(_apply);
  }

  void _apply(List<ConnectivityResult> results) {
    final next = results.any((r) => r != ConnectivityResult.none);
    if (next == _online) return;
    _online = next;
    if (next) {
      lastOnlineAt = DateTime.now();
      debugPrint('ConnectivityMonitor: ONLINE');
    } else {
      lastOfflineAt = DateTime.now();
      debugPrint('ConnectivityMonitor: OFFLINE');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
