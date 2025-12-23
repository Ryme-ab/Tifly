import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class BabyLogsDataSource {
  final SupabaseClient client;

  BabyLogsDataSource({required this.client});

  Future<List<BabyLog>> getFilteredLogs({
    required String childId,
    LogType? type,
    DateTime? date,
    String? time, // "HH:mm"
  }) async {
    final allLogs = <BabyLog>[];

    // 🟦 helper for date filter
    bool matchDate(DateTime ts) {
      if (date == null) return true;
      return ts.year == date.year &&
          ts.month == date.month &&
          ts.day == date.day;
    }

    // 🟦 helper for time filter
    bool matchTime(DateTime ts) {
      if (time == null) return true;
      final t = "${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}";
      return t == time;
    }

    try {
      // ---------- FEEDING ----------
      if (type == null || type == LogType.feeding) {
        final data = await client
            .from('meals')
            .select()
            .eq('child_id', childId);

        for (final e in data) {
          final log = BabyLog.fromFeeding(e);
          if (matchDate(log.timestamp) && matchTime(log.timestamp)) {
            allLogs.add(log);
          }
        }
      }

      // ---------- SLEEP ----------
      if (type == null || type == LogType.sleep) {
        final data = await client
            .from('sleep')
            .select()
            .eq('child_id', childId);

        for (final e in data) {
          final log = BabyLog.fromSleep(e);
          if (matchDate(log.timestamp) && matchTime(log.timestamp)) {
            allLogs.add(log);
          }
        }
      }

      // ---------- MEDICATION ----------
      if (type == null || type == LogType.medication) {
        final data = await client
            .from('medicines')
            .select()
            .eq('baby_id', childId);

        for (final e in data) {
          final log = BabyLog.fromMedication(e);
          if (matchDate(log.timestamp) && matchTime(log.timestamp)) {
            allLogs.add(log);
          }
        }
      }

      // ---------- GROWTH ----------
      if (type == null || type == LogType.growth) {
        final data = await client
            .from('growth')
            .select()
            .eq('child_id', childId);

        for (final e in data) {
          final log = BabyLog.fromGrowth(e);
          if (matchDate(log.timestamp) && matchTime(log.timestamp)) {
            allLogs.add(log);
          }
        }
      }

      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allLogs;
    } catch (e) {
      throw Exception('Filter failed: $e');
    }
  }
}
