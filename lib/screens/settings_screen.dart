import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(currentProjectProvider);
    final projectNotifier = ref.read(currentProjectProvider.notifier);
    final projects = projectNotifier.getAllProjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        children: [
          const Text('引っ越しプロジェクト',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...projects.map((p) => Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text('作成: ${_formatDate(p.createdAt)}'),
                  trailing: p.id == project?.id
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary)
                      : null,
                  onTap: () => projectNotifier.selectProject(p.id),
                ),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () =>
                _showCreateProjectDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('新しいプロジェクトを作成'),
          ),
          const Divider(height: 48),
          const Text('アプリについて',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('バージョン'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            title: Text('ハコログ'),
            subtitle: Text(
                '段ボールにQRコードを貼って中身を管理。\n「あれどこ？」をゼロにする引っ越しアプリ'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showCreateProjectDialog(
      BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいプロジェクト'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例: 2026年3月 引っ越し',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text),
            child: const Text('作成'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      ref
          .read(currentProjectProvider.notifier)
          .createProject(result.trim());
    }
    controller.dispose();
  }
}
