import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';

class OpeningProgressBar extends StatelessWidget {
  final int opened;
  final int total;

  const OpeningProgressBar({
    super.key,
    required this.opened,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? opened / total : 0.0;

    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '開封進捗',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$opened / $total 箱',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.opened),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '開封済み: $opened / 未開封: ${total - opened}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
