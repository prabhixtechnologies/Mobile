class MailboxSummary {
  MailboxSummary({
    required this.id,
    required this.name,
    required this.address,
    this.kind,
    this.mine = false,
    this.folders = const [],
  });

  final String id;
  final String name;
  final String address;
  final String? kind;
  final bool mine;
  final List<MailFolder> folders;

  factory MailboxSummary.fromJson(Map<String, dynamic> json) {
    final nested = json['folders'];
    return MailboxSummary(
      id: '${json['id']}',
      name: '${json['name'] ?? json['address'] ?? 'Mailbox'}',
      address: '${json['address'] ?? ''}',
      kind: json['kind']?.toString(),
      mine: json['mine'] == true,
      folders: nested is List
          ? nested
              .whereType<Map>()
              .map((e) => MailFolder.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'kind': kind,
        'mine': mine,
        'folders': folders.map((f) => f.toJson()).toList(),
      };
}

class MailFolder {
  MailFolder({
    required this.id,
    required this.name,
    this.mailboxId,
    this.kind,
    this.unreadCount = 0,
    this.threadCount = 0,
    this.system = false,
  });

  final String id;
  final String name;
  final String? mailboxId;
  final String? kind;
  final int unreadCount;
  final int threadCount;
  final bool system;

  factory MailFolder.fromJson(Map<String, dynamic> json) {
    final kind = json['kind']?.toString();
    return MailFolder(
      id: '${json['id']}',
      name: '${json['name'] ?? json['displayName'] ?? kind ?? 'Folder'}',
      mailboxId: json['mailboxId']?.toString(),
      kind: kind,
      unreadCount: _int(json['unreadCount']),
      threadCount: _int(json['threadCount']),
      system: kind != null && kind != 'CUSTOM',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mailboxId': mailboxId,
        'kind': kind,
        'unreadCount': unreadCount,
        'threadCount': threadCount,
      };

  IconDataHint get iconHint {
    switch (kind) {
      case 'INBOX':
        return IconDataHint.inbox;
      case 'SENT':
        return IconDataHint.sent;
      case 'DRAFTS':
        return IconDataHint.drafts;
      case 'ARCHIVE':
        return IconDataHint.archive;
      case 'TRASH':
        return IconDataHint.trash;
      case 'SPAM':
        return IconDataHint.spam;
      default:
        return IconDataHint.folder;
    }
  }
}

enum IconDataHint { inbox, sent, drafts, archive, trash, spam, folder, star }

class MailThreadSummary {
  MailThreadSummary({
    required this.id,
    required this.subject,
    this.preview,
    this.fromAddress,
    this.fromName,
    this.unread = false,
    this.starred = false,
    this.hasAttachments = false,
    this.messageCount = 0,
    this.status,
    this.folderId,
    this.mailboxId,
    this.updatedAt,
    this.direction,
  });

  final String id;
  final String subject;
  final String? preview;
  final String? fromAddress;
  final String? fromName;
  final bool unread;
  final bool starred;
  final bool hasAttachments;
  final int messageCount;
  final String? status;
  final String? folderId;
  final String? mailboxId;
  final String? updatedAt;
  final String? direction;

  String get correspondent =>
      (fromName?.isNotEmpty == true)
          ? fromName!
          : (fromAddress?.isNotEmpty == true ? fromAddress! : 'Unknown');

  factory MailThreadSummary.fromJson(Map<String, dynamic> json) {
    return MailThreadSummary(
      id: '${json['id']}',
      subject: '${json['subject'] ?? '(no subject)'}',
      preview: json['preview']?.toString() ?? json['snippet']?.toString(),
      fromAddress: json['fromAddress']?.toString() ??
          json['correspondent']?.toString() ??
          json['from']?.toString(),
      fromName: json['fromName']?.toString() ??
          json['correspondentName']?.toString(),
      unread: json['unread'] == true ||
          json['read'] == false ||
          _int(json['unreadCount']) > 0,
      starred: json['starred'] == true,
      hasAttachments: json['hasAttachments'] == true,
      messageCount: _int(json['messageCount']),
      status: json['status']?.toString(),
      folderId: json['folderId']?.toString(),
      mailboxId: json['mailboxId']?.toString(),
      updatedAt: json['updatedAt']?.toString() ??
          json['lastMessageAt']?.toString(),
      direction: json['lastMessageDirection']?.toString() ??
          json['direction']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'preview': preview,
        'fromAddress': fromAddress,
        'fromName': fromName,
        'unread': unread,
        'starred': starred,
        'hasAttachments': hasAttachments,
        'messageCount': messageCount,
        'status': status,
        'folderId': folderId,
        'mailboxId': mailboxId,
        'updatedAt': updatedAt,
        'direction': direction,
      };

  MailThreadSummary copyWith({
    bool? unread,
    bool? starred,
  }) {
    return MailThreadSummary(
      id: id,
      subject: subject,
      preview: preview,
      fromAddress: fromAddress,
      fromName: fromName,
      unread: unread ?? this.unread,
      starred: starred ?? this.starred,
      hasAttachments: hasAttachments,
      messageCount: messageCount,
      status: status,
      folderId: folderId,
      mailboxId: mailboxId,
      updatedAt: updatedAt,
      direction: direction,
    );
  }
}

class MailMessage {
  MailMessage({
    required this.id,
    required this.body,
    this.bodyHtml,
    this.fromAddress,
    this.fromName,
    this.toAddresses = const [],
    this.ccAddresses = const [],
    this.occurredAt,
    this.direction,
    this.subject,
    this.attachmentCount = 0,
  });

  final String id;
  final String body;
  final String? bodyHtml;
  final String? fromAddress;
  final String? fromName;
  final List<String> toAddresses;
  final List<String> ccAddresses;
  final String? occurredAt;
  final String? direction;
  final String? subject;
  final int attachmentCount;

  bool get isOutbound =>
      direction == 'OUTBOUND' || direction == 'AGENT' || direction == 'OUT';

  factory MailMessage.fromJson(Map<String, dynamic> json) {
    final html = json['bodyHtml']?.toString();
    final text = json['bodyText']?.toString() ?? json['body']?.toString() ?? '';
    List<String> emails(dynamic raw) {
      if (raw is! List) return const [];
      return raw.map((e) => '$e').where((e) => e.isNotEmpty).toList();
    }

    return MailMessage(
      id: '${json['id']}',
      body: text.isNotEmpty ? text : _stripHtml(html ?? ''),
      bodyHtml: html,
      fromAddress: json['fromAddress']?.toString() ?? json['from']?.toString(),
      fromName: json['fromName']?.toString(),
      toAddresses: emails(json['to'] ?? json['toAddresses']),
      ccAddresses: emails(json['cc'] ?? json['ccAddresses']),
      occurredAt: json['occurredAt']?.toString() ?? json['createdAt']?.toString(),
      direction: json['direction']?.toString() ?? json['senderType']?.toString(),
      subject: json['subject']?.toString(),
      attachmentCount: _int(json['attachmentCount']),
    );
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class HelpdeskTicket {
  HelpdeskTicket({
    required this.id,
    required this.subject,
    this.status,
    this.priority,
    this.assigneeName,
    this.assigneeUserId,
    this.preview,
    this.customerEmail,
    this.referenceKey,
    this.unreadCount = 0,
    this.hasAttachments = false,
    this.lastMessageAt,
    this.slaDueAt,
    this.slaBreachedAt,
    this.mailboxId,
    this.tags = const [],
  });

  final String id;
  final String subject;
  final String? status;
  final String? priority;
  final String? assigneeName;
  final String? assigneeUserId;
  final String? preview;
  final String? customerEmail;
  final String? referenceKey;
  final int unreadCount;
  final bool hasAttachments;
  final String? lastMessageAt;
  final String? slaDueAt;
  final String? slaBreachedAt;
  final String? mailboxId;
  final List<String> tags;

  bool get isBreached => slaBreachedAt != null && slaBreachedAt!.isNotEmpty;

  factory HelpdeskTicket.fromJson(Map<String, dynamic> json) {
    final tagRaw = json['tags'];
    final tags = <String>[];
    if (tagRaw is List) {
      for (final t in tagRaw) {
        if (t is Map) {
          final name = t['name'] ?? t['slug'];
          if (name != null) tags.add('$name');
        } else {
          tags.add('$t');
        }
      }
    }
    return HelpdeskTicket(
      id: '${json['id']}',
      subject: '${json['subject'] ?? '(no subject)'}',
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      assigneeName: json['assigneeName']?.toString(),
      assigneeUserId: json['assigneeUserId']?.toString(),
      preview: json['preview']?.toString() ?? json['snippet']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      referenceKey: json['referenceKey']?.toString(),
      unreadCount: _int(json['unreadCount']),
      hasAttachments: json['hasAttachments'] == true,
      lastMessageAt: json['lastMessageAt']?.toString(),
      slaDueAt: json['slaDueAt']?.toString(),
      slaBreachedAt: json['slaBreachedAt']?.toString(),
      mailboxId: json['mailboxId']?.toString(),
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'status': status,
        'priority': priority,
        'assigneeName': assigneeName,
        'assigneeUserId': assigneeUserId,
        'preview': preview,
        'customerEmail': customerEmail,
        'referenceKey': referenceKey,
        'unreadCount': unreadCount,
        'hasAttachments': hasAttachments,
        'lastMessageAt': lastMessageAt,
        'slaDueAt': slaDueAt,
        'slaBreachedAt': slaBreachedAt,
        'mailboxId': mailboxId,
        'tags': tags,
      };
}

class CannedReply {
  CannedReply({
    required this.id,
    required this.title,
    required this.bodyHtml,
    this.shortcut,
  });

  final String id;
  final String title;
  final String bodyHtml;
  final String? shortcut;

  String get bodyText => MailMessage._stripHtml(bodyHtml);

  factory CannedReply.fromJson(Map<String, dynamic> json) => CannedReply(
        id: '${json['id']}',
        title: '${json['title'] ?? json['name'] ?? 'Reply'}',
        bodyHtml: '${json['bodyHtml'] ?? json['body'] ?? ''}',
        shortcut: json['shortcut']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'bodyHtml': bodyHtml,
        'shortcut': shortcut,
      };
}

class TicketNote {
  TicketNote({
    required this.id,
    required this.body,
    this.authorUserId,
    this.createdAt,
  });

  final String id;
  final String body;
  final String? authorUserId;
  final String? createdAt;

  factory TicketNote.fromJson(Map<String, dynamic> json) => TicketNote(
        id: '${json['id']}',
        body: MailMessage._stripHtml(
          '${json['bodyHtml'] ?? json['body'] ?? json['bodyText'] ?? ''}',
        ),
        authorUserId: json['authorUserId']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

class HelpdeskDetail {
  HelpdeskDetail({
    required this.ticket,
    this.messages = const [],
    this.notes = const [],
  });

  final HelpdeskTicket ticket;
  final List<MailMessage> messages;
  final List<TicketNote> notes;
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

String relativeTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'now';
  if (day == today) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
  if (diff.inDays < 7) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[dt.weekday - 1];
  }
  return '${dt.day}/${dt.month}/${dt.year % 100}';
}

String dateSectionLabel(String? iso) {
  if (iso == null || iso.isEmpty) return 'Earlier';
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return 'Earlier';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final delta = today.difference(day).inDays;
  if (delta == 0) return 'Today';
  if (delta == 1) return 'Yesterday';
  if (delta < 7) return 'This week';
  if (delta < 30) return 'This month';
  return 'Earlier';
}
