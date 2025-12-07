import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';

class FeedingLogDataSource {
  final SupabaseClient client;

  FeedingLogDataSource({required this.client});

  Future<List<FeedingLog>> getLogs(String userId, String childId) async {
    final data = await client
        .from('meals')
        .select()
        .eq('user_id', userId)
        .eq('child_id', childId)
        .order('created_at', ascending: false);

    return data.map<FeedingLog>((row) => FeedingLog.fromJson(row)).toList();
  }

  Future<FeedingLog> addLog(FeedingLog log) async {
    final response = await client
        .from('meals')
        .insert(log.toJson())
        .select()
        .single();

    return FeedingLog.fromJson(response);
  }

  Future<FeedingLog> updateLog(String id, String userId, FeedingLog log) async {
    final response = await client
        .from('meals')
        .update(log.toJson())
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return FeedingLog.fromJson(response);
  }

  Future<void> deleteLog(String id, String userId) async {
    await client.from('meals').delete().eq('id', id).eq('user_id', userId);
  }
}
