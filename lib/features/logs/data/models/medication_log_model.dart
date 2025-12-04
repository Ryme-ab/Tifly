class Medication {
  final String id;
  final String babyId;
  final String medicineName;
  final int dosage;
  final String durationUnit; // 'days', 'weeks', 'months'
  final int durationValue;
  final String frequencyType; // e.g., 'Everyday', 'Twice a day'
  final String? appearanceColor; // optional
  final String? timeOfMedication; // HH:mm:ss
  final int? frequencyPerDay;
  final int? intervalHours;
  final String? intervalStartTime; // HH:mm:ss
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.babyId,
    required this.medicineName,
    required this.dosage,
    required this.durationUnit,
    required this.durationValue,
    required this.frequencyType,
    this.appearanceColor,
    this.timeOfMedication,
    this.frequencyPerDay,
    this.intervalHours,
    this.intervalStartTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      babyId: json['baby_id'] ?? '',
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? 1,
      durationUnit: json['duration_unit'] ?? 'days',
      durationValue: json['duration_value'] ?? 1,
      frequencyType: json['frequency_type'] ?? 'Everyday',
      appearanceColor: json['appearance_color'],
      timeOfMedication: json['time_of_medication'],
      frequencyPerDay: json['frequency_per_day'],
      intervalHours: json['interval_hours'],
      intervalStartTime: json['interval_start_time'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baby_id': babyId,
      'medicine_name': medicineName,
      'dosage': dosage,
      'duration_unit': durationUnit,
      'duration_value': durationValue,
      'frequency_type': frequencyType,
      'appearance_color': appearanceColor,
      'time_of_medication': timeOfMedication,
      'frequency_per_day': frequencyPerDay,
      'interval_hours': intervalHours,
      'interval_start_time': intervalStartTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Medication copyWith({
    String? id,
    String? babyId,
    String? medicineName,
    int? dosage,
    String? durationUnit,
    int? durationValue,
    String? frequencyType,
    String? appearanceColor,
    String? timeOfMedication,
    int? frequencyPerDay,
    int? intervalHours,
    String? intervalStartTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      durationUnit: durationUnit ?? this.durationUnit,
      durationValue: durationValue ?? this.durationValue,
      frequencyType: frequencyType ?? this.frequencyType,
      appearanceColor: appearanceColor ?? this.appearanceColor,
      timeOfMedication: timeOfMedication ?? this.timeOfMedication,
      frequencyPerDay: frequencyPerDay ?? this.frequencyPerDay,
      intervalHours: intervalHours ?? this.intervalHours,
      intervalStartTime: intervalStartTime ?? this.intervalStartTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
