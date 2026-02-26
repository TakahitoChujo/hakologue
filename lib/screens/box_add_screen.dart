import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/box_provider.dart';
import '../providers/database_provider.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';
import '../data/room_presets.dart';
import '../widgets/item_input_row.dart';
import '../widgets/photo_preview.dart';
import '../widgets/qr_display.dart';
import 'box_detail_screen.dart';

class BoxAddScreen extends ConsumerStatefulWidget {
  const BoxAddScreen({super.key});

  @override
  ConsumerState<BoxAddScreen> createState() => _BoxAddScreenState();
}

class _BoxAddScreenState extends ConsumerState<BoxAddScreen> {
  final _nameController = TextEditingController();
  String _selectedRoom = RoomPresets.rooms.first;
  final List<Map<String, dynamic>> _pendingItems = [];
  final List<String> _photoPaths = [];
  String? _createdBoxId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBox() async {
    if (_isSaving) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('箱の名前を入力してください')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final box = await ref.read(boxListProvider.notifier).addBox(
            name: name,
            room: _selectedRoom,
          );

      final itemsNotifier = ref.read(boxItemsProvider(box.id).notifier);
      for (final item in _pendingItems) {
        await itemsNotifier.addItem(
          name: item['name'] as String,
          quantity: item['quantity'] as int,
        );
      }

      for (final path in _photoPaths) {
        await ref
            .read(boxListProvider.notifier)
            .addPhotoToBox(box.id, path);
      }

      setState(() => _createdBoxId = box.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addPhoto() async {
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
      path = await photoService.takePhoto('temp', 'temp');
    } else {
      path = await photoService.pickFromGallery('temp', 'temp');
    }

    if (path != null) {
      setState(() => _photoPaths.add(path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdBoxId != null) {
      return _buildQrResult();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('箱を追加'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('箱の名前',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: '例: キッチン - 食器',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('部屋カテゴリ',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RoomPresets.rooms.map((room) {
                final icon = RoomPresets.roomIcons[room] ?? '📦';
                return ChoiceChip(
                  label: Text('$icon $room'),
                  selected: _selectedRoom == room,
                  onSelected: (_) =>
                      setState(() => _selectedRoom = room),
                  selectedColor:
                      AppColors.primary.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('中身を登録',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ItemInputRow(
              onAdd: (name, quantity) {
                setState(() {
                  _pendingItems
                      .add({'name': name, 'quantity': quantity});
                });
              },
            ),
            const SizedBox(height: 8),
            ..._pendingItems.asMap().entries.map((entry) => ListTile(
                  dense: true,
                  title: Text(entry.value['name'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('x${entry.value['quantity']}'),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, size: 20),
                        onPressed: () => setState(
                            () => _pendingItems.removeAt(entry.key)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            const Text('写真を撮影',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            PhotoPreview(
              photoPaths: _photoPaths,
              onAddPhoto: _addPhoto,
              onDeletePhoto: (index) =>
                  setState(() => _photoPaths.removeAt(index)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBox,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.borderRadius),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('箱を保存してQRコードを表示',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrResult() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコード生成完了'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.opened, size: 64),
              const SizedBox(height: 16),
              const Text('箱を作成しました！',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('このQRコードを印刷して段ボールに貼ってください',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              QrDisplay(
                boxId: _createdBoxId!,
                boxName: _nameController.text,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BoxDetailScreen(boxId: _createdBoxId!),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('箱の詳細を見る'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ホームに戻る'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
