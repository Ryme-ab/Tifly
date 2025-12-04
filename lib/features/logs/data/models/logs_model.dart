class FeedingLog {
  final String id;
  final String childId;
  final DateTime mealTime;
  final String mealType;
  final String items;
  final int amount;
  final String status;
  final DateTime createdAt;

  FeedingLog({
    required this.id,
    required this.childId,
    required this.mealTime,
    required this.mealType,
    required this.items,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory FeedingLog.fromJson(Map<String, dynamic> json) {
    return FeedingLog(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      mealTime: json['meal_time'] != null 
          ? DateTime.parse(json['meal_time']) 
          : DateTime.now(),
      mealType: json['meal_type'] ?? '',
      items: json['items'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'meal_time': mealTime.toIso8601String(),
      'meal_type': mealType,
      'items': items,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'meal_time': mealTime.toIso8601String(),
      'meal_type': mealType,
      'items': items,
      'amount': amount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FeedingLog copyWith({
    String? id,
    String? childId,
    DateTime? mealTime,
    String? mealType,
    String? items,
    int? amount,
    String? status,
    DateTime? createdAt, required String mealtype,
  }) {
    return FeedingLog(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      mealTime: mealTime ?? this.mealTime,
      mealType: mealType ?? this.mealType,
      items: items ?? this.items,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
