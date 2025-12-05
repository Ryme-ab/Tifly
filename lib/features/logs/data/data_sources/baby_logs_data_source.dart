import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class BabyLogsDataSource {
  final SupabaseClient client;

  BabyLogsDataSource({required this.client});

  Future<List<BabyLog>> getAllLogs(String childId) async {
    final allLogs = <BabyLog>[];

    try {
      // Fetch feeding logs
      final mealsData = await client
          .from('meals')
          .select()
          .eq('child_id', childId)
          .order('meal_time', ascending: false)
          .limit(50);

      for (final meal in mealsData) {
        allLogs.add(BabyLog.fromFeeding(meal));
      }

      // Fetch sleep logs
      final sleepData = await client
          .from('sleep')
          .select()
          .eq('child_id', childId)
          .order('start_time', ascending: false)
          .limit(50);

      for (final sleep in sleepData) {
        allLogs.add(BabyLog.fromSleep(sleep));
      }

      // Fetch medication logs
      final healthData = await client
          .from('medicines')
          .select()
          .eq('baby_id', childId)
          .order('created_at', ascending: false)
          .limit(50);

      for (final health in healthData) {
        allLogs.add(BabyLog.fromMedication(health));
      }

      // Try to fetch growth logs (optional)
      try {
        final growthData = await client
            .from('growth')
            .select()
            .eq('child_id', childId)
            .order('date', ascending: false)
            .limit(20);

        for (final growth in growthData) {
          allLogs.add(BabyLog.fromGrowth(growth));
        }
      } catch (e) {
        // Growth table might not exist
      }

      // Sort all logs by timestamp (most recent first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      throw Exception('Failed to fetch baby logs: $e');
    }
  }

  Future<List<BabyLog>> getLogsByType(String childId, LogType type) async {
    try {
      switch (type) {
        case LogType.feeding:
          final data = await client
              .from('meals')
              .select()
              .eq('child_id', childId)
              .order('meal_time', ascending: false);
          return data.map<BabyLog>((e) => BabyLog.fromFeeding(e)).toList();

        case LogType.sleep:
          final data = await client
              .from('sleep')
              .select()
              .eq('child_id', childId)
              .order('start_time', ascending: false);
          return data.map<BabyLog>((e) => BabyLog.fromSleep(e)).toList();

        case LogType.medication:
          final data = await client
              .from('medication')
              .select()
              .eq('baby_id', childId)
              .order('created_at', ascending: false);
          return data.map<BabyLog>((e) => BabyLog.fromMedication(e)).toList();

        case LogType.growth:
          final data = await client
              .from('growth')
              .select()
              .eq('child_id', childId)
              .order('date', ascending: false);
          return data.map<BabyLog>((e) => BabyLog.fromGrowth(e)).toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch logs by type: $e');
    }
  }
}
