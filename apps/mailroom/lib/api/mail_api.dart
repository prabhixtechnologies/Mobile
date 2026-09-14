import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../models/mail_models.dart';

/// Personal mailbox API on top of [ApiClient.dio]. Helpdesk lives in OneOps.
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
      sidebar({bool company = false}) async {
    final res = await api.dio.get<dynamic>(
      'mailbox',
      queryParameters: company ? {'mode': 'company'} : null,
    );
    final boxes = _list(res.data).map(MailboxSummary.fromJson).toList();
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
      return const [];
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

  Future<void> reply({
    required String threadId,
    required String body,
    String replyMode = 'REPLY',
    List<String> to = const [],
  }) async {
    await api.dio.post<void>(
      'mail/threads/$threadId/reply',
      data: {
        'replyMode': replyMode,
        if (to.isNotEmpty) 'to': to,
        'bodyHtml': body.replaceAll('\n', '<br/>'),
        'bodyText': body,
      },
    );
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

  Future<List<MailAlias>> aliases(String mailboxId) async {
    final res = await api.dio.get<dynamic>('mailbox/$mailboxId/aliases');
    return _list(res.data).map(MailAlias.fromJson).toList();
  }

  Future<MailAlias> createAlias({
    required String mailboxId,
    required String address,
  }) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      'mailbox/$mailboxId/aliases',
      data: {'address': address},
    );
    return MailAlias.fromJson(res.data ?? {});
  }

  Future<void> deleteAlias({
    required String mailboxId,
    required String aliasId,
  }) async {
    await api.dio.delete<void>('mailbox/$mailboxId/aliases/$aliasId');
  }

  Future<String> signature(String mailboxId) async {
    final res = await api.dio.get<Map<String, dynamic>>('mail/mailboxes/$mailboxId');
    return '${res.data?['signature'] ?? ''}';
  }

  Future<void> saveSignature({
    required String mailboxId,
    required String signature,
  }) async {
    await api.dio.patch<void>(
      'mail/mailboxes/$mailboxId',
      data: {'signature': signature},
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
