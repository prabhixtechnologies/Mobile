import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(config: AppConfig.fromEnvironment());
  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const MailroomApp(),
    ),
  );
  // ignore: unawaited_futures
  state.bootstrap();
}
