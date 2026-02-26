import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';
import 'database_provider.dart';
import 'project_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final project = ref.watch(currentProjectProvider);
  final searchService = ref.watch(searchServiceProvider);

  if (query.isEmpty || project == null) return [];
  return searchService.search(query, project.id);
});
