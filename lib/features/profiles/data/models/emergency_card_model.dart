import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';

class EmergencyCardModel extends EmergencyCard {
  const EmergencyCardModel({
    required super.id,
    required super.childId,
    required super.fullName,
    required super.dateOfBirth,
    super.photoUrl,
    required super.bloodType,
    super.allergies,
    super.chronicConditions,
    super.medications,
    required super.medicalContacts,
    required super.emergencyContacts,
    super.vaccinationSummary,
    super.medicalNotes,
    required super.healthIdentifiers,
    required super.updatedAt,
    super.syncStatus,
  });

  factory EmergencyCardModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCardModel(
      id: json['id'],
      childId: json['child_id'],
      fullName: json['full_name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      photoUrl: json['photo_url'],
      bloodType: json['blood_type'],
      allergies: List<String>.from(json['allergies'] ?? []),
      chronicConditions: json['chronic_conditions'],
      medications: (json['medications'] as List? ?? [])
          .map((m) => MedicationInfoModel.fromJson(m))
          .toList(),
      medicalContacts: MedicalContactsModel.fromJson(json['medical_contacts']),
      emergencyContacts:
          EmergencyContactsModel.fromJson(json['emergency_contacts']),
      vaccinationSummary: json['vaccination_summary'],
      medicalNotes: json['medical_notes'],
      healthIdentifiers:
          HealthIdentifiersModel.fromJson(json['health_identifiers']),
      updatedAt: DateTime.parse(json['updated_at']),
      syncStatus: json['sync_status'] ?? 'synced',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'photo_url': photoUrl,
      'blood_type': bloodType,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'medications':
          medications.map((m) => (m as MedicationInfoModel).toJson()).toList(),
      'medical_contacts': (medicalContacts as MedicalContactsModel).toJson(),
      'emergency_contacts':
          (emergencyContacts as EmergencyContactsModel).toJson(),
      'vaccination_summary': vaccinationSummary,
      'medical_notes': medicalNotes,
      'health_identifiers':
          (healthIdentifiers as HealthIdentifiersModel).toJson(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  factory EmergencyCardModel.fromEntity(EmergencyCard entity) {
    return EmergencyCardModel(
      id: entity.id,
      childId: entity.childId,
      fullName: entity.fullName,
      dateOfBirth: entity.dateOfBirth,
      photoUrl: entity.photoUrl,
      bloodType: entity.bloodType,
      allergies: entity.allergies,
      chronicConditions: entity.chronicConditions,
      medications: entity.medications
          .map((m) => MedicationInfoModel(name: m.name, dosage: m.dosage))
          .toList(),
      medicalContacts: MedicalContactsModel(
        doctorName: entity.medicalContacts.doctorName,
        doctorPhone: entity.medicalContacts.doctorPhone,
        hospitalName: entity.medicalContacts.hospitalName,
        emergencyNumber: entity.medicalContacts.emergencyNumber,
      ),
      emergencyContacts: EmergencyContactsModel(
        primaryName: entity.emergencyContacts.primaryName,
        primaryPhone: entity.emergencyContacts.primaryPhone,
        secondaryName: entity.emergencyContacts.secondaryName,
        secondaryPhone: entity.emergencyContacts.secondaryPhone,
      ),
      vaccinationSummary: entity.vaccinationSummary,
      medicalNotes: entity.medicalNotes,
      healthIdentifiers: HealthIdentifiersModel(
        insuranceNumber: entity.healthIdentifiers.insuranceNumber,
        nationalId: entity.healthIdentifiers.nationalId,
      ),
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }
}

class MedicationInfoModel extends MedicationInfo {
  const MedicationInfoModel({required super.name, required super.dosage});

  factory MedicationInfoModel.fromJson(Map<String, dynamic> json) {
    return MedicationInfoModel(
      name: json['name'],
      dosage: json['dosage'],
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'dosage': dosage};
}

class MedicalContactsModel extends MedicalContacts {
  const MedicalContactsModel({
    super.doctorName,
    super.doctorPhone,
    super.hospitalName,
    super.emergencyNumber,
  });

  factory MedicalContactsModel.fromJson(Map<String, dynamic> json) {
    return MedicalContactsModel(
      doctorName: json['doctor_name'],
      doctorPhone: json['doctor_phone'],
      hospitalName: json['hospital_name'],
      emergencyNumber: json['emergency_number'],
    );
  }

  Map<String, dynamic> toJson() => {
        'doctor_name': doctorName,
        'doctor_phone': doctorPhone,
        'hospital_name': hospitalName,
        'emergency_number': emergencyNumber,
      };
}

class EmergencyContactsModel extends EmergencyContacts {
  const EmergencyContactsModel({
    required super.primaryName,
    required super.primaryPhone,
    super.secondaryName,
    super.secondaryPhone,
  });

  factory EmergencyContactsModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactsModel(
      primaryName: json['primary_name'],
      primaryPhone: json['primary_phone'],
      secondaryName: json['secondary_name'],
      secondaryPhone: json['secondary_phone'],
    );
  }

  Map<String, dynamic> toJson() => {
        'primary_name': primaryName,
        'primary_phone': primaryPhone,
        'secondary_name': secondaryName,
        'secondary_phone': secondaryPhone,
      };
}

class HealthIdentifiersModel extends HealthIdentifiers {
  const HealthIdentifiersModel({super.insuranceNumber, super.nationalId});

  factory HealthIdentifiersModel.fromJson(Map<String, dynamic> json) {
    return HealthIdentifiersModel(
      insuranceNumber: json['insurance_number'],
      nationalId: json['national_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'insurance_number': insuranceNumber,
        'national_id': nationalId,
      };
}
