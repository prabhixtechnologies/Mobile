import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../models/mail_models.dart';

/// Mailbox + helpdesk API surface on top of [ApiClient.dio].
class MailApi {
  MailApi(this.api);

  final ApiClient api;

  Future<List<MailboxSummary>> mailboxes() async {
    final res = await api.dio.get<dynamic>('mailbox');
    return _list(res.data).map(MailboxSummary.fromJson).toList();
  }

  Future<List<MailFolder>> foldersForMailbox(String mailboxId) async {
    final res = await api.dio.get<dynamic>('mailbox/$mailboxId/folders');
    return _list(res.data).map(MailFolder.fromJson).toList();
  }

  /// Flatten folders from sidebar mailboxes; prefer `mine` first.
  Future<({List<MailboxSummary> mailboxes, List<MailFolder> folders})>
      sidebar() async {
    final boxes = await mailboxes();
    boxes.sort((a, b) {
      if (a.mine == b.mine) return a.name.compareTo(b.name);
      return a.mine ? -1 : 1;
    });
    final folders = <MailFolder>[
      for (final box in boxes) ...box.folders,
    ];
    if (folders.isEmpty && boxes.isNotEmpty) {
      for (final box in boxes) {
        folders.addAll(await foldersForMailbox(box.id));
      }
    }
    return (mailboxes: boxes, folders: folders);
  }

  Future<List<MailThreadSummary>> folderThreads(String folderId) async {
    final res = await api.dio.get<dynamic>(
      'mailbox/folders/$folderId/threads',
      queryParameters: {'limit': 100},
    );
    return _list(res.data).map(MailThreadSummary.fromJson).toList();
  }

  Future<List<MailThreadSummary>> starred() async {
    final res = await api.dio.get<dynamic>('mailbox/starred');
    return _list(res.data).map(MailThreadSummary.fromJson).toList();
  }

  Future<MailThreadSummary?> threadSummary(String threadId) async {
    try {
      final res =
          await api.dio.get<Map<String, dynamic>>('mailbox/threads/$threadId');
      return MailThreadSummary.fromJson(res.data ?? {});
    } catch (_) {
      final res =
          await api.dio.get<Map<String, dynamic>>('mail/threads/$threadId');
      final thread = res.data?['thread'];
      if (thread is Map) {
        return MailThreadSummary.fromJson(Map<String, dynamic>.from(thread));
      }
      return MailThreadSummary.fromJson(res.data ?? {});
    }
  }

  Future<List<MailMessage>> threadMessages(String threadId) async {
    try {
      final res =
          await api.dio.get<dynamic>('mailbox/threads/$threadId/messages');
      return _list(res.data).map(MailMessage.fromJson).toList();
    } catch (_) {
      final detail = await helpdeskThread(threadId);
      return detail.messages;
    }
  }

  Future<MailThreadSummary> patchFlags({
    required String threadId,
    bool? read,
    bool? starred,
  }) async {
    final res = await api.dio.patch<Map<String, dynamic>>(
      'mailbox/threads/$threadId/flags',
      data: {
        if (read != null) 'read': read,
        if (starred != null) 'starred': starred,
      },
    );
    return MailThreadSummary.fromJson(res.data ?? {});
  }

  Future<void> moveThreads({
    required String folderId,
    required List<String> threadIds,
  }) async {
    await api.dio.post<void>(
      'mailbox/folders/$folderId/move',
      data: {'threadIds': threadIds},
    );
  }

  Future<void> bulkFlags({
    required List<String> threadIds,
    bool? read,
    bool? starred,
  }) async {
    await api.dio.post<void>(
      'mailbox/threads/flags',
      data: {
        'threadIds': threadIds,
        if (read != null) 'read': read,
        if (starred != null) 'starred': starred,
      },
    );
  }

  Future<List<HelpdeskTicket>> helpdeskThreads({
    String? status,
    String? priority,
    String? q,
    bool mine = false,
    String? assigneeUserId,
  }) async {
    final res = await api.dio.get<dynamic>(
      'mail/threads',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (priority != null && priority.isNotEmpty) 'priority': priority,
        if (q != null && q.isNotEmpty) 'q': q,
        if (mine) 'assigneeUserId': assigneeUserId,
        'limit': 50,
      },
    );
    return _list(res.data).map(HelpdeskTicket.fromJson).toList();
  }

  Future<HelpdeskDetail> helpdeskThread(String id) async {
    final res = await api.dio.get<Map<String, dynamic>>('mail/threads/$id');
    final data = res.data ?? {};
    final threadRaw = data['thread'];
    final ticket = HelpdeskTicket.fromJson(
      threadRaw is Map
          ? Map<String, dynamic>.from(threadRaw)
          : Map<String, dynamic>.from(data),
    );
    final messages = _list(data['messages']).map(MailMessage.fromJson).toList();
    final notes = _list(data['notes']).map(TicketNote.fromJson).toList();
    return HelpdeskDetail(ticket: ticket, messages: messages, notes: notes);
  }

  Future<void> reply({
    required String threadId,
    required String body,
    String replyMode = 'REPLY',
    List<String> to = const [],
    String? cannedReplyId,
  }) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/reply',
      data: {
        'replyMode': replyMode,
        if (to.isNotEmpty) 'to': to,
        'bodyHtml': body.replaceAll('\n', '<br/>'),
        'bodyText': body,
        if (cannedReplyId != null) 'cannedReplyId': cannedReplyId,
      },
    );
  }

  Future<void> addNote({required String threadId, required String body}) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/notes',
      data: {'bodyHtml': body.replaceAll('\n', '<br/>')},
    );
  }

  Future<HelpdeskTicket> patchTicket({
    required String threadId,
    String? status,
    String? priority,
  }) async {
    final res = await api.dio.patch<Map<String, dynamic>>(
      'mail/threads/$threadId',
      data: {
        if (status != null) 'status': status,
        if (priority != null) 'priority': priority,
      },
    );
    final data = res.data ?? {};
    final thread = data['thread'];
    if (thread is Map) {
      return HelpdeskTicket.fromJson(Map<String, dynamic>.from(thread));
    }
    return HelpdeskTicket.fromJson(data);
  }

  Future<void> assign({required String threadId, required String userId}) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/assign',
      data: {'userId': userId},
    );
  }

  Future<void> unassign({required String threadId}) async {
    await api.dio.post<void>('mail/threads/$threadId/unassign');
  }

  Future<List<CannedReply>> cannedReplies() async {
    final res = await api.dio.get<dynamic>('mail/canned-replies');
    return _list(res.data).map(CannedReply.fromJson).toList();
  }

  Future<void> compose({
    required String mailboxId,
    required List<String> to,
    required String subject,
    required String body,
    List<String> cc = const [],
  }) async {
    await api.dio.post<void>(
      'mailbox/compose',
      data: {
        'mailboxId': mailboxId,
        'to': to,
        if (cc.isNotEmpty) 'cc': cc,
        'subject': subject,
        'bodyHtml': body.replaceAll('\n', '<br/>'),
        'bodyText': body,
      },
    );
  }

  List<Map<String, dynamic>> _list(dynamic data) {
    final list = data is List
        ? data
        : (data is Map && data['items'] is List)
            ? data['items'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
