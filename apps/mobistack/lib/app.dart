import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/barcode_scanner_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/commons_component_screen.dart';
import 'screens/compatibility_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/device_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/invoice_screen.dart';
import 'screens/login_screen.dart';
import 'screens/members_screen.dart';
import 'screens/more_screen.dart';
import 'screens/movements_screen.dart';
import 'screens/private_notes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/purchases_screen.dart';
import 'screens/repairs_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_journey.dart';
import 'screens/shop_ops_screens.dart';
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
            switch (app.gate) {
              case ShopGate.start:
                const open = {'/start', '/shop/new', '/shop/join', '/shop/invite'};
                return open.contains(loc) ? null : '/start';
              case ShopGate.joinUnion:
                return loc == '/union/join' ? null : '/union/join';
              case ShopGate.waitingShop:
                return loc == '/shop/waiting' ? null : '/shop/waiting';
              case ShopGate.waitingUnion:
                return loc == '/union/waiting' ? null : '/union/waiting';
              case ShopGate.outside:
                return loc == '/shop/outside' ? null : '/shop/outside';
              case ShopGate.catalog:
                if (loc == '/login' ||
                    loc == '/splash' ||
                    loc == '/home' ||
                    loc == '/more' ||
                    loc == '/start' ||
                    loc.startsWith('/shop') ||
                    loc.startsWith('/union')) {
                  return '/commons';
                }
                final open = loc == '/billing' || loc.startsWith('/commons');
                return open ? null : '/commons';
            }
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
                    SizedBox(
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
        GoRoute(path: '/start', builder: (_, __) => const ShopStartScreen()),
        GoRoute(path: '/shop/new', builder: (_, __) => const CreateShopScreen()),
        GoRoute(path: '/shop/join', builder: (_, __) => const JoinShopScreen()),
        GoRoute(path: '/shop/invite', builder: (_, __) => const InviteShopScreen()),
        GoRoute(path: '/shop/waiting', builder: (_, __) => const WaitingScreen(union: false)),
        GoRoute(path: '/shop/outside', builder: (_, __) => const OutsideUnionScreen()),
        GoRoute(path: '/union/join', builder: (_, __) => const JoinUnionScreen()),
        GoRoute(path: '/union/waiting', builder: (_, __) => const WaitingScreen(union: true)),
        ShellRoute(
          builder: (context, state, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
            GoRoute(
              path: '/commons',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: CompatibilityScreen()),
            ),
            GoRoute(
              path: '/billing',
              pageBuilder: (_, __) =>
                  const NoTransitionPage(child: BillingScreen()),
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
        GoRoute(path: '/compatibility', builder: (_, __) => const PrivateNotesScreen()),
        GoRoute(path: '/customers', builder: (_, __) => const CustomersScreen()),
        GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersScreen()),
        GoRoute(path: '/purchases', builder: (_, __) => const PurchasesScreen()),
        GoRoute(path: '/members', builder: (_, __) => const MembersScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(
          path: '/movements',
          builder: (_, state) => MovementsScreen(variantId: state.uri.queryParameters['variant']),
        ),
        GoRoute(path: '/inbox', builder: (_, __) => const InboxScreen()),
        GoRoute(path: '/support', builder: (_, __) => const SupportScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/audit', builder: (_, __) => const AuditScreen()),
        GoRoute(path: '/health', builder: (_, __) => const HealthScreen()),
        GoRoute(path: '/standing', builder: (_, __) => const StandingScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationPrefsScreen()),
        GoRoute(path: '/import', builder: (_, __) => const ImportScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/scan', builder: (_, __) => const BarcodeScannerScreen()),
        GoRoute(
          path: '/invoice/:id',
          builder: (_, state) => InvoiceScreen(saleId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/devices/:id',
          builder: (_, state) =>
              DeviceDetailScreen(deviceId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/commons/devices/:id',
          builder: (_, state) =>
              DeviceDetailScreen(deviceId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/commons/components/:id',
          builder: (_, state) =>
              CommonsComponentScreen(componentId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppState>().themeMode;
    Px.active = mode == ThemeMode.light ? PxPalette.lightMode : PxPalette.darkMode;
    return MaterialApp.router(
      title: 'MobiStack',
      theme: buildMobiStackTheme(PxPalette.lightMode),
      darkTheme: buildMobiStackTheme(PxPalette.darkMode),
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
