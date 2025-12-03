class UserModel {
  final String? id; // Supabase ID (optional)
  final String fullName;
  final String email;
  final String phone;
  final String pwd;
  final String role;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.pwd,
    this.role = 'parent',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'pwd': pwd,
      'role': role,
    };
  }
}
