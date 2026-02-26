class MoveProject {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime? completedAt;

  MoveProject({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MoveProject.fromJson(Map<String, dynamic> json) => MoveProject(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}
