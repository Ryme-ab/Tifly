class PlannedMeal {
  final String id;
  final String userId;
  final String childId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final String title;
  final String subtitle;
  final bool isDone;
  final String? ingredients;
  final String? recipe;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlannedMeal({
    required this.id,
    required this.userId,
    required this.childId,
    required this.date,
    required this.mealType,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.ingredients,
    this.recipe,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      childId: json['child_id']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      mealType: json['meal_type']?.toString() ?? 'breakfast',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      // Handle both boolean (from Supabase) and integer (from SQLite)
      isDone: json['is_done'] is bool 
          ? json['is_done'] as bool
          : (json['is_done'] == 1 || json['is_done'] == true),
      ingredients: json['ingredients']?.toString(),
      recipe: json['recipe']?.toString(),
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
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'meal_type': mealType,
      'title': title,
      'subtitle': subtitle,
      'is_done': isDone,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Include optional fields if not null
    if (ingredients != null && ingredients!.isNotEmpty) {
      json['ingredients'] = ingredients;
    }
    if (recipe != null && recipe!.isNotEmpty) {
      json['recipe'] = recipe;
    }

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  Map<String, dynamic> toInsertJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'child_id': childId,
      'date': date.toIso8601String().split('T')[0],
      'meal_type': mealType,
      'title': title,
      'subtitle': subtitle,
      'is_done': isDone,
    };

    if (ingredients != null && ingredients!.isNotEmpty) {
      json['ingredients'] = ingredients;
    }
    if (recipe != null && recipe!.isNotEmpty) {
      json['recipe'] = recipe;
    }

    return json;
  }

  PlannedMeal copyWith({
    String? id,
    String? userId,
    String? childId,
    DateTime? date,
    String? mealType,
    String? title,
    String? subtitle,
    bool? isDone,
    String? ingredients,
    String? recipe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isDone: isDone ?? this.isDone,
      ingredients: ingredients ?? this.ingredients,
      recipe: recipe ?? this.recipe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper to get normalized date (without time)
  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);
}
