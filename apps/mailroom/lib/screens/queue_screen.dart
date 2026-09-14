import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

/// Helpdesk work lives in OneOps. This route remains so old bookmarks do not 404.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: Atmosphere(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, top + 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Helpdesk moved',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 12),
              Text(
                'The team queue, assignees and SLAs are part of OneOps now, not Mailroom. Open OneOps → Inbox to work tickets.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/mail'),
                style: FilledButton.styleFrom(backgroundColor: Px.accent),
                child: const Text('Back to mail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
