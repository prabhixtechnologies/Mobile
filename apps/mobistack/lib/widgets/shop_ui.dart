import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../state/app_state.dart';
import '../theme/prabhix_theme.dart';

/// Offline / sync strip for intermittent shop connectivity.
class ShopSyncBar extends StatelessWidget {
  const ShopSyncBar({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final offline = !state.online;
    final pending = state.pendingOps;
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
                ? 'Offline · $pending sale${pending == 1 ? '' : 's'} queued'
                : (cached
                    ? 'Offline · showing last shop sync'
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
                'Cached shop data · pull to refresh',
              );

    return Material(
      color: bg,
      child: InkWell(
        onTap: offline ? null : () => state.refreshAll(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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

class ShopHeroHeader extends StatelessWidget {
  const ShopHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fraunces(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    height: 1.1,
                    color: Px.ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    this.tone = KpiTone.neutral,
  });

  final String label;
  final String value;
  final String? hint;
  final KpiTone tone;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      KpiTone.accent => Px.accent,
      KpiTone.warning => Px.warning,
      KpiTone.danger => Px.danger,
      KpiTone.success => Px.success,
      KpiTone.neutral => Px.focus,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Px.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: accent, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Px.muted,
                  letterSpacing: 1.1,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: Px.ink,
              height: 1.05,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

enum KpiTone { neutral, accent, warning, danger, success }

class ShopEmpty extends StatelessWidget {
  const ShopEmpty({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inventory_2_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Px.faint),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Px.ink,
              ),
            ),
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

class ShopSearchField extends StatelessWidget {
  const ShopSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Px.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Px.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Px.faint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ShopListTile extends StatelessWidget {
  const ShopListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Px.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Px.accent.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Px.accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Px.accent,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
