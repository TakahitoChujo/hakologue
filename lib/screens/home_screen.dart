import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/box_provider.dart';
import '../providers/project_provider.dart';
import '../widgets/box_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/room_filter_chips.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';
import 'box_add_screen.dart';
import 'box_detail_screen.dart';
import 'qr_scan_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(currentProjectProvider);
    final boxes = ref.watch(filteredBoxListProvider);
    final allBoxes = ref.watch(boxListProvider);
    final selectedRoom = ref.watch(selectedRoomProvider);

    final totalBoxes = allBoxes.length;
    final openedBoxes = allBoxes.where((b) => b.isOpened).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(project?.name ?? 'ハコログ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrScanScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingMedium),
            child: OpeningProgressBar(
                opened: openedBoxes, total: totalBoxes),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingMedium),
            child: RoomFilterChips(
              selectedRoom: selectedRoom,
              onSelected: (room) =>
                  ref.read(selectedRoomProvider.notifier).state = room,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: boxes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'まだ箱がありません\n＋ボタンから箱を追加しましょう',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingMedium),
                    itemCount: boxes.length,
                    itemBuilder: (context, index) {
                      final box = boxes[index];
                      final items =
                          ref.watch(boxItemsProvider(box.id));
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BoxCard(
                          box: box,
                          items: items,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BoxDetailScreen(boxId: box.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BoxAddScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('箱を追加'),
      ),
    );
  }
}
