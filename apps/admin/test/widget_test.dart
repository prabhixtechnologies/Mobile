import 'package:admin/config.dart';
import 'package:admin/screens/account_screen.dart';
import 'package:admin/screens/login_screen.dart';
import 'package:admin/screens/platform_screen.dart';
import 'package:admin/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

AppState readyState() {
  final state = AppState(config: AppConfig.fromEnvironment());
  state.phase = AuthPhase.ready;
  state.me = AuthMe(
    id: 'u1',
    email: 'staff@prabhix.test',
    displayName: 'Staff',
    platformAdmin: true,
  );
  state.overview = PlatformOverview(
    tenants: const TenantCounts(total: 12, active: 9, trial: 2),
    accounts: const AccountCounts(total: 40, platformAdmins: 3, lockedOut: 1),
  );
  state.tenants = [
    TenantSummary(id: 't1', name: 'Acme Shop', status: 'ACTIVE'),
  ];
  state.workspaces = [
    AdminWorkspace(id: 'w1', name: 'Acme Shop', active: true, members: 4),
  ];
  state.mobiRevenue = const RevenueSnapshot(capturedTotal: 12000, pendingTotal: 500);
  state.identityUsers = [
    IdentityUserRow(id: 'iu1', email: 'ops@prabhix.test', status: 'ACTIVE'),
  ];
  state.mailHealth = MailHealth(
    sesOk: true,
    sesNote: 'SES transport ready',
    outboxInFlight: 2,
    mailboxes: 8,
  );
  state.commonsQueue = [
    CommonsReviewItem(id: 'c1', title: 'Fitment note', status: 'PENDING'),
  ];
  state.staffGrants = [
    StaffGrant(id: 'g1', userId: 'u1', role: 'SUPPORT'),
  ];
  state.staffRoles = {'OWNER'};
  state.liveUsers = [
    AdminLiveUser(
      userId: 'lu1',
      fullName: 'Live Ada',
      email: 'ada@shop.test',
      deviceId: 'd1',
      platform: 'android',
      seenAt: 'now',
    ),
  ];
  return state;
}

Widget wrap(AppState state, Widget child) {
  return ChangeNotifierProvider.value(
    value: state,
    child: MaterialApp(home: child),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('login asks for Identity', (tester) async {
    final state = AppState(config: AppConfig.fromEnvironment());
    state.phase = AuthPhase.signedOut;
    await tester.pumpWidget(wrap(state, const LoginScreen()));
    await tester.pump();
    expect(find.text('Continue with Identity'), findsOneWidget);
    state.dispose();
  });

  testWidgets('overview, tenants, commerce, ops sections', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const PlatformScreen()));
    await tester.pump();
    expect(find.text('Control'), findsOneWidget);
    expect(find.text('ONEOPS TENANTS'), findsOneWidget);

    await tester.tap(find.text('Tenants'));
    await tester.pump();
    expect(find.text('Acme Shop'), findsWidgets);

    await tester.tap(find.text('Commerce'));
    await tester.pump();
    expect(find.text('Commerce'), findsWidgets);
    expect(find.text('REVENUE'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pump();
    expect(find.text('Operations'), findsOneWidget);

    Future<void> openOps(String label) async {
      final chip = find.text(label);
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
    }

    await openOps('Identity');
    expect(find.text('ops@prabhix.test'), findsOneWidget);
    expect(find.text('Disable'), findsOneWidget);

    await openOps('Mail');
    expect(find.text('Mail health'), findsOneWidget);
    expect(find.textContaining('SES'), findsWidgets);

    await openOps('Commons');
    expect(find.text('Fitment note'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);

    await openOps('Staff');
    expect(find.text('Grant a staff role'), findsOneWidget);
    expect(find.text('Revoke tokens'), findsOneWidget);

    await openOps('Live');
    expect(find.text('Live Ada'), findsOneWidget);
    expect(find.byTooltip('Kick'), findsOneWidget);

    await openOps('Infra');
    expect(find.text('Promote'), findsWidgets);

    state.dispose();
  });

  testWidgets('account opens Identity copy', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const AccountScreen()));
    await tester.pump();
    expect(find.text('Manage account'), findsOneWidget);
    state.dispose();
  });
}
