import 'package:dio/dio.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';

import '../models/mail_models.dart';

/// Query-parameter routes on `/api/v1/oneops`. Path segments such as
/// `mailbox/folders/{id}/threads` are not served by the mailbox controller.
class MailboxRoutes {
  static const folderThreadsPage = 'mailbox/folders/threads/page';
  static const thread = 'mailbox/threads';
  static const messages = 'mailbox/threads/messages';
  static const flags = 'mailbox/threads/flags';
  static const move = 'mailbox/folders/move';
  static const folders = 'mailbox/folders';
  static const drafts = 'mailbox/drafts';
  static const aliases = 'mailbox/aliases';
  static const attachments = 'mailbox/attachments';
  static const reply = 'mail/threads/reply';
  static const mailboxes = 'mail/mailboxes';

  static Map<String, dynamic> folderPage({
    required String folderId,
    String? cursor,
    String? query,
    int limit = 50,
  }) =>
      {
        'folderId': folderId,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      };
}

/// Personal mailbox API on top of [ApiClient.dio]. Helpdesk lives in OneOps.
class MailApi {
  MailApi(this.api);

  final ApiClient api;

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

  Future<List<MailFolder>> foldersForMailbox(String mailboxId) async {
    final res = await api.dio.get<dynamic>(
      MailboxRoutes.folders,
      queryParameters: {'mailboxId': mailboxId},
    );
    return _list(res.data).map(MailFolder.fromJson).toList();
  }

  Future<ThreadPage> folderThreads(
    String folderId, {
    String? cursor,
    String? query,
  }) async {
    final res = await api.dio.get<dynamic>(
      MailboxRoutes.folderThreadsPage,
      queryParameters: MailboxRoutes.folderPage(
        folderId: folderId,
        cursor: cursor,
        query: query,
      ),
    );
    final data = res.data;
    final items = _list(data).map(MailThreadSummary.fromJson).toList();
    final map = data is Map ? data : const {};
    return ThreadPage(
      items: items,
      nextCursor: map['nextCursor']?.toString(),
      hasMore: map['hasMore'] == true,
    );
  }

  Future<List<MailThreadSummary>> starred() async {
    final res = await api.dio.get<dynamic>('mailbox/starred');
    return _list(res.data).map(MailThreadSummary.fromJson).toList();
  }

  Future<List<MailThreadSummary>> snoozed() async {
    final res = await api.dio.get<dynamic>('mailbox/snoozed');
    return _list(res.data).map(MailThreadSummary.fromJson).toList();
  }

  Future<MailThreadSummary> threadSummary(String threadId) async {
    final res = await api.dio.get<Map<String, dynamic>>(
      MailboxRoutes.thread,
      queryParameters: {'threadId': threadId},
    );
    return MailThreadSummary.fromJson(res.data ?? {});
  }

  Future<List<MailMessage>> threadMessages(String threadId) async {
    final res = await api.dio.get<dynamic>(
      MailboxRoutes.messages,
      queryParameters: {'threadId': threadId},
    );
    return _list(res.data).map(MailMessage.fromJson).toList();
  }

  Future<List<MailAttachment>> attachmentsForMessage(String messageId) async {
    final res = await api.dio.get<dynamic>(
      MailboxRoutes.attachments,
      queryParameters: {'messageId': messageId},
    );
    return _list(res.data).map(MailAttachment.fromJson).toList();
  }

