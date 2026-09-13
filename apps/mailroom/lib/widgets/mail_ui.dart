import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../models/mail_models.dart';
import '../theme/prabhix_theme.dart';

Color avatarColor(String seed) {
  const palette = [
    Color(0xFF0E7490),
    Color(0xFF1D4ED8),
    Color(0xFF7C3AED),
    Color(0xFFBE185D),
    Color(0xFFB45309),
    Color(0xFF047857),
    Color(0xFF0F766E),
    Color(0xFF4338CA),
  ];
  var hash = 0;
  for (final c in seed.codeUnits) {
    hash = (hash + c) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.label,
    this.size = 40,
    this.selected = false,
  });

  final String label;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Px.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, color: Px.accentInk, size: size * 0.55),
      );
    }
    final letter = label.trim().isEmpty ? '?' : label.trim()[0].toUpperCase();
    final color = avatarColor(label);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

class MailShimmerList extends StatefulWidget {
  const MailShimmerList({super.key});

  @override
  State<MailShimmerList> createState() => _MailShimmerListState();
}

class _MailShimmerListState extends State<MailShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = 0.35 + (_c.value * 0.35);
        return ListView.builder(
          itemCount: 8,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Px.line.withValues(alpha: t),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Px.line.withValues(alpha: t),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Px.line.withValues(alpha: t * 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HtmlMailBody extends StatelessWidget {
  const HtmlMailBody({super.key, required this.message});

  final MailMessage message;

  @override
  Widget build(BuildContext context) {
    final html = message.bodyHtml;
    if (html != null && html.trim().isNotEmpty) {
      return HtmlWidget(
        html,
        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Px.ink,
              height: 1.45,
              fontSize: 15,
            ),
      );
    }
    return SelectableText(
      message.body.isEmpty ? '(empty message)' : message.body,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Px.ink,
            height: 1.45,
          ),
    );
  }
}

IconData folderIcon(IconDataHint hint) {
  switch (hint) {
    case IconDataHint.inbox:
      return Icons.inbox_rounded;
    case IconDataHint.sent:
      return Icons.send_rounded;
    case IconDataHint.drafts:
      return Icons.drafts_rounded;
    case IconDataHint.archive:
      return Icons.archive_rounded;
    case IconDataHint.trash:
      return Icons.delete_outline_rounded;
    case IconDataHint.spam:
      return Icons.report_gmailerrorred_rounded;
    case IconDataHint.star:
      return Icons.star_rounded;
    case IconDataHint.folder:
      return Icons.folder_rounded;
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.tone = ChipTone.neutral});

  final String label;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      ChipTone.danger => (Px.danger.withValues(alpha: 0.12), Px.danger),
      ChipTone.warning => (Px.warning.withValues(alpha: 0.14), Px.warning),
      ChipTone.success => (Px.success.withValues(alpha: 0.12), Px.success),
      ChipTone.accent => (Px.bgAccent, Px.accent),
      ChipTone.neutral => (Px.line.withValues(alpha: 0.45), Px.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.$2,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

enum ChipTone { neutral, accent, success, warning, danger }

ChipTone priorityTone(String? priority) {
  switch (priority) {
    case 'URGENT':
      return ChipTone.danger;
    case 'HIGH':
      return ChipTone.warning;
    case 'LOW':
      return ChipTone.neutral;
    default:
      return ChipTone.accent;
  }
}

ChipTone statusTone(String? status) {
  switch (status) {
    case 'RESOLVED':
    case 'CLOSED':
      return ChipTone.success;
    case 'SPAM':
    case 'TRASH':
      return ChipTone.neutral;
    case 'ON_HOLD':
    case 'PENDING_CUSTOMER':
      return ChipTone.warning;
    default:
      return ChipTone.accent;
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.mail_outline_rounded, size: 56, color: Px.faint),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
