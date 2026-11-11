import 'package:dio/dio.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_models.dart';

class ChatApi {
  ChatApi(this.api);

  final ApiClient api;
  static const _uuid = Uuid();

  Future<List<ConversationSummary>> conversations({String queue = 'mine'}) async {
    final res = await api.dio.get<dynamic>(
      'chat/conversations',
      queryParameters: {'queue': queue, 'limit': 50},
    );
    return _list(res.data).map(ConversationSummary.fromJson).toList();
  }

  Future<Map<String, dynamic>> conversation(String id) async {
    final res = await api.dio.get<Map<String, dynamic>>(
      'chat/conversations',
      queryParameters: {'id': id},
    );
    return res.data ?? {};
  }

  Future<List<ChatMessage>> messages(String id) async {
    try {
      final res = await api.dio.get<dynamic>(
        'chat/conversations/messages',
        queryParameters: {'id': id},
      );
      return _list(res.data).map(ChatMessage.fromJson).toList();
    } catch (_) {
      final detail = await conversation(id);
      final raw = detail['messages'] as List? ?? const [];
      return raw
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Future<void> sendMessage(
    String id,
    String body, {
    bool note = false,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    await api.dio.post<void>(
      'chat/conversations/messages',
      queryParameters: {'id': id, 'note': note},
      data: {'body': body, if (note) 'internal': true},
      options: Options(headers: {'Idempotency-Key': key}),
    );
  }

  Future<void> assign(String id, String agentId) async {
    await api.dio.post<void>(
      'chat/conversations/assign',
      queryParameters: {'id': id},
      data: {'agentId': agentId},
    );
  }

  Future<void> markRead(String id) async {
    await api.dio.post<void>(
      'chat/conversations/read',
      queryParameters: {'id': id},
      data: {},
    );
  }

  Future<void> heartbeat() async {
    await api.dio.post<void>('chat/presence/heartbeat', data: {});
  }

  Future<List<CannedReply>> cannedReplies() async {
    final res = await api.dio.get<dynamic>('chat/canned-replies');
    return _list(res.data).map(CannedReply.fromJson).toList();
  }

  Future<String> aiSuggest(String conversationId) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      'chat/conversations/ai/reply/suggest',
      queryParameters: {'id': conversationId},
      data: {},
    );
    return '${res.data?['suggestion'] ?? res.data?['text'] ?? res.data?['body'] ?? ''}';
  }

  Future<String> aiRewrite(String conversationId, String draft, {String mode = 'improve'}) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      'chat/conversations/ai/rewrite',
      queryParameters: {'id': conversationId},
      data: {'draft': draft, 'mode': mode},
    );
    return '${res.data?['text'] ?? res.data?['body'] ?? res.data?['rewrite'] ?? draft}';
  }

  Future<DashboardKpis> dashboard() async {
    final res = await api.dio.get<Map<String, dynamic>>('dashboard');
    return DashboardKpis.fromJson(res.data ?? {});
  }

  Future<List<LiveVisitor>> liveVisitors() async {
    final res = await api.dio.get<dynamic>('visitors/live');
    return _list(res.data).map(LiveVisitor.fromJson).toList();
  }

  Future<VisitorDetail> visitor(String id) async {
    final res = await api.dio.get<Map<String, dynamic>>('visitors/$id');
    return VisitorDetail.fromJson(res.data ?? {});
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
