import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/models/moving_box.dart';

void main() {
  group('MovingBox', () {
    test('creates with required fields and defaults', () {
      final now = DateTime.now();
      final box = MovingBox(
        id: 'box-1',
        projectId: 'proj-1',
        name: 'キッチン食器',
        room: 'キッチン',
        createdAt: now,
      );

      expect(box.id, 'box-1');
      expect(box.projectId, 'proj-1');
      expect(box.name, 'キッチン食器');
      expect(box.room, 'キッチン');
      expect(box.photoIds, isEmpty);
      expect(box.isOpened, false);
      expect(box.createdAt, now);
      expect(box.openedAt, isNull);
    });

    test('photoIds defaults to empty list', () {
      final box = MovingBox(
        id: 'id',
        projectId: 'pid',
        name: 'test',
        room: 'test',
        createdAt: DateTime.now(),
      );
      expect(box.photoIds, isA<List<String>>());
      expect(box.photoIds, isEmpty);
    });

    test('toJson serializes all fields', () {
      final box = MovingBox(
        id: 'box-1',
        projectId: 'proj-1',
        name: 'テスト箱',
        room: 'リビング',
        photoIds: ['/path/to/photo.jpg'],
        isOpened: true,
        createdAt: DateTime(2026, 3, 1),
        openedAt: DateTime(2026, 3, 2),
      );

      final json = box.toJson();
      expect(json['id'], 'box-1');
      expect(json['projectId'], 'proj-1');
      expect(json['photoIds'], ['/path/to/photo.jpg']);
      expect(json['isOpened'], true);
      expect(json['openedAt'], isNotNull);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'box-1',
        'projectId': 'proj-1',
        'name': 'テスト箱',
        'room': 'リビング',
        'photoIds': ['/path/photo.jpg'],
        'isOpened': true,
        'createdAt': '2026-03-01T00:00:00.000',
        'openedAt': '2026-03-02T00:00:00.000',
      };

      final box = MovingBox.fromJson(json);
      expect(box.id, 'box-1');
      expect(box.isOpened, true);
      expect(box.photoIds.length, 1);
      expect(box.openedAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'box-1',
        'projectId': 'proj-1',
        'name': 'テスト箱',
        'room': 'リビング',
        'createdAt': '2026-03-01T00:00:00.000',
      };

      final box = MovingBox.fromJson(json);
      expect(box.photoIds, isEmpty);
      expect(box.isOpened, false);
      expect(box.openedAt, isNull);
    });

    test('roundtrip preserves data', () {
      final original = MovingBox(
        id: 'rt-id',
        projectId: 'rt-proj',
        name: '往復箱',
        room: '寝室',
        photoIds: ['/a.jpg', '/b.jpg'],
        isOpened: true,
        createdAt: DateTime(2026, 3, 1),
        openedAt: DateTime(2026, 3, 5),
      );

      final restored = MovingBox.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.projectId, original.projectId);
      expect(restored.name, original.name);
      expect(restored.room, original.room);
      expect(restored.photoIds.length, 2);
      expect(restored.isOpened, original.isOpened);
    });

    test('isOpened toggle works', () {
      final box = MovingBox(
        id: 'id',
        projectId: 'pid',
        name: 'test',
        room: 'test',
        createdAt: DateTime.now(),
      );
      expect(box.isOpened, false);
      box.isOpened = true;
      box.openedAt = DateTime.now();
      expect(box.isOpened, true);
      expect(box.openedAt, isNotNull);
    });
  });
}
