class Medication {
  final String id;
  final String babyId;
  final String medicineName;
  final int dosageAmount;
  final String dosageUnit;
  final String frequency;
  final List<String> times;
  final int durationValue;
  final String durationUnit;
  final String? notes;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Medication({
    required this.id,
    required this.babyId,
    required this.medicineName,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequency,
    required this.times,
    required this.durationValue,
    required this.durationUnit,
    this.notes,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      babyId: json['baby_id'] as String,
      medicineName: json['medicine_name'] as String,
      dosageAmount: json['dosage_amount'] as int,
      dosageUnit: json['dosage_unit'] as String,
      frequency: json['frequency'] as String,
      times: json['times'] != null ? List<String>.from(json['times']) : [],
      durationValue: json['duration_value'] as int,
      durationUnit: json['duration_unit'] as String,
      notes: json['notes'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
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
      'notes': notes,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  Medication copyWith({
    String? id,
    String? babyId,
    String? medicineName,
    int? dosageAmount,
    String? dosageUnit,
    String? frequency,
    List<String>? times,
    int? durationValue,
    String? durationUnit,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Medication(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      medicineName: medicineName ?? this.medicineName,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      durationValue: durationValue ?? this.durationValue,
      durationUnit: durationUnit ?? this.durationUnit,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
