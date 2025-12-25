import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/doctors_repository.dart';

// States
abstract class DoctorsState {}

class DoctorsInitial extends DoctorsState {}

class DoctorsLoading extends DoctorsState {}

class DoctorsLoaded extends DoctorsState {
  final List<Doctor> doctors;

  DoctorsLoaded(this.doctors);
}

class DoctorLoaded extends DoctorsState {
  final Doctor doctor;

  DoctorLoaded(this.doctor);
}

class DoctorsError extends DoctorsState {
  final String message;

  DoctorsError(this.message);
}

// Cubit
class DoctorsCubit extends Cubit<DoctorsState> {
  final DoctorsRepository repository;

  DoctorsCubit({required this.repository}) : super(DoctorsInitial());

  Future<void> loadDoctors() async {
    try {
      emit(DoctorsLoading());
      final doctors = await repository.fetchDoctors();
      emit(DoctorsLoaded(doctors));
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }

  Future<void> loadDoctorById(String id) async {
    try {
      emit(DoctorsLoading());
      final doctor = await repository.fetchDoctorById(id);
      emit(DoctorLoaded(doctor));
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }

  Future<void> addDoctor(Doctor doctor) async {
    try {
      emit(DoctorsLoading());
      await repository.addDoctor(doctor);
      // Reload all doctors
      await loadDoctors();
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }

  Future<void> updateDoctor(Doctor doctor) async {
    try {
      emit(DoctorsLoading());
      await repository.updateDoctor(doctor);
      // Reload all doctors
      await loadDoctors();
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      emit(DoctorsLoading());
      await repository.deleteDoctor(id);
      // Reload all doctors
      await loadDoctors();
    } catch (e) {
      emit(DoctorsError(e.toString()));
    }
  }
}
