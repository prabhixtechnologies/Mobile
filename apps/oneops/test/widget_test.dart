import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oneops/config.dart';
import 'package:oneops/models/chat_models.dart';
import 'package:oneops/models/inbox_models.dart';
import 'package:oneops/screens/account_screen.dart';
import 'package:oneops/screens/chat_inbox_screen.dart';
import 'package:oneops/screens/dashboard_screen.dart';
import 'package:oneops/screens/inbox_detail_screen.dart';
import 'package:oneops/screens/inbox_screen.dart';
import 'package:oneops/screens/login_screen.dart';
import 'package:oneops/screens/members_screen.dart';
import 'package:oneops/screens/notifications_screen.dart';
import 'package:oneops/screens/orders_screen.dart';
import 'package:oneops/screens/visitor_detail_screen.dart';
import 'package:oneops/screens/visitors_screen.dart';
import 'package:oneops/state/app_state.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

AppState readyState() {
  final state = AppState(config: AppConfig.fromEnvironment());
  state.phase = AuthPhase.ready;
  state.me = AuthMe(
    id: 'u1',
    email: 'op@prabhix.test',
    displayName: 'Operator',
    selectedOrganizationId: 'org1',
    organizations: [OrganizationSummary(id: 'org1', name: 'Acme')],
  );
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

  testWidgets('dashboard KPIs', (tester) async {
    final state = readyState();
    state.dashboard = DashboardKpis(
      openConversations: 4,
      unassignedConversations: 1,
      visitorsToday: 7,
      seatsUsed: 2,
      seatsLimit: 10,
    );
    await tester.pumpWidget(wrap(state, const DashboardScreen()));
    await tester.pump();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('4'), findsWidgets);
    expect(find.text('Orders'), findsOneWidget);
    state.dispose();
  });

  testWidgets('inbox lists tickets', (tester) async {
    final state = readyState();
    state.tickets = [
      InboxTicket(id: 't1', subject: 'Reset password please', status: 'OPEN'),
    ];
    await tester.pumpWidget(wrap(state, const InboxScreen()));
    await tester.pump();
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Reset password please'), findsOneWidget);
    state.dispose();
  });

  testWidgets('inbox detail reply and assign', (tester) async {
    final state = readyState();
    state.tickets = [
      InboxTicket(id: 't1', subject: 'Reset password please', status: 'OPEN'),
    ];
    await tester.pumpWidget(wrap(state, const InboxDetailScreen(threadId: 't1')));
    await tester.pump();
    expect(find.text('Reset password please'), findsOneWidget);
    expect(find.text('Assign to me'), findsOneWidget);
    expect(find.text('Reply…'), findsOneWidget);
    state.dispose();
  });

  testWidgets('live chat queue', (tester) async {
    final state = readyState();
    state.conversations = [
      ConversationSummary(id: 'c1', subject: 'Chat with Ada'),
    ];
    await tester.pumpWidget(wrap(state, const ChatInboxScreen()));
    await tester.pump();
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Chat with Ada'), findsOneWidget);
    state.dispose();
  });

  testWidgets('visitors list', (tester) async {
    final state = readyState();
    state.visitors = [
      LiveVisitor(visitorId: 'v1', displayName: 'Visitor Ada'),
    ];
    await tester.pumpWidget(wrap(state, const VisitorsScreen()));
    await tester.pump();
    expect(find.text('Live visitors'), findsOneWidget);
    expect(find.text('Visitor Ada'), findsOneWidget);
    state.dispose();
  });

  testWidgets('visitor detail', (tester) async {
    final state = readyState();
    state.visitors = [
      LiveVisitor(
        visitorId: 'v1',
        displayName: 'Visitor Ada',
        currentPath: '/pricing',
      ),
    ];
    await tester.pumpWidget(wrap(state, const VisitorDetailScreen(visitorId: 'v1')));
    await tester.pump();
    expect(find.text('Visitor Ada'), findsWidgets);
    expect(find.textContaining('/pricing'), findsOneWidget);
    state.dispose();
  });

  testWidgets('orders list', (tester) async {
    final state = readyState();
    state.orders = [
      OrderRow(id: 'o1', label: 'ORD-100', status: 'PAID', total: '199'),
    ];
    await tester.pumpWidget(wrap(state, const OrdersScreen()));
    await tester.pump();
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('ORD-100'), findsOneWidget);
    expect(find.text('Fulfil'), findsOneWidget);
    state.dispose();
  });

  testWidgets('members list', (tester) async {
    final state = readyState();
    state.members = [
      MemberRow(id: 'm1', label: 'Ada Lovelace', email: 'ada@acme.test'),
    ];
    await tester.pumpWidget(wrap(state, const MembersScreen()));
    await tester.pump();
    expect(find.text('Members'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    state.dispose();
  });

  testWidgets('notifications prefs', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const NotificationsScreen()));
    await tester.pump();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Email notifications'), findsOneWidget);
    state.dispose();
  });

  testWidgets('account opens Identity copy', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const AccountScreen()));
    await tester.pump();
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Manage account'), findsOneWidget);
    expect(find.textContaining('Identity'), findsWidgets);
    state.dispose();
  });
}
