import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sleep.dart';

class SleepRepository {
  final SupabaseClient client;

  SleepRepository(this.client);

  Future<List<SleepLog>> getSleepLogs(String childId) async {
    final data = await client
        .from('sleep')
        .select()
        .eq('child_id', childId)
        .order('start_time', ascending: false);

    return (data as List)
        .map((e) => SleepLog.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSleep(SleepLog log) async {
    await client.from('sleep').insert(log.toMap());
  }

  Future<void> deleteSleep(String id) async {
    await client.from('sleep').delete().eq('id', id);
  }
}
