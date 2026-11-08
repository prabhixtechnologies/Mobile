typedef AccessTokenProvider = Future<String?> Function();

/// Product ids accepted by POST /api/v1/telemetry/batch.
enum TelemetryProduct {
  oneops,
  admin,
  mailroom,
  mobistack,
  identity,
}

enum TelemetrySurface {
  web,
  android,
  ios,
}

class TelemetryConfig {
  const TelemetryConfig({
    required this.apiBaseUrl,
    required this.product,
    this.surface,
    this.appVersion,
    this.getAccessToken,
    this.enabled = true,
    this.maxQueue = 5000,
  });

  final String apiBaseUrl;
  final TelemetryProduct product;
  final TelemetrySurface? surface;
  final String? appVersion;
  final AccessTokenProvider? getAccessToken;
  final bool enabled;
  final int maxQueue;

  String get productId => product.name;
}
