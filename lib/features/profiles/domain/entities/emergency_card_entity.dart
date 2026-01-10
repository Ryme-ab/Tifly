import 'package:equatable/equatable.dart';

class EmergencyCard extends Equatable {
  final String id;
  final String childId;
  final String fullName;
  final DateTime dateOfBirth;
  final String? photoUrl;
  final String bloodType;
  final List<String> allergies;
  final String? chronicConditions;
  final List<MedicationInfo> medications;
  final MedicalContacts medicalContacts;
  final EmergencyContacts emergencyContacts;
  final String? vaccinationSummary;
  final String? medicalNotes;
  final HealthIdentifiers healthIdentifiers;
  final DateTime updatedAt;
  final String syncStatus; // synced | pending | failed

  const EmergencyCard({
    required this.id,
    required this.childId,
    required this.fullName,
    required this.dateOfBirth,
    this.photoUrl,
    required this.bloodType,
    this.allergies = const [],
    this.chronicConditions,
    this.medications = const [],
    required this.medicalContacts,
    required this.emergencyContacts,
    this.vaccinationSummary,
    this.medicalNotes,
    required this.healthIdentifiers,
    required this.updatedAt,
    this.syncStatus = 'pending',
  });

  @override
  List<Object?> get props => [
        id,
        childId,
        fullName,
        dateOfBirth,
        photoUrl,
        bloodType,
        allergies,
        chronicConditions,
        medications,
        medicalContacts,
        emergencyContacts,
        vaccinationSummary,
        medicalNotes,
        healthIdentifiers,
        updatedAt,
        syncStatus,
      ];
}

class MedicationInfo extends Equatable {
  final String name;
  final String dosage;

  const MedicationInfo({required this.name, required this.dosage});

  @override
  List<Object?> get props => [name, dosage];
}

class MedicalContacts extends Equatable {
  final String? doctorName;
  final String? doctorPhone;
  final String? hospitalName;
  final String? emergencyNumber;

  const MedicalContacts({
    this.doctorName,
    this.doctorPhone,
    this.hospitalName,
    this.emergencyNumber,
  });

  @override
  List<Object?> get props =>
      [doctorName, doctorPhone, hospitalName, emergencyNumber];
}

class EmergencyContacts extends Equatable {
  final String primaryName;
  final String primaryPhone;
  final String? secondaryName;
  final String? secondaryPhone;

  const EmergencyContacts({
    required this.primaryName,
    required this.primaryPhone,
    this.secondaryName,
    this.secondaryPhone,
  });

  @override
  List<Object?> get props =>
      [primaryName, primaryPhone, secondaryName, secondaryPhone];
}

class HealthIdentifiers extends Equatable {
  final String? insuranceNumber;
  final String? nationalId;

  const HealthIdentifiers({this.insuranceNumber, this.nationalId});

  @override
  List<Object?> get props => [insuranceNumber, nationalId];
}
