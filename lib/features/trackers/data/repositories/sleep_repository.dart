import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';

class SleepRepository {
  final SupabaseClient client;

  SleepRepository(this.client);

  /// Load all sleep logs for a specific child
  Future<List<SleepLog>> getSleepLogs(String childId) async {
    final data = await client
        .from('sleep')
        .select()
        .eq('child_id', childId)
        .order('start_time', ascending: false);

    return (data as List)
        .map((row) => SleepLog.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Check if a similar sleep log exists (duplicate)
  Future<bool> checkDuplicate({
    required String childId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final result = await client
        .from('sleep')
        .select('id')
        .eq('child_id', childId)
        .eq('start_time', startTime.toIso8601String())
        .eq('end_time', endTime.toIso8601String());

    return result.isNotEmpty;
  }

  /// Insert a new sleep log
  Future<void> addSleep(SleepLog log) async {
    await client.from('sleep').insert(log.toJson());
  }

  /// Delete a sleep record
  Future<void> deleteSleep(String id) async {
    await client.from('sleep').delete().eq('id', id);
  }
  /// Update a sleep record
  Future<void> updateSleep(SleepLog log) async {
    await client
        .from('sleep')
        .update(log.toJson())
        .eq('id', log.id)
        .eq('user_id', log.userId);
  }
}
