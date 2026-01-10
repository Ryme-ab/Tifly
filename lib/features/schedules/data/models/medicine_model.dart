class MedicineSchedule {
  final String id;
  final String babyId;
  final String medicineName;
  final int dosageAmount;
  final String dosageUnit;
  final String frequency;
  final List<String> times;
  final int durationValue;
  final String durationUnit;
  final String? color;
  final String? notes;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  MedicineSchedule({
    required this.id,
    required this.babyId,
    required this.medicineName,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequency,
    required this.times,
    required this.durationValue,
    required this.durationUnit,
    this.color,
    this.notes,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String,
      babyId: json['baby_id'] as String,
      medicineName: json['medicine_name'] as String,
      dosageAmount: json['dosage_amount'] as int,
      dosageUnit: json['dosage_unit'] as String,
      frequency: json['frequency'] as String,
      times: List<String>.from(json['times'] as List),
      durationValue: json['duration_value'] as int,
      durationUnit: json['duration_unit'] as String,
      color: json['color'] as String?,
      notes: json['notes'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baby_id': babyId,
      'medicine_name': medicineName,
      'dosage_amount': dosageAmount,
      'dosage_unit': dosageUnit,
      'frequency': frequency,
      'times': times,
      'duration_value': durationValue,
      'duration_unit': durationUnit,
      'color': color,
      'notes': notes,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
