import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/schedules/data/models/appointment_model.dart';
import 'package:tifli/features/schedules/data/repositories/appointments_repository.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/schedules/presentation/cubit/appointments_state.dart';


class AppointmentsCubit extends Cubit<AppointmentsState> {
  final AppointmentsRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;

  late final StreamSubscription _childSelectionSubscription;

  AppointmentsCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(AppointmentsInitial()) {
    // Listen to child selection changes and auto-reload
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadAppointments();
      } else if (state is NoChildSelected) {
        emit(AppointmentsInitial());
      }
    });
  }

  /// Load all appointments for the currently selected child
  Future<void> loadAppointments() async {
    try {
      final childState = childSelectionCubit.state;

      if (childState is! ChildSelected) {
        emit(AppointmentsError('No child selected'));
        return;
      }

      emit(AppointmentsLoading());
      final appointments = await repository.getAppointments(childState.childId);
      emit(AppointmentsLoaded(appointments));
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  /// Load a single appointment by ID
  Future<void> loadAppointment(String appointmentId, String childId) async {
    try {
      emit(AppointmentsLoading());
      final appointment = await repository.getAppointment(appointmentId, childId);
      if (appointment != null) {
        emit(AppointmentLoaded(appointment));
      } else {
        emit(AppointmentsError('Appointment not found'));
      }
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  /// Add a new appointment (childId will be auto-filled from ChildSelectionCubit)
  Future<void> addAppointment(Appointment appointment) async {
    try {
      final childState = childSelectionCubit.state;

      if (childState is! ChildSelected) {
        emit(AppointmentsError('No child selected'));
        return;
      }

      // Create appointment with the selected childId
      final appointmentWithChild = appointment.copyWith(
        childId: childState.childId,
      );

      await repository.addAppointment(appointmentWithChild);
      await loadAppointments(); // Reload the list
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  /// Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) async {
    try {
      await repository.updateAppointment(appointment);
      await loadAppointments(); // Reload the list
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  /// Delete an appointment
  Future<void> deleteAppointment(String appointmentId, String childId) async {
    try {
      await repository.deleteAppointment(appointmentId, childId);
      await loadAppointments(); // Reload the list
    } catch (e) {
      emit(AppointmentsError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }
}
