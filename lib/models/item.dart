class Item {
  final String id;
  final String boxId;
  String name;
  int quantity;
  String? note;

  Item({
    required this.id,
    required this.boxId,
    required this.name,
    this.quantity = 1,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'boxId': boxId,
        'name': name,
        'quantity': quantity,
        'note': note,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        boxId: json['boxId'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as int? ?? 1,
        note: json['note'] as String?,
      );
}
