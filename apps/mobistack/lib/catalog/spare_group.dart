import 'package:uuid/uuid.dart';

import '../services/sync_store.dart';
import 'fitment_library.dart';

const _uuid = Uuid();

class SpareMember {
  const SpareMember({required this.brand, required this.name});

  final String brand;
  final String name;

  String get label => '$brand $name';

  Map<String, dynamic> toJson() => {'brand': brand, 'name': name};

  factory SpareMember.fromJson(Map<String, dynamic> json) {
    return SpareMember(brand: '${json['brand'] ?? ''}', name: '${json['name'] ?? ''}');
  }
}

/// Phones a technician has said share one spare. Saved on the device, then shared.
class SpareGroup {
  const SpareGroup({
    required this.id,
    required this.categoryCode,
    required this.quality,
    required this.note,
    required this.members,
    required this.shareStatus,
  });

  final String id;
  final String categoryCode;
  final String quality;
  final String note;
  final List<SpareMember> members;
  final String shareStatus;

  bool contains(String brand, String name) {
    return members.any((member) => member.brand == brand && member.name == name);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryCode': categoryCode,
        'quality': quality,
        'note': note,
        'members': members.map((member) => member.toJson()).toList(),
        'shareStatus': shareStatus,
      };

  factory SpareGroup.fromJson(Map<String, dynamic> json) {
    final raw = json['members'];
    final members = <SpareMember>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) members.add(SpareMember.fromJson(Map<String, dynamic>.from(row)));
      }
    }
    return SpareGroup(
      id: '${json['id'] ?? ''}',
      categoryCode: '${json['categoryCode'] ?? ''}',
      quality: '${json['quality'] ?? 'EXACT'}',
      note: '${json['note'] ?? ''}',
      members: members,
      shareStatus: '${json['shareStatus'] ?? 'local'}',
    );
  }

  SpareGroup copyWith({
    String? quality,
    String? note,
    List<SpareMember>? members,
    String? shareStatus,
  }) {
    return SpareGroup(
      id: id,
      categoryCode: categoryCode,
      quality: quality ?? this.quality,
      note: note ?? this.note,
      members: members ?? this.members,
      shareStatus: shareStatus ?? this.shareStatus,
    );
  }
}

class FitmentBook {
  const FitmentBook(this.groups);

  final List<SpareGroup> groups;

  static Future<FitmentBook> load(SyncStore sync) async {
    try {
      final rows = await sync.spareGroups();
      return FitmentBook(rows.map(SpareGroup.fromJson).toList());
    } catch (_) {
      return const FitmentBook([]);
    }
  }

  Future<void> persist(SyncStore sync) {
    return sync.saveSpareGroups(groups.map((group) => group.toJson()).toList());
  }

  List<SpareGroup> forPhone(String categoryCode, String brand, String name) {
    return groups
        .where((group) => group.categoryCode == categoryCode && group.contains(brand, name))
        .toList();
  }

  FitmentBook upsert(SpareGroup group) {
    final next = groups.where((existing) => existing.id != group.id).toList()..add(group);
    return FitmentBook(next);
  }

  FitmentBook remove(String id) {
    return FitmentBook(groups.where((group) => group.id != id).toList());
  }
}

SpareGroup newSpareGroup({
  required String categoryCode,
  required String quality,
  required String note,
  required List<SpareMember> members,
}) {
  return SpareGroup(
    id: _uuid.v4(),
    categoryCode: categoryCode,
    quality: quality,
    note: note.trim(),
    members: members,
    shareStatus: 'local',
  );
}

String spareQualityLabel(String quality) {
  return switch (quality) {
    'COMPATIBLE' => 'Also fits',
    'REQUIRES_MODIFICATION' => 'Needs work',
    _ => 'Exact',
  };
}

String spareShareLabel(String status) {
  return switch (status) {
    'pending' => 'Waiting for review',
    'shared' => 'Shared with every shop',
    _ => 'On this phone',
  };
}

String _clip(String value, int max) => value.length > max ? value.substring(0, max) : value;

String sparePartName(String partLabel, SpareGroup group) {
  final note = group.note.trim();
  if (note.isNotEmpty) return _clip(note, 160);
  final names = group.members.map((member) => member.name).join(' / ');
  final title = '$partLabel · $names';
  return title.length > 160 ? title.substring(0, 160) : title;
}

class SpareShareResult {
  const SpareShareResult({required this.status, required this.message});

  final String status;
  final String message;
}

/// Sends one part plus the phones it fits. Review accepts both together.
Future<SpareShareResult> shareSpareGroup(
  Future<dynamic> Function(Map<String, dynamic> body) post,
  SpareGroup group,
  String partLabel,
) async {
  if (group.members.length < 2) {
    return const SpareShareResult(
      status: 'failed',
      message: 'Add at least one other phone before sharing.',
    );
  }
  try {
    final response = await post({
      'kind': 'ADD_COMPONENT',
      'reason': _clip(group.note.trim().isEmpty ? 'Fitted on the bench' : group.note.trim(), 500),
      'payload': {
        'categoryCode': group.categoryCode,
        'name': sparePartName(partLabel, group),
        'description': group.members.map((member) => member.label).join(', '),
        'fits': [
          for (final member in group.members)
            {'brand': member.brand, 'name': member.name, 'fit': group.quality},
        ],
      },
    });
    final data = response is Map
        ? response
        : (response as dynamic).data;
    final status = data is Map ? '${data['status'] ?? ''}' : '';
    if (status == 'APPLIED') {
      return const SpareShareResult(
        status: 'shared',
        message: 'Shared. Every shop can see this spare.',
      );
    }
    return const SpareShareResult(
      status: 'pending',
      message: 'Saved here, and sent for review before other shops see it.',
    );
  } catch (error) {
    return SpareShareResult(status: 'failed', message: _serverMessage(error));
  }
}

String _serverMessage(Object error) {
  try {
    final data = (error as dynamic).response?.data;
    if (data is Map && data['message'] != null) return '${data['message']}';
  } catch (_) {}
  return 'Could not reach the catalog. The group stays on this phone.';
}

String categoryLabel(String code) {
  for (final category in fitmentCategories) {
    if (category.code == code) return category.label;
  }
  return code;
}
