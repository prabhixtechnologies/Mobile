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
      apiBaseUrl: state.config.apiHostBase,
      product: TelemetryProduct.mailroom,
      appVersion: '1.1.10',
      getAccessToken: () => state.identity.refreshIfNeeded(),
    ),
  );
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MailroomApp(),
    ),
  );
  // ignore: unawaited_futures
  state.bootstrap();
}
