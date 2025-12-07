import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';

class GrowthRepository {
  final SupabaseClient client;

  GrowthRepository(this.client);

  Future<List<GrowthLog>> getGrowthLogs(String childId) async {
    final data = await client
        .from('growth')
        .select()
        .eq('child_id', childId)
        .order('date', ascending: false);

    return (data as List)
        .map((e) => GrowthLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGrowth(GrowthLog log) async {
    await client.from('growth').insert(log.toJson());
  }

  Future<void> deleteGrowth(String id) async {
    await client.from('growth').delete().eq('id', id);
  }

  Future<bool> checkDuplicate({
    required String childId,
    required DateTime date,
    required double height,
    required double weight,
    required double headCircumference,
  }) async {
    try {
      final duplicate = await client
          .from('growth')
          .select('id')
          .eq('child_id', childId)
          .eq('date', date.toIso8601String())
          .eq('height', height)
          .eq('weight', weight)
          .eq('head_circumference', headCircumference)
          .maybeSingle();

      return duplicate != null;
    } catch (e) {
      print("Error checking duplicate: $e");
      return false;
    }
  }

  Future<void> updateGrowth(GrowthLog log) async {
    await client
        .from('growth')
        .update(log.toJson())
        .eq('id', log.id)
        .eq('user_id', log.userId);
  }
}
