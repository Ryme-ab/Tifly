import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/logs/data/repositories/medication_log_repository.dart';
import 'package:tifli/features/logs/data/models/medication_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_state.dart';

class MedicationCubit extends Cubit<MedicationState> {
  final MedicationRepository repo;
  String? currentBabyId;

  MedicationCubit({required this.repo}) : super(MedicationInitial());

  // Load all medications for a baby
  Future<void> loadMedications(String babyId) async {
    currentBabyId = babyId;
    emit(MedicationLoading());
    try {
      final meds = await repo.getMedicines(babyId);
      emit(MedicationLoaded(meds));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  // Add a new medication
  Future<void> addMedication(Medication med) async {
    try {
      await repo.addMedicine(med);
      if (currentBabyId != null) {
        await loadMedications(currentBabyId!);
      }
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  // Update existing medication
  Future<void> updateMedication(String id, Medication med) async {
    try {
      await repo.updateMedicine(id, med);
      if (currentBabyId != null) {
        await loadMedications(currentBabyId!);
      }
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  // Delete medication
  Future<void> deleteMedication(String id) async {
    try {
      await repo.deleteMedicine(id);
      if (currentBabyId != null) {
        await loadMedications(currentBabyId!);
      }
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }
}
