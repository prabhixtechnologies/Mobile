import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  static const queues = ['mine', 'unassigned', 'all'];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(onPressed: () => state.flushOutbound(), icon: const Icon(Icons.cloud_upload_outlined)),
          IconButton(onPressed: () => state.refreshChat(), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: queues.map((q) {
                return ChoiceChip(
                  label: Text(q),
                  selected: state.chatQueue == q,
                  onSelected: (_) => state.refreshChat(queue: q),
                );
              }).toList(),
            ),
          ),
          if (state.pendingOutbound > 0)
            MaterialBanner(
              content: Text('${state.pendingOutbound} message(s) waiting to send'),
              actions: [
                TextButton(onPressed: () => state.flushOutbound(), child: const Text('Flush')),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => state.refreshChat(),
              child: state.conversations.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No conversations in this queue.')),
                      ],
                    )
                  : ListView.separated(
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final c = state.conversations[i];
                        return ListTile(
                          title: Text(c.title),
                          subtitle: Text(
                            c.lastMessagePreview ?? c.status ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: c.unreadAgentCount > 0
                              ? Badge(label: Text('${c.unreadAgentCount}'))
                              : null,
                          onTap: () => context.push('/chat/${c.id}'),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
