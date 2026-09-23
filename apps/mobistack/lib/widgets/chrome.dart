import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/prabhix_theme.dart';

/// Widget tests cannot leave flutter_animate timers pending.
bool get skipMotionForTests => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

/// Soft atmospheric field — not a flat fill.
class Atmosphere extends StatelessWidget {
  const Atmosphere({super.key, required this.child, this.intense = false});

  final Widget child;
  final bool intense;

  @override
  Widget build(BuildContext context) {
    final light = !Px.isDark;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: light
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFDDF6F0), Color(0xFFF7FBFA)],
                  )
                : null,
            color: light ? null : Px.bg,
          ),
        ),
        Positioned(
          top: light ? -80 : -160,
          right: light ? -40 : -90,
          child: _Glow(
            size: intense ? 420 : (light ? 220 : 320),
            color: Px.accent.withValues(alpha: light ? 0.18 : (intense ? 0.28 : 0.16)),
          ),
        ),
        if (!light)
          Positioned(
            bottom: -180,
            left: -120,
            child: _Glow(
              size: intense ? 460 : 340,
              color: Px.focus.withValues(alpha: intense ? 0.16 : 0.08),
            ),
          ),
        if (!light) const CustomPaint(painter: _HorizonPainter(), child: SizedBox.expand()),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glow = IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
    if (skipMotionForTests) return glow;
    return glow
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.04, 1.04),
          duration: 6.seconds,
          curve: Curves.easeInOut,
        );
  }
}

class _HorizonPainter extends CustomPainter {
  const _HorizonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Px.accent.withValues(alpha: 0.0),
          Px.accent.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.22, 0.55],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glow);

    final arc = Path()
      ..moveTo(-20, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.02,
        size.width + 20,
        size.height * 0.22,
      );
    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Px.accent.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 56.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Px.accent, Px.accentStrong],
            ),
            boxShadow: [
              BoxShadow(
                color: Px.accent.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'M',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Px.accentInk,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 18 : 26,
                ),
          ),
        ),
        SizedBox(width: compact ? 10 : 14),
        Text(
          'MobiStack',
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.w700,
            fontSize: compact ? 20 : 28,
            height: 1.05,
            color: Px.ink,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class PxPrimaryButton extends StatelessWidget {
  const PxPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: onPressed == null
                ? [Px.faint, Px.muted]
                : [Px.accent, Px.accentStrong],
          ),
          boxShadow: onPressed == null
              ? null
              : [
                  BoxShadow(
                    color: Px.accent.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: busy ? null : onPressed,
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Px.accentInk,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Px.accentInk, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Px.accentInk,
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.toUpperCase()) {
      'ACTIVE' => Px.success,
      'TRIAL' => Px.focus,
      'SUSPENDED' => Px.warning,
      'CANCELLED' => Px.danger,
      _ => Px.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class FadeSlide extends StatelessWidget {
  const FadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.dy = 18,
  });

  final Widget child;
  final Duration delay;
  final double dy;

  @override
  Widget build(BuildContext context) {
    if (skipMotionForTests) return child;
    return child
        .animate()
        .fadeIn(duration: 500.ms, delay: delay, curve: Px.curve)
        .moveY(begin: dy, end: 0, duration: 560.ms, delay: delay, curve: Px.curve);
  }
}

/// Decorative arc used behind hero copy.
class HeroArc extends StatelessWidget {
  const HeroArc({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _ArcPainter(),
    );
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        -size.height * 0.4,
        size.width,
        size.height,
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Px.accent.withValues(alpha: 0.25);
    canvas.drawPath(path, paint);
    // ticks
    for (var i = 0; i < 7; i++) {
      final t = i / 6;
      final x = size.width * t;
      final y = size.height - math.sin(t * math.pi) * size.height * 0.85;
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = Px.accent.withValues(alpha: 0.45));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
