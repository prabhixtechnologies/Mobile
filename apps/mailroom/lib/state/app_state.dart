import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../api/mail_api.dart';
import '../config.dart';
import '../models/mail_models.dart';

enum AuthPhase { loading, signedOut, needsOrg, ready }

class AppState extends ChangeNotifier {
  AppState({required AppConfig config})
      : identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
    mail = MailApi(api);
    offline = OfflineRuntime(
      appId: 'mailroom',
      pull: _pullLive,
      flushHandler: _flushOutboxItem,
    );
  }

  final IdentityClient identity;
  late final ApiClient api;
  late final MailApi mail;
  late final OfflineRuntime offline;

  AuthPhase phase = AuthPhase.loading;
  AuthMe? me;
  List<OrganizationSummary> organizations = const [];
  String? error;
  bool busy = false;
  bool servingFromCache = false;
  int pendingOutbox = 0;
  DateTime? lastSyncedAt;

  List<MailboxSummary> mailboxes = const [];
  List<MailFolder> folders = const [];
  String? selectedFolderId;
  bool starredMode = false;
  List<MailThreadSummary> threads = const [];
  List<HelpdeskTicket> queue = const [];
  List<CannedReply> canned = const [];

  String searchQuery = '';
  bool selecting = false;
  final Set<String> selectedIds = {};

  /// Last move for Undo snackbar.
  UndoMove? lastUndo;

  String queueStatus = 'OPEN';
  String? queuePriority;
  bool queueMineOnly = false;
  String queueQuery = '';

  bool get online => offline.connectivity.online;
  bool get offlineMode => offline.connectivity.offline;

  String get currentFolderTitle {
    if (starredMode) return 'Starred';
    for (final f in folders) {
      if (f.id == selectedFolderId) return f.name;
    }
    return 'Inbox';
  }

  List<MailThreadSummary> get visibleThreads {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return threads;
    return threads.where((t) {
      final hay =
          '${t.subject} ${t.correspondent} ${t.preview ?? ''} ${t.fromAddress ?? ''}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  int get unreadInView => visibleThreads.where((t) => t.unread).length;

  Future<void> bootstrap() async {
    phase = AuthPhase.loading;
    notifyListeners();
    try {
      await offline.start();
      offline.connectivity.addListener(_onConnectivityChanged);
      offline.sync.addListener(_onSyncChanged);
      final session = await identity.tokenStore.session();
      if (session == null) {
        phase = AuthPhase.signedOut;
        notifyListeners();
        return;
      }
      await identity.refreshIfNeeded();
      await _loadMeAndRoute();
    } catch (e) {
      error = '$e';
      phase = AuthPhase.signedOut;
      notifyListeners();
    }
  }

  void _onConnectivityChanged() {
    notifyListeners();
    if (online && phase == AuthPhase.ready) {
      unawaited(syncNow());
    }
  }

  void _onSyncChanged() {
    lastSyncedAt = offline.sync.lastSyncAt;
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (phase != AuthPhase.ready) return;
    await offline.syncNow();
    pendingOutbox = await offline.outbox.pendingCount();
    notifyListeners();
  }

  Future<void> signIn() async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await identity.signIn();
      await _loadMeAndRoute();
    } catch (e) {
      error = '$e';
      phase = AuthPhase.signedOut;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> selectOrg(OrganizationSummary org) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await api.selectOrganization(org.id);
      phase = AuthPhase.ready;
      await loadMailbox();
    } catch (e) {
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> loadMailbox({bool forceNetwork = false}) async {
    busy = true;
    error = null;
    notifyListeners();

    // Instant paint from disk — works with zero connectivity.
    await _hydrateFromCache();
    if (threads.isNotEmpty || folders.isNotEmpty) {
      busy = false;
      servingFromCache = true;
      notifyListeners();
    }

    if (offlineMode && !forceNetwork) {
      busy = false;
      servingFromCache = folders.isNotEmpty || threads.isNotEmpty;
      error = servingFromCache
          ? null
          : 'You are offline and no cached mail is available yet.';
      pendingOutbox = await offline.outbox.pendingCount();
      notifyListeners();
      return;
    }

    final failures = <String>[];
    try {
      await _pullLive();
      servingFromCache = false;
    } catch (e, st) {
      debugPrint('live pull failed, keeping cache: $e\n$st');
      failures.add('network');
      servingFromCache = folders.isNotEmpty || threads.isNotEmpty;
      if (!servingFromCache) {
        error = 'Could not reach the server. $e';
      }
    }

    pendingOutbox = await offline.outbox.pendingCount();
    if (failures.isNotEmpty && servingFromCache) {
      error = 'Showing cached mail · will sync when online';
    }
    busy = false;
    notifyListeners();
  }

  Future<void> _pullLive() async {
    final failures = <String>[];

    try {
      final side = await mail.sidebar();
      mailboxes = side.mailboxes;
      folders = side.folders;
      if (!starredMode) {
        selectedFolderId ??= _preferredInboxId(folders);
      }
      await offline.store.putJson(
        'sidebar.mailboxes',
        mailboxes.map((m) => m.toJson()).toList(),
      );
      await offline.store.putJson(
        'sidebar.folders',
        folders.map((f) => f.toJson()).toList(),
      );
      debugPrint(
        'sidebar ok mailboxes=${mailboxes.length} folders=${folders.length}',
      );
    } catch (e, st) {
      debugPrint('sidebar failed: $e\n$st');
      failures.add('sidebar');
      rethrow;
    }

    try {
      if (starredMode) {
        threads = await mail.starred();
        await offline.store.putJson(
          'threads.starred',
          threads.map((t) => t.toJson()).toList(),
        );
      } else if (selectedFolderId != null) {
        threads = await mail.folderThreads(selectedFolderId!);
        await offline.store.putJson(
          'threads.folder.$selectedFolderId',
          threads.map((t) => t.toJson()).toList(),
        );
      }
      await offline.store.putMeta(
        'selection',
        starredMode ? 'starred' : (selectedFolderId ?? ''),
      );
      debugPrint('threads ok count=${threads.length}');
    } catch (e, st) {
      debugPrint('threads failed: $e\n$st');
      failures.add('threads');
    }

    try {
      await refreshQueue(silent: true);
    } catch (e, st) {
      debugPrint('helpdesk failed: $e\n$st');
      failures.add('helpdesk');
    }

    try {
      canned = await mail.cannedReplies();
      await offline.store.putJson(
        'canned',
        canned.map((c) => c.toJson()).toList(),
      );
    } catch (e) {
      debugPrint('canned skipped: $e');
    }

    lastSyncedAt = DateTime.now();
    await offline.store.putMeta('lastSyncedAt', lastSyncedAt!.toIso8601String());
    if (failures.contains('threads')) {
      throw StateError('threads pull failed');
    }
  }

  Future<void> _hydrateFromCache() async {
    final boxesRaw = await offline.store.getJson('sidebar.mailboxes');
    if (boxesRaw is List) {
      mailboxes = boxesRaw
          .whereType<Map>()
          .map((e) => MailboxSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final foldersRaw = await offline.store.getJson('sidebar.folders');
    if (foldersRaw is List) {
      folders = foldersRaw
          .whereType<Map>()
          .map((e) => MailFolder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final selection = await offline.store.getMeta('selection');
    if (selection == 'starred') {
      starredMode = true;
      selectedFolderId = null;
    } else if (selection != null && selection.isNotEmpty) {
      starredMode = false;
      selectedFolderId = selection;
    } else {
      selectedFolderId ??= _preferredInboxId(folders);
    }

    final key = starredMode
        ? 'threads.starred'
        : (selectedFolderId != null
            ? 'threads.folder.$selectedFolderId'
            : null);
    if (key != null) {
      final threadsRaw = await offline.store.getJson(key);
      if (threadsRaw is List) {
        threads = threadsRaw
            .whereType<Map>()
            .map((e) => MailThreadSummary.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    final queueRaw = await offline.store.getJson('helpdesk.queue');
    if (queueRaw is List) {
      queue = queueRaw
          .whereType<Map>()
          .map((e) => HelpdeskTicket.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final cannedRaw = await offline.store.getJson('canned');
    if (cannedRaw is List) {
      canned = cannedRaw
          .whereType<Map>()
          .map((e) => CannedReply.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    final synced = await offline.store.getMeta('lastSyncedAt');
    if (synced != null) lastSyncedAt = DateTime.tryParse(synced);
    pendingOutbox = await offline.outbox.pendingCount();
  }

  Future<void> _flushOutboxItem(OutboxItem item) async {
    if (item.type == 'flags') {
      await mail.patchFlags(
        threadId: '${item.payload['threadId']}',
        read: item.payload['read'] as bool?,
        starred: item.payload['starred'] as bool?,
      );
      return;
    }
    if (item.type == 'bulkFlags') {
      await mail.bulkFlags(
        threadIds: (item.payload['threadIds'] as List).map((e) => '$e').toList(),
        read: item.payload['read'] as bool?,
        starred: item.payload['starred'] as bool?,
      );
      return;
    }
    if (item.type == 'move') {
      await mail.moveThreads(
        folderId: '${item.payload['folderId']}',
        threadIds: (item.payload['threadIds'] as List).map((e) => '$e').toList(),
      );
      return;
    }
    throw UnsupportedError('Unknown outbox type ${item.type}');
  }

  Future<void> _enqueueOrRun({
    required String type,
    required Map<String, dynamic> payload,
    required Future<void> Function() onlineAction,
  }) async {
    if (online) {
      try {
        await onlineAction();
        return;
      } catch (e) {
        // Fall through to queue for intermittent links.
        debugPrint('online action failed, queueing: $e');
      }
    }
    await offline.outbox.enqueue(type: type, payload: payload);
    pendingOutbox = await offline.outbox.pendingCount();
    await offline.notifier.showPendingOutbox(pendingOutbox);
    notifyListeners();
  }

  Future<void> selectFolder(String folderId) async {
    starredMode = false;
    selectedFolderId = folderId;
    busy = true;
    error = null;
    notifyListeners();

    final cached = await offline.store.getJson('threads.folder.$folderId');
    if (cached is List) {
      threads = cached
          .whereType<Map>()
          .map((e) => MailThreadSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      servingFromCache = true;
      busy = false;
      notifyListeners();
    }

    if (offlineMode) {
      await offline.store.putMeta('selection', folderId);
      busy = false;
      notifyListeners();
      return;
    }

    try {
      threads = await mail.folderThreads(folderId);
      await offline.store.putJson(
        'threads.folder.$folderId',
        threads.map((t) => t.toJson()).toList(),
      );
      await offline.store.putMeta('selection', folderId);
      servingFromCache = false;
    } catch (e) {
      if (threads.isEmpty) error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> showStarred() async {
    starredMode = true;
    selectedFolderId = null;
    busy = true;
    error = null;
    notifyListeners();

    final cached = await offline.store.getJson('threads.starred');
    if (cached is List) {
      threads = cached
          .whereType<Map>()
          .map((e) => MailThreadSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      servingFromCache = true;
      busy = false;
      notifyListeners();
    }

    if (offlineMode) {
      await offline.store.putMeta('selection', 'starred');
      busy = false;
      notifyListeners();
      return;
    }

    try {
      threads = await mail.starred();
      await offline.store.putJson(
        'threads.starred',
        threads.map((t) => t.toJson()).toList(),
      );
      await offline.store.putMeta('selection', 'starred');
      servingFromCache = false;
    } catch (e) {
      if (threads.isEmpty) error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshQueue({bool silent = false}) async {
    if (!silent) {
      busy = true;
      error = null;
      notifyListeners();
    }
    try {
      if (offlineMode) {
        final raw = await offline.store.getJson('helpdesk.queue');
        if (raw is List) {
          queue = raw
              .whereType<Map>()
              .map((e) => HelpdeskTicket.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        servingFromCache = true;
        return;
      }
      queue = await mail.helpdeskThreads(
        status: queueStatus,
        priority: queuePriority,
        q: queueQuery.isEmpty ? null : queueQuery,
        mine: queueMineOnly,
        assigneeUserId: queueMineOnly ? me?.id : null,
      );
      await offline.store.putJson(
        'helpdesk.queue',
        queue.map((t) => t.toJson()).toList(),
      );
      debugPrint('helpdesk queue ok count=${queue.length}');
    } catch (e) {
      if (!silent) error = '$e';
      rethrow;
    } finally {
      if (!silent) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> setQueueFilters({
    String? status,
    String? priority,
    bool? mineOnly,
    String? query,
  }) async {
    if (status != null) queueStatus = status;
    if (priority != null) {
      queuePriority = priority.isEmpty ? null : priority;
    }
    if (mineOnly != null) queueMineOnly = mineOnly;
    if (query != null) queueQuery = query;
    await refreshQueue();
  }

  Future<void> toggleStar(MailThreadSummary thread) async {
    final next = !thread.starred;
    _patchThreadLocal(thread.id, starred: next);
    await _persistThreadsCache();
    await _enqueueOrRun(
      type: 'flags',
      payload: {'threadId': thread.id, 'starred': next},
      onlineAction: () async {
        final updated =
            await mail.patchFlags(threadId: thread.id, starred: next);
        _replaceThread(updated);
        await _persistThreadsCache();
      },
    );
  }

  Future<void> markRead(MailThreadSummary thread, {required bool read}) async {
    _patchThreadLocal(thread.id, unread: !read);
    await _persistThreadsCache();
    await _enqueueOrRun(
      type: 'flags',
      payload: {'threadId': thread.id, 'read': read},
      onlineAction: () async {
        final updated = await mail.patchFlags(threadId: thread.id, read: read);
        _replaceThread(updated);
        await _persistThreadsCache();
      },
    );
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    notifyListeners();
  }

  void enterSelection([String? seedId]) {
    selecting = true;
    selectedIds.clear();
    if (seedId != null) selectedIds.add(seedId);
    notifyListeners();
  }

  void exitSelection() {
    selecting = false;
    selectedIds.clear();
    notifyListeners();
  }

  void toggleSelected(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    if (selectedIds.isEmpty) selecting = false;
    notifyListeners();
  }

  void selectAllVisible() {
    selecting = true;
    selectedIds
      ..clear()
      ..addAll(visibleThreads.map((t) => t.id));
    notifyListeners();
  }

  Future<void> bulkMarkRead({required bool read}) async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return;
    for (final id in ids) {
      _patchThreadLocal(id, unread: !read);
    }
    exitSelection();
    await _persistThreadsCache();
    await _enqueueOrRun(
      type: 'bulkFlags',
      payload: {'threadIds': ids, 'read': read},
      onlineAction: () => mail.bulkFlags(threadIds: ids, read: read),
    );
  }

  Future<void> bulkStar({required bool starred}) async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return;
    for (final id in ids) {
      _patchThreadLocal(id, starred: starred);
    }
    exitSelection();
    await _persistThreadsCache();
    await _enqueueOrRun(
      type: 'bulkFlags',
      payload: {'threadIds': ids, 'starred': starred},
      onlineAction: () => mail.bulkFlags(threadIds: ids, starred: starred),
    );
  }

  Future<UndoMove?> moveWithUndo({
    required List<String> threadIds,
    required String targetKind,
  }) async {
    final target = _folderOfKind(targetKind);
    if (target == null) {
      error = 'No $targetKind folder available.';
      notifyListeners();
      return null;
    }
    final sourceFolderId = selectedFolderId;
    final removed = threads.where((t) => threadIds.contains(t.id)).toList();
    threads = threads.where((t) => !threadIds.contains(t.id)).toList();
    selectedIds.removeAll(threadIds);
    if (selectedIds.isEmpty) selecting = false;
    lastUndo = UndoMove(
      threadIds: threadIds,
      fromFolderId: sourceFolderId,
      threads: removed,
      label: targetKind == 'TRASH' ? 'moved to Trash' : 'archived',
    );
    await _persistThreadsCache();
    notifyListeners();

    await _enqueueOrRun(
      type: 'move',
      payload: {'folderId': target.id, 'threadIds': threadIds},
      onlineAction: () =>
          mail.moveThreads(folderId: target.id, threadIds: threadIds),
    );
    return lastUndo;
  }

  Future<void> undoLastMove() async {
    final undo = lastUndo;
    if (undo == null || undo.fromFolderId == null) return;
    threads = [...undo.threads, ...threads];
    lastUndo = null;
    await _persistThreadsCache();
    notifyListeners();
    await _enqueueOrRun(
      type: 'move',
      payload: {
        'folderId': undo.fromFolderId!,
        'threadIds': undo.threadIds,
      },
      onlineAction: () => mail.moveThreads(
        folderId: undo.fromFolderId!,
        threadIds: undo.threadIds,
      ),
    );
  }

  Future<void> archiveThread(String threadId) async {
    await moveWithUndo(threadIds: [threadId], targetKind: 'ARCHIVE');
  }

  Future<void> trashThread(String threadId) async {
    await moveWithUndo(threadIds: [threadId], targetKind: 'TRASH');
  }

  Future<UndoMove?> bulkArchive() async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return null;
    return moveWithUndo(threadIds: ids, targetKind: 'ARCHIVE');
  }

  Future<UndoMove?> bulkTrash() async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return null;
    return moveWithUndo(threadIds: ids, targetKind: 'TRASH');
  }

  void bump() => notifyListeners();

  Future<void> signOut() async {
    busy = true;
    notifyListeners();
    try {
      await api.platformLogout();
      await identity.signOut();
    } finally {
      me = null;
      mailboxes = const [];
      folders = const [];
      threads = const [];
      queue = const [];
      canned = const [];
      phase = AuthPhase.signedOut;
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _persistThreadsCache() async {
    if (starredMode) {
      await offline.store.putJson(
        'threads.starred',
        threads.map((t) => t.toJson()).toList(),
      );
    } else if (selectedFolderId != null) {
      await offline.store.putJson(
        'threads.folder.$selectedFolderId',
        threads.map((t) => t.toJson()).toList(),
      );
    }
  }

  String? _preferredInboxId(List<MailFolder> list) {
    final mineBoxes = mailboxes.where((m) => m.mine).map((m) => m.id).toSet();
    MailFolder? inbox;
    for (final f in list) {
      if (f.kind == 'INBOX' &&
          (mineBoxes.isEmpty || mineBoxes.contains(f.mailboxId))) {
        inbox = f;
        break;
      }
    }
    inbox ??= list.where((f) => f.kind == 'INBOX').firstOrNull;
    return inbox?.id ?? (list.isNotEmpty ? list.first.id : null);
  }

  void _patchThreadLocal(String id, {bool? unread, bool? starred}) {
    threads = [
      for (final t in threads)
        if (t.id == id) t.copyWith(unread: unread, starred: starred) else t,
    ];
    notifyListeners();
  }

  void _replaceThread(MailThreadSummary updated) {
    threads = [
      for (final t in threads)
        if (t.id == updated.id) updated else t,
    ];
    notifyListeners();
  }

  MailFolder? _folderOfKind(String kind) {
    for (final f in folders) {
      if (f.kind == kind) return f;
    }
    return null;
  }

  Future<void> _loadMeAndRoute() async {
    me = await api.authMe();
    await identity.tokenStore.saveProfile(
      userId: me!.id,
      email: me!.email,
      displayName: me!.displayName,
      platformAdmin: me!.platformAdmin,
    );
    organizations = me!.organizations.isNotEmpty
        ? me!.organizations
        : await api.organizations();
    final session = await identity.tokenStore.session();
    final selected = session?.organizationId ?? me!.selectedOrganizationId;
    if (selected != null && selected.isNotEmpty) {
      await api.selectOrganization(selected);
      phase = AuthPhase.ready;
      await loadMailbox();
    } else if (organizations.length == 1) {
      await selectOrg(organizations.first);
    } else {
      phase = AuthPhase.needsOrg;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    offline.connectivity.removeListener(_onConnectivityChanged);
    offline.sync.removeListener(_onSyncChanged);
    unawaited(offline.dispose());
    super.dispose();
  }
}

class UndoMove {
  UndoMove({
    required this.threadIds,
    required this.fromFolderId,
    required this.threads,
    required this.label,
  });

  final List<String> threadIds;
  final String? fromFolderId;
  final List<MailThreadSummary> threads;
  final String label;
}
