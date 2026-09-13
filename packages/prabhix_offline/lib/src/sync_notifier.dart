import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local alerts for sync windows / pending outbox (works without FCM).
class SyncNotifier {
  SyncNotifier();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init({String channelName = 'Prabhix sync'}) async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        'prabhix_sync',
        channelName,
        description: 'Offline queue and sync status',
        importance: Importance.defaultImportance,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> showPendingOutbox(int count) async {
    if (!_ready || count <= 0) return;
    await _plugin.show(
      9101,
      'Waiting for connection',
      count == 1
          ? '1 change will sync when you are online'
          : '$count changes will sync when you are online',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prabhix_sync',
          'Prabhix sync',
          channelDescription: 'Offline queue and sync status',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showSynced({required int flushed, String? detail}) async {
    if (!_ready) return;
    if (flushed <= 0 && detail == null) return;
    await _plugin.show(
      9102,
      'Synced',
      detail ??
          (flushed == 1
              ? '1 queued change sent'
              : '$flushed queued changes sent'),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prabhix_sync',
          'Prabhix sync',
          channelDescription: 'Offline queue and sync status',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
