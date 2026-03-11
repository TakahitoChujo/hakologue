import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/move_project.dart';
import '../services/database_service.dart';
import 'database_provider.dart';

const _uuid = Uuid();

final currentProjectProvider =
    StateNotifierProvider<CurrentProjectNotifier, MoveProject?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return CurrentProjectNotifier(db);
});

class CurrentProjectNotifier extends StateNotifier<MoveProject?> {
  final DatabaseService _db;

  CurrentProjectNotifier(this._db) : super(null);

  void load() {
    final projectId = _db.currentProjectId;
    if (projectId != null) {
      state = _db.getProject(projectId);
    }

    if (state == null) {
      final projects = _db.getAllProjects();
      if (projects.isNotEmpty) {
        state = projects.first;
        _db.setCurrentProjectId(state!.id);
      }
    }
  }

  Future<void> createProject(String name) async {
    final project = MoveProject(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _db.saveProject(project);
    await _db.setCurrentProjectId(project.id);
    state = project;
  }

  Future<void> selectProject(String id) async {
    final project = _db.getProject(id);
    if (project != null) {
      state = project;
      await _db.setCurrentProjectId(id);
    }
  }

  List<MoveProject> getAllProjects() => _db.getAllProjects();
}
