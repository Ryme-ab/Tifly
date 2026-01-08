// create table public.medicine_schedules (
//   id uuid not null default gen_random_uuid (),
//   child_id uuid not null,
//   medicine_name text not null,
//   dosage_amount integer not null,
//   dosage_unit text not null,
//   frequency text not null,
//   times jsonb not null,
//   duration_value integer not null,
//   duration_unit text not null,
//   color text null,
//   notes text null,
//   start_date date not null default CURRENT_DATE,
//   end_date date not null,
//   created_at timestamp with time zone null default now(),
//   constraint medicine_schedules_pkey primary key (id)
// ) TABLESPACE pg_default;



import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment_model.dart';

class MEDECDataSource {
  final SupabaseClient client;

  MEDECDataSource({required this.client});

  Future<List<Appointment>> getMEDEC(String childId) async {
    final data = await client
        .from('MEDEC')
        .select()
        .eq('child_id', childId)
        .order('appointment_date', ascending: true);

    return (data as List).map((e) => Appointment.fromJson(e)).toList();
  }

  Future<Appointment> getAppointmentById(String id) async {
    final data = await client
        .from('MEDEC')
        .select()
        .eq('id', id)
        .single();

    return Appointment.fromJson(data);
  }

  Future<Appointment> addAppointment(Appointment appointment) async {
    final response = await client
        .from('MEDEC')
        .insert(appointment.toJson())
        .select()
        .single();

    return Appointment.fromJson(response);
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await client
        .from('MEDEC')
        .update(appointment.toJson())
        .eq('id', appointment.id);
  }

  Future<void> deleteAppointment(String id) async {
    await client.from('MEDEC').delete().eq('id', id);
  }
}
