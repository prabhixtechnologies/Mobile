/// Prabhix design tokens and Material 3 themes for all four Flutter apps.
///
/// The colour values, scales and type roles in `src/prabhix_tokens.dart` are
/// generated from `web-kit/packages/brand/tokens.json` — the same file the web
/// apps build their CSS from. That is what stops mobile and web drifting.
///
/// Usage:
///
/// ```dart
/// MaterialApp.router(
///   theme: prabhixTheme(brand: 'mobistack', brightness: Brightness.light, density: PxDensity.compact),
///   darkTheme: prabhixTheme(brand: 'mobistack', brightness: Brightness.dark, density: PxDensity.compact),
///   themeMode: ThemeMode.system,
/// )
/// ```
///
/// Then read colours from the context, never from a global:
///
/// ```dart
/// Container(color: context.px.surfaceSelected)
/// ```
library;

export 'src/prabhix_tokens.dart';
export 'src/px_theme.dart';