  Future<List<int>> downloadAttachment(String attachmentId) async {
    final res = await api.dio.get<List<int>>(
      MailboxRoutes.attachments,
      queryParameters: {'attachmentId': attachmentId},
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  Future<PendingAttachment> uploadAttachment(String path, String filename) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      MailboxRoutes.attachments,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: filename),
      }),
    );
    return PendingAttachment.fromJson(res.data ?? {});
  }

  Future<MailThreadSummary> patchFlags({
    required String threadId,
    bool? read,
    bool? starred,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) async {
    final res = await api.dio.patch<Map<String, dynamic>>(
      MailboxRoutes.flags,
      queryParameters: {'threadId': threadId},
      data: {
        if (read != null) 'read': read,
        if (starred != null) 'starred': starred,
        if (snoozeUntil != null) 'snoozeUntil': snoozeUntil.toUtc().toIso8601String(),
        if (clearSnooze) 'clearSnooze': true,
      },
    );
    return MailThreadSummary.fromJson(res.data ?? {});
  }

  Future<void> moveThreads({
    required String folderId,
    required List<String> threadIds,
  }) async {
    await api.dio.post<void>(
      MailboxRoutes.move,
      queryParameters: {'folderId': folderId},
      data: {'threadIds': threadIds},
    );
  }

  Future<void> bulkFlags({
    required List<String> threadIds,
    bool? read,
    bool? starred,
    DateTime? snoozeUntil,
    bool clearSnooze = false,
  }) async {
    await api.dio.post<void>(
      MailboxRoutes.flags,
      data: {
        'threadIds': threadIds,
        if (read != null) 'read': read,
        if (starred != null) 'starred': starred,
        if (snoozeUntil != null) 'snoozeUntil': snoozeUntil.toUtc().toIso8601String(),
        if (clearSnooze) 'clearSnooze': true,
      },
    );
  }

  Future<List<MailDraft>> drafts() async {
    final res = await api.dio.get<dynamic>(MailboxRoutes.drafts);
    return _list(res.data).map(MailDraft.fromJson).toList();
  }

  Future<MailDraft> draft(String draftId) async {
    final res = await api.dio.get<Map<String, dynamic>>(
      MailboxRoutes.drafts,
      queryParameters: {'draftId': draftId},
    );
    return MailDraft.fromJson(res.data ?? {});
  }

  Future<MailDraft> saveDraft({
    String? threadId,
    String? mailboxId,
    List<String> to = const [],
    List<String> cc = const [],
    List<String> bcc = const [],
    String? subject,
    String? bodyHtml,
    List<String> attachmentIds = const [],
  }) async {
    final res = await api.dio.put<Map<String, dynamic>>(
      MailboxRoutes.drafts,
      data: {
        if (threadId != null) 'threadId': threadId,
        if (mailboxId != null) 'mailboxId': mailboxId,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        if (subject != null) 'subject': subject,
        if (bodyHtml != null) 'bodyHtml': bodyHtml,
        'attachmentIds': attachmentIds,
      },
    );
    return MailDraft.fromJson(res.data ?? {});
  }

  Future<void> discardDraft(String draftId) async {
    await api.dio.delete<void>(
      MailboxRoutes.drafts,
      queryParameters: {'draftId': draftId},
    );
  }

  Future<void> reply({
    required String threadId,
    required String body,
    String replyMode = 'REPLY',
    List<String> to = const [],
    List<String> cc = const [],
    List<String> bcc = const [],
    List<String> attachmentIds = const [],
  }) async {
    await api.dio.post<void>(
      MailboxRoutes.reply,
      queryParameters: {'id': threadId},
      data: {
        'replyMode': replyMode,
        if (to.isNotEmpty) 'to': to,
        if (cc.isNotEmpty) 'cc': cc,
        if (bcc.isNotEmpty) 'bcc': bcc,
        'bodyHtml': _html(body),
        'bodyText': body,
        if (attachmentIds.isNotEmpty) 'attachmentIds': attachmentIds,
      },
    );
  }

  Future<void> compose({
    required String mailboxId,
    required List<String> to,
    required String subject,
    required String body,
    List<String> cc = const [],
    List<String> bcc = const [],
    List<String> attachmentIds = const [],
    String? draftId,
  }) async {
    await api.dio.post<void>(
      'mailbox/compose',
      data: {
        'mailboxId': mailboxId,
        'to': to,
        if (cc.isNotEmpty) 'cc': cc,
        if (bcc.isNotEmpty) 'bcc': bcc,
        'subject': subject,
        'bodyHtml': _html(body),
        'bodyText': body,
        if (attachmentIds.isNotEmpty) 'attachmentIds': attachmentIds,
        if (draftId != null) 'draftId': draftId,
      },
    );
  }

  Future<List<MailAlias>> aliases(String mailboxId) async {
    final res = await api.dio.get<dynamic>(
      MailboxRoutes.aliases,
      queryParameters: {'mailboxId': mailboxId},
    );
    return _list(res.data).map(MailAlias.fromJson).toList();
  }

  Future<MailAlias> createAlias({
    required String mailboxId,
    required String address,
  }) async {
    final res = await api.dio.post<Map<String, dynamic>>(
      MailboxRoutes.aliases,
      queryParameters: {'mailboxId': mailboxId},
      data: {'address': address},
    );
    return MailAlias.fromJson(res.data ?? {});
  }

  Future<void> deleteAlias({
    required String mailboxId,
    required String aliasId,
  }) async {
    await api.dio.delete<void>(
      MailboxRoutes.aliases,
      queryParameters: {'mailboxId': mailboxId, 'aliasId': aliasId},
    );
  }

  Future<String> signature(String mailboxId) async {
    final res = await api.dio.get<Map<String, dynamic>>(
      MailboxRoutes.mailboxes,
      queryParameters: {'id': mailboxId},
    );
    return '${res.data?['signature'] ?? ''}';
  }

  Future<void> saveSignature({
    required String mailboxId,
    required String signature,
  }) async {
    await api.dio.patch<void>(
      MailboxRoutes.mailboxes,
      queryParameters: {'id': mailboxId},
      data: {'signature': signature},
    );
  }

  static String _html(String body) => body
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('\n', '<br/>');

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
