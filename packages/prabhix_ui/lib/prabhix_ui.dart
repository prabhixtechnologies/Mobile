/// Shared interaction primitives for the Prabhix Flutter apps.
///
/// The colours and type live in `prabhix_theme`; this package is the layer above — the
/// behaviours that were previously re-invented per screen, usually incompletely:
/// confirmation, undo, the long-press action list, and the loading/empty/error states.
///
/// Contract: `Infra/docs/UX-STANDARD.md`.
library;

export 'src/actions.dart';
export 'src/destructive.dart';
export 'src/states.dart';
