class ConversationSummary {
  ConversationSummary({
    required this.id,
    this.subject,
    this.visitorName,
    this.visitorEmail,
    this.status,
    this.priority,
    this.lastMessagePreview,
    this.lastMessageAt,
    this.unreadAgentCount = 0,
    this.assignedAgentId,
  });

  final String id;
  final String? subject;
  final String? visitorName;
  final String? visitorEmail;
  final String? status;
  final String? priority;
  final String? lastMessagePreview;
  final String? lastMessageAt;
  final int unreadAgentCount;
  final String? assignedAgentId;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: '${json['id']}',
      subject: json['subject']?.toString(),
      visitorName: json['visitorName']?.toString(),
      visitorEmail: json['visitorEmail']?.toString(),
      status: json['status']?.toString(),
      priority: json['priority']?.toString(),
      lastMessagePreview: json['lastMessagePreview']?.toString(),
      lastMessageAt: json['lastMessageAt']?.toString(),
      unreadAgentCount: _int(json['unreadAgentCount']),
      assignedAgentId: json['assignedAgentId']?.toString(),
    );
  }

  String get title =>
      subject?.isNotEmpty == true
          ? subject!
          : (visitorName?.isNotEmpty == true ? visitorName! : visitorEmail ?? 'Conversation');
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.body,
    this.senderType,
    this.occurredAt,
  });

  final String id;
  final String body;
  final String? senderType;
  final String? occurredAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: '${json['id'] ?? json['messageId']}',
      body: '${json['body'] ?? json['text'] ?? ''}',
      senderType: json['senderType']?.toString(),
      occurredAt: json['occurredAt']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  bool get isNote => senderType == 'NOTE';
  bool get isAgent => senderType == 'AGENT';
}

class CannedReply {
  CannedReply({required this.id, required this.title, required this.body, this.shortcut});

  final String id;
  final String title;
  final String body;
  final String? shortcut;

  factory CannedReply.fromJson(Map<String, dynamic> json) {
    return CannedReply(
      id: '${json['id']}',
      title: '${json['title'] ?? json['name'] ?? ''}',
      body: '${json['body'] ?? ''}',
      shortcut: json['shortcut']?.toString(),
    );
  }
}

class LiveVisitor {
  LiveVisitor({
    required this.visitorId,
    this.externalKey,
    this.displayName,
    this.email,
    this.currentPath,
    this.currentTitle,
    this.since,
  });

  final String visitorId;
  final String? externalKey;
  final String? displayName;
  final String? email;
  final String? currentPath;
  final String? currentTitle;
  final String? since;

  factory LiveVisitor.fromJson(Map<String, dynamic> json) {
    return LiveVisitor(
      visitorId: '${json['visitorId'] ?? json['id']}',
      externalKey: json['externalKey']?.toString(),
      displayName: json['displayName']?.toString(),
      email: json['email']?.toString(),
      currentPath: json['currentPath']?.toString(),
      currentTitle: json['currentTitle']?.toString(),
      since: json['since']?.toString(),
    );
  }

  String get label =>
      displayName?.isNotEmpty == true
          ? displayName!
          : (email?.isNotEmpty == true ? email! : visitorId);
}

class DashboardKpis {
  DashboardKpis({
    this.openConversations = 0,
    this.unassignedConversations = 0,
    this.visitorsToday = 0,
    this.ordersLast30Days = 0,
    this.revenueLast30Days = 0,
    this.seatsUsed = 0,
    this.seatsLimit = 0,
    this.mrr = 0,
    this.currency,
  });

  final int openConversations;
  final int unassignedConversations;
  final int visitorsToday;
  final int ordersLast30Days;
  final int revenueLast30Days;
  final int seatsUsed;
  final int seatsLimit;
  final int mrr;
  final String? currency;

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] is Map
        ? Map<String, dynamic>.from(json['kpis'] as Map)
        : json;
    return DashboardKpis(
      openConversations: _int(kpis['openConversations']),
      unassignedConversations: _int(kpis['unassignedConversations']),
      visitorsToday: _int(kpis['visitorsToday']),
      ordersLast30Days: _int(kpis['ordersLast30Days']),
      revenueLast30Days: _int(kpis['revenueLast30Days']),
      seatsUsed: _int(kpis['seatsUsed']),
      seatsLimit: _int(kpis['seatsLimit']),
      mrr: _int(kpis['mrr']),
      currency: kpis['currency']?.toString(),
    );
  }
}

int _int(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
