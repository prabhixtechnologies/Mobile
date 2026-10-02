import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/chrome.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = brandColors(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 28, 16 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const FadeSlide(child: OpeningBrand()),
              const SizedBox(height: 18),
              FadeSlide(
                delay: 80.ms,
                child: Text(
                  'Inventory, sales, and repairs.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.inkMuted,
                        fontSize: 17,
                      ),
                ),
              ),
              const Spacer(),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.danger),
                  ),
                ),
              FadeSlide(
                delay: 140.ms,
                child: PxPrimaryButton(
                  label: state.busy ? 'Signing in…' : 'Login with Prabhix Identity',
                  busy: state.busy,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: state.busy ? null : () => state.signIn(),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: state.busy ? null : () => state.signIn(create: true),
                child: Text('Create account', style: TextStyle(color: colors.accentText)),
              ),
              const SizedBox(height: 12),
              const PoweredByPrabhix(),
            ],
          ),
        ),
      ),
    );
  }
}
