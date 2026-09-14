import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Atmosphere(
        intense: true,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 20, 28, 20 + bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeSlide(
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: BrandMark(),
                  ),
                ),
                const Spacer(flex: 2),
                FadeSlide(delay: 80.ms, child: const HeroArc()),
                const SizedBox(height: 12),
                FadeSlide(
                  delay: 120.ms,
                  child: Text(
                    'Shared\nmailboxes.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 42,
                          height: 1.02,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlide(
                  delay: 180.ms,
                  child: Text(
                    'Your mail, folders and replies — Identity sign-in only.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Px.muted,
                          fontSize: 17,
                        ),
                  ),
                ),
                const Spacer(flex: 3),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(state.error!, style: const TextStyle(color: Px.danger)),
                  ),
                FadeSlide(
                  delay: 240.ms,
                  child: PxPrimaryButton(
                    label: state.busy ? 'Opening Identity…' : 'Continue with Identity',
                    busy: state.busy,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: state.busy ? null : () => state.signIn(),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Mailroom · threads · compose',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
