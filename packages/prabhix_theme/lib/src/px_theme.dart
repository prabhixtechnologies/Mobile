// CupertinoPageTransitionsBuilder lives in src/cupertino/route.dart and material.dart does
// not re-export it, so the iOS page transition needs this import explicitly.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// SystemUiOverlayStyle for the status bar; not re-exported by material.dart either.
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'prabhix_tokens.dart';

/// Density mode. MobiStack's counter and the Admin console default to [compact];
/// see `themes` in `web-kit/packages/brand/tokens.json`.
enum PxDensity {
  comfortable(row: 44, control: 40, padX: 16, padY: 10),
  compact(row: 34, control: 32, padX: 10, padY: 6);

  const PxDensity({
    required this.row,
    required this.control,
    required this.padX,
    required this.padY,
  });

  final double row;
  final double control;
  final double padX;
  final double padY;

  VisualDensity get visual =>
      this == PxDensity.compact ? const VisualDensity(horizontal: -1, vertical: -1) : VisualDensity.standard;
}

/// The 49 semantic colour roles, reachable from any widget through
/// `Theme.of(context).extension<PxPalette>()` or the [PxContext.px] shorthand.
///
/// This exists so no widget reads a mutable global. A theme change rebuilds
/// through the normal inherited-widget path and animates between palettes.
@immutable
class PxPalette extends ThemeExtension<PxPalette> {
  const PxPalette({required this.colors, required this.density});

  final PxColors colors;
  final PxDensity density;

  @override
  PxPalette copyWith({PxColors? colors, PxDensity? density}) =>
      PxPalette(colors: colors ?? this.colors, density: density ?? this.density);

  @override
  PxPalette lerp(ThemeExtension<PxPalette>? other, double t) {
    if (other is! PxPalette) return this;
    return PxPalette(
      colors: colors.lerpTo(other.colors, t),
      density: t < 0.5 ? density : other.density,
    );
  }
}

extension PxContext on BuildContext {
  /// The active product palette. Throws in debug if the app forgot to install
  /// a Prabhix theme, which is better than silently rendering the wrong brand.
  PxColors get px => Theme.of(this).extension<PxPalette>()!.colors;

  PxDensity get pxDensity => Theme.of(this).extension<PxPalette>()!.density;
}

FontWeight _w(int weight) => FontWeight.values.firstWhere(
      (f) => f.value == weight,
      orElse: () => FontWeight.w400,
    );

