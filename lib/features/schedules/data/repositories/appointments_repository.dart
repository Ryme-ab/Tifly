import '../data_sources/appointments_remote_data_source.dart';
import '../models/appointment_model.dart';

class AppointmentsRepository {
  final AppointmentsDataSource dataSource;

  AppointmentsRepository({required this.dataSource});

  /// Get all appointments for a child
  Future<List<Appointment>> getAppointments(String childId) =>
      dataSource.getAppointments(childId);

  /// Get a single appointment by ID
  Future<Appointment?> getAppointment(String id, String childId) =>
      dataSource.getAppointmentById(id);

  /// Add a new appointment
  Future<Appointment> addAppointment(Appointment appointment) =>
      dataSource.addAppointment(appointment);

  /// Update an existing appointment
  Future<void> updateAppointment(Appointment appointment) =>
      dataSource.updateAppointment(appointment);

  /// Delete an appointment
  Future<void> deleteAppointment(String id, String childId) =>
      dataSource.deleteAppointment(id);
}
