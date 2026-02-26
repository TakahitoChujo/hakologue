import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/database_provider.dart';
import '../providers/project_provider.dart';
import '../constants/app_colors.dart';
import 'box_detail_screen.dart';

class QrScanScreen extends ConsumerStatefulWidget {
  const QrScanScreen({super.key});

  @override
  ConsumerState<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends ConsumerState<QrScanScreen> {
  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;

      if (value.startsWith('hakologue://box/')) {
        final boxId = value.replaceFirst('hakologue://box/', '');
        if (!_isValidUuid(boxId)) continue;
        _hasScanned = true;
        _navigateToBox(boxId);
        return;
      }
    }
  }

  static final _uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false);

  bool _isValidUuid(String value) =>
      value.length == 36 && _uuidRegex.hasMatch(value);

  void _navigateToBox(String boxId) {
    final db = ref.read(databaseServiceProvider);
    final project = ref.read(currentProjectProvider);
    final box = db.getBox(boxId);

    if (box != null && project != null && box.projectId == project.id) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => BoxDetailScreen(boxId: boxId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('この箱はこの端末に登録されていません')),
      );
      setState(() => _hasScanned = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スキャン'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: _onDetect,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: const Column(
              children: [
                Text(
                  '段ボールに貼ったQRコードを\nカメラに映してください',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'QRが読めない場合は\n箱一覧から検索もできます',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
