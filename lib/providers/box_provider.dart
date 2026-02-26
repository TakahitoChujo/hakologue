import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/moving_box.dart';
import '../models/item.dart';
import '../services/database_service.dart';
import 'database_provider.dart';
import 'project_provider.dart';

const _uuid = Uuid();

final boxListProvider =
    StateNotifierProvider<BoxListNotifier, List<MovingBox>>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final project = ref.watch(currentProjectProvider);
  return BoxListNotifier(db, project?.id);
});

final selectedRoomProvider = StateProvider<String?>((ref) => null);

final filteredBoxListProvider = Provider<List<MovingBox>>((ref) {
  final boxes = ref.watch(boxListProvider);
  final selectedRoom = ref.watch(selectedRoomProvider);

  if (selectedRoom == null) return boxes;
  return boxes.where((box) => box.room == selectedRoom).toList();
});

final boxItemsProvider =
    StateNotifierProvider.family<BoxItemsNotifier, List<Item>, String>(
        (ref, boxId) {
  final db = ref.watch(databaseServiceProvider);
  return BoxItemsNotifier(db, boxId);
});

class BoxListNotifier extends StateNotifier<List<MovingBox>> {
  final DatabaseService _db;
  final String? _projectId;

  BoxListNotifier(this._db, this._projectId) : super([]) {
    load();
  }

  void load() {
    if (_projectId == null) return;
    state = _db.getBoxesByProject(_projectId);
  }

  Future<MovingBox> addBox({required String name, required String room}) async {
    if (_projectId == null) throw Exception('No project selected');

    final box = MovingBox(
      id: _uuid.v4(),
      projectId: _projectId,
      name: name,
      room: room,
      createdAt: DateTime.now(),
    );
    await _db.saveBox(box);
    state = [...state, box];
    return box;
  }

  Future<void> updateBox(MovingBox box) async {
    await _db.saveBox(box);
    state = state.map((b) => b.id == box.id ? box : b).toList();
  }

  Future<void> toggleOpened(String boxId) async {
    final box = _db.getBox(boxId);
    if (box == null) return;

    box.isOpened = !box.isOpened;
    box.openedAt = box.isOpened ? DateTime.now() : null;
    await _db.saveBox(box);
    state = state.map((b) => b.id == boxId ? box : b).toList();
  }

  Future<void> deleteBox(String boxId) async {
    await _db.deleteBox(boxId);
    state = state.where((b) => b.id != boxId).toList();
  }

  Future<void> addPhotoToBox(String boxId, String photoPath) async {
    final box = _db.getBox(boxId);
    if (box == null) return;

    box.photoIds.add(photoPath);
    await _db.saveBox(box);
    state = state.map((b) => b.id == boxId ? box : b).toList();
  }
}

class BoxItemsNotifier extends StateNotifier<List<Item>> {
  final DatabaseService _db;
  final String _boxId;

  BoxItemsNotifier(this._db, this._boxId) : super([]) {
    load();
  }

  void load() {
    state = _db.getItemsByBox(_boxId);
  }

  Future<void> addItem(
      {required String name, int quantity = 1, String? note}) async {
    final item = Item(
      id: _uuid.v4(),
      boxId: _boxId,
      name: name,
      quantity: quantity,
      note: note,
    );
    await _db.saveItem(item);
    state = [...state, item];
  }

  Future<void> updateItem(Item item) async {
    await _db.saveItem(item);
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  Future<void> deleteItem(String itemId) async {
    await _db.deleteItem(itemId);
    state = state.where((i) => i.id != itemId).toList();
  }
}
