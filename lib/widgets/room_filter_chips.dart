import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../data/room_presets.dart';

class RoomFilterChips extends StatelessWidget {
  final String? selectedRoom;
  final ValueChanged<String?> onSelected;

  const RoomFilterChips({
    super.key,
    required this.selectedRoom,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('全て'),
              selected: selectedRoom == null,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          ),
          ...RoomPresets.rooms.map((room) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(room),
                  selected: selectedRoom == room,
                  onSelected: (_) =>
                      onSelected(selectedRoom == room ? null : room),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              )),
        ],
      ),
    );
  }
}
