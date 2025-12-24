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

  // ✅ This is what gets called when READING from database
  factory GrowthLog.fromJson(Map<String, dynamic> json) {
    return GrowthLog(
      id: json['id']?.toString() ?? '',
      childId: json['child_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      date: DateTime.parse(
        json['date']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      height: json['height'] != null
          ? double.parse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : null,
      headCircumference: json['head_circumference'] != null
          ? double.parse(json['head_circumference'].toString())
          : null,
      notes: json['notes']?.toString(),
      createdAt: DateTime.parse(
        json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // ✅ This is what gets called when INSERTING to database
  // Notice: NO 'id' field - lets database generate it!
  Map<String, dynamic> toJson() {
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

  // ✅ Needed for editing functionality
  GrowthLog copyWith({
    String? id,
    String? childId,
    String? userId,
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
      userId: userId ?? this.userId,
      date: date ?? this.date,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      headCircumference: headCircumference ?? this.headCircumference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}