import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/services/search_service.dart';
import 'package:hakologue/models/item.dart';
import 'package:hakologue/models/moving_box.dart';

void main() {
  group('SearchResult', () {
    test('holds item and box references', () {
      final item = Item(id: 'i1', boxId: 'b1', name: '包丁');
      final box = MovingBox(
        id: 'b1',
        projectId: 'p1',
        name: 'キッチン箱',
        room: 'キッチン',
        createdAt: DateTime.now(),
      );

      final result = SearchResult(item: item, box: box);
      expect(result.item.name, '包丁');
      expect(result.box.name, 'キッチン箱');
    });
  });
}
