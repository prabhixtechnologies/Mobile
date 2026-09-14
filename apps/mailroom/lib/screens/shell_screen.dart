import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final company = state.canReadCompany;
    final index = state.companyMail && company ? 1 : 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: company
          ? NavigationBar(
              height: 68,
              selectedIndex: index,
              backgroundColor: Px.surface.withValues(alpha: 0.94),
              indicatorColor: Px.bgAccent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) {
                context.go('/mail');
                if (i == 0) {
                  unawaited(state.setCompanyMail(false));
                } else {
                  unawaited(state.setCompanyMail(true));
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.mail_outline_rounded),
                  selectedIcon: const Icon(Icons.mail_rounded),
                  label: state.offlineMode ? 'Mail · offline' : 'My mail',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.corporate_fare_outlined),
                  selectedIcon: Icon(Icons.corporate_fare_rounded),
                  label: 'Company mail',
                ),
              ],
            )
          : null,
    );
  }
}
