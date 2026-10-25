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
    final models = index.list('commons/devices', {'brandId': 'b1', 'categoryCode': 'DISPLAY_FOLDER'});
    expect(models, hasLength(phones));
    expect(models!.every((row) => row['shared'] == true), isTrue);
    final page = index.detail('d0', 'DISPLAY_FOLDER', categoryLabel: 'Display');
    final families = page!['families'] as List;
    final members = (families.single as Map)['members'] as List;
    expect(members, hasLength(phones));
    expect(index.detail('missing', 'DISPLAY_FOLDER', categoryLabel: 'Display'), isNull);
  });

  test('a spare that lists only its own phone is model-specific', () {
    final catalog = {
      'brands': [
        {'id': 'b1', 'name': 'Honor'},
        {'id': 'b2', 'name': 'Apple'},
      ],
      'devices': [
        {'id': 'honor8', 'brandId': 'b1', 'name': 'Honor 8'},
        {'id': 'honor9', 'brandId': 'b1', 'name': 'Honor 9'},
        {'id': 'bare', 'brandId': 'b1', 'name': 'Device'},
        {'id': 'se', 'brandId': 'b2', 'name': 'iPhone SE (2022)'},
      ],
      'components': [
        {'id': 'shared', 'categoryCode': 'DISPLAY_FOLDER', 'name': 'Shared combo'},
        {'id': 'solo', 'categoryCode': 'DISPLAY_FOLDER', 'name': 'Apple iPhone SE (2022) Folder'},
      ],
      'fitments': [
        {'id': 'f1', 'componentId': 'shared', 'deviceId': 'honor8', 'fitQuality': 'EXACT'},
        {'id': 'f2', 'componentId': 'shared', 'deviceId': 'honor9', 'fitQuality': 'EXACT'},
        {'id': 'f3', 'componentId': 'solo', 'deviceId': 'se', 'fitQuality': 'EXACT'},
      ],
    };

    final index = CatalogIndex(catalog);
    final honor = index.list('commons/devices', {
      'brandId': 'b1',
      'categoryCode': 'DISPLAY_FOLDER',
    });
    expect(honor!.firstWhere((row) => row['id'] == 'honor8')['shared'], isTrue);
    expect(honor.firstWhere((row) => row['id'] == 'honor9')['shared'], isTrue);
    expect(honor.firstWhere((row) => row['id'] == 'bare')['shared'], isFalse);

    final apple = index.list('commons/devices', {
      'brandId': 'b2',
      'categoryCode': 'DISPLAY_FOLDER',
    });
    expect(apple!.single['shared'], isFalse);

    final brands = index.list('commons/brands', {'categoryCode': 'DISPLAY_FOLDER'});
    expect(brands!.map((row) => row['id']), containsAll(['b1', 'b2']));

    final stored = projectCatalogLists('g1', catalog);
    final storedApple = stored[catalogListStorageKey(
      'commons/devices',
      {'brandId': 'b2', 'categoryCode': 'DISPLAY_FOLDER'},
      groupId: 'g1',
    )];
    expect(storedApple!.single['shared'], isFalse);
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
