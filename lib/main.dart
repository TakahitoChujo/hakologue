import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'providers/database_provider.dart';
import 'providers/project_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService();
  try {
    await dbService.init();
  } catch (e) {
    runApp(_ErrorApp(message: 'データベースの初期化に失敗しました: $e'));
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const _AppInitializer(),
    ),
  );
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('起動エラー',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppInitializer extends ConsumerStatefulWidget {
  const _AppInitializer();

  @override
  ConsumerState<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<_AppInitializer> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final notifier = ref.read(currentProjectProvider.notifier);
        notifier.load();
        if (ref.read(currentProjectProvider) == null) {
          await notifier.createProject('引っ越しプロジェクト');
        }
        if (mounted) setState(() => _initialized = true);
      } catch (e) {
        if (mounted) setState(() => _error = e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('初期化エラー: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return const HakologueApp();
  }
}
