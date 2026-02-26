import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';
import '../data/room_presets.dart';
import 'box_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'アイテム名で検索（例: 包丁）',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.borderRadius),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state =
                              '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          if (results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingMedium),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '検索結果: ${results.length}件',
                  style:
                      const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'アイテム名を入力してください'
                          : '該当するアイテムが見つかりません',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(
                        Dimensions.paddingMedium),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final roomIcon =
                          RoomPresets.roomIcons[result.box.room] ??
                              '📦';
                      return Card(
                        child: ListTile(
                          leading: Text(roomIcon,
                              style:
                                  const TextStyle(fontSize: 28)),
                          title: Text(
                              '${result.box.name}: ${result.box.room}'),
                          subtitle: Text(
                            'ヒット: 「${result.item.name}${result.item.quantity > 1 ? ' x${result.item.quantity}' : ''}」',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                result.box.isOpened
                                    ? Icons.check_box
                                    : Icons
                                        .check_box_outline_blank,
                                color: result.box.isOpened
                                    ? AppColors.opened
                                    : AppColors.unopened,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BoxDetailScreen(
                                  boxId: result.box.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
