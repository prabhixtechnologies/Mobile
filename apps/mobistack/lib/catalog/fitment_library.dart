import 'dart:convert';

import 'package:flutter/services.dart';

class FitmentPhone {
  const FitmentPhone({
    required this.brand,
    required this.name,
    this.year,
    this.batteryMah,
    this.inches,
    this.resolution = '',
    this.modelCode = '',
  });

  final String brand;
  final String name;
  final int? year;
  final int? batteryMah;
  final double? inches;
  final String resolution;
  final String modelCode;

  String get title => name;

  factory FitmentPhone.fromJson(Map<String, dynamic> json) {
    return FitmentPhone(
      brand: '${json['b'] ?? ''}',
      name: '${json['n'] ?? ''}',
      year: json['y'] is num ? (json['y'] as num).toInt() : null,
      batteryMah: json['m'] is num ? (json['m'] as num).toInt() : null,
      inches: json['i'] is num ? (json['i'] as num).toDouble() : null,
      resolution: '${json['r'] ?? ''}',
      modelCode: '${json['c'] ?? ''}',
    );
  }
}

class FitmentCategory {
  const FitmentCategory({
    required this.code,
    required this.label,
    required this.blurb,
  });

  final String code;
  final String label;
  final String blurb;
}

const fitmentCategories = <FitmentCategory>[
  FitmentCategory(
    code: 'DISPLAY_FOLDER',
    label: 'Display',
    blurb: 'Panel and combo assemblies',
  ),
  FitmentCategory(
    code: 'BATTERY',
    label: 'Battery',
    blurb: 'Cell capacity from public specs',
  ),
  FitmentCategory(
    code: 'TEMPERED_GLASS',
    label: 'Tempered glass',
    blurb: 'Protector size, cutout still unchecked',
  ),
  FitmentCategory(
    code: 'TOUCH_OCA',
    label: 'Touch / OCA',
    blurb: 'Touch glass for this panel',
  ),
  FitmentCategory(
    code: 'BACK_COVER',
    label: 'Back cover',
    blurb: 'Rear housing for this model',
  ),
  FitmentCategory(
    code: 'FRAME',
    label: 'Frame',
    blurb: 'Middle frame for this model',
  ),
  FitmentCategory(
    code: 'POWER_VOLUME_FLEX',
    label: 'Side keys',
    blurb: 'Power and volume flex',
  ),
  FitmentCategory(
    code: 'CHARGING_BOARD',
    label: 'Charging board',
    blurb: 'Sub-board and port',
  ),
  FitmentCategory(
    code: 'DISPLAY_CONNECTOR',
    label: 'Display connector',
    blurb: 'Panel flex connector',
  ),
  FitmentCategory(
    code: 'CAMERA',
    label: 'Camera',
    blurb: 'Rear and front modules',
  ),
  FitmentCategory(
    code: 'SPEAKER',
    label: 'Speaker',
    blurb: 'Earpiece and loudspeaker',
  ),
  FitmentCategory(
    code: 'MICROPHONE',
    label: 'Microphone',
    blurb: 'Main and secondary mics',
  ),
  FitmentCategory(
    code: 'IC_CHIP',
    label: 'IC / chip',
    blurb: 'Power, charging, and audio ICs',
  ),
];

FitmentCategory? categoryByCode(String code) {
  for (final category in fitmentCategories) {
    if (category.code == code) return category;
  }
  return null;
}

class FitmentLibrary {
  FitmentLibrary._(this.phones);

  final List<FitmentPhone> phones;

  static FitmentLibrary? _cached;

  static Future<FitmentLibrary> load() async {
    final existing = _cached;
    if (existing != null) return existing;
    final raw = await rootBundle.loadString('assets/fitment_catalog.json');
    final decoded = jsonDecode(raw);
    final rows = decoded is Map ? decoded['phones'] : null;
    final phones = <FitmentPhone>[];
    if (rows is List) {
      for (final row in rows) {
        if (row is Map) {
          phones.add(FitmentPhone.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }
    final library = FitmentLibrary._(phones);
    _cached = library;
    return library;
  }

  List<String> brands() {
    final names = phones.map((p) => p.brand).toSet().toList();
    names.sort();
    return names;
  }

  int countBrand(String brand) =>
      phones.where((p) => p.brand == brand).length;

  List<FitmentPhone> byBrand(String brand) {
    final rows = phones.where((p) => p.brand == brand).toList();
    rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rows;
  }

  FitmentPhone? findPhone(String brand, String name) {
    for (final phone in phones) {
      if (phone.brand == brand && phone.name == name) return phone;
    }
    return null;
  }

  List<FitmentPhone> search(String query, {String? brand}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return phones.where((p) {
      if (brand != null && p.brand != brand) return false;
      final hay = '${p.brand} ${p.name} ${p.modelCode} ${p.resolution}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }
}

String fitmentSpec(FitmentPhone phone, String category) {
  final bits = <String>[];
  final panel = category == 'DISPLAY_FOLDER' ||
      category == 'TOUCH_OCA' ||
      category == 'TEMPERED_GLASS' ||
      category == 'DISPLAY_CONNECTOR';
  if (category == 'BATTERY' && phone.batteryMah != null) {
    bits.add('${phone.batteryMah} mAh');
  }
  if (panel) {
    if (phone.inches != null) bits.add('${_trimInches(phone.inches!)} in');
    if (phone.resolution.isNotEmpty) bits.add(phone.resolution);
  }
  if (phone.modelCode.isNotEmpty) bits.add(phone.modelCode);
  if (bits.isEmpty && phone.year != null) bits.add('${phone.year}');
  if (bits.isEmpty && phone.batteryMah != null) bits.add('${phone.batteryMah} mAh');
  return bits.join(' · ');
}

String _trimInches(double inches) {
  final text = inches.toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}
