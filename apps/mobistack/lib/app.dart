import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/barcode_scanner_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/compatibility_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/device_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/more_screen.dart';
import 'screens/movements_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/purchases_screen.dart';
import 'screens/repairs_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/support_screen.dart';
import 'screens/workspaces_screen.dart';
import 'state/app_state.dart';
import 'theme/prabhix_theme.dart';
import 'widgets/chrome.dart';

class MobiStackApp extends StatefulWidget {
  const MobiStackApp({super.key});

  @override
  State<MobiStackApp> createState() => _MobiStackAppState();
}

class _MobiStackAppState extends State<MobiStackApp> {
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
          case AuthPhase.ready:
            if (loc == '/login' || loc == '/splash') return '/home';
            return null;
        }
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => Atmosphere(
            intense: true,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 28),
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Px.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        ShellRoute(
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
            GoRoute(
              path: '/compatibility',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: CompatibilityScreen()),
            ),
            GoRoute(
              path: '/more',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: MoreScreen()),
            ),
            GoRoute(
              path: '/inventory',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: InventoryScreen()),
            ),
            GoRoute(
              path: '/sales',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: SalesScreen()),
            ),
            GoRoute(
              path: '/repairs',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: RepairsScreen()),
            ),
          ],
        ),
        GoRoute(path: '/workspaces', builder: (_, __) => const WorkspacesScreen()),
        GoRoute(path: '/customers', builder: (_, __) => const CustomersScreen()),
        GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersScreen()),
        GoRoute(path: '/purchases', builder: (_, __) => const PurchasesScreen()),
        GoRoute(path: '/members', builder: (_, __) => const MembersScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/movements', builder: (_, __) => const MovementsScreen()),
        GoRoute(path: '/billing', builder: (_, __) => const BillingScreen()),
        GoRoute(path: '/inbox', builder: (_, __) => const InboxScreen()),
        GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/scan', builder: (_, __) => const BarcodeScannerScreen()),
        GoRoute(
          path: '/devices/:id',
          builder: (_, state) =>
              DeviceDetailScreen(deviceId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MobiStack',
      theme: buildPrabhixAdminTheme(),
      routerConfig: _router,
    );
  }
}
