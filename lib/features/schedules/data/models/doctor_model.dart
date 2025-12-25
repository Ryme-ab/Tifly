class Doctor {
  final String id;
  final String fullName;
  final String? specialty;
  final String? phone;
  final String? hospitalName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.fullName,
    this.specialty,
    this.phone,
    this.hospitalName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      specialty: json['specialty'],
      phone: json['phone'],
      hospitalName: json['hospital_name'],
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
      'full_name': fullName,
      'specialty': specialty,
      'phone': phone,
      'hospital_name': hospitalName,
      'updated_at': updatedAt.toIso8601String(),
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Only include created_at if it's not a new item
    if (id.isNotEmpty) {
      json['created_at'] = createdAt.toIso8601String();
    }

    return json;
  }

  Doctor copyWith({
    String? id,
    String? fullName,
    String? specialty,
    String? phone,
    String? hospitalName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      hospitalName: hospitalName ?? this.hospitalName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
