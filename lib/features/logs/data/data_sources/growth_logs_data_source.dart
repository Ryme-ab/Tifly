import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';

class GrowthLogDataSource {
  final SupabaseClient client;

  GrowthLogDataSource({required this.client});

  Future<List<GrowthLog>> getLogs(String userId, String childId) async {
    final data = await client
        .from('growth')
        .select()
        .eq('user_id', userId)
        .eq('child_id', childId)
        .order('created_at', ascending: false);

    return data.map<GrowthLog>((row) => GrowthLog.fromJson(row)).toList();
  }

  Future<GrowthLog> addLog(GrowthLog log) async {
    final response = await client
        .from('growth')
        .insert(log.toJson())
        .select()
        .single();

    return GrowthLog.fromJson(response);
  }

  Future<GrowthLog> updateLog(String id, String userId, GrowthLog log) async {
    final response = await client
        .from('growth')
        .update(log.toJson())
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return GrowthLog.fromJson(response);
  }

  Future<void> deleteLog(String id, String userId) async {
    await client.from('growth').delete().eq('id', id).eq('user_id', userId);
  }
}
