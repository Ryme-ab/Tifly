class ProfileParent {
  final String id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? role;
  final String? profileImage;
  final DateTime? createdAt;

  ProfileParent({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.profileImage,
    this.createdAt,
  });

  factory ProfileParent.fromMap(Map<String, dynamic> map) {
    return ProfileParent(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      role: map['role'] as String?,
      profileImage: map['profile_image'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
