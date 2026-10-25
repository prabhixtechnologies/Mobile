import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'catalog_projection.dart';
import 'sync_store.dart';

typedef CatalogGet = Future<String> Function(
  String path,
  Map<String, dynamic> query,
  String groupId,
);

/// Selected group first, then every other group not already handled this pass.
List<String> catalogWarmOrder(String? selected, Iterable<String> groups, Set<String> done) {
  final ordered = <String>[];
  final seen = <String>{};
  void add(String? id) {
    if (id == null || id.isEmpty || done.contains(id) || !seen.add(id)) return;
    ordered.add(id);
  }

  add(selected);
  for (final id in groups) {
    add(id);
  }
  return ordered;
}

/// Installs each group's catalog snapshot on the phone.
///
/// One HTTP request and one SQLite transaction per group. The raw graph is stored once.
/// Brand and phone lists are indexed for the catalog screen. A phone's spare
/// page is built from that graph when the phone is opened, so a part shared by
/// many phones is not copied once per phone while the UI is trying to draw.
class CatalogMirror {
  CatalogMirror({
    required this.sync,
    required this.get,
    required this.online,
    required this.groupId,
    required this.groupIds,
    this.onInstalled,
  });

  final SyncStore sync;
  final CatalogGet get;
  final bool Function() online;
  final String? Function() groupId;
  final List<String> Function() groupIds;
  final void Function()? onInstalled;
  Future<void>? _inFlight;

  /// Downloads every group this phone belongs to. The open group goes first.
  ///
  /// Callers that arrive while a download is already running share that same
  /// download. A group switch during the run is picked up on the next group,
  /// so the newly opened catalog is not left waiting on the previous one.
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
    if (!online()) {
      debugPrint('catalog refresh starting without an online flag');
    }
    final done = <String>{};
    while (true) {
      final pending = catalogWarmOrder(groupId(), groupIds(), done);
      if (pending.isEmpty) return;
      final group = pending.first;
      done.add(group);
      final saved = await _install(group);
      if (!saved) return;
    }
  }

  Future<bool> _install(String group) async {
    try {
      final readable = await sync.catalogGraphReadable(group);
      final installed = readable ? await sync.catalogVersion(group) : null;
      final raw = await get('commons/snapshot', {
        if (installed != null) 'version': installed,
      }, group);
      if (raw.isEmpty) return false;
      final staged = await compute(stageCatalogSnapshot, {
        'group': group,
        'raw': raw,
      });
      if (staged == null) return true;
      final version = staged['version'];
      final graph = staged['graph'];
      if (version == null || version.isEmpty || graph == null || graph.isEmpty) {
        throw const FormatException('Catalog snapshot is incomplete');
      }
      final decoded = await compute(jsonDecode, graph);
      if (decoded is! Map) {
        throw const FormatException('Catalog snapshot is incomplete');
      }
      final index = CatalogIndex(Map<String, dynamic>.from(decoded));
      // Only the open group paints from memory. Another group's graph stays on disk
      // so a background save cannot replace the list the person is looking at.
      final openNow = groupId() == group;
      if (openNow) {
        sync.adoptCatalog(group, index);
        onInstalled?.call();
      }
      final encoded = await compute(encodeCatalogLists, {
        'group': group,
        'graph': graph,
      });
      await sync.installEncodedCatalog(
        groupId: group,
        version: version,
        graphJson: graph,
        encodedLists: encoded,
      );
      if (!openNow && groupId() == group) {
        sync.adoptCatalog(group, index);
        onInstalled?.call();
      }
      debugPrint('catalog snapshot $version installed for $group lists=${encoded.length}');
      return true;
    } catch (e, st) {
      debugPrint('catalog snapshot $group skipped: $e\n$st');
      return false;
    }
  }
}
