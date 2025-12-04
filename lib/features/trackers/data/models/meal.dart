import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Meal {
  final String id;
  final String childId;
  final DateTime mealTime;
  final String mealType;
  final String items;
  final int amount;
  final String? status;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.childId,
    required this.mealTime,
    required this.mealType,
    required this.items,
    required this.amount,
    this.status,
    required this.createdAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id']?.toString() ?? '',
      childId: json['child_id']?.toString() ?? '',
      mealTime: DateTime.parse(json['meal_time']?.toString() ?? DateTime.now().toIso8601String()),
      mealType: json['meal_type']?.toString() ?? '',
      items: json['items']?.toString() ?? '',
      amount: json['amount'] is int ? json['amount'] as int : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'child_id': childId,
      'meal_time': mealTime.toIso8601String(),
      'meal_type': mealType,
      'items': items,
      'amount': amount,
      'status': status ?? 'completed',
    };
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(mealTime);
  }

  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(mealTime);
  }

  String get formattedDateTime {
    return DateFormat('MMM d, yyyy h:mm a').format(mealTime);
  }

  String get formattedDuration {
    return "${amount}ml";
  }

  Color get qualityColor {
    switch (mealType.toLowerCase()) {
      case 'breast milk':
        return const Color(0xffe0f7fa);
      case 'formula':
        return const Color(0xffffebee);
      case 'solid food':
        return const Color(0xfffff9c4);
      case 'juice':
        return const Color(0xffe8f5e9);
      default:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (mealType.toLowerCase()) {
      case 'breast milk':
        return Icons.water_drop;
      case 'formula':
        return Icons.local_drink;
      case 'solid food':
        return Icons.fastfood;
      case 'juice':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }
}