import 'package:flutter/material.dart';

class SleepLog {
  final String id;
  final String childId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String quality;
  final String description;
  final DateTime createdAt;

  SleepLog({
    required this.id,
    required this.childId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.quality,
    required this.description,
    required this.createdAt,
  });

  /// ✅ FIXED: Properly calculates duration even when sleep crosses midnight
  String getFormattedDuration() {
    // Calculate the difference
    Duration duration = endTime.difference(startTime);
    
    // If duration is negative, it means end time is before start time
    // This happens when sleep crosses midnight but dates weren't set correctly
    // We should handle this by assuming it's the next day
    if (duration.isNegative) {
      // Add 24 hours to make it positive
      duration = duration + const Duration(days: 1);
    }
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  /// Get duration in minutes (useful for calculations)
  int getDurationInMinutes() {
    Duration duration = endTime.difference(startTime);
    
    // Handle negative duration (crossing midnight)
    if (duration.isNegative) {
      duration = duration + const Duration(days: 1);
    }
    
    return duration.inMinutes;
  }

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id']?.toString() ?? '',
      childId: json['child_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      startTime: DateTime.parse(
        json['start_time']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      endTime: DateTime.parse(
        json['end_time']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      quality: json['quality']?.toString() ?? 'fair',
      description: json['description']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quality': quality,
      'description': description,
    };
  }

  SleepLog copyWith({
    String? id,
    String? childId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? quality,
    String? description,
    DateTime? createdAt,
  }) {
    return SleepLog(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get qualityColor {
    switch (quality.toLowerCase()) {
      case 'good':
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'fair':
        return const Color(0xFFFFA726);
      case 'poor':
      case 'not_good':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  IconData get qualityIcon {
    switch (quality.toLowerCase()) {
      case 'good':
      case 'excellent':
        return Icons.sentiment_very_satisfied;
      case 'fair':
        return Icons.sentiment_neutral;
      case 'poor':
      case 'not_good':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}