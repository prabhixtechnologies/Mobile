import 'package:flutter/foundation.dart';

import 'catalog_projection.dart';
import 'sync_store.dart';

typedef CatalogGet = Future<String> Function(String path, Map<String, dynamic> query);

/// Installs the backend's one immutable catalog snapshot on the phone.
///
/// One HTTP request, one SQLite transaction. The raw graph is stored once.
/// Brand and phone lists are indexed for the catalog screen. A phone's spare
/// page is built from that graph when the phone is opened, so a part shared by
/// many phones is not copied once per phone while the UI is trying to draw.
class CatalogMirror {
  CatalogMirror({
    required this.sync,
    required this.get,
    required this.online,
    required this.groupId,
    this.onInstalled,
  });

  final SyncStore sync;
  final CatalogGet get;
  final bool Function() online;
  final String? Function() groupId;
  final void Function()? onInstalled;
  Future<void>? _inFlight;

  /// Downloads the snapshot when this phone is online.
  ///
  /// Callers that arrive while a download is already running share that same
  /// download instead of starting another one.
  Future<void> warm() {
    final current = _inFlight;
    if (current != null) return current;
    final run = _warm();
    _inFlight = run;
    return run.whenComplete(() {
      if (identical(_inFlight, run)) _inFlight = null;
    });
  }

  Future<void> _warm() async {
    if (!online()) return;
    final group = groupId();
    if (group == null || group.isEmpty) return;
    try {
      final installed = await sync.catalogVersion(group);
      final raw = await get('commons/snapshot', {
        if (installed != null) 'version': installed,
      });
      if (raw.isEmpty) return;
      final prepared = await compute(prepareCatalogInstall, {
        'group': group,
        'raw': raw,
      });
      if (prepared == null) return;
      final version = prepared.remove('version');
      final graph = prepared.remove('graph');
      if (version == null || version.isEmpty || graph == null || graph.isEmpty) {
        throw const FormatException('Catalog snapshot is incomplete');
      }
      await sync.installEncodedCatalog(
        groupId: group,
        version: version,
        graphJson: graph,
        encodedLists: prepared,
      );
      debugPrint('catalog snapshot $version installed lists=${prepared.length}');
      onInstalled?.call();
    } catch (e, st) {
      debugPrint('catalog snapshot skipped: $e\n$st');
    }
  }
}
