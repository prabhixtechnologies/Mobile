import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        context.read<AppState>().refreshNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Atmosphere(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
          children: [
            SwitchListTile(
              title: const Text('Email notifications'),
              subtitle: const Text('SLA breaches, assignments, mentions'),
              value: state.emailNotifications,
              onChanged: (v) => state.setEmailNotifications(v),
            ),
            SwitchListTile(
              title: const Text('Push notifications'),
              subtitle: const Text('Urgent threads on this device'),
              value: state.pushNotifications,
              onChanged: (v) => state.setPushNotifications(v),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: state.busy ? null : () => state.saveNotificationPrefs(),
                child: const Text('Save preferences'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
