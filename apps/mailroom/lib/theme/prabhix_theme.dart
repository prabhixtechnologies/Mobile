import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Prabhix Mailroom — brand-led, not a Gmail/Outlook clone.
abstract final class Px {
  static const ink = Color(0xFF0C1524);
  static const muted = Color(0xFF5B6B7C);
  static const faint = Color(0xFF8A9AAB);
  static const bg = Color(0xFFF3F6FB);
  static const bgAccent = Color(0xFFDCE9F7);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFD5DEE8);
  static const accent = Color(0xFF0E7490);
  static const accentStrong = Color(0xFF0F766E);
  static const accentInk = Color(0xFFF0FDFA);
  static const focus = Color(0xFF0891B2);
  static const danger = Color(0xFFB42318);
  static const success = Color(0xFF067647);
  static const warning = Color(0xFFB45309);

  static const motion = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;
}

ThemeData buildPrabhixAdminTheme() {
  final display = GoogleFonts.frauncesTextTheme();
  final body = GoogleFonts.sourceSans3TextTheme();

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -1.2,
      height: 1.05,
    ),
    displayMedium: display.displayMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -0.8,
      height: 1.08,
    ),
    headlineLarge: display.headlineLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -0.6,
      height: 1.1,
    ),
    headlineMedium: display.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineSmall: display.headlineSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -0.2,
    ),
    titleLarge: body.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
      letterSpacing: -0.2,
    ),
    titleMedium: body.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Px.ink,
    ),
    bodyLarge: body.bodyLarge?.copyWith(color: Px.ink, height: 1.45),
    bodyMedium: body.bodyMedium?.copyWith(color: Px.muted, height: 1.45),
    bodySmall: body.bodySmall?.copyWith(color: Px.faint, height: 1.4),
    labelLarge: body.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: Px.ink,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Px.bg,
    colorScheme: const ColorScheme.light(
      primary: Px.accent,
      onPrimary: Px.accentInk,
      secondary: Px.focus,
      onSecondary: Px.accentInk,
      surface: Px.surface,
      onSurface: Px.ink,
      error: Px.danger,
      outline: Px.line,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Px.ink,
      titleTextStyle: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: Px.ink,
        fontSize: 22,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Px.surface.withValues(alpha: 0.92),
      indicatorColor: Px.bgAccent,
      labelTextStyle: WidgetStatePropertyAll(
        body.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    dividerTheme: const DividerThemeData(color: Px.line, thickness: 1, space: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    splashFactory: InkSparkle.splashFactory,
  );
}
