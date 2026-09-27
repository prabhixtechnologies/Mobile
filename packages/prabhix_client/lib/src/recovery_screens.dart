import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client_recovery.dart';

class SecuritySignInScreen extends StatelessWidget {
  const SecuritySignInScreen({
    super.key,
    required this.reason,
    required this.onSignIn,
    this.busy = false,
  });

  final SecuritySignInReason reason;
  final VoidCallback? onSignIn;
  final bool busy;

  String get title => switch (reason) {
        SecuritySignInReason.sessionReplaced => 'Sign in again for security',
        SecuritySignInReason.tokenRevoked => 'Your session was revoked',
        SecuritySignInReason.unknown => 'Sign in again',
      };

  String get body => switch (reason) {
        SecuritySignInReason.sessionReplaced =>
          'We refreshed platform security. Your shop data on this phone is still here — sign in again to continue.',
        SecuritySignInReason.tokenRevoked =>
          'An administrator ended this session. Sign in again when you are ready.',
        SecuritySignInReason.unknown =>
          'Sign in again to continue. Offline drafts and saved shop data stay on this device.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.shield_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(body, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: busy ? null : onSignIn,
                child: Text(busy ? 'Opening Identity…' : 'Sign in with Prabhix Identity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpgradeRequiredScreen extends StatelessWidget {
  const UpgradeRequiredScreen({
    super.key,
    required this.gate,
    this.onOpenStore,
  });

  final UpgradeGate gate;
  final VoidCallback? onOpenStore;

  @override
  Widget build(BuildContext context) {
    final policy = gate.policy;
    final notes = policy.notes?.trim();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.system_update_alt, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Update required',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'This build (${gate.currentBuild}) is below the minimum supported '
                '(${policy.minNativeBuild}). Install the latest app to sign in.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(notes, style: Theme.of(context).textTheme.bodyMedium),
              ],
              const Spacer(flex: 2),
              FilledButton(
                onPressed: onOpenStore ?? () => _openStore(policy.storeUrl),
                child: const Text('Get the update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(String? url) async {
    final target = url?.trim();
    if (target == null || target.isEmpty) return;
    final uri = Uri.tryParse(target);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class JourneyRetryScreen extends StatelessWidget {
  const JourneyRetryScreen({
    super.key,
    required this.message,
    required this.onRetry,
    this.busy = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.cloud_off_outlined, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Could not load your shop', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(context).textTheme.bodyLarge),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: busy ? null : onRetry,
                child: Text(busy ? 'Retrying…' : 'Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen gate shown above the router when [controller] blocks the app.
class ClientRecoveryOverlay extends StatelessWidget {
  const ClientRecoveryOverlay({
    super.key,
    required this.controller,
    required this.child,
    this.onSecuritySignIn,
    this.busy = false,
  });

  final ClientRecoveryController controller;
  final Widget child;
  final VoidCallback? onSecuritySignIn;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final upgrade = controller.upgradeGate;
        if (upgrade != null) {
          return UpgradeRequiredScreen(gate: upgrade);
        }
        final security = controller.pendingSecuritySignIn;
        if (security != null) {
          return SecuritySignInScreen(
            reason: security,
            busy: busy,
            onSignIn: onSecuritySignIn,
          );
        }
        return child;
      },
    );
  }
}
