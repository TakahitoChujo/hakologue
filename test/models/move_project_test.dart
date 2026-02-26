import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/models/move_project.dart';

void main() {
  group('MoveProject', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final project = MoveProject(
        id: 'test-id',
        name: 'テストプロジェクト',
        createdAt: now,
      );

      expect(project.id, 'test-id');
      expect(project.name, 'テストプロジェクト');
      expect(project.createdAt, now);
      expect(project.completedAt, isNull);
    });

    test('creates with optional completedAt', () {
      final now = DateTime.now();
      final project = MoveProject(
        id: 'test-id',
        name: 'テスト',
        createdAt: now,
        completedAt: now,
      );

      expect(project.completedAt, now);
    });

    test('toJson serializes correctly', () {
      final createdAt = DateTime(2026, 3, 1, 10, 0);
      final project = MoveProject(
        id: 'abc-123',
        name: '2026年引っ越し',
        createdAt: createdAt,
      );

      final json = project.toJson();
      expect(json['id'], 'abc-123');
      expect(json['name'], '2026年引っ越し');
      expect(json['createdAt'], createdAt.toIso8601String());
      expect(json['completedAt'], isNull);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'abc-123',
        'name': '2026年引っ越し',
        'createdAt': '2026-03-01T10:00:00.000',
        'completedAt': '2026-04-01T10:00:00.000',
      };

      final project = MoveProject.fromJson(json);
      expect(project.id, 'abc-123');
      expect(project.name, '2026年引っ越し');
      expect(project.createdAt, DateTime(2026, 3, 1, 10, 0));
      expect(project.completedAt, DateTime(2026, 4, 1, 10, 0));
    });

    test('fromJson handles null completedAt', () {
      final json = {
        'id': 'abc',
        'name': 'テスト',
        'createdAt': '2026-03-01T10:00:00.000',
        'completedAt': null,
      };

      final project = MoveProject.fromJson(json);
      expect(project.completedAt, isNull);
    });

    test('roundtrip toJson -> fromJson preserves data', () {
      final original = MoveProject(
        id: 'roundtrip-id',
        name: '往復テスト',
        createdAt: DateTime(2026, 3, 15, 12, 30),
        completedAt: DateTime(2026, 4, 15, 18, 0),
      );

      final restored = MoveProject.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.createdAt, original.createdAt);
      expect(restored.completedAt, original.completedAt);
    });

    test('name is mutable', () {
      final project = MoveProject(
        id: 'id',
        name: '旧名',
        createdAt: DateTime.now(),
      );
      project.name = '新名';
      expect(project.name, '新名');
    });
  });
}
