import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'cadence.dart';
import 'queue_store.dart';
import 'scrub.dart';
import 'telemetry_config.dart';

/// Local-queue product analytics. [track] never awaits the network.
///
/// Upload cadence uses connectivity + app-resume hooks (same approach as
/// [prabhix_offline]): Workmanager is incompatible with the current Flutter
/// Android embedding. Policy remains 24h after success / 1h after failure.
class Telemetry with WidgetsBindingObserver {
  Telemetry(this.config, {TelemetryQueueStore? store, http.Client? httpClient})
      : _store = store ?? TelemetryQueueStore('${config.productId}_telemetry.db'),
        _http = httpClient ?? http.Client();

  final TelemetryConfig config;
  final TelemetryQueueStore _store;
  final http.Client _http;
  final _uuid = const Uuid();

  TelemetryMeta? _meta;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _started = false;
  bool _flushing = false;

  Future<void> start() async {
    if (_started || !config.enabled) {
      return;
    }
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _meta = await _store.loadMeta();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      unawaited(maybeFlush());
    });
    unawaited(maybeFlush());
  }

  Future<void> dispose() async {
    if (!_started) {
      return;
    }
    WidgetsBinding.instance.removeObserver(this);
    await _connectivitySub?.cancel();
    _http.close();
    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(maybeFlush());
    }
  }

  /// Enqueue only. Never throws into product code.
  void track(String name, [Map<String, Object?> props = const {}]) {
    if (!config.enabled) {
      return;
    }
    unawaited(_enqueue(name, props));
  }

  Future<void> flushNow() => maybeFlush(force: true);

  Future<void> _enqueue(String name, Map<String, Object?> props) async {
    try {
      if (!isAllowedEventName(name)) {
        return;
      }
      final meta = await _ensureMeta();
      await _store.enqueue(
        QueuedEvent(
          id: _uuid.v4(),
          name: name,
          occurredAt: DateTime.now().toUtc(),
          sessionId: meta.sessionId,
          props: scrubProps(props),
        ),
        config.maxQueue,
      );
    } catch (e, st) {
      debugPrint('telemetry enqueue ignored: $e\n$st');
    }
  }

  Future<TelemetryMeta> _ensureMeta() async {
    return _meta ??= await _store.loadMeta();
  }

  Future<void> maybeFlush({bool force = false}) async {
    if (!config.enabled || _flushing) {
      return;
    }
    _flushing = true;
    try {
      final meta = await _ensureMeta();
      final policy = FlushPolicyState(
        lastSuccessAt: meta.lastSuccessAt,
        lastFailureAt: meta.lastFailureAt,
        lastAttemptAt: meta.lastAttemptAt,
      );
      final now = DateTime.now();
      if (!force && !shouldFlush(policy, now)) {
        return;
      }

      final events = await _store.peek(200);
      if (events.isEmpty) {
        meta.lastSuccessAt = now;
        meta.lastFailureAt = null;
        meta.lastAttemptAt = now;
        await _store.saveMeta(meta);
        return;
      }

      final surface = (config.surface ?? _defaultSurface()).name;
      final body = {
        'installId': meta.installId,
        'product': config.productId,
        'surface': surface,
        'appVersion': config.appVersion,
        'events': events.map((e) => e.toJson()).toList(),
      };

      final uri = Uri.parse(
        '${config.apiBaseUrl.replaceAll(RegExp(r'/$'), '')}/api/v1/telemetry/batch',
      );
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final token = config.getAccessToken == null
          ? null
          : await config.getAccessToken!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 8));

      meta.lastAttemptAt = now;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _store.remove(events.map((e) => e.id).toList());
        meta.lastSuccessAt = now;
        meta.lastFailureAt = null;
      } else {
        meta.lastFailureAt = now;
      }
      await _store.saveMeta(meta);
    } catch (e, st) {
      debugPrint('telemetry flush ignored: $e\n$st');
      try {
        final meta = await _ensureMeta();
        meta.lastAttemptAt = DateTime.now();
        meta.lastFailureAt = meta.lastAttemptAt;
        await _store.saveMeta(meta);
      } catch (_) {}
    } finally {
      _flushing = false;
    }
  }

  TelemetrySurface _defaultSurface() {
    if (kIsWeb) {
      return TelemetrySurface.web;
    }
    if (Platform.isIOS) {
      return TelemetrySurface.ios;
    }
    return TelemetrySurface.android;
  }
}

Telemetry? _singleton;

Telemetry? get telemetry => _singleton;

Telemetry configureTelemetry(TelemetryConfig config) {
  _singleton = Telemetry(config);
  unawaited(_singleton!.start());
  return _singleton!;
}

void track(String name, [Map<String, Object?> props = const {}]) {
  _singleton?.track(name, props);
}
