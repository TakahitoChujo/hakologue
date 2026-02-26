import 'package:hive_flutter/hive_flutter.dart';
import '../models/move_project.dart';
import '../models/moving_box.dart';
import '../models/item.dart';

class DatabaseService {
  static const String _projectsBox = 'projects';
  static const String _boxesBox = 'boxes';
  static const String _itemsBox = 'items';
  static const String _settingsBox = 'settings';

  late Box<dynamic> _projectsStore;
  late Box<dynamic> _boxesStore;
  late Box<dynamic> _itemsStore;
  late Box<dynamic> _settingsStore;

  Future<void> init() async {
    await Hive.initFlutter();
    _projectsStore = await Hive.openBox(_projectsBox);
    _boxesStore = await Hive.openBox(_boxesBox);
    _itemsStore = await Hive.openBox(_itemsBox);
    _settingsStore = await Hive.openBox(_settingsBox);
  }

  // --- Projects ---

  Future<void> saveProject(MoveProject project) async {
    await _projectsStore.put(project.id, project.toJson());
  }

  MoveProject? getProject(String id) {
    final data = _projectsStore.get(id);
    if (data == null) return null;
    return MoveProject.fromJson(Map<String, dynamic>.from(data as Map));
  }

  List<MoveProject> getAllProjects() {
    return _projectsStore.values
        .map((data) =>
            MoveProject.fromJson(Map<String, dynamic>.from(data as Map)))
        .toList();
  }

  Future<void> deleteProject(String id) async {
    await _projectsStore.delete(id);
    final boxes = getBoxesByProject(id);
    for (final box in boxes) {
      await deleteBox(box.id);
    }
  }

  // --- Current Project ---

  String? get currentProjectId =>
      _settingsStore.get('currentProjectId') as String?;

  Future<void> setCurrentProjectId(String id) async {
    await _settingsStore.put('currentProjectId', id);
  }

  // --- Boxes ---

  Future<void> saveBox(MovingBox box) async {
    await _boxesStore.put(box.id, box.toJson());
  }

  MovingBox? getBox(String id) {
    final data = _boxesStore.get(id);
    if (data == null) return null;
    return MovingBox.fromJson(Map<String, dynamic>.from(data as Map));
  }

  List<MovingBox> getBoxesByProject(String projectId) {
    return _boxesStore.values
        .map((data) =>
            MovingBox.fromJson(Map<String, dynamic>.from(data as Map)))
        .where((box) => box.projectId == projectId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> deleteBox(String id) async {
    await _boxesStore.delete(id);
    final items = getItemsByBox(id);
    for (final item in items) {
      await _itemsStore.delete(item.id);
    }
  }

  // --- Items ---

  Future<void> saveItem(Item item) async {
    await _itemsStore.put(item.id, item.toJson());
  }

  Item? getItem(String id) {
    final data = _itemsStore.get(id);
    if (data == null) return null;
    return Item.fromJson(Map<String, dynamic>.from(data as Map));
  }

  List<Item> getItemsByBox(String boxId) {
    return _itemsStore.values
        .map(
            (data) => Item.fromJson(Map<String, dynamic>.from(data as Map)))
        .where((item) => item.boxId == boxId)
        .toList();
  }

  Future<void> deleteItem(String id) async {
    await _itemsStore.delete(id);
  }

  // --- Search ---

  List<Map<String, dynamic>> searchItems(String query, String projectId) {
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
  }
}
