import 'package:equatable/equatable.dart';

class ChildModel extends Equatable {
  final String id;
  final String firstName;
  final DateTime birthDate;
  final String? gender;
  final String? profileImage;

  ChildModel({
    required this.id,
    required this.firstName,
    required this.birthDate,
    this.gender,
    this.profileImage,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      firstName: json['first_name'],
      birthDate: DateTime.parse(json['birth_date']),
      gender: json['gender'],
      profileImage: json['profile_image'],
    );
  }

  @override
  List<Object?> get props => [id, firstName, birthDate];
}
