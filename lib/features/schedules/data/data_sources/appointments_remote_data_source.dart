import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class AppointmentsDataSource {
  final SupabaseClient client;

  AppointmentsDataSource({required this.client});

  Future<List<Appointment>> getAppointments(String childId) async {
    final data = await client
        .from('appointments')
        .select()
        .eq('child_id', childId)
        .order('appointment_date', ascending: true);

    return (data as List).map((e) => Appointment.fromJson(e)).toList();
  }

  Future<Appointment> getAppointmentById(String id) async {
    final data = await client
        .from('appointments')
        .select()
        .eq('id', id)
        .single();

    return Appointment.fromJson(data);
  }

  Future<Appointment> addAppointment(Appointment appointment) async {
    final response = await client
        .from('appointments')
        .insert(appointment.toJson())
        .select()
        .single();

    return Appointment.fromJson(response);
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await client
        .from('appointments')
        .update(appointment.toJson())
        .eq('id', appointment.id);
  }

  Future<void> deleteAppointment(String id) async {
    await client.from('appointments').delete().eq('id', id);
  }
}
