import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/medication_log_model.dart';

class MedicationDataSource {
  final SupabaseClient client;

  MedicationDataSource({required this.client});

  // Get all medicines for a specific baby
  Future<List<Medication>> getMedicines(String userId, String babyId) async {
    final data = await client
        .from('medicines')
        .select()
        .eq('user_id', userId)
        .eq('baby_id', babyId)
        .order('created_at', ascending: false);

    return data.map<Medication>((row) => Medication.fromJson(row)).toList();
  }

  // Add a new medicine
  Future<Medication> addMedicine(Medication medicine) async {
    final response = await client
        .from('medicines')
        .insert(medicine.toJson())
        .select()
        .single();

    return Medication.fromJson(response);
  }

  // Update an existing medicine
  Future<Medication> updateMedicine(
    String id,
    String userId,
    Medication medicine,
  ) async {
    final response = await client
        .from('medicines')
        .update(medicine.toJson())
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return Medication.fromJson(response);
  }

  // Delete a medicine
  Future<void> deleteMedicine(String id, String userId) async {
    await client.from('medicines').delete().eq('id', id).eq('user_id', userId);
  }
}
