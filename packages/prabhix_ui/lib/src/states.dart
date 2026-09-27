import 'package:flutter/material.dart';
import 'package:prabhix_theme/prabhix_theme.dart';

/// The four states every list, table and detail pane can be in.
///
/// Screens that only render "has data" are the reason an app feels unfinished: a slow
/// network shows a blank rectangle, an error shows the same blank rectangle, and a genuinely
/// empty list is indistinguishable from both.
enum PxViewState { loading, empty, error, ready }

/// A first-run or filtered-to-nothing state that tells the user what to do next.
///
/// An empty state with no action is a dead end. [action] is optional only because some
/// lists genuinely have nothing to offer — a filtered result set, for example, where the
/// right move is to clear the filter, which the caller passes as the action.
class PxEmpty extends StatelessWidget {
  const PxEmpty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Drops the illustration and tightens the spacing, for an empty state inside a panel
  /// rather than one that owns the whole screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final px = context.px;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: compact ? 20 : 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // The accent pair, so an empty state is the product's colour rather than
                  // a grey box. This is the screen a new user sees first.
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [px.accentSubtle, px.accent2Subtle],
                  ),
                ),
                child: Icon(icon, size: 30, color: px.accentSubtleInk),
              ),
              const SizedBox(height: 18),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: px.inkMuted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A failure the user can act on, rather than a red string.
///
/// [onRetry] is required because an error with no way forward leaves the user with nothing
/// but the back button. If a particular failure genuinely cannot be retried, show a [PxEmpty]
/// explaining why instead of pretending it is transient.
class PxError extends StatelessWidget {
  const PxError({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'That did not load',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final px = context.px;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: px.dangerSubtle,
                border: Border.all(color: px.dangerSubtleBorder),
              ),
              child: Icon(Icons.cloud_off_rounded, size: 26, color: px.dangerSubtleInk),
            ),
            const SizedBox(height: 16),
            Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: px.inkMuted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A shimmering placeholder shaped like the content that is coming.
///
/// Shaped, not a spinner: a skeleton that matches the real layout stops the page jumping
/// when the data lands, and tells the user what kind of thing to expect.
class PxSkeleton extends StatefulWidget {
  const PxSkeleton({
    super.key,
    this.rows = 6,
    this.rowHeight = 64,
    this.padding = const EdgeInsets.all(16),
  });

  final int rows;
  final double rowHeight;
  final EdgeInsets padding;

  @override
  State<PxSkeleton> createState() => _PxSkeletonState();
}

class _PxSkeletonState extends State<PxSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final px = context.px;
    // Respects the platform "reduce motion" setting: a looping shimmer is exactly the kind
    // of animation that setting exists to stop.
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: widget.padding,
      child: Column(
        children: [
          for (var i = 0; i < widget.rows; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => Opacity(
                  opacity: animate ? 0.45 + 0.35 * _pulse.value : 0.6,
                  child: Container(
                    height: widget.rowHeight,
                    decoration: BoxDecoration(
                      color: px.surfaceSunken,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: px.border),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders the right one of the four states.
///
/// Having one widget make the choice is what stops a screen from quietly forgetting the
/// error case: the type system will not let a caller omit it.
class PxStateView extends StatelessWidget {
  const PxStateView({
    super.key,
    required this.state,
    required this.ready,
    required this.empty,
    required this.error,
    this.loading,
  });

  final PxViewState state;
  final WidgetBuilder ready;
  final WidgetBuilder empty;
  final WidgetBuilder error;
  final WidgetBuilder? loading;

  @override
  Widget build(BuildContext context) => switch (state) {
        PxViewState.loading => (loading ?? (_) => const PxSkeleton())(context),
        PxViewState.empty => empty(context),
        PxViewState.error => error(context),
        PxViewState.ready => ready(context),
      };
}
