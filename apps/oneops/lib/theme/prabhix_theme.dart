import 'package:flutter/material.dart';
import 'package:prabhix_theme/prabhix_theme.dart';

export 'package:prabhix_theme/prabhix_theme.dart';

/// OneOps' theme, from the one source the web consoles use.
///
/// This file used to carry eleven hand-typed `Color` constants and a light-only
/// [ThemeData]. Both are now generated from `web-kit/packages/brand/tokens.json`, so the app
/// and `oneOps/web` cannot drift apart, dark mode exists, and every colour pair has been
/// contrast-checked by the token build.
///
/// OneOps is indigo with fuchsia as its partner accent.
const String kBrand = 'oneops';

/// The legacy accessor the screens are written against.
///
/// Prefer `context.px` in new code: it reads the [PxPalette] theme extension, so a widget
/// rebuilds when the theme changes and a screen can be previewed in both modes. [Px] is a
/// mutable global and can do neither; it is kept because roughly a hundred call sites use
/// it, and [syncPx] keeps it in step with the theme that is actually on screen.
///
/// These are colours that change with the theme, so they are getters rather than constants:
/// `const TextStyle(color: Px.danger)` will not compile, and should not.
abstract final class Px {
  static PxColors active = pxOneopsLight;
  static bool isDark = false;

  static Color get ink => active.ink;
  static Color get muted => active.inkMuted;
  static Color get faint => active.inkFaint;
  static Color get bg => active.bg;
  static Color get bgAccent => active.bgAccent;
  static Color get surface => active.surface;
  static Color get surfaceHigh => active.surfaceRaised;
  static Color get line => active.border;

  /// Anything that identifies a control rather than separating two rows needs this: it is
  /// asserted at 3:1 against the surface, which [line] deliberately is not.
  static Color get lineStrong => active.borderStrong;

  static Color get accent => active.accent;
  static Color get accentStrong => active.accentHover;
  static Color get accentInk => active.accentInk;

  /// The partner accent. Use it for the second series in a chart, a secondary call to
  /// action, or the far end of a gradient — not for a third meaning.
  static Color get accent2 => active.accent2;
  static Color get accent2Ink => active.accent2Ink;

  /// The shadow/overlay colour. Near-black in light mode, but a deepened brand hue in
  /// dark mode, so a shadow written against it does not turn grey in the dark theme.
  static Color get scrim => active.scrim;

  static Color get focus => active.focus;
  static Color get surfaceSunken => active.surfaceSunken;

  /// The tinted status pairs. Each ink is asserted at 4.5:1 on its own subtle fill, which
  /// is why a tinted chip must take both from the same family rather than mixing a tint
  /// with the solid ink.
  static Color get accentSubtle => active.accentSubtle;
  static Color get accentSubtleInk => active.accentSubtleInk;
  static Color get accentSubtleBorder => active.accentSubtleBorder;
  static Color get warningSubtle => active.warningSubtle;
  static Color get warningSubtleInk => active.warningSubtleInk;
  static Color get warningSubtleBorder => active.warningSubtleBorder;
  static Color get dangerSubtle => active.dangerSubtle;
  static Color get dangerSubtleInk => active.dangerSubtleInk;
  static Color get successSubtle => active.successSubtle;
  static Color get successSubtleInk => active.successSubtleInk;
  static Color get dangerInk => active.dangerInk;

  static Color get danger => active.danger;
  static Color get success => active.success;
  static Color get warning => active.warning;

  static const motion = PxDuration.slow;
  static const curve = Curves.easeOutCubic;

  static List<BoxShadow> get lift => isDark
      ? const []
      : [
          BoxShadow(color: active.scrim.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
          BoxShadow(color: active.scrim.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        ];
}

ThemeData oneOpsTheme(Brightness brightness) => prabhixTheme(brand: kBrand, brightness: brightness);

/// Points [Px] at the palette of the theme that is actually on screen.
///
/// Call this from `MaterialApp.builder`, not where the themes are constructed: under
/// [ThemeMode.system] the brightness is not known until the app has an inherited theme, and
/// pointing [Px] at the light palette while the dark theme paints is how the old apps ended
/// up with light-mode text on dark cards.
void syncPx(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  Px.active = dark ? pxOneopsDark : pxOneopsLight;
  Px.isDark = dark;
}
