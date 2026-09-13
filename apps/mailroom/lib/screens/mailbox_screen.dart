import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/mail_models.dart';
import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';
import '../widgets/chrome.dart';
import '../widgets/mail_ui.dart';

class MailboxScreen extends StatefulWidget {
  const MailboxScreen({super.key});

  @override
  State<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  final _search = TextEditingController();
  bool _searchOpen = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _withUndo(Future<UndoMove?> Function() action) async {
    final undo = await action();
    if (!mounted || undo == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Conversation ${undo.label}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => context.read<AppState>().undoLastMove(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final threads = state.visibleThreads;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: state.selecting ? null : _MailNav(state: state),
        appBar: state.selecting
            ? _SelectionAppBar(state: state, onUndoable: _withUndo)
            : _searchOpen
                ? _SearchAppBar(
                    controller: _search,
                    onClose: () {
                      setState(() => _searchOpen = false);
                      _search.clear();
                      state.clearSearch();
                    },
                    onChanged: state.setSearchQuery,
                  )
                : AppBar(
                    titleSpacing: 8,
                    title: FadeSlide(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentFolderTitle,
                            style: GoogleFonts.fraunces(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: Px.ink,
                            ),
                          ),
                          Text(
                            state.unreadInView > 0
                                ? '${state.unreadInView} unread'
                                : '${threads.length} conversations',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Search',
                        onPressed: () => setState(() => _searchOpen = true),
                        icon: const Icon(Icons.search_rounded),
                      ),
                      IconButton(
                        tooltip: state.online ? 'Sync now' : 'Offline',
                        onPressed: state.busy
                            ? null
                            : () => state.online
                                ? state.syncNow()
                                : state.loadMailbox(),
                        icon: Icon(
                          state.online
                              ? Icons.cloud_sync_rounded
                              : Icons.cloud_off_rounded,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'select') state.enterSelection();
                          if (v == 'out') state.signOut();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'select', child: Text('Select')),
                          PopupMenuItem(value: 'out', child: Text('Sign out')),
                        ],
                      ),
                    ],
                  ),
        floatingActionButton: state.selecting
            ? null
            : FloatingActionButton(
                onPressed: () => context.push('/compose'),
                backgroundColor: Px.accent,
                foregroundColor: Px.accentInk,
                elevation: 6,
                child: const Icon(Icons.edit_rounded),
              )
                .animate()
                .scale(delay: 200.ms, duration: 420.ms, curve: Px.curve),
        body: Column(
          children: [
            SyncStatusBar(state: state),
            Expanded(
              child: RefreshIndicator(
                color: Px.accent,
                onRefresh: () => state.syncNow(),
                child: state.busy && threads.isEmpty
                    ? const MailShimmerList()
                    : threads.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.5,
                                child: EmptyState(
                                  title: state.searchQuery.isEmpty
                                      ? 'Quiet in ${state.currentFolderTitle}'
                                      : 'No matches',
                                  subtitle: state.searchQuery.isEmpty
                                      ? (state.offlineMode
                                          ? 'Cached copy · will refresh when you reconnect'
                                          : 'Pull to sync · swipe to archive or delete')
                                      : 'Try another search term',
                                  icon: Icons.inbox_outlined,
                                ),
                              ),
                            ],
                          )
                        : _GroupedThreadList(
                            threads: threads,
                            selecting: state.selecting,
                            selectedIds: state.selectedIds,
                            onOpen: (t) async {
                              if (state.selecting) {
                                state.toggleSelected(t.id);
                                return;
                              }
                              if (t.unread) await state.markRead(t, read: true);
                              if (context.mounted) {
                                context.push('/thread/${t.id}');
                              }
                            },
                            onLongPress: (t) {
                              HapticFeedback.mediumImpact();
                              state.enterSelection(t.id);
                            },
                            onStar: (t) => state.toggleStar(t),
                            onArchive: (t) => _withUndo(
                              () => state.moveWithUndo(
                                threadIds: [t.id],
                                targetKind: 'ARCHIVE',
                              ),
                            ),
                            onTrash: (t) => _withUndo(
                              () => state.moveWithUndo(
                                threadIds: [t.id],
                                targetKind: 'TRASH',
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final offline = state.offlineMode;
    final pending = state.pendingOutbox;
    final cached = state.servingFromCache;
    if (!offline && pending == 0 && !cached) {
      return const SizedBox.shrink();
    }

    final (bg, fg, icon, label) = offline
        ? (
            Px.warning.withValues(alpha: 0.14),
            Px.warning,
            Icons.cloud_off_rounded,
            pending > 0
                ? 'Offline · $pending change${pending == 1 ? '' : 's'} queued'
                : (cached
                    ? 'Offline · showing last sync'
                    : 'Offline · waiting for connection'),
          )
        : pending > 0
            ? (
                Px.focus.withValues(alpha: 0.12),
                Px.focus,
                Icons.upload_rounded,
                'Syncing $pending queued change${pending == 1 ? '' : 's'}…',
              )
            : (
                Px.accent.withValues(alpha: 0.1),
                Px.accent,
                Icons.history_rounded,
                'Cached view · pull to refresh',
              );

    return Material(
      color: bg,
      child: InkWell(
        onTap: offline ? null : () => state.syncNow(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontSize: 12.5,
                      ),
                ),
              ),
              if (!offline)
                Text(
                  'Sync',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontSize: 12,
                      ),
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms);
  }
}

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({
    required this.controller,
    required this.onClose,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onClose;
  final ValueChanged<String> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onClose,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search conversations',
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
      ),
      actions: [
        if (controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(Icons.close_rounded),
          ),
      ],
    );
  }
}

