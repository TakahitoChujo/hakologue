import '../models/item.dart';
import '../models/moving_box.dart';
import 'database_service.dart';

class SearchResult {
  final Item item;
  final MovingBox box;

  SearchResult({required this.item, required this.box});
}

class SearchService {
  final DatabaseService _db;

  SearchService(this._db);

  List<SearchResult> search(String query, String projectId) {
    if (query.isEmpty) return [];

    final results = _db.searchItems(query, projectId);
    return results
        .map((r) => SearchResult(
              item: r['item'] as Item,
              box: r['box'] as MovingBox,
            ))
        .toList();
  }
}
