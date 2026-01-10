import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/medication_log_model.dart';
import 'package:tifli/features/logs/data/repositories/medication_log_repository.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'medication_log_state.dart';

class MedicationLogCubit extends Cubit<MedicationState> {
  final MedicationRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;

  late final StreamSubscription _childSelectionSubscription;

  MedicationLogCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(MedicationInitial()) {
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadMedicines();
      } else if (state is NoChildSelected) {
        emit(MedicationInitial());
      }
    });
  }

  Future<void> loadMedicines() async {
    try {
      final childState = childSelectionCubit.state;

      if (childState is! ChildSelected) {
        emit(MedicationError('No child selected'));
        return;
      }

      emit(MedicationLoading());
      final medicines = await repository.getMedicines(childState.childId);
      emit(MedicationLoaded(medicines));
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> addMedicine(Medication medicine) async {
    try {
      await repository.addMedicine(medicine);
      await loadMedicines();
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> updateMedicine(String id, Medication medicine) async {
    try {
      await repository.updateMedicine(id, medicine);
      await loadMedicines();
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await repository.deleteMedicine(id);
      await loadMedicines();
    } catch (e) {
      emit(MedicationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }

  void deleteMedication(String id) {}
}
