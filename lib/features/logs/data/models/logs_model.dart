import 'package:tifli/features/trackers/data/models/meal.dart';

class FeedingLog {
  final String id;
  final String userId;
  final String childId;
  final DateTime mealTime;
  final String mealType;
  final String items;
  final int amount;
  final String status;
  final DateTime createdAt;

  FeedingLog({
    required this.id,
    required this.userId,
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
      userId: json['user_id'] ?? '',
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
      'user_id': userId,
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
      'user_id': userId,
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
    String? userId,
    String? childId,
    DateTime? mealTime,
    String? mealType,
    String? items,
    int? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return FeedingLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      childId: childId ?? this.childId,
      mealTime: mealTime ?? this.mealTime,
      mealType: mealType ?? this.mealType,
      items: items ?? this.items,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Meal feedingLogToMeal(FeedingLog log) {
  return Meal(
    id: log.id,
    userId: log.userId,
    childId: log.childId,
    mealTime: log.mealTime,
    mealType: log.mealType,
    items: log.items,
    amount: log.amount,
    status: log.status,
    createdAt: log.createdAt,
  );
}
}
