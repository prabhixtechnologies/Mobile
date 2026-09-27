import 'package:flutter/material.dart';
import 'package:prabhix_theme/prabhix_theme.dart';

export 'package:prabhix_theme/prabhix_theme.dart';

/// MobiStack's theme, from the one source `MobiStack/web` uses.
///
/// This file used to carry two full hand-typed palettes and a 200-line [ThemeData]. Its
/// accent was `#0A8F78` where the web app's was `#0E7490` — the same product in two
/// different greens, which is the clearest example of what the token system exists to stop.
/// Both palettes and the theme are now generated from
/// `web-kit/packages/brand/tokens.json`.
///
/// MobiStack is ochre with teal as its partner accent, on warm sand surfaces, at `compact`
/// density: a counter tool is used standing up, fast, under shop lighting.
const String kBrand = 'mobistack';

/// The legacy accessor the screens are written against.
///
/// Prefer `context.px` in new code: it reads the [PxPalette] theme extension, so a widget
/// rebuilds when the theme changes and a screen can be previewed in both modes. [Px] is a
/// mutable global and can do neither; it is kept because roughly two hundred call sites use
/// it, and [syncPx] keeps it in step with the theme that is actually on screen.
abstract final class Px {
  static PxColors active = pxMobistackLight;
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

  /// The partner accent. Use it for totals, the second series in a chart, or the far end of
  /// a gradient — not for a third meaning.
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

  /// Ochre and amber share an arc, so warning in MobiStack is the tint's ink rather than the
  /// solid fill: a solid amber badge beside an ochre accent reads as the accent.
  static Color get warning => active.warningSubtleInk;

  static const motion = PxDuration.slow;
  static const curve = Curves.easeOutCubic;

  static List<BoxShadow> get lift => isDark
      ? const []
      : [
          BoxShadow(color: active.scrim.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
          BoxShadow(color: active.scrim.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1)),
        ];
}

ThemeData mobiStackTheme(Brightness brightness) =>
    prabhixTheme(brand: kBrand, brightness: brightness, density: PxDensity.compact);

/// Points [Px] at the palette of the theme that is actually on screen.
///
/// Call this from `MaterialApp.builder`, not where the themes are constructed: under
/// [ThemeMode.system] the brightness is not known until the app has an inherited theme. The
/// old code resolved it from [ThemeMode] alone, so `ThemeMode.system` on a light device
/// painted the light theme with the dark palette's colours.
void syncPx(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  Px.active = dark ? pxMobistackDark : pxMobistackLight;
  Px.isDark = dark;
}

/// The shared page transition, kept here because `PxPageTransitions` is referenced by name
/// from the router. The theme itself now supplies predictive back on Android and the
/// Cupertino transition on iOS; this stays for the routes that opt into a custom one.
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
