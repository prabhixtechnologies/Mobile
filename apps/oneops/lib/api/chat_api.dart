import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../models/chat_models.dart';

class ChatApi {
  ChatApi(this.api);

  final ApiClient api;

  Future<List<ConversationSummary>> conversations({String queue = 'mine'}) async {
    final res = await api.dio.get<dynamic>(
      'chat/conversations',
      queryParameters: {'queue': queue, 'limit': 50},
    );
    return _list(res.data).map(ConversationSummary.fromJson).toList();
  }

  Future<Map<String, dynamic>> conversation(String id) async {
    final res = await api.dio.get<Map<String, dynamic>>('chat/conversations/$id');
    return res.data ?? {};
  }

  Future<List<ChatMessage>> messages(String id) async {
    try {
      final res = await api.dio.get<dynamic>('chat/conversations/$id/messages');
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

  Future<void> sendMessage(String id, String body, {bool note = false}) async {
    await api.dio.post<void>(
      'chat/conversations/$id/messages',
      queryParameters: {'note': note},
      data: {'body': body, if (note) 'internal': true},
    );
  }

  Future<void> assign(String id, String agentId) async {
    await api.dio.post<void>(
      'chat/conversations/$id/assign',
      data: {'agentId': agentId},
    );
  }

  Future<List<CannedReply>> cannedReplies() async {
    final res = await api.dio.get<dynamic>('chat/canned-replies');
    return _list(res.data).map(CannedReply.fromJson).toList();
  }

  Future<String> aiSuggest(String conversationId) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      'chat/conversations/$conversationId/ai/suggest',
      data: {},
    );
    return '${res.data?['suggestion'] ?? res.data?['text'] ?? res.data?['body'] ?? ''}';
  }

  Future<String> aiRewrite(String conversationId, String draft, {String mode = 'improve'}) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      'chat/conversations/$conversationId/ai/rewrite',
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
