import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/account_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/chat_inbox_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inbox_detail_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/org_select_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/visitor_detail_screen.dart';
import 'screens/visitors_screen.dart';
import 'state/app_state.dart';
import 'theme/prabhix_theme.dart';

class OneOpsApp extends StatefulWidget {
  const OneOpsApp({super.key});

  @override
  State<OneOpsApp> createState() => _OneOpsAppState();
}

class _OneOpsAppState extends State<OneOpsApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: state,
      redirect: (context, routerState) {
        final app = context.read<AppState>();
        final loc = routerState.matchedLocation;
        switch (app.phase) {
          case AuthPhase.loading:
            return loc == '/splash' ? null : '/splash';
          case AuthPhase.signedOut:
            return loc == '/login' ? null : '/login';
          case AuthPhase.needsOrg:
            return loc == '/orgs' ? null : '/orgs';
          case AuthPhase.ready:
            if (loc == '/login' || loc == '/orgs' || loc == '/splash') {
              final deep = app.pendingDeepLinkChatId;
              if (deep != null) {
                app.consumeDeepLink();
                return '/chat/$deep';
              }
              return '/home/dashboard';
            }
            final deep = app.pendingDeepLinkChatId;
            if (deep != null) {
              app.consumeDeepLink();
              return '/chat/$deep';
            }
            return null;
        }
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/orgs', builder: (_, __) => const OrgSelectScreen()),
        ShellRoute(
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/home/dashboard',
              pageBuilder: (_, __) => const NoTransitionPage(child: DashboardScreen()),
            ),
            GoRoute(
              path: '/home/inbox',
              pageBuilder: (_, __) => const NoTransitionPage(child: InboxScreen()),
            ),
            GoRoute(
              path: '/home/chat',
              pageBuilder: (_, __) => const NoTransitionPage(child: ChatInboxScreen()),
            ),
            GoRoute(
              path: '/home/visitors',
              pageBuilder: (_, __) => const NoTransitionPage(child: VisitorsScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/chat/:id',
          builder: (_, state) => ChatDetailScreen(conversationId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/inbox/:id',
          builder: (_, state) => InboxDetailScreen(threadId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/visitors/:id',
          builder: (_, state) =>
              VisitorDetailScreen(visitorId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(path: '/members', builder: (_, __) => const MembersScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prabhix OneOps',
      theme: buildPrabhixAdminTheme(),
      routerConfig: _router,
    );
  }
}
