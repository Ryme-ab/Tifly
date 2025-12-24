class Appointment {
  final String id;
  final String childId;
  final String? doctorId;
  final String title;
  final String? description;
  final DateTime appointmentDate;
  final int? durationMinutes;
  final String? location;
  final String? hospitalName;
  final String status;
  final bool reminderEnabled;
  final int? reminderMinutesBefore;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.childId,
    this.doctorId,
    required this.title,
    this.description,
    required this.appointmentDate,
    this.durationMinutes,
    this.location,
    this.hospitalName,
    required this.status,
    required this.reminderEnabled,
    this.reminderMinutesBefore,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      childId: json['child_id'] ?? '',
      doctorId: json['doctor_id'],
      title: json['title'] ?? '',
      description: json['description'],
      appointmentDate: json['appointment_date'] != null
          ? DateTime.parse(json['appointment_date'])
          : DateTime.now(),
      durationMinutes: json['duration_minutes'],
      location: json['location'],
      hospitalName: json['hospital_name'],
      status: json['status'] ?? 'scheduled',
      reminderEnabled: json['reminder_enabled'] ?? true,
      reminderMinutesBefore: json['reminder_minutes_before'],
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
    final json = <String, dynamic>{
      'child_id': childId,
      'doctor_id': doctorId,
      'title': title,
      'description': description,
      'appointment_date': appointmentDate.toIso8601String(),
      'duration_minutes': durationMinutes,
      'location': location,
      'hospital_name': hospitalName,
      'status': status,
      'reminder_enabled': reminderEnabled,
      'reminder_minutes_before': reminderMinutesBefore,
      'notes': notes,
    };

    // Only include id, created_at, and updated_at for updates (when id exists and is not empty)
    if (id.isNotEmpty) {
      json['id'] = id;
      json['created_at'] = createdAt.toIso8601String();
      json['updated_at'] = updatedAt.toIso8601String();
    }
    // For inserts, Supabase will auto-generate id, created_at, and updated_at

    return json;
  }

  Appointment copyWith({
    String? id,
    String? childId,
    String? doctorId,
    String? title,
    String? description,
    DateTime? appointmentDate,
    int? durationMinutes,
    String? location,
    String? hospitalName,
    String? status,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      doctorId: doctorId ?? this.doctorId,
      title: title ?? this.title,
      description: description ?? this.description,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      hospitalName: hospitalName ?? this.hospitalName,
      status: status ?? this.status,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
