import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../services/photo_service.dart';
import '../services/search_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final photoServiceProvider = Provider<PhotoService>((ref) {
  return PhotoService();
});

final searchServiceProvider = Provider<SearchService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SearchService(db);
});
