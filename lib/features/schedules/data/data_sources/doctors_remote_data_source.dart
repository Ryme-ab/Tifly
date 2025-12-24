import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_model.dart';

class DoctorsDataSource {
  final SupabaseClient client;

  DoctorsDataSource({required this.client});

  Future<List<Doctor>> getDoctors() async {
    final data = await client
        .from('doctor')
        .select()
        .order('full_name', ascending: true);

    return (data as List).map((e) => Doctor.fromJson(e)).toList();
  }

  Future<Doctor> getDoctorById(String id) async {
    final data = await client
        .from('doctor')
        .select()
        .eq('id', id)
        .single();

    return Doctor.fromJson(data);
  }

  Future<Doctor> addDoctor(Doctor doctor) async {
    final response = await client
        .from('doctor')
        .insert(doctor.toJson())
        .select()
        .single();

    return Doctor.fromJson(response);
  }

  Future<void> updateDoctor(Doctor doctor) async {
    await client
        .from('doctor')
        .update(doctor.toJson())
        .eq('id', doctor.id);
  }

  Future<void> deleteDoctor(String id) async {
    await client.from('doctor').delete().eq('id', id);
  }
}
