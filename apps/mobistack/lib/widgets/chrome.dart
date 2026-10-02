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
            // The web app's `--px-gradient-brand-fade`: the accent wash at the top of the
            // page settling into the plain surface. It used to be two mint literals, which
            // is why the app read teal while the shop's ochre branding sat on top of it.
            gradient: light
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Px.bgAccent, Px.surface],
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
        // The partner accent in the opposite corner, so the wash has two hues in it rather
        // than one hue at two opacities. Light mode gets it too; it used to be dark-only.
        Positioned(
          bottom: light ? -150 : -180,
          left: light ? -110 : -120,
          child: _Glow(
            size: intense ? 460 : 340,
            color: Px.accent2.withValues(alpha: light ? 0.12 : (intense ? 0.16 : 0.08)),
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

/// Colours from the theme that is actually on screen.
///
/// The opening screens used to read the [Px] global. That global can still be the other
/// mode for the first frame, which painted the word in the same tone as the page.
PxColors brandColors(BuildContext context) =>
    Theme.of(context).extension<PxPalette>()?.colors ?? pxMobistackLight;

/// First screen while the session is loading. Solid page colour, so the word cannot
/// sit on a wash of the same tone.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = brandColors(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 24, 28, 16 + bottom),
          child: const Column(
            children: [
              Spacer(),
              OpeningBrand(),
              Spacer(),
              PoweredByPrabhix(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Word, then the MobiStack mark. This replaces the yellow ring that used to sit alone
/// in the middle of the startup screen.
class OpeningBrand extends StatelessWidget {
  const OpeningBrand({super.key, this.markSize = 88});

  final double markSize;

  @override
  Widget build(BuildContext context) {
    final colors = brandColors(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MobiStack',
          textAlign: TextAlign.center,
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.w700,
            fontSize: 40,
            height: 1.05,
            color: colors.ink,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 18),
        MobiStackMark(size: markSize),
      ],
    );
  }
}

/// The stacked M, ochre into teal, with the stroke taken from the accent ink so it
/// stays readable in both modes.
class MobiStackMark extends StatelessWidget {
  const MobiStackMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = brandColors(context);
    return Semantics(
      label: 'MobiStack logo',
      child: CustomPaint(
        size: Size.square(size),
        painter: _MobiMarkPainter(
          from: colors.accent,
          to: colors.accent2,
          stroke: colors.accentInk,
        ),
      ),
    );
  }
}

class _MobiMarkPainter extends CustomPainter {
  const _MobiMarkPainter({required this.from, required this.to, required this.stroke});

  final Color from;
  final Color to;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64;
    canvas.save();
    canvas.scale(scale);
    final bounds = const Rect.fromLTWH(0, 0, 64, 64);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(16)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [from, to],
        ).createShader(bounds),
    );
    canvas.drawPath(
      Path()
        ..moveTo(19.05, 45.9)
        ..lineTo(19.05, 17.95)
        ..lineTo(30.9, 34.15)
        ..lineTo(42.75, 17.95)
        ..lineTo(42.75, 45.9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MobiMarkPainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to || oldDelegate.stroke != stroke;
}

/// Small line under the opening screens: the company name and its own mark.
class PoweredByPrabhix extends StatelessWidget {
  const PoweredByPrabhix({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = brandColors(context);
    final caption = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.inkMuted,
          fontSize: 12,
          letterSpacing: 0.2,
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Powered by', style: caption),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PrabhixMark(size: 22),
            const SizedBox(width: 8),
            Text(
              'Prabhix Technologies',
              style: caption?.copyWith(color: colors.ink, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

/// House mark, kept on the Technologies cyan-to-indigo pair so it stays the company
/// logo rather than another copy of the product accent.
class PrabhixMark extends StatelessWidget {
  const PrabhixMark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    const house = pxTechnologiesLight;
    return Semantics(
      label: 'Prabhix Technologies logo',
      child: CustomPaint(
        size: Size.square(size),
        painter: _PrabhixMarkPainter(
          from: house.accent,
          to: house.accent2,
          ink: house.accentInk,
          second: house.accent2SubtleBorder,
        ),
      ),
    );
  }
}

class _PrabhixMarkPainter extends CustomPainter {
  const _PrabhixMarkPainter({
    required this.from,
    required this.to,
    required this.ink,
    required this.second,
  });

  final Color from;
  final Color to;
  final Color ink;
  final Color second;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 36);
    const bounds = Rect.fromLTWH(0, 0, 36, 36);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, const Radius.circular(10)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [from, to],
        ).createShader(bounds),
    );
    canvas.drawPath(_letter, Paint()..color = ink);
    canvas.drawPath(_second, Paint()..color = second);
    canvas.restore();
  }

  static final Path _letter = Path()
    ..moveTo(10, 24)
    ..lineTo(10, 12)
    ..relativeLineTo(4.2, 0)
    ..relativeCubicTo(3.2, 0, 5, 1.8, 5, 3.7)
    ..relativeCubicTo(0, 1.9, -1.9, 3.8, -5, 3.8)
    ..relativeLineTo(0, 4.5)
    ..lineTo(10, 24)
    ..close()
    ..moveTo(14.2, 17.5)
    ..relativeLineTo(2, 0)
    ..relativeCubicTo(1.1, 0, 1.8, -0.6, 1.8, -1.5)
    ..relativeCubicTo(0, -0.9, -0.7, -1.5, -1.8, -1.5)
    ..relativeLineTo(-2, 0)
    ..close();

  static final Path _second = Path()
    ..moveTo(22.5, 12)
    ..relativeLineTo(3.5, 0)
    ..relativeLineTo(5, 12)
    ..relativeLineTo(-3.7, 0)
    ..relativeLineTo(-0.9, -2.3)
    ..relativeLineTo(-4.5, 0)
    ..relativeLineTo(-0.9, 2.3)
    ..lineTo(17, 24)
    ..relativeLineTo(5.5, -12)
    ..close()
    ..moveTo(24.7, 19.1)
    ..relativeLineTo(-1.5, -3.8)
    ..relativeLineTo(-1.5, 3.8)
    ..relativeLineTo(3, 0)
    ..close();

  @override
  bool shouldRepaint(covariant _PrabhixMarkPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.ink != ink ||
      oldDelegate.second != second;
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = brandColors(context);
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
              colors: [colors.accent, colors.accentHover],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'M',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.accentInk,
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
            color: colors.ink,
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
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
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
