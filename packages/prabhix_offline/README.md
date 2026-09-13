# Offline-first helpers for Prabhix Flutter apps.
#
# Use [OfflineRuntime] per app:
# - KvStore for last-good snapshots (hours/days without network)
# - Outbox for mutations queued until a connectivity window opens
# - ConnectivityMonitor + SyncEngine to flush + pull when online
# - SyncNotifier for local pop-up alerts (pending / synced)
# - Connectivity + app-resume hooks drain the outbox when a network window opens
