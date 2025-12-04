class GrowthLog {
  final String id;
  final String childId;
  final DateTime date;
  final double height;
  final double weight;
  final double headCircumference;
  final String notes;
  final DateTime createdAt;

  GrowthLog({
    required this.id,
    required this.childId,
    required this.date,
    required this.height,
    required this.weight,
    required this.headCircumference,
    required this.notes,
    required this.createdAt,
  });

  factory GrowthLog.fromJson(Map<String, dynamic> json) {
    return GrowthLog(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      height: (json['height'] is double)
          ? json['height']
          : double.tryParse(json['height']?.toString() ?? '0') ?? 0.0,
      weight: (json['weight'] is double)
          ? json['weight']
          : double.tryParse(json['weight']?.toString() ?? '0') ?? 0.0,
      headCircumference: (json['head_circumference'] is double)
          ? json['head_circumference']
          : double.tryParse(json['head_circumference']?.toString() ?? '0') ??
                0.0,
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'date': date.toIso8601String(),
      'height': height,
      'weight': weight,
      'head_circumference': headCircumference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GrowthLog copyWith({
    String? id,
    String? childId,
    DateTime? date,
    double? height,
    double? weight,
    double? headCircumference,
    String? notes,
    DateTime? createdAt,
  }) {
    return GrowthLog(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      headCircumference: headCircumference ?? this.headCircumference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
