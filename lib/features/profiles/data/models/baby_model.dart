// lib/features/babies/data/models/baby_model.dart
class Baby {
  final String? id;
  final String parentId;
  final String firstName;
  final String birthDate;
  final String gender;
  final String? bloodtype;
  final int? circm;
  final int? born_weight;
  final int? born_height;
  final String? profileImage;

  Baby({
    this.id,
    required this.parentId,
    required this.firstName,
    required this.birthDate,
    required this.gender,
    this.bloodtype,
    this.circm,
    this.born_weight,
    this.born_height,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'first_name': firstName,
      'birth_date': birthDate,
      'gender': gender,
      'blood_type': bloodtype,
      'circum': circm,
      'born_weight': born_weight,
      'born_height': born_height,
      'profile_image': profileImage,
    };
  }

  factory Baby.fromMap(Map<String, dynamic> map) {
    return Baby(
      id: map['id'],
      parentId: map['parent_id'],
      firstName: map['first_name'],
      birthDate: map['birth_date'],
      gender: map['gender'],
      bloodtype: map['blood_type'],
      circm: map['circum'],
      born_weight: map['born_weight'],
      born_height: map['born_height'],
      profileImage: map['profile_image'],
    );
  }
}

/// Extension to calculate age from birthDate
extension BabyExtension on Baby {
  int get age {
    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return 0;
    final today = DateTime.now();
    int years = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      years--;
    }
    return years;
  }
}
