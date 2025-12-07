class ChecklistItem {
  final String id;
  final String userId;
  final String childId;
  final String title;
  final bool done;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChecklistItem({
    required this.id,
    required this.userId,
    required this.childId,
    required this.title,
    required this.done,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      childId: json['child_id'] ?? '',
      title: json['title'] ?? '',
      done: json['done'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'child_id': childId,
      'title': title,
      'done': done,
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Only include created_at if it's not a new item
    if (id.isNotEmpty) {
      json['created_at'] = createdAt.toIso8601String();
    }

    return json;
  }

  ChecklistItem copyWith({
    String? id,
    String? userId,
    String? childId,
    String? title,
    bool? done,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
