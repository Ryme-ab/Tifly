import 'package:tifli/features/logs/data/models/medication_log_model.dart';

abstract class MedicationState {}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<Medication> medicines;

  MedicationLoaded(this.medicines);
}

class MedicationError extends MedicationState {
  final String message;

  MedicationError(this.message);
}
