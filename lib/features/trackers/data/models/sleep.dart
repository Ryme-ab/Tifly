class SleepLog {
  final String id;
  final String childId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String? quality;
  final String? notes;

  SleepLog({
    required this.id,
    required this.childId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    this.quality,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': childId,
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'quality': quality,
      'descp': notes,
    };
  }

  factory SleepLog.fromMap(Map<String, dynamic> map) {
    return SleepLog(
      id: map['id'],
      childId: map['child_id'],
      userId: map['user_id'] ?? '',
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      quality: map['quality'],
      notes: map['descp'],
    );
  }
}
