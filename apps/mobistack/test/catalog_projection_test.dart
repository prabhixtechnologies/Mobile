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

  test('the ticked list and the opened phone agree', () {
    final catalog = {
      'brands': [
        {'id': 'b1', 'name': 'Samsung'},
      ],
      'devices': [
        {'id': 'a', 'brandId': 'b1', 'name': 'A10'},
        {'id': 'b', 'brandId': 'b1', 'name': 'A20'},
        {'id': 'solo', 'brandId': 'b1', 'name': 'A30'},
      ],
      'components': [
        {'id': 'combo', 'categoryCode': 'display_folder', 'name': 'Combo'},
        {'id': 'dangling', 'categoryCode': 'DISPLAY_FOLDER', 'name': 'Broken'},
      ],
      'fitments': [
        {'id': 'f1', 'componentId': 'combo', 'deviceId': 'a'},
        {'id': 'f2', 'componentId': 'combo', 'deviceId': 'b'},
        {'id': 'f3', 'componentId': 'dangling', 'deviceId': 'solo'},
        {'id': 'f4', 'componentId': 'dangling', 'deviceId': 'missing-phone'},
      ],
    };
    final index = CatalogIndex(catalog);
    final rows = index.list('commons/devices', {
      'brandId': 'b1',
      'categoryCode': 'DISPLAY_FOLDER',
    })!;
    expect(rows.firstWhere((row) => row['id'] == 'a')['shared'], isTrue);
    expect(rows.firstWhere((row) => row['id'] == 'solo')['shared'], isFalse);

    final page = index.detail('a', 'display_folder', categoryLabel: 'Display')!;
    final members = ((page['families'] as List).single as Map)['members'] as List;
    expect(members.map((member) => (member as Map)['id']), ['a', 'b']);

    final stored = projectCatalogLists('g1', catalog);
    final storedRows = stored[catalogListStorageKey(
      'commons/devices',
      {'brandId': 'b1', 'categoryCode': 'DISPLAY_FOLDER'},
      groupId: 'g1',
    )]!;
    expect(storedRows.firstWhere((row) => row['id'] == 'a')['shared'], isTrue);
    expect(storedRows.firstWhere((row) => row['id'] == 'solo')['shared'], isFalse);
  });

  test('a graph larger than one database value splits and joins', () {
    final graph = 'x' * (catalogGraphChunkChars + 10);
    final chunks = splitCatalogGraph(graph);
    expect(chunks, hasLength(2));
    expect(chunks.join(), graph);
    expect(splitCatalogGraph(''), isEmpty);
  });

  test('a phone page is built for every phone in the snapshot', () {
    final catalog = {
      'brands': [
        {'id': 'b1', 'name': 'Samsung'},
      ],
      'devices': [
        {'id': 'd1', 'brandId': 'b1', 'name': 'A10'},
      ],
      'components': [
        {'id': 'c1', 'categoryCode': 'display_folder', 'name': 'Combo', 'description': ''},
      ],
      'fitments': [
        {
          'id': 'f1',
          'componentId': 'c1',
          'deviceId': 'd1',
          'fitQuality': 'EXACT',
          'confirmations': 1,
          'disputes': 0,
          'disputed': false,
          'verified': true,
        },
      ],
    };
    final page = CatalogIndex(catalog).detail('d1', 'DISPLAY_FOLDER', categoryLabel: 'Display');
    expect(page, isNotNull);
    expect((page!['families'] as List), hasLength(1));
  });

  test('search finds a brand, a phone, or both words together', () {
    final catalog = {
      'brands': [
        {'id': 'samsung', 'name': 'Samsung'},
        {'id': 'apple', 'name': 'Apple'},
      ],
      'devices': [
        {'id': 'm20', 'brandId': 'samsung', 'name': 'Galaxy M20', 'modelCode': 'SM-M205F'},
        {'id': 'a12', 'brandId': 'samsung', 'name': 'Galaxy A12', 'modelCode': ''},
        {'id': 'se', 'brandId': 'apple', 'name': 'iPhone SE (2022)', 'modelCode': 'A2595'},
      ],
      'components': [
        {'id': 'shared', 'categoryCode': 'DISPLAY_FOLDER', 'name': 'Shared combo'},
      ],
      'fitments': [
        {'id': 'f1', 'componentId': 'shared', 'deviceId': 'm20', 'fitQuality': 'EXACT'},
        {'id': 'f2', 'componentId': 'shared', 'deviceId': 'a12', 'fitQuality': 'EXACT'},
        {'id': 'f3', 'componentId': 'shared', 'deviceId': 'se', 'fitQuality': 'EXACT'},
      ],
    };

    final index = CatalogIndex(catalog);
    final model = index.search('DISPLAY_FOLDER', 'm20');
    expect(model.brands, isEmpty);
    expect(model.phones.map((row) => row['id']), ['m20']);
    expect(model.phones.single['brandName'], 'Samsung');

    final brand = index.search('DISPLAY_FOLDER', 'samsung');
    expect(brand.brands.map((row) => row['id']), ['samsung']);
    expect(brand.phones, isEmpty);

    final both = index.search('DISPLAY_FOLDER', 'samsung m20');
    expect(both.brands, isEmpty);
    expect(both.phones.map((row) => row['id']), ['m20']);

    final code = index.search('DISPLAY_FOLDER', 'sm-m205f');
    expect(code.phones.map((row) => row['id']), ['m20']);

    final spaced = index.search('display_folder', 'se 2022');
    expect(spaced.phones.map((row) => row['id']), ['se']);
    expect(index.search('DISPLAY_FOLDER', 'apple se').phones.map((row) => row['id']), ['se']);

    expect(catalogSearchHits('galaxy a12', ['Samsung', 'Galaxy A12']), isTrue);
    expect(catalogPhoneSearchHits('samsung', fields: ['Samsung', 'Galaxy M20'], phoneFields: ['Galaxy M20']), isFalse);
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
