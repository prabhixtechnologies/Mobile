import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// One counter palette. [Px] points at whichever mode is on screen.
class PxPalette {
  const PxPalette({
    required this.dark,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.bg,
    required this.bgAccent,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.accent,
    required this.accentStrong,
    required this.accentInk,
    required this.focus,
    required this.danger,
    required this.success,
    required this.warning,
  });

  final bool dark;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color bg;
  final Color bgAccent;
  final Color surface;
  final Color surfaceHigh;
  final Color line;
  final Color accent;
  final Color accentStrong;
  final Color accentInk;
  final Color focus;
  final Color danger;
  final Color success;
  final Color warning;

  static const darkMode = PxPalette(
    dark: true,
    ink: Color(0xFFF3F6FA),
    muted: Color(0xFFA8B7C7),
    faint: Color(0xFF6E8296),
    bg: Color(0xFF071018),
    bgAccent: Color(0xFF123044),
    surface: Color(0xFF12202C),
    surfaceHigh: Color(0xFF1A2C3C),
    line: Color(0xFF2A3D4F),
    accent: Color(0xFF2EE6C7),
    accentStrong: Color(0xFF14B8A6),
    accentInk: Color(0xFF04221C),
    focus: Color(0xFF7DD3FC),
    danger: Color(0xFFFF8B7B),
    success: Color(0xFF3DDC97),
    warning: Color(0xFFF5C16C),
  );

  /// Daylight counter: cool air, white cards, a jewel teal.
  static const lightMode = PxPalette(
    dark: false,
    ink: Color(0xFF102028),
    muted: Color(0xFF3E5563),
    faint: Color(0xFF6D8492),
    bg: Color(0xFFE7F2F0),
    bgAccent: Color(0xFFD4F3EB),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF4F8F7),
    line: Color(0xFFD3E4E0),
    accent: Color(0xFF0A8F78),
    accentStrong: Color(0xFF067A68),
    accentInk: Color(0xFFFFFFFF),
    focus: Color(0xFF0E7490),
    danger: Color(0xFFC4322A),
    success: Color(0xFF0E8A5F),
    warning: Color(0xFFC2710C),
  );
}

abstract final class Px {
  static PxPalette active = PxPalette.darkMode;

  static Color get ink => active.ink;
  static Color get muted => active.muted;
  static Color get faint => active.faint;
  static Color get bg => active.bg;
  static Color get bgAccent => active.bgAccent;
  static Color get surface => active.surface;
  static Color get surfaceHigh => active.surfaceHigh;
  static Color get line => active.line;
  static Color get accent => active.accent;
  static Color get accentStrong => active.accentStrong;
  static Color get accentInk => active.accentInk;
  static Color get focus => active.focus;
  static Color get danger => active.danger;
  static Color get success => active.success;
  static Color get warning => active.warning;

  static bool get isDark => active.dark;

  static List<BoxShadow> get lift => isDark
      ? const []
      : const [
          BoxShadow(
            color: Color(0x14064E45),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0A064E45),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ];

  static const motion = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;
}

ThemeData buildMobiStackTheme(PxPalette palette) {
  final base = palette.dark ? ThemeData.dark() : ThemeData.light();
  final display = GoogleFonts.frauncesTextTheme(base.textTheme);
  final body = GoogleFonts.sourceSans3TextTheme(base.textTheme);

  final textTheme = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -1.2,
      height: 1.05,
    ),
    displayMedium: display.displayMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -0.8,
      height: 1.08,
    ),
    headlineLarge: display.headlineLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -0.6,
      height: 1.1,
    ),
    headlineMedium: display.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -0.4,
      height: 1.15,
    ),
    headlineSmall: display.headlineSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -0.2,
    ),
    titleLarge: body.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
      letterSpacing: -0.2,
    ),
    titleMedium: body.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: palette.ink,
    ),
    bodyLarge: body.bodyLarge?.copyWith(color: palette.ink, height: 1.45),
    bodyMedium: body.bodyMedium?.copyWith(color: palette.muted, height: 1.45),
    bodySmall: body.bodySmall?.copyWith(color: palette.faint, height: 1.4),
    labelLarge: body.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: palette.ink,
    ),
  );

  final radius = BorderRadius.circular(16);
  final fieldBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: palette.line),
  );
  final scheme = palette.dark
      ? ColorScheme.dark(
          primary: palette.accent,
          onPrimary: palette.accentInk,
          secondary: palette.focus,
          onSecondary: palette.accentInk,
          surface: palette.surface,
          onSurface: palette.ink,
          error: palette.danger,
          outline: palette.line,
        )
      :       ColorScheme.light(
          primary: palette.accent,
          onPrimary: palette.accentInk,
          secondary: palette.focus,
          onSecondary: palette.accentInk,
          secondaryContainer: palette.bgAccent,
          onSecondaryContainer: palette.accentStrong,
          surface: palette.surface,
          onSurface: palette.ink,
          error: palette.danger,
          outline: palette.line,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: palette.dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: palette.bg,
    canvasColor: palette.bg,
    colorScheme: scheme,
    textTheme: textTheme,
    iconTheme: IconThemeData(color: palette.ink),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: palette.ink,
        backgroundColor: palette.dark ? Colors.transparent : palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: palette.ink,
      systemOverlayStyle: palette.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: palette.ink,
        fontSize: 22,
      ),
    ),
    dividerTheme: DividerThemeData(color: palette.line, thickness: 1, space: 1),
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PxPageTransitions(),
        TargetPlatform.iOS: PxPageTransitions(),
        TargetPlatform.linux: PxPageTransitions(),
        TargetPlatform.macOS: PxPageTransitions(),
        TargetPlatform.windows: PxPageTransitions(),
      },
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceHigh,
      hintStyle: TextStyle(color: palette.faint),
      labelStyle: TextStyle(color: palette.muted),
      floatingLabelStyle: TextStyle(color: palette.accent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: palette.accent, width: 1.4),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titleTextStyle: display.titleLarge?.copyWith(
        color: palette.ink,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.surfaceHigh,
      contentTextStyle: body.bodyMedium?.copyWith(color: palette.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.accentInk,
        textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: palette.accent),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accent,
      foregroundColor: palette.accentInk,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.surface,
      selectedColor: palette.accent,
      labelStyle: body.labelLarge?.copyWith(color: palette.ink, fontSize: 12),
      secondaryLabelStyle: body.labelLarge?.copyWith(color: palette.accentInk, fontSize: 12),
      side: BorderSide(color: palette.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return palette.accentInk;
        return palette.faint;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return palette.accent;
        return palette.surfaceHigh;
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: palette.accent,
      textColor: palette.ink,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.accent),
  );
}

ThemeData buildPrabhixAdminTheme() => buildMobiStackTheme(PxPalette.darkMode);

class PxPageTransitions extends PageTransitionsBuilder {
  const PxPageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Px.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
