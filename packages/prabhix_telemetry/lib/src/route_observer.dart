import 'package:flutter/widgets.dart';

import 'telemetry.dart';

/// Emits `screen_view` for Navigator route changes that carry a [RouteSettings.name].
class TelemetryNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _track(newRoute);
    }
  }

  void _track(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) {
      return;
    }
    track('screen_view', {'screen': name});
  }
}

/// Path-based screen_view for GoRouter (routes often have no RouteSettings.name).
mixin TelemetryGoRouterTracking {
  String? _lastTelemetryPath;

  void trackGoRouterPath(String path) {
    if (path.isEmpty || path == _lastTelemetryPath) {
      return;
    }
    _lastTelemetryPath = path;
    track('screen_view', {'screen': path});
  }
}
