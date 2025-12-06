class ParentProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? role;

  ParentProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
  });

  factory ParentProfileModel.fromJson(Map<String, dynamic> json) {
    return ParentProfileModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  ParentProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
  }) {
    return ParentProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}
