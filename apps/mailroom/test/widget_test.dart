import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailroom/config.dart';
import 'package:mailroom/models/mail_models.dart';
import 'package:mailroom/screens/account_screen.dart';
import 'package:mailroom/screens/compose_screen.dart';
import 'package:mailroom/screens/login_screen.dart';
import 'package:mailroom/screens/mailbox_screen.dart';
import 'package:mailroom/screens/queue_screen.dart';
import 'package:mailroom/screens/settings_screen.dart';
import 'package:mailroom/screens/shell_screen.dart';
import 'package:mailroom/state/app_state.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:provider/provider.dart';

AppState readyState() {
  final state = AppState(config: AppConfig.fromEnvironment());
  state.phase = AuthPhase.ready;
  state.me = AuthMe(
    id: 'u1',
    email: 'mail@prabhix.test',
    displayName: 'Mailer',
    permissions: {'MAIL_READ_ALL'},
  );
  state.mailboxes = [
    MailboxSummary(
      id: 'mb1',
      name: 'Inbox',
      address: 'mailer@acme.test',
      mine: true,
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

  testWidgets('mail list shows a thread', (tester) async {
    final state = readyState();
    state.threads = [
      MailThreadSummary(id: 'th1', subject: 'Welcome to Mailroom', fromName: 'Ada'),
    ];
    await tester.pumpWidget(wrap(state, const MailboxScreen()));
    await tester.pump();
    expect(find.text('Welcome to Mailroom'), findsOneWidget);
    state.dispose();
  });

  testWidgets('compose screen', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const ComposeScreen()));
    await tester.pump();
    expect(find.text('Compose'), findsOneWidget);
    expect(find.text('To'), findsWidgets);
    state.dispose();
  });

  testWidgets('aliases and signature', (tester) async {
    final state = readyState();
    state.aliases = [MailAlias(id: 'a1', address: 'hello@acme.test')];
    state.signature = 'Thanks, Mailer';
    await tester.pumpWidget(wrap(state, const SettingsScreen()));
    await tester.pump();
    expect(find.text('Aliases and signature'), findsOneWidget);
    expect(find.text('hello@acme.test'), findsOneWidget);
    expect(find.text('Save signature'), findsOneWidget);
    state.dispose();
  });

  testWidgets('company mail mode in the shell', (tester) async {
    final state = readyState();
    state.companyMail = true;
    final router = GoRouter(
      initialLocation: '/mail',
      routes: [
        ShellRoute(
          builder: (context, _, child) => ShellScreen(child: child),
          routes: [
            GoRoute(
              path: '/mail',
              builder: (_, __) => const MailboxScreen(),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    expect(find.text('Company mail'), findsOneWidget);
    expect(find.text('My mail'), findsOneWidget);
    state.dispose();
  });

  testWidgets('helpdesk points at OneOps inbox', (tester) async {
    final state = readyState();
    await tester.pumpWidget(wrap(state, const QueueScreen()));
    await tester.pump();
    expect(find.text('Helpdesk moved'), findsOneWidget);
    expect(find.textContaining('OneOps'), findsWidgets);
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
