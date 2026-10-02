import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:prabhix_client/prabhix_client.dart';
import 'package:provider/provider.dart';

import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/org_select_screen.dart';
import 'screens/platform_screen.dart';
import 'state/app_state.dart';
import 'theme/prabhix_theme.dart';
import 'widgets/chrome.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
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
              return '/platform';
            }
            return null;
        }
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/orgs', builder: (_, __) => const OrgSelectScreen()),
        GoRoute(path: '/platform', builder: (_, __) => const PlatformScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClientRecoveryOverlay(
      controller: context.read<AppState>().recovery,
      busy: context.watch<AppState>().busy,
      onSecuritySignIn: () => context.read<AppState>().signIn(),
        child: MaterialApp.router(
          title: 'Prabhix Admin',
          debugShowCheckedModeBanner: false,
          theme: adminTheme(Brightness.light),
          darkTheme: adminTheme(Brightness.dark),
          themeMode: ThemeMode.light,
          // Px is a mutable global, so it has to be re-pointed at whichever theme actually
          // resolved before any descendant reads it.
          builder: (context, child) {
            syncPx(Theme.of(context).brightness);
            return child!;
          },
          routerConfig: _router,
        ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Atmosphere(
        intense: true,
        child: Center(
          child: const BrandMark()
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Px.curve,
              ),
        ),
      ),
    );
  }
}
