import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:prabhix_identity/prabhix_identity.dart';

typedef SseEventHandler = void Function(String event, String data);

/// Minimal SSE client for `GET /chat/stream` with exponential backoff.
class ChatSseClient {
  ChatSseClient({
    required this.streamUrl,
    required this.identity,
    required this.orgHeaderName,
    required this.deviceHeaderName,
    required this.deviceHeader,
  });

  final String streamUrl;
  final IdentityClient identity;
  final String orgHeaderName;
  final String deviceHeaderName;
  final String deviceHeader;

  http.Client? _client;
  StreamSubscription<String>? _sub;
  bool _stopped = false;
  int _attempt = 0;

  Future<void> start(SseEventHandler onEvent) async {
    _stopped = false;
    while (!_stopped) {
      try {
        await _connect(onEvent);
        _attempt = 0;
      } catch (_) {
        if (_stopped) return;
        final delay = Duration(milliseconds: (500 * (1 << _attempt.clamp(0, 5))).toInt());
        _attempt++;
        await Future<void>.delayed(delay);
      }
    }
  }

  Future<void> _connect(SseEventHandler onEvent) async {
    await stop(permanent: false);
    final token = await identity.refreshIfNeeded();
    final session = await identity.tokenStore.session();
    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (token != null) 'Authorization': 'Bearer $token',
      deviceHeaderName: await identity.tokenStore.deviceId(),
      'X-Prabhix-Device-Label': deviceHeader,
      if (session?.organizationId != null) orgHeaderName: session!.organizationId!,
    };
    _client = http.Client();
    final request = http.Request('GET', Uri.parse(streamUrl))..headers.addAll(headers);
    final response = await _client!.send(request);
    if (response.statusCode != 200) {
      throw StateError('SSE HTTP ${response.statusCode}');
    }

    var event = 'message';
    final dataBuf = StringBuffer();
    final completer = Completer<void>();

    _sub = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        if (line.startsWith('event:')) {
          event = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          if (dataBuf.isNotEmpty) dataBuf.write('\n');
          dataBuf.write(line.substring(5).trimLeft());
        } else if (line.isEmpty) {
          final data = dataBuf.toString();
          dataBuf.clear();
          if (data.isNotEmpty) onEvent(event, data);
          event = 'message';
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    await completer.future;
  }

  Future<void> stop({bool permanent = true}) async {
    if (permanent) _stopped = true;
    await _sub?.cancel();
    _sub = null;
    _client?.close();
    _client = null;
  }
}
