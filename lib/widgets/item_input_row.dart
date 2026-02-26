import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ItemInputRow extends StatefulWidget {
  final Function(String name, int quantity) onAdd;

  const ItemInputRow({super.key, required this.onAdd});

  @override
  State<ItemInputRow> createState() => _ItemInputRowState();
}

class _ItemInputRowState extends State<ItemInputRow> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  static const _maxNameLength = 200;
  static const _maxQuantity = 9999;

  void _submit() {
    var name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (name.length > _maxNameLength) {
      name = name.substring(0, _maxNameLength);
    }

    final parsed = int.tryParse(_quantityController.text) ?? 1;
    final quantity = parsed.clamp(1, _maxQuantity);
    widget.onAdd(name, quantity);
    _nameController.clear();
    _quantityController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'アイテム名（例: 赤いマグカップ）',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              hintText: '数量',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _submit,
          icon: const Icon(Icons.add_circle),
          color: AppColors.primary,
          iconSize: 32,
        ),
      ],
    );
  }
}
