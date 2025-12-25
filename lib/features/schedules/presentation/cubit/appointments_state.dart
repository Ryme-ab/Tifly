

import 'package:tifli/features/schedules/data/models/appointment_model.dart';

abstract class AppointmentsState {}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<Appointment> appointments;

  AppointmentsLoaded(this.appointments);
}

class AppointmentLoaded extends AppointmentsState {
  final Appointment appointment;

  AppointmentLoaded(this.appointment);
}

class AppointmentsError extends AppointmentsState {
  final String message;

  AppointmentsError(this.message);
}
