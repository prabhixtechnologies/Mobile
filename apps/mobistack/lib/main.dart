import 'package:flutter/material.dart';
import 'package:prabhix_telemetry/prabhix_telemetry.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(config: AppConfig.fromEnvironment());
  configureTelemetry(
    TelemetryConfig(
      apiBaseUrl: state.config.telemetryApiHostBase,
      product: TelemetryProduct.mobistack,
      appVersion: '1.3.42',
      getAccessToken: () => state.identity.refreshIfNeeded(),
    ),
  );
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MobiStackApp(),
    ),
  );
  // ignore: unawaited_futures
  state.bootstrap();
}