/// Builds the Material 3 theme for one product in one mode.
///
/// `brand` is the same key the web uses in `[data-brand]`: `technologies`,
/// `oneops`, `admin`, `mobistack`, `mailroom`.
ThemeData prabhixTheme({
  required String brand,
  required Brightness brightness,
  PxDensity density = PxDensity.comfortable,
}) {
  final theme = pxThemes[brand];
  assert(theme != null, 'unknown brand "$brand" — see pxThemes in prabhix_tokens.dart');
  final c = brightness == Brightness.dark ? theme!.dark : theme!.light;

  final display = GoogleFonts.fraunces();
  final body = GoogleFonts.sourceSans3();

  TextStyle role(
    double size,
    double height,
    int weight,
    double tracking, {
    bool serif = false,
    Color? color,
  }) =>
      (serif ? display : body).copyWith(
        fontSize: size,
        height: height,
        fontWeight: _w(weight),
        letterSpacing: tracking,
        color: color ?? c.ink,
      );

  final text = TextTheme(
    displayLarge: role(PxType.displaySize, PxType.displayHeight, PxType.displayWeight, PxType.displayTracking, serif: true),
    displayMedium: role(PxType.titleLgSize, PxType.titleLgHeight, PxType.titleLgWeight, PxType.titleLgTracking, serif: true),
    displaySmall: role(PxType.titleLgSize, PxType.titleLgHeight, PxType.titleLgWeight, PxType.titleLgTracking, serif: true),
    headlineLarge: role(PxType.titleLgSize, PxType.titleLgHeight, PxType.titleLgWeight, PxType.titleLgTracking, serif: true),
    headlineMedium: role(PxType.titleMdSize, PxType.titleMdHeight, PxType.titleMdWeight, PxType.titleMdTracking),
    headlineSmall: role(PxType.titleMdSize, PxType.titleMdHeight, PxType.titleMdWeight, PxType.titleMdTracking),
    titleLarge: role(PxType.titleMdSize, PxType.titleMdHeight, PxType.titleMdWeight, PxType.titleMdTracking),
    titleMedium: role(PxType.titleSmSize, PxType.titleSmHeight, PxType.titleSmWeight, PxType.titleSmTracking),
    titleSmall: role(PxType.labelSize, PxType.labelHeight, PxType.labelWeight, PxType.labelTracking),
    bodyLarge: role(PxType.bodyLgSize, PxType.bodyLgHeight, PxType.bodyLgWeight, PxType.bodyLgTracking),
    bodyMedium: role(PxType.bodyMdSize, PxType.bodyMdHeight, PxType.bodyMdWeight, PxType.bodyMdTracking),
    bodySmall: role(PxType.bodySmSize, PxType.bodySmHeight, PxType.bodySmWeight, PxType.bodySmTracking, color: c.inkMuted),
    labelLarge: role(PxType.labelSize, PxType.labelHeight, PxType.labelWeight, PxType.labelTracking),
    labelMedium: role(PxType.captionSize, PxType.captionHeight, PxType.captionWeight, PxType.captionTracking, color: c.inkMuted),
    labelSmall: role(PxType.overlineSize, PxType.overlineHeight, PxType.overlineWeight, PxType.overlineTracking, color: c.inkMuted),
  );

  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: c.accentInk,
    primaryContainer: c.accentSubtle,
    onPrimaryContainer: c.accentSubtleInk,
    secondary: c.info,
    onSecondary: c.infoInk,
    secondaryContainer: c.infoSubtle,
    onSecondaryContainer: c.infoSubtleInk,
    tertiary: c.success,
    onTertiary: c.successInk,
    tertiaryContainer: c.successSubtle,
    onTertiaryContainer: c.successSubtleInk,
    error: c.danger,
    onError: c.dangerInk,
    errorContainer: c.dangerSubtle,
    onErrorContainer: c.dangerSubtleInk,
    surface: c.surface,
    onSurface: c.ink,
    surfaceDim: c.surfaceSunken,
    surfaceBright: c.surfaceRaised,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surfaceSunken,
    surfaceContainer: c.bg,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.surfaceRaised,
    onSurfaceVariant: c.inkMuted,
    outline: c.borderStrong,
    outlineVariant: c.border,
    scrim: c.scrim,
    shadow: c.scrim,
    inverseSurface: c.ink,
    onInverseSurface: c.surface,
    inversePrimary: c.accentSubtle,
  );

  final radius = BorderRadius.circular(PxRadius.lg);

  // Control borders use borderStrong, which the token build asserts at 3:1.
  // `border` is for dividers only and is deliberately below that.
  OutlineInputBorder inputBorder(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(PxRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    textTheme: text,
    visualDensity: density.visual,
    extensions: [PxPalette(colors: c, density: density)],
    dividerColor: c.border,
    dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
      systemOverlayStyle:
          brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: c.border)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: density.padX, vertical: density.padY + 2),
      border: inputBorder(c.borderStrong, 1),
      enabledBorder: inputBorder(c.borderStrong, 1),
      focusedBorder: inputBorder(c.focus, 2),
      errorBorder: inputBorder(c.danger, 1),
      focusedErrorBorder: inputBorder(c.danger, 2),
      disabledBorder: inputBorder(c.border, 1),
      labelStyle: text.labelLarge?.copyWith(color: c.inkMuted),
      hintStyle: text.bodyMedium?.copyWith(color: c.inkFaint),
      errorStyle: text.bodySmall?.copyWith(color: c.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: c.accentInk,
        disabledBackgroundColor: c.accentDisabled,
        disabledForegroundColor: c.inkDisabled,
        minimumSize: Size(0, density.control + 4),
        padding: EdgeInsets.symmetric(horizontal: density.padX + 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PxRadius.md)),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.ink,
        side: BorderSide(color: c.borderStrong),
        minimumSize: Size(0, density.control + 4),
        padding: EdgeInsets.symmetric(horizontal: density.padX + 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PxRadius.md)),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.accent,
        minimumSize: Size(0, density.control),
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.inkMuted,
        // 48dp minimum, per UX-STANDARD 3.1. Do not shrink primary actions.
        minimumSize: const Size(48, 48),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: c.inkMuted,
      textColor: c.ink,
      minVerticalPadding: density.padY,
      contentPadding: EdgeInsets.symmetric(horizontal: density.padX),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PxRadius.md)),
      selectedTileColor: c.surfaceSelected,
      selectedColor: c.accent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceSunken,
      selectedColor: c.accentSubtle,
      side: BorderSide(color: c.border),
      labelStyle: text.labelMedium?.copyWith(color: c.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PxRadius.full)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: c.border)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(PxRadius.xl)),
      ),
      showDragHandle: true,
      dragHandleColor: c.border,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.surface),
      actionTextColor: c.accentSubtle,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PxRadius.md)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.accentSubtle,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? c.accent : c.inkMuted,
        ),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.accent,
      linearTrackColor: c.surfaceSunken,
      circularTrackColor: c.surfaceSunken,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(PxRadius.sm),
      ),
      textStyle: text.bodySmall?.copyWith(color: c.surface),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
