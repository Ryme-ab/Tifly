import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/features/schedules/data/models/medicine_model.dart';
import 'package:tifli/features/schedules/domain/repositories/medicine_schedule_repository.dart';

abstract class MedicineScheduleState {}

class MedicineScheduleInitial extends MedicineScheduleState {}

class MedicineScheduleLoading extends MedicineScheduleState {}

class MedicineScheduleLoaded extends MedicineScheduleState {
  final List<MedicineSchedule> schedules;
  MedicineScheduleLoaded(this.schedules);
}

class MedicineScheduleError extends MedicineScheduleState {
  final String message;
  MedicineScheduleError(this.message);
}

class MedicineScheduleCubit extends Cubit<MedicineScheduleState> {
  final MedicineScheduleRepository repository;

  MedicineScheduleCubit({required this.repository}) : super(MedicineScheduleInitial());

  Future<void> loadSchedules(String babyId) async {
    emit(MedicineScheduleLoading());
    try {
      final schedules = await repository.getSchedules(babyId);
      emit(MedicineScheduleLoaded(schedules));
    } catch (e) {
      emit(MedicineScheduleError(e.toString()));
    }
  }

  Future<void> deleteSchedule(String id, String babyId) async {
    try {
      await repository.deleteSchedule(id);
      loadSchedules(babyId); // Reload after delete
    } catch (e) {
      emit(MedicineScheduleError(e.toString()));
    }
  }
}
