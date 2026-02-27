import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/move_project.dart';
import '../models/moving_box.dart';
import '../models/item.dart';

class DatabaseException implements Exception {
  final String message;
  final Object? cause;

  DatabaseException(this.message, [this.cause]);

  @override
  String toString() => 'DatabaseException: $message';
}

class DatabaseService {
  static const String _projectsBox = 'projects';
  static const String _boxesBox = 'boxes';
  static const String _itemsBox = 'items';
  static const String _settingsBox = 'settings';
  static const String _encryptionKeyName = 'hakologue_db_key';

  final FlutterSecureStorage _secureStorage;

  late Box<dynamic> _projectsStore;
  late Box<dynamic> _boxesStore;
  late Box<dynamic> _itemsStore;
  late Box<dynamic> _settingsStore;

  DatabaseService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> init() async {
    await Hive.initFlutter();
    final cipher = HiveAesCipher(await _getOrCreateKey());
    await _migrateIfNeeded(cipher);
    _projectsStore =
        await Hive.openBox(_projectsBox, encryptionCipher: cipher);
    _boxesStore = await Hive.openBox(_boxesBox, encryptionCipher: cipher);
    _itemsStore = await Hive.openBox(_itemsBox, encryptionCipher: cipher);
    _settingsStore =
        await Hive.openBox(_settingsBox, encryptionCipher: cipher);
  }

  Future<List<int>> _getOrCreateKey() async {
    final existing = await _secureStorage.read(key: _encryptionKeyName);
    if (existing != null) {
      return base64Url.decode(existing);
    }
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64Url.encode(key),
    );
    return key;
  }

  Future<void> _migrateIfNeeded(HiveAesCipher cipher) async {
    final migrated =
        await _secureStorage.read(key: '${_encryptionKeyName}_migrated');
    if (migrated == 'true') return;

    for (final name in [_projectsBox, _boxesBox, _itemsBox, _settingsBox]) {
      if (!await Hive.boxExists(name)) continue;

      try {
        final plain = await Hive.openBox(name);
        if (plain.isEmpty) {
          await plain.close();
          continue;
        }
        final data = Map<dynamic, dynamic>.from(plain.toMap());
        await plain.close();
        await Hive.deleteBoxFromDisk(name);

        final encrypted = await Hive.openBox(name, encryptionCipher: cipher);
        await encrypted.putAll(data);
        await encrypted.close();
      } catch (_) {
        if (Hive.isBoxOpen(name)) {
          await Hive.box(name).close();
        }
      }
    }

    await _secureStorage.write(
      key: '${_encryptionKeyName}_migrated',
      value: 'true',
    );
  }

  // --- Projects ---

  Future<void> saveProject(MoveProject project) async {
    try {
      await _projectsStore.put(project.id, project.toJson());
    } catch (e) {
      throw DatabaseException('プロジェクトの保存に失敗しました', e);
    }
  }

  MoveProject? getProject(String id) {
    try {
      final data = _projectsStore.get(id);
      if (data == null) return null;
      return MoveProject.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      throw DatabaseException('プロジェクトの取得に失敗しました', e);
    }
  }

  List<MoveProject> getAllProjects() {
    try {
      return _projectsStore.values
          .map((data) =>
              MoveProject.fromJson(Map<String, dynamic>.from(data as Map)))
          .toList();
    } catch (e) {
      throw DatabaseException('プロジェクト一覧の取得に失敗しました', e);
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _projectsStore.delete(id);
      final boxes = getBoxesByProject(id);
      for (final box in boxes) {
        await deleteBox(box.id);
      }
    } catch (e) {
      throw DatabaseException('プロジェクトの削除に失敗しました', e);
    }
  }

  // --- Current Project ---

  String? get currentProjectId {
    try {
      return _settingsStore.get('currentProjectId') as String?;
    } catch (e) {
      throw DatabaseException('設定の取得に失敗しました', e);
    }
  }

  Future<void> setCurrentProjectId(String id) async {
    try {
      await _settingsStore.put('currentProjectId', id);
    } catch (e) {
      throw DatabaseException('設定の保存に失敗しました', e);
    }
  }

  // --- Boxes ---

  Future<void> saveBox(MovingBox box) async {
    try {
      await _boxesStore.put(box.id, box.toJson());
    } catch (e) {
      throw DatabaseException('箱の保存に失敗しました', e);
    }
  }

  MovingBox? getBox(String id) {
    try {
      final data = _boxesStore.get(id);
      if (data == null) return null;
      return MovingBox.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      throw DatabaseException('箱の取得に失敗しました', e);
    }
  }

  List<MovingBox> getBoxesByProject(String projectId) {
    try {
      return _boxesStore.values
          .map((data) =>
              MovingBox.fromJson(Map<String, dynamic>.from(data as Map)))
          .where((box) => box.projectId == projectId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      throw DatabaseException('箱一覧の取得に失敗しました', e);
    }
  }

  Future<void> deleteBox(String id) async {
    try {
      await _boxesStore.delete(id);
      final items = getItemsByBox(id);
      for (final item in items) {
        await _itemsStore.delete(item.id);
      }
    } catch (e) {
      throw DatabaseException('箱の削除に失敗しました', e);
    }
  }

  // --- Items ---

  Future<void> saveItem(Item item) async {
    try {
      await _itemsStore.put(item.id, item.toJson());
    } catch (e) {
      throw DatabaseException('アイテムの保存に失敗しました', e);
    }
  }

  Item? getItem(String id) {
    try {
      final data = _itemsStore.get(id);
      if (data == null) return null;
      return Item.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      throw DatabaseException('アイテムの取得に失敗しました', e);
    }
  }

  List<Item> getItemsByBox(String boxId) {
    try {
      return _itemsStore.values
          .map(
              (data) => Item.fromJson(Map<String, dynamic>.from(data as Map)))
          .where((item) => item.boxId == boxId)
          .toList();
    } catch (e) {
      throw DatabaseException('アイテム一覧の取得に失敗しました', e);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _itemsStore.delete(id);
    } catch (e) {
      throw DatabaseException('アイテムの削除に失敗しました', e);
    }
  }

  // --- Search ---

  List<Map<String, dynamic>> searchItems(String query, String projectId) {
    try {
      final lowerQuery = query.toLowerCase();
      final results = <Map<String, dynamic>>[];

      final boxes = getBoxesByProject(projectId);
      for (final box in boxes) {
        final items = getItemsByBox(box.id);
        for (final item in items) {
          if (item.name.toLowerCase().contains(lowerQuery) ||
              (item.note?.toLowerCase().contains(lowerQuery) ?? false)) {
            results.add({
              'item': item,
              'box': box,
            });
          }
        }
      }
      return results;
    } catch (e) {
      throw DatabaseException('検索に失敗しました', e);
    }
  }
}
