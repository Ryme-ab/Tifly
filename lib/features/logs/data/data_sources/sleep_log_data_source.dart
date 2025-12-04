import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';

class SleepLogDataSource {
  final SupabaseClient client;

  SleepLogDataSource({required this.client});

  Future<List<SleepLog>> getLogs(String childId) async {
    final data = await client
        .from('sleep')
        .select()
        .eq('child_id', childId)
        .order('created_at', ascending: false);

    return data.map<SleepLog>((row) => SleepLog.fromJson(row)).toList();
  }

  Future<SleepLog> addLog(SleepLog log) async {
    final response = await client
        .from('sleep')
        .insert(log.toJson())
        .select()
        .single();
    
    return SleepLog.fromJson(response);
  }

  Future<SleepLog> updateLog(String id, SleepLog log) async {
    final response = await client
        .from('sleep')
        .update(log.toJson())
        .eq('id', id)
        .select()
        .single();
    
    return SleepLog.fromJson(response);
  }

  Future<void> deleteLog(String id) async {
    await client.from('sleep').delete().eq('id', id);
  }
}
