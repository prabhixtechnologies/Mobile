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
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Px.bg),
        Positioned(
          top: -120,
          right: -80,
          child: _Glow(
            size: intense ? 340 : 280,
            color: Px.focus.withValues(alpha: intense ? 0.22 : 0.14),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -100,
          child: _Glow(
            size: intense ? 380 : 300,
            color: Px.accent.withValues(alpha: intense ? 0.18 : 0.12),
          ),
        ),
        Positioned(
          top: MediaQuery.sizeOf(context).height * 0.35,
          left: MediaQuery.sizeOf(context).width * 0.2,
          child: _Glow(
            size: 200,
            color: Px.bgAccent.withValues(alpha: 0.9),
          ),
        ),
        // Fine grain mesh lines
        CustomPaint(painter: _MeshPainter(), child: const SizedBox.expand()),
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

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Px.ink.withValues(alpha: 0.035)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Diagonal accent slash
    final slash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Px.accent.withValues(alpha: 0.0),
          Px.accent.withValues(alpha: 0.06),
          Px.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 120
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, -40),
      Offset(size.width * 1.1, size.height * 0.7),
      slash,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false, this.product = 'OneOps'});

  final bool compact;
  final String product;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 36.0 : 52.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 10 : 14),
            gradient: const LinearGradient(
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
            'P',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Px.accentInk,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 18 : 24,
                ),
          ),
        ),
        SizedBox(width: compact ? 10 : 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Prabhix',
              style: GoogleFonts.fraunces(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 18 : 22,
                height: 1.05,
                color: Px.ink,
              ),
            ),            Text(
              product.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Px.accent,
                    letterSpacing: 1.6,
                    fontSize: compact ? 11 : 12,
                  ),
            ),
          ],
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
                : const [Px.accent, Px.accentStrong],
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
                  ? const SizedBox(
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
