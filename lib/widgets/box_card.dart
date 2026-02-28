import 'package:flutter/material.dart';
import '../models/moving_box.dart';
import '../models/item.dart';
import '../constants/app_colors.dart';
import '../constants/dimensions.dart';
import '../data/room_presets.dart';

class BoxCard extends StatelessWidget {
  final MovingBox box;
  final List<Item> items;
  final VoidCallback onTap;

  const BoxCard({
    super.key,
    required this.box,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final roomIcon = RoomPresets.roomIcons[box.room] ?? '📦';
    final itemNames = items.map((i) => i.name).take(3).join(', ');
    final extraCount =
        items.length > 3 ? '... 他${items.length - 3}件' : '';

    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingMedium),
          child: Row(
            children: [
              Text(roomIcon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: Dimensions.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${box.name}: ${box.room}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (items.isNotEmpty)
                      Text(
                        '$itemNames$extraCount',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          box.isOpened
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 18,
                          color: box.isOpened
                              ? AppColors.opened
                              : AppColors.unopened,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            box.isOpened ? '開封済み' : '未開封',
                            style: TextStyle(
                              fontSize: 13,
                              color: box.isOpened
                                  ? AppColors.opened
                                  : AppColors.unopened,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
