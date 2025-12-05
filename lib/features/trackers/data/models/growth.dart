class GrowthLog {
  final String id;
  final String childId;
  final String userId;
  final DateTime date;
  final double? height;
  final double? weight;
  final double? headCircumference;
  final String? notes;
  final DateTime createdAt;

  GrowthLog({
    required this.id,
    required this.childId,
    required this.userId,
    required this.date,
    this.height,
    this.weight,
    this.headCircumference,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': childId,
      'user_id': userId,
      'date': date.toIso8601String(),
      'height': height,
      'weight': weight,
      'head_circumference': headCircumference,
      'notes': notes,
    };
  }

  factory GrowthLog.fromMap(Map<String, dynamic> map) {
    return GrowthLog(
      id: map['id'],
      childId: map['child_id'],
      userId: map['user_id'] ?? '',
      date: DateTime.parse(map['date']),
      height: map['height'] != null
          ? double.parse(map['height'].toString())
          : null,
      weight: map['weight'] != null
          ? double.parse(map['weight'].toString())
          : null,
      headCircumference: map['head_circumference'] != null
          ? double.parse(map['head_circumference'].toString())
          : null,
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
