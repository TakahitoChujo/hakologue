import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';

class QrDisplay extends StatelessWidget {
  final String boxId;
  final String boxName;

  const QrDisplay({
    super.key,
    required this.boxId,
    required this.boxName,
  });

  String get _qrData => 'hakologue://box/$boxId';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(Dimensions.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.borderRadius),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: Dimensions.qrSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          boxName,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
