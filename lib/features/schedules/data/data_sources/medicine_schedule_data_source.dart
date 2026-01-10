import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medicine_model.dart';

class MedicineScheduleDataSource {
  final SupabaseClient client;

  MedicineScheduleDataSource({required this.client});

  Future<List<MedicineSchedule>> getSchedules(String babyId) async {
    final data = await client
        .from('medicine_schedules')
        .select()
        .eq('baby_id', babyId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => MedicineSchedule.fromJson(e)).toList();
  }

  Future<void> addSchedule(MedicineSchedule schedule) async {
    await client.from('medicine_schedules').insert(schedule.toJson());
  }
  
  Future<void> deleteSchedule(String id) async {
    await client.from('medicine_schedules').delete().eq('id', id);
  }
}