class _SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SelectionAppBar({required this.state, required this.onUndoable});

  final AppState state;
  final Future<void> Function(Future<UndoMove?> Function()) onUndoable;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Px.bgAccent,
      leading: IconButton(
        onPressed: state.exitSelection,
        icon: const Icon(Icons.close_rounded),
      ),
      title: Text('${state.selectedIds.length} selected'),
      actions: [
        IconButton(
          tooltip: 'Select all',
          onPressed: state.selectAllVisible,
          icon: const Icon(Icons.select_all_rounded),
        ),
        IconButton(
          tooltip: 'Mark read',
          onPressed: () => state.bulkMarkRead(read: true),
          icon: const Icon(Icons.mark_email_read_outlined),
        ),
        IconButton(
          tooltip: 'Archive',
          onPressed: () => onUndoable(state.bulkArchive),
          icon: const Icon(Icons.archive_outlined),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: () => onUndoable(state.bulkTrash),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _MailNav extends StatelessWidget {
  const _MailNav({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Px.bg,
      child: Atmosphere(
        intense: true,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: BrandMark(compact: true),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  state.me?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (state.pendingOutbox > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Px.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Px.warning.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_send_rounded,
                            color: Px.warning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${state.pendingOutbox} waiting to sync',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Px.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _NavTile(
                icon: Icons.star_rounded,
                iconColor: Px.warning,
                label: 'Starred',
                selected: state.starredMode,
                onTap: () {
                  Navigator.pop(context);
                  state.showStarred();
                },
              ),
              for (final box in state.mailboxes) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Text(
                    box.mine ? 'Personal · ${box.name}' : box.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Px.accent,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                  ),
                ),
                ...box.folders.map(
                  (f) => _NavTile(
                    icon: folderIcon(f.iconHint),
                    label: f.name,
                    trailing: f.unreadCount > 0 ? '${f.unreadCount}' : null,
                    selected:
                        !state.starredMode && state.selectedFolderId == f.id,
                    onTap: () {
                      Navigator.pop(context);
                      state.selectFolder(f.id);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _NavTile(
                icon: Icons.support_agent_rounded,
                label: 'Helpdesk queue',
                trailing: state.queue.isEmpty ? null : '${state.queue.length}',
                onTap: () {
                  Navigator.pop(context);
                  context.go('/queue');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.trailing,
    this.selected = false,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? Px.accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: iconColor ?? (selected ? Px.accent : Px.muted)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? Px.ink : Px.ink,
                          fontSize: 15,
                        ),
                  ),
                ),
                if (trailing != null)
                  Text(
                    trailing!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Px.accent,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupedThreadList extends StatelessWidget {
  const _GroupedThreadList({
    required this.threads,
    required this.selecting,
    required this.selectedIds,
    required this.onOpen,
    required this.onLongPress,
    required this.onStar,
    required this.onArchive,
    required this.onTrash,
  });

  final List<MailThreadSummary> threads;
  final bool selecting;
  final Set<String> selectedIds;
  final ValueChanged<MailThreadSummary> onOpen;
  final ValueChanged<MailThreadSummary> onLongPress;
  final ValueChanged<MailThreadSummary> onStar;
  final ValueChanged<MailThreadSummary> onArchive;
  final ValueChanged<MailThreadSummary> onTrash;

  @override
  Widget build(BuildContext context) {
    final sections = <String, List<MailThreadSummary>>{};
    for (final t in threads) {
      final key = dateSectionLabel(t.updatedAt);
      sections.putIfAbsent(key, () => []).add(t);
    }

    final children = <Widget>[];
    var i = 0;
    for (final entry in sections.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            entry.key,
            style: GoogleFonts.fraunces(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Px.muted,
            ),
          ),
        ),
      );
      for (final t in entry.value) {
        final delay = (i * 28).clamp(0, 240);
        i++;
        children.add(
          FadeSlide(
            delay: Duration(milliseconds: delay),
            dy: 10,
            child: _SwipeThreadRow(
              thread: t,
              selecting: selecting,
              selected: selectedIds.contains(t.id),
              onOpen: () => onOpen(t),
              onLongPress: () => onLongPress(t),
              onStar: () => onStar(t),
              onArchive: () => onArchive(t),
              onTrash: () => onTrash(t),
            ),
          ),
        );
      }
    }
    children.add(const SizedBox(height: 88));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }
}

class _SwipeThreadRow extends StatelessWidget {
  const _SwipeThreadRow({
    required this.thread,
    required this.selecting,
    required this.selected,
    required this.onOpen,
    required this.onLongPress,
    required this.onStar,
    required this.onArchive,
    required this.onTrash,
  });

  final MailThreadSummary thread;
  final bool selecting;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onLongPress;
  final VoidCallback onStar;
  final VoidCallback onArchive;
  final VoidCallback onTrash;

  @override
  Widget build(BuildContext context) {
    final weight = thread.unread ? FontWeight.w700 : FontWeight.w500;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? Px.bgAccent
            : thread.unread
                ? Px.surface
                : Px.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          onLongPress: onLongPress,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: thread.unread ? Px.accent : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: selecting ? onOpen : onStar,
                          child: selecting || !thread.starred
                              ? PersonAvatar(
                                  label: thread.correspondent,
                                  selected: selected,
                                )
                              : Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    PersonAvatar(label: thread.correspondent),
                                    const Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Icon(Icons.star_rounded,
                                          size: 16, color: Px.warning),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      thread.correspondent,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: weight,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    relativeTime(thread.updatedAt),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: thread.unread
                                              ? FontWeight.w700
                                              : FontWeight.w400,
                                          color: thread.unread
                                              ? Px.accent
                                              : Px.faint,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                thread.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: weight,
                                      color: Px.ink,
                                      fontSize: 14.5,
                                    ),
                              ),
                              if (thread.preview != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  thread.preview!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 13.5),
                                ),
                              ],
                              if (thread.hasAttachments) ...[
                                const SizedBox(height: 6),
                                const Icon(Icons.attach_file_rounded,
                                    size: 15, color: Px.faint),
                              ],
                            ],
                          ),
                        ),
                        if (!selecting)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onStar,
                            icon: Icon(
                              thread.starred
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: thread.starred ? Px.warning : Px.faint,
                              size: 22,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selecting) return row;

    return Slidable(
      key: ValueKey(thread.id),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.28,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onArchive(),
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: Px.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_rounded, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Archive',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.28,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onTrash(),
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: Px.danger,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_rounded, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Delete',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      child: row,
    );
  }
}
