import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/compose_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mailbox_screen.dart';
import 'screens/org_select_screen.dart';
import 'screens/queue_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/thread_detail_screen.dart';
import 'screens/ticket_detail_screen.dart';
import 'state/app_state.dart';
import 'theme/prabhix_theme.dart';

class MailroomApp extends StatefulWidget {
  const MailroomApp({super.key});

  @override
  State<MailroomApp> createState() => _MailroomAppState();
}

class _MailroomAppState extends State<MailroomApp> {
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
              return '/mail';
            }
            if (loc == '/mailbox') return '/mail';
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
              path: '/mail',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: MailboxScreen()),
            ),
            GoRoute(
              path: '/queue',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: QueueScreen()),
            ),
          ],
        ),
        GoRoute(
          path: '/thread/:id',
          builder: (_, state) =>
              ThreadDetailScreen(threadId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/ticket/:id',
          builder: (_, state) =>
              TicketDetailScreen(threadId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/compose', builder: (_, __) => const ComposeScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prabhix Mailroom',
      theme: buildPrabhixAdminTheme(),
      routerConfig: _router,
    );
  }
}
