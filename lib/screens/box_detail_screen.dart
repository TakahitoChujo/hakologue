import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/box_provider.dart';
import '../providers/database_provider.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';
import '../widgets/item_input_row.dart';
import '../widgets/photo_preview.dart';
import '../widgets/qr_display.dart';

class BoxDetailScreen extends ConsumerWidget {
  final String boxId;

  const BoxDetailScreen({super.key, required this.boxId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxes = ref.watch(boxListProvider);
    final box = boxes.where((b) => b.id == boxId).firstOrNull;
    final items = ref.watch(boxItemsProvider(boxId));

    if (box == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('箱が見つかりません')),
        body: const Center(child: Text('この箱は存在しません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${box.name}: ${box.room}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoPreview(
              photoPaths: box.photoIds,
              onAddPhoto: () =>
                  _addPhoto(context, ref, box.projectId),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  box.isOpened
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color:
                      box.isOpened ? AppColors.opened : AppColors.unopened,
                  size: 32,
                ),
                title: Text(
                  box.isOpened ? '開封済み' : '未開封',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: box.isOpened
                        ? AppColors.opened
                        : AppColors.unopened,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => ref
                      .read(boxListProvider.notifier)
                      .toggleOpened(boxId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: box.isOpened
                        ? AppColors.unopened
                        : AppColors.opened,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                      box.isOpened ? '未開封に戻す' : '開封済みにする'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('中身',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ItemInputRow(
              onAdd: (name, quantity) {
                ref.read(boxItemsProvider(boxId).notifier).addItem(
                      name: name,
                      quantity: quantity,
                    );
              },
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('アイテムがまだありません',
                      style:
                          TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...items.map((item) => Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: AppColors.error,
                      child:
                          const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(boxItemsProvider(boxId).notifier)
                          .deleteItem(item.id);
                    },
                    child: ListTile(
                      title: Text(item.name),
                      trailing: item.quantity > 1
                          ? Text('x${item.quantity}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary))
                          : null,
                    ),
                  )),
            const SizedBox(height: 24),
            const Text('QRコード',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Center(
              child: QrDisplay(boxId: boxId, boxName: box.name),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto(
      BuildContext context, WidgetRef ref, String projectId) async {
    final photoService = ref.read(photoServiceProvider);
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('カメラで撮影'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('ギャラリーから選択'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    String? path;
    if (source == 'camera') {
      path = await photoService.takePhoto(projectId, boxId);
    } else {
      path = await photoService.pickFromGallery(projectId, boxId);
    }

    if (path != null) {
      ref.read(boxListProvider.notifier).addPhotoToBox(boxId, path);
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('箱を削除'),
        content: const Text(
            'この箱と中身のアイテムを削除しますか？この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(boxListProvider.notifier).deleteBox(boxId);
      Navigator.pop(context);
    }
  }
}
