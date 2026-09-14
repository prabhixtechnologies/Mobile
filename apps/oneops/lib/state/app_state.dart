import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:prabhix_identity/prabhix_identity.dart';
import 'package:prabhix_offline/prabhix_offline.dart';

import '../api/chat_api.dart';
import '../api/inbox_api.dart';
import '../config.dart';
import '../models/chat_models.dart';
import '../models/inbox_models.dart';
import '../services/outbound_queue.dart';
import '../services/push_registration.dart';
import '../services/sse_client.dart';

enum AuthPhase { loading, signedOut, needsOrg, ready }

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState({required this.config})
      : identity = IdentityClient(config: config.identity) {
    api = ApiClient(config: config.product, identity: identity);
    chat = ChatApi(api);
    inbox = InboxApi(api);
    WidgetsBinding.instance.addObserver(this);
  }

  final AppConfig config;
  final IdentityClient identity;
  late final ApiClient api;
  late final ChatApi chat;
  late final InboxApi inbox;
  final OutboundQueue outbound = OutboundQueue();
  final ConnectivityMonitor connectivity = ConnectivityMonitor();
  final SyncNotifier syncNotifier = SyncNotifier();

  AuthPhase phase = AuthPhase.loading;
  AuthMe? me;
  List<OrganizationSummary> organizations = const [];
  String? error;
  bool busy = false;

  String chatQueue = 'mine';
  List<ConversationSummary> conversations = const [];
  List<LiveVisitor> visitors = const [];
  DashboardKpis? dashboard;
  List<InboxTicket> tickets = const [];
  List<OrderRow> orders = const [];
  List<MemberRow> members = const [];
  bool emailNotifications = true;
  bool pushNotifications = false;
  int pendingOutbound = 0;
  String? pendingDeepLinkChatId;
  bool servingFromCache = false;

  bool get online => connectivity.online;

  ChatSseClient? _sse;
  StreamSubscription<Uri>? _linkSub;
  final AppLinks _appLinks = AppLinks();

  Future<void> bootstrap() async {
    phase = AuthPhase.loading;
    notifyListeners();
    await connectivity.start();
    await syncNotifier.init(channelName: 'OneOps sync');
    connectivity.addListener(_onNet);
    await _listenDeepLinks();
    try {
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

  void _onNet() {
    notifyListeners();
    if (online && phase == AuthPhase.ready) {
      unawaited(flushOutbound());
      unawaited(refreshHome());
    } else if (!online && pendingOutbound > 0) {
      unawaited(syncNotifier.showPendingOutbox(pendingOutbound));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && phase == AuthPhase.ready) {
      unawaited(flushOutbound());
      unawaited(refreshChat());
    }
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
      await _onAuthenticated();
    } catch (e) {
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshDashboard() async {
    try {
      dashboard = await chat.dashboard();
      debugPrint(
        'dashboard ok open=${dashboard?.openConversations} '
        'visitorsToday=${dashboard?.visitorsToday}',
      );
    } catch (e, st) {
      debugPrint('refreshDashboard failed: $e\n$st');
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> refreshChat({String? queue}) async {
    if (queue != null) chatQueue = queue;
    busy = true;
    notifyListeners();
    try {
      conversations = await chat.conversations(queue: chatQueue);
      pendingOutbound = await outbound.pendingCount();
      debugPrint('chat ok queue=$chatQueue count=${conversations.length}');
    } catch (e, st) {
      debugPrint('refreshChat failed: $e\n$st');
      error = '$e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshVisitors() async {
    try {
      visitors = await chat.liveVisitors();
      debugPrint('live visitors ok count=${visitors.length}');
    } catch (e, st) {
      debugPrint('refreshVisitors failed: $e\n$st');
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> refreshHome() async {
    busy = true;
    error = null;
    notifyListeners();
    final failures = <String>[];

    Future<void> soft(String label, Future<void> Function() run) async {
      try {
        await run();
      } catch (e, st) {
        debugPrint('refreshHome $label failed: $e\n$st');
        failures.add(label);
      }
    }

    await Future.wait([
      soft('dashboard', () async {
        dashboard = await chat.dashboard();
        debugPrint(
          'dashboard ok open=${dashboard?.openConversations} '
          'visitorsToday=${dashboard?.visitorsToday}',
        );
      }),
      soft('chat', () async {
        conversations = await chat.conversations(queue: chatQueue);
        pendingOutbound = await outbound.pendingCount();
        debugPrint('chat ok queue=$chatQueue count=${conversations.length}');
      }),
      soft('visitors', () async {
        visitors = await chat.liveVisitors();
        debugPrint('live visitors ok count=${visitors.length}');
      }),
      soft('inbox', () async {
        tickets = await inbox.tickets();
        debugPrint('inbox ok count=${tickets.length}');
      }),
    ]);

    if (failures.isNotEmpty) {
      error = 'Some sections failed: ${failures.join(', ')}';
    }
    busy = false;
    notifyListeners();
  }

  Future<void> sendOrQueue({
    required String conversationId,
    required String body,
    bool note = false,
  }) async {
    try {
      await chat.sendMessage(conversationId, body, note: note);
    } catch (_) {
      await outbound.enqueue(conversationId: conversationId, body: body, note: note);
      pendingOutbound = await outbound.pendingCount();
      await syncNotifier.showPendingOutbox(pendingOutbound);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> flushOutbound() async {
    final before = await outbound.pendingCount();
    final items = await outbound.peek();
    var flushed = 0;
    for (final item in items) {
      try {
        await chat.sendMessage(item.conversationId, item.body, note: item.note);
        await outbound.remove(item.id);
        flushed++;
      } catch (_) {
        break;
      }
    }
    pendingOutbound = await outbound.pendingCount();
    if (flushed > 0) {
      await syncNotifier.showSynced(flushed: flushed);
    } else if (pendingOutbound > 0 && !online) {
      await syncNotifier.showPendingOutbox(pendingOutbound);
    } else if (before > 0 && pendingOutbound == 0) {
      await syncNotifier.showSynced(flushed: before);
    }
    notifyListeners();
  }

  Future<void> refreshInbox() async {
    try {
      tickets = await inbox.tickets();
      error = null;
    } catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    try {
      orders = await inbox.orders();
      error = null;
    } catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> fulfillOrder(String orderId) async {
    try {
      await inbox.fulfill(orderId);
      await refreshOrders();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> refreshMembers() async {
    final orgId = me?.selectedOrganizationId ??
        (organizations.isNotEmpty ? organizations.first.id : null);
    if (orgId == null) return;
    try {
      members = await inbox.members(orgId);
      error = null;
    } catch (e) {
      error = '$e';
    }
    notifyListeners();
  }

  Future<void> inviteMember(String email) async {
    if (email.isEmpty) return;
    try {
      final roleId = await inbox.firstRoleId();
      if (roleId == null) {
        error = 'No role available to invite with.';
        notifyListeners();
        return;
      }
      await inbox.invite(email: email, roleId: roleId);
      await refreshMembers();
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    try {
      final profile = await inbox.profile();
      final prefs = profile['notificationPrefs'];
      if (prefs is Map) {
        emailNotifications = prefs['email'] != false;
        pushNotifications = prefs['push'] == true;
      }
    } catch (e) {
      debugPrint('notification prefs skipped: $e');
    }
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    emailNotifications = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    pushNotifications = value;
    notifyListeners();
  }

  Future<void> saveNotificationPrefs() async {
    try {
      await inbox.updateNotificationPrefs(
        email: emailNotifications,
        push: pushNotifications,
      );
    } catch (e) {
      error = '$e';
      notifyListeners();
    }
  }

  Future<void> openAccount() => identity.openAccount();

  Future<void> signOut() async {
    await _sse?.stop();
    _sse = null;
    busy = true;
    notifyListeners();
    try {
      await api.platformLogout();
      await identity.signOut();
    } finally {
      me = null;
      conversations = const [];
      visitors = const [];
      dashboard = null;
      tickets = const [];
      orders = const [];
      members = const [];
      phase = AuthPhase.signedOut;
      busy = false;
      notifyListeners();
    }
  }

  void consumeDeepLink() {
    pendingDeepLinkChatId = null;
  }

  Future<void> _onAuthenticated() async {
    await refreshHome();
    await flushOutbound();
    unawaited(PushRegistration.register(api));
    unawaited(_startSse());
    notifyListeners();
  }

  Future<void> _startSse() async {
    await _sse?.stop();
    final base = config.product.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    _sse = ChatSseClient(
      streamUrl: '$base/chat/stream',
      identity: identity,
      orgHeaderName: config.product.orgHeaderName,
      deviceHeaderName: config.product.deviceHeaderName,
      deviceHeader: config.product.deviceHeader,
    );
    unawaited(
      _sse!.start((event, data) {
        if (event == 'heartbeat' || data == 'ping') return;
        try {
          final json = jsonDecode(data);
          if (json is Map && json['conversationId'] != null) {
            unawaited(refreshChat());
          }
        } catch (_) {
          unawaited(refreshChat());
        }
      }),
    );
  }

  Future<void> _listenDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleUri(initial);
      _linkSub ??= _appLinks.uriLinkStream.listen(_handleUri);
    } catch (_) {
      // Deep links optional in tests / desktops.
    }
  }

  void _handleUri(Uri uri) {
    if (uri.scheme != kDeepLinkScheme) return;
    if (uri.host == 'chat' && uri.pathSegments.isNotEmpty) {
      pendingDeepLinkChatId = uri.pathSegments.first;
      notifyListeners();
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'chat') {
      pendingDeepLinkChatId = uri.pathSegments[1];
      notifyListeners();
    }
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
      await _onAuthenticated();
    } else if (organizations.length == 1) {
      await selectOrg(organizations.first);
    } else {
      phase = AuthPhase.needsOrg;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivity.removeListener(_onNet);
    connectivity.dispose();
    unawaited(_sse?.stop() ?? Future.value());
    unawaited(_linkSub?.cancel() ?? Future.value());
    super.dispose();
  }
}
