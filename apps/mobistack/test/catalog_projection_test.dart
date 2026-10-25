import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobistack/services/catalog_mirror.dart';
import 'package:mobistack/services/catalog_projection.dart';

void main() {
  test('a shared part is stored once, not once per phone', () {
    const phones = 40;
    final catalog = {
      'brands': [
        {'id': 'b1', 'name': 'Samsung'},
      ],
      'devices': [
        for (var i = 0; i < phones; i++) {'id': 'd$i', 'brandId': 'b1', 'name': 'Phone $i'},
      ],
      'components': [
        {'id': 'c1', 'categoryCode': 'DISPLAY_FOLDER', 'name': 'Combo', 'description': ''},
      ],
      'fitments': [
        for (var i = 0; i < phones; i++)
          {
            'id': 'f$i',
            'componentId': 'c1',
            'deviceId': 'd$i',
            'fitQuality': 'EXACT',
            'confirmations': 1,
            'disputes': 0,
            'disputed': false,
            'verified': true,
          },
      ],
    };

    final prepared = prepareCatalogInstall({
      'group': 'g1',
      'raw': jsonEncode({
        'version': '9',
        'unchanged': false,
        'catalog': catalog,
      }),
    });

    expect(prepared, isNotNull);
    expect(prepared!.keys.where((key) => key.startsWith('catalog.detail.')), isEmpty);
    expect(prepared['version'], '9');

    final lists = projectCatalogLists('g1', catalog);
    final brandKey = catalogListStorageKey('commons/brands', const {}, groupId: 'g1');
    expect(lists[brandKey], hasLength(1));
    expect(lists[brandKey]!.single['deviceCount'], phones);

    final index = CatalogIndex(catalog);
    expect(index.list('commons/brands', {'categoryCode': 'DISPLAY_FOLDER'}), hasLength(1));
    expect(index.list('commons/brands', {'categoryCode': 'BATTERY'}), isEmpty);
    expect(
      index.list('commons/devices', {'brandId': 'b1', 'categoryCode': 'DISPLAY_FOLDER'}),
      hasLength(phones),
    );
    final page = index.detail('d0', 'DISPLAY_FOLDER', categoryLabel: 'Display');
    final families = page!['families'] as List;
    final members = (families.single as Map)['members'] as List;
    expect(members, hasLength(phones));
    expect(index.detail('missing', 'DISPLAY_FOLDER', categoryLabel: 'Display'), isNull);
  });

  test('every membership is downloaded, open group first', () {
    expect(
      catalogWarmOrder('b', ['a', 'b', 'c'], {}),
      ['b', 'a', 'c'],
    );
    expect(
      catalogWarmOrder('b', ['a', 'b', ''], {'a'}),
      ['b'],
    );
    expect(catalogWarmOrder(null, const [], {}), isEmpty);
  });

  test('an unchanged snapshot installs nothing', () {
    expect(
      prepareCatalogInstall({
        'group': 'g1',
        'raw': jsonEncode({'version': '9', 'unchanged': true, 'catalog': null}),
      }),
      isNull,
    );
  });
}
