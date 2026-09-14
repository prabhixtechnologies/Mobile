class InboxTicket {
  InboxTicket({
    required this.id,
    required this.subject,
    this.status,
    this.priority,
    this.assigneeUserId,
    this.preview,
    this.customerEmail,
    this.unreadCount = 0,
  });

  final String id;
  final String subject;
  final String? status;
  final String? priority;
  final String? assigneeUserId;
  final String? preview;
  final String? customerEmail;
  final int unreadCount;

  factory InboxTicket.fromJson(Map<String, dynamic> json) {
    final thread = json['thread'] is Map
        ? Map<String, dynamic>.from(json['thread'] as Map)
        : json;
    return InboxTicket(
      id: '${thread['id']}',
      subject: '${thread['subject'] ?? '(no subject)'}',
      status: thread['status']?.toString(),
      priority: thread['priority']?.toString(),
      assigneeUserId: thread['assigneeUserId']?.toString(),
      preview: thread['snippet']?.toString() ?? thread['preview']?.toString(),
      customerEmail: thread['customerEmail']?.toString(),
      unreadCount: _int(thread['unreadCount']),
    );
  }
}

class InboxMessage {
  InboxMessage({
    required this.id,
    required this.body,
    this.fromAddress,
    this.direction,
    this.occurredAt,
  });

  final String id;
  final String body;
  final String? fromAddress;
  final String? direction;
  final String? occurredAt;

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: '${json['id']}',
      body: '${json['bodyText'] ?? json['snippet'] ?? json['bodyHtml'] ?? ''}',
      fromAddress: json['fromAddress']?.toString(),
      direction: json['direction']?.toString(),
      occurredAt: json['occurredAt']?.toString(),
    );
  }
}

class OrderRow {
  OrderRow({
    required this.id,
    required this.label,
    this.status,
    this.total,
  });

  final String id;
  final String label;
  final String? status;
  final String? total;

  factory OrderRow.fromJson(Map<String, dynamic> json) {
    return OrderRow(
      id: '${json['id']}',
      label: '${json['number'] ?? json['email'] ?? json['id']}',
      status: json['status']?.toString(),
      total: json['total']?.toString() ?? json['grandTotal']?.toString(),
    );
  }
}

class MemberRow {
  MemberRow({
    required this.id,
    required this.label,
    this.email,
    this.role,
  });

  final String id;
  final String label;
  final String? email;
  final String? role;

  factory MemberRow.fromJson(Map<String, dynamic> json) {
    final role = json['role'];
    return MemberRow(
      id: '${json['id']}',
      label: '${json['displayName'] ?? json['name'] ?? json['email'] ?? json['id']}',
      email: json['email']?.toString(),
      role: role is Map ? role['name']?.toString() : role?.toString(),
    );
  }
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
