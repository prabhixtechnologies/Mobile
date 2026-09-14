import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../models/inbox_models.dart';

/// Helpdesk inbox on `/mail/threads` — read, reply, assign.
class InboxApi {
  InboxApi(this.api);

  final ApiClient api;

  Future<List<InboxTicket>> tickets({String? status}) async {
    final res = await api.dio.get<dynamic>(
      'mail/threads',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': 50,
      },
    );
    return _list(res.data).map(InboxTicket.fromJson).toList();
  }

  Future<({InboxTicket ticket, List<InboxMessage> messages})> ticket(
    String id,
  ) async {
    final res = await api.dio.get<Map<String, dynamic>>('mail/threads/$id');
    final data = res.data ?? {};
    final ticket = InboxTicket.fromJson(data);
    final messages = _list(data['messages']).map(InboxMessage.fromJson).toList();
    return (ticket: ticket, messages: messages);
  }

  Future<void> reply({required String threadId, required String body}) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/reply',
      data: {
        'replyMode': 'REPLY',
        'bodyHtml': body.replaceAll('\n', '<br/>'),
        'bodyText': body,
      },
    );
  }

  Future<void> assign({required String threadId, required String userId}) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/assign',
      data: {'userId': userId},
    );
  }

  Future<List<OrderRow>> orders() async {
    final res = await api.dio.get<dynamic>('commerce/orders', queryParameters: {'limit': 50});
    return _list(res.data).map(OrderRow.fromJson).toList();
  }

  Future<void> fulfill(String orderId) async {
    await api.dio.post<void>('commerce/orders/$orderId/fulfill', data: {});
  }

  Future<List<MemberRow>> members(String orgId) async {
    final res = await api.dio.get<dynamic>(
      'organizations/$orgId/members',
      queryParameters: {'limit': 50},
    );
    return _list(res.data).map(MemberRow.fromJson).toList();
  }

  Future<void> invite({required String email, required String roleId}) async {
    await api.dio.post<void>('invites', data: {'email': email, 'roleId': roleId});
  }

  Future<String?> firstRoleId() async {
    final res = await api.dio.get<dynamic>('roles');
    final roles = _list(res.data);
    if (roles.isEmpty) return null;
    return '${roles.first['id']}';
  }

  Future<Map<String, dynamic>> profile() async {
    final res = await api.dio.get<Map<String, dynamic>>('users/me');
    return res.data ?? {};
  }

  Future<void> updateNotificationPrefs({
    required bool email,
    required bool push,
  }) async {
    await api.dio.patch<void>(
      'users/me/notification-prefs',
      data: {
        'preferences': {'email': email, 'push': push},
      },
    );
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : (data is Map && data['content'] is List)
                ? data['content'] as List
                : const [];
    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
