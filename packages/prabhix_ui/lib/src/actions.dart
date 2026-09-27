import 'package:flutter/material.dart';
// CustomSemanticsAction, for the screen-reader rotor. material.dart does not re-export it.
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:prabhix_theme/prabhix_theme.dart';

import 'destructive.dart';

/// One thing a user can do to a row.
///
/// The same description drives the long-press sheet on touch, the right-click menu on
/// desktop and web, the swipe actions, and the screen-reader custom actions. That is the
/// point: a gesture is a *shortcut* to an action, never the only way to reach it. An action
/// that exists only as a swipe is invisible to anyone who does not know it is there, and
/// unreachable to anyone using a switch device or a keyboard.
@immutable
class PxAction {
  const PxAction({
    required this.label,
    required this.icon,
    required this.onInvoke,
    this.risk = PxRisk.undoable,
    this.confirmTitle,
    this.confirmMessage,
    this.enabled = true,
    this.shortcut,
  });

  final String label;
  final IconData icon;
  final VoidCallback onInvoke;

  /// Decides whether invoking asks first or offers an undo. See [PxRisk].
  final PxRisk risk;

  /// Shown by the confirmation when [risk] is [PxRisk.confirm]. Defaults are generic, so
  /// anything with real consequences should say what specifically is about to happen.
  final String? confirmTitle;
  final String? confirmMessage;

  final bool enabled;

  /// Displayed, not bound — the binding lives with the screen's [Shortcuts]. Showing it in
  /// the menu is how a user ever discovers the keyboard path.
  final String? shortcut;

  bool get isDestructive => risk == PxRisk.confirm;
}

/// Runs an action, inserting the confirmation its risk level calls for.
Future<void> invokePxAction(BuildContext context, PxAction action) async {
  if (!action.enabled) return;
  if (action.risk == PxRisk.confirm) {
    final ok = await confirmDestructive(
      context,
      title: action.confirmTitle ?? action.label,
      message: action.confirmMessage ?? 'This cannot be undone.',
      confirmLabel: action.label,
    );
    if (!ok) return;
  }
  action.onInvoke();
}

/// The canonical action list for a row, as a bottom sheet.
///
/// This is the touch form of the right-click menu. Everything a user can do to the thing
/// they long-pressed is here, including the things also reachable by swiping, so a user who
/// never discovers the swipe is not locked out of half the app.
Future<void> showPxActionSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<PxAction> actions,
}) async {
  HapticFeedback.mediumImpact();
  final chosen = await showModalBottomSheet<PxAction>(
    context: context,
    showDragHandle: true,
    // A sheet that stops halfway down a long action list hides the destructive item, which
    // is the one most worth seeing before tapping.
    isScrollControlled: true,
    builder: (sheetContext) {
      final px = sheetContext.px;
      final text = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: px.inkMuted),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: px.border),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  for (final action in actions)
                    ListTile(
                      enabled: action.enabled,
                      leading: Icon(
                        action.icon,
                        color: action.isDestructive ? px.dangerSubtleInk : px.ink,
                      ),
                      title: Text(
                        action.label,
                        style: TextStyle(
                          color: action.isDestructive ? px.dangerSubtleInk : px.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: action.shortcut == null
                          ? null
                          : Text(
                              action.shortcut!,
                              style: text.labelSmall?.copyWith(color: px.inkFaint),
                            ),
                      onTap: () => Navigator.of(sheetContext).pop(action),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  if (chosen != null && context.mounted) await invokePxAction(context, chosen);
}

/// Wraps a row so every input method reaches the same action list.
///
/// Long-press on touch, secondary (right) click on desktop and web, and a screen reader's
/// custom-actions rotor all open the same set. [onTap] stays the primary action.
class PxActionable extends StatelessWidget {
  const PxActionable({
    super.key,
    required this.child,
    required this.title,
    required this.actions,
    this.subtitle,
    this.onTap,
  });

  final Widget child;
  final String title;
  final String? subtitle;
  final List<PxAction> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    void open() => showPxActionSheet(
          context,
          title: title,
          subtitle: subtitle,
          actions: actions,
        );

    return Semantics(
      // The rotor equivalent. Without this the long-press menu is unreachable with
      // TalkBack or VoiceOver, because those intercept the gesture itself.
      customSemanticsActions: {
        for (final action in actions.where((a) => a.enabled))
          CustomSemanticsAction(label: action.label): () => invokePxAction(context, action),
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: open,
        onSecondaryTap: open,
        child: child,
      ),
    );
  }
}
