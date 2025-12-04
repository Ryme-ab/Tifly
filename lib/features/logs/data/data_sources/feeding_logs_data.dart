import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';

class FeedingLogDataSource {
  final SupabaseClient client;

  FeedingLogDataSource({required this.client});

  Future<List<FeedingLog>> getLogs(String childId) async {
    final data = await client
        .from('meals')
        .select()
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

  Future<FeedingLog> updateLog(String id, FeedingLog log) async {
    final response = await client
        .from('meals')
        .update(log.toJson())
        .eq('id', id)
        .select()
        .single();
    
    return FeedingLog.fromJson(response);
  }

  Future<void> deleteLog(String id) async {
    await client.from('meals').delete().eq('id', id);
  }
}
