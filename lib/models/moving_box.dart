class MovingBox {
  final String id;
  final String projectId;
  String name;
  String room;
  List<String> photoIds;
  bool isOpened;
  final DateTime createdAt;
  DateTime? openedAt;

  MovingBox({
    required this.id,
    required this.projectId,
    required this.name,
    required this.room,
    List<String>? photoIds,
    this.isOpened = false,
    required this.createdAt,
    this.openedAt,
  }) : photoIds = photoIds ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'room': room,
        'photoIds': photoIds,
        'isOpened': isOpened,
        'createdAt': createdAt.toIso8601String(),
        'openedAt': openedAt?.toIso8601String(),
      };

  factory MovingBox.fromJson(Map<String, dynamic> json) => MovingBox(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        name: json['name'] as String,
        room: json['room'] as String,
        photoIds: List<String>.from(json['photoIds'] as List? ?? []),
        isOpened: json['isOpened'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        openedAt: json['openedAt'] != null
            ? DateTime.parse(json['openedAt'] as String)
            : null,
      );
}
