class SleepLog {
  final String id;
  final String childId;
  final DateTime startTime;
  final DateTime endTime;
  final String quality;
  final String description;
  final DateTime createdAt;

  SleepLog({
    required this.id,
    required this.childId,
    required this.startTime,
    required this.endTime,
    required this.quality,
    required this.description,
    required this.createdAt,
  });

  factory SleepLog.fromJson(Map<String, dynamic> json) {
    return SleepLog(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time']) 
          : DateTime.now(),
      quality: json['quality'] ?? '',
      description: json['descp'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quality': quality,
      'descp': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quality': quality,
      'descp': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SleepLog copyWith({
    String? id,
    String? childId,
    DateTime? startTime,
    DateTime? endTime,
    String? quality,
    String? description,
    DateTime? createdAt,
  }) {
    return SleepLog(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to calculate duration in hours
  double getDurationInHours() {
    final duration = endTime.difference(startTime);
    return duration.inMinutes / 60.0;
  }

  // Helper method to format duration as "Xh Ym"
  String getFormattedDuration() {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
