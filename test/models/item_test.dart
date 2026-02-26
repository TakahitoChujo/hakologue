import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/models/item.dart';

void main() {
  group('Item', () {
    test('creates with required fields and defaults', () {
      final item = Item(
        id: 'item-1',
        boxId: 'box-1',
        name: '赤いマグカップ',
      );

      expect(item.id, 'item-1');
      expect(item.boxId, 'box-1');
      expect(item.name, '赤いマグカップ');
      expect(item.quantity, 1);
      expect(item.note, isNull);
    });

    test('creates with optional fields', () {
      final item = Item(
        id: 'item-1',
        boxId: 'box-1',
        name: '皿',
        quantity: 5,
        note: '割れ物注意',
      );

      expect(item.quantity, 5);
      expect(item.note, '割れ物注意');
    });

    test('toJson serializes correctly', () {
      final item = Item(
        id: 'item-1',
        boxId: 'box-1',
        name: 'テスト',
        quantity: 3,
        note: 'メモ',
      );

      final json = item.toJson();
      expect(json['id'], 'item-1');
      expect(json['boxId'], 'box-1');
      expect(json['name'], 'テスト');
      expect(json['quantity'], 3);
      expect(json['note'], 'メモ');
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'item-1',
        'boxId': 'box-1',
        'name': 'コップ',
        'quantity': 2,
        'note': '白い',
      };

      final item = Item.fromJson(json);
      expect(item.id, 'item-1');
      expect(item.name, 'コップ');
      expect(item.quantity, 2);
      expect(item.note, '白い');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'item-1',
        'boxId': 'box-1',
        'name': 'テスト',
      };

      final item = Item.fromJson(json);
      expect(item.quantity, 1);
      expect(item.note, isNull);
    });

    test('roundtrip preserves data', () {
      final original = Item(
        id: 'rt-id',
        boxId: 'rt-box',
        name: '往復アイテム',
        quantity: 10,
        note: '往復メモ',
      );

      final restored = Item.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.boxId, original.boxId);
      expect(restored.name, original.name);
      expect(restored.quantity, original.quantity);
      expect(restored.note, original.note);
    });

    test('name and quantity are mutable', () {
      final item = Item(id: 'id', boxId: 'bid', name: '旧名');
      item.name = '新名';
      item.quantity = 5;
      expect(item.name, '新名');
      expect(item.quantity, 5);
    });
  });
}
