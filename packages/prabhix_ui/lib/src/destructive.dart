import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prabhix_theme/prabhix_theme.dart';

/// How much ceremony an action that destroys something deserves.
///
/// The choices are not interchangeable and picking the wrong one is the usual cause of
/// both kinds of complaint — "it deleted my work without asking" and "why does it ask me
/// four times a minute".
///
/// The rule the apps follow:
///
///  * **Safe** when the action is its own inverse and costs nothing to get wrong. Starring,
///    toggling read. Offering to undo a toggle is noise, because pressing it again *is*
///    the undo.
///  * **Undo** when the action is reversible and frequent. Archiving mail, hiding a row,
///    moving something to another folder. The action happens immediately; a snackbar offers
///    to put it back. Interrupting a hundred-times-a-day action with a dialog is the worse
///    design.
///  * **Confirm** when the action is irreversible, financial, or visible to someone else.
///    Voiding a sale, deleting a customer, fulfilling an order. These are rare enough that
///    the interruption costs nothing and frequent enough in *aggregate* that one accident
///    is expensive.
///
/// Mirrors `ActionRisk` in `@prabhix/ui`, so a row's action list reads the same on mobile
/// and on the web.
enum PxRisk {
  /// Self-inverse. Do it now, say nothing.
  safe,

  /// Reversible. Do it now, offer [showUndo].
  undoable,

  /// Irreversible. Ask first with [confirmDestructive].
  confirm,
}

/// Asks before doing something that cannot be taken back.
///
/// Returns `true` only if the user chose the destructive option. Dismissing by tapping
/// outside, pressing Escape or swiping back all return `false`, so the caller can always
/// treat a non-`true` answer as "do nothing".
///
/// The destructive button is the *filled* one and carries the danger role, because a
/// destructive action styled as a quiet text button beside a prominent "Cancel" is a
/// well-known way to get the wrong one tapped. The text is a verb — "Void sale", not
/// "OK" — so the button alone says what will happen if the user reads nothing else.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  IconData icon = Icons.warning_amber_rounded,
}) async {
  final px = context.px;
  final answer = await showDialog<bool>(
    context: context,
    // A destructive confirmation must be a deliberate choice, so it cannot be dismissed by
    // a stray tap on the scrim — only by the explicit cancel.
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: Icon(icon, color: px.dangerSubtleInk),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: px.danger,
            foregroundColor: px.dangerInk,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return answer ?? false;
}

/// Reports that something reversible just happened, and offers to put it back.
///
/// [onUndo] runs if the user takes the offer. The window is deliberately longer than the
/// Material default of four seconds: the mistakes this catches are noticed a moment after
/// the screen settles, not instantly.
void showUndo(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
  Duration duration = const Duration(seconds: 7),
}) {
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    ),
  );
}

/// Reports an outcome with no undo — a failure, or a success nothing can be done about.
///
/// [error] is `null` on success. Keeping both in one call means a caller cannot
/// accidentally report a failure with the success styling, which is how "Sale voided"
/// ended up being shown for a request that had failed.
void showOutcome(BuildContext context, {String? error, required String success}) {
  final px = context.px;
  final failed = error != null;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              failed ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              size: 18,
              color: failed ? px.dangerSubtleInk : px.successSubtleInk,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(failed ? error : success)),
          ],
        ),
        backgroundColor: failed ? px.dangerSubtle : px.successSubtle,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

/// A long-press that cannot be triggered by accident.
///
/// Wraps [child] so a long press first gives haptic feedback, then runs [onAction]. The
/// feedback is the point: a destructive long-press with no physical acknowledgement is
/// invisible until it has already happened, which is exactly how a sale got voided by a
/// thumb resting on a list.
///
/// Pair this with [PxRisk]: a long-press that maps to [PxRisk.confirm] must still confirm.
class PxLongPress extends StatelessWidget {
  const PxLongPress({
    super.key,
    required this.child,
    required this.onAction,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onAction;
  final VoidCallback? onTap;

  /// Announced to a screen reader as the long-press action, because a gesture with no
  /// accessible equivalent does not exist for anyone using TalkBack or VoiceOver.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      onLongPressHint: semanticLabel,
      onLongPress: onAction,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onAction();
        },
        child: child,
      ),
    );
  }
}
