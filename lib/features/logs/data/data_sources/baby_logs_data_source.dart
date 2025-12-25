import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class BabyLogsDataSource {
  final SupabaseClient client;

  BabyLogsDataSource({required this.client});

  Future<List<BabyLog>> getAllLogs(String childId) async {
    return getFilteredLogs(childId: childId);
  }

  /// Enhanced filtering method with support for type, date, time, and date range
  Future<List<BabyLog>> getFilteredLogs({
    required String childId,
    LogType? type,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? time,
  }) async {
    final allLogs = <BabyLog>[];

    try {
      // Determine which log types to fetch
      final typesToFetch = type != null ? [type] : LogType.values;

      for (final logType in typesToFetch) {
        switch (logType) {
          case LogType.feeding:
            final logs = await _fetchFeedingLogs(
              childId,
              date: date,
              startDate: startDate,
              endDate: endDate,
              time: time,
            );
            allLogs.addAll(logs);
            break;

          case LogType.sleep:
            final logs = await _fetchSleepLogs(
              childId,
              date: date,
              startDate: startDate,
              endDate: endDate,
              time: time,
            );
            allLogs.addAll(logs);
            break;

          case LogType.medication:
            final logs = await _fetchMedicationLogs(
              childId,
              date: date,
              startDate: startDate,
              endDate: endDate,
              time: time,
            );
            allLogs.addAll(logs);
            break;

          case LogType.growth:
            try {
              final logs = await _fetchGrowthLogs(
                childId,
                date: date,
                startDate: startDate,
                endDate: endDate,
              );
              allLogs.addAll(logs);
            } catch (e) {
              // Growth table might not exist
            }
            break;
        }
      }

      // Sort all logs by timestamp (most recent first)
      allLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allLogs;
    } catch (e) {
      throw Exception('Failed to fetch filtered logs: $e');
    }
  }

  Future<List<BabyLog>> _fetchFeedingLogs(
    String childId, {
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? time,
  }) async {
    var query = client.from('meals').select().eq('child_id', childId);

    // Apply date filters
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('meal_time', startOfDay.toIso8601String())
          .lt('meal_time', endOfDay.toIso8601String());
    } else if (startDate != null && endDate != null) {
      query = query
          .gte('meal_time', startDate.toIso8601String())
          .lte('meal_time', endDate.toIso8601String());
    }

    final data = await query.order('meal_time', ascending: false).limit(100);
    final logs = data.map<BabyLog>((e) => BabyLog.fromFeeding(e)).toList();

    // Apply time filter in memory if specified
    if (time != null) {
      return _filterByTime(logs, time);
    }

    return logs;
  }

  Future<List<BabyLog>> _fetchSleepLogs(
    String childId, {
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? time,
  }) async {
    var query = client.from('sleep').select().eq('child_id', childId);

    // Apply date filters
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String());
    } else if (startDate != null && endDate != null) {
      query = query
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String());
    }

    final data = await query.order('start_time', ascending: false).limit(100);
    final logs = data.map<BabyLog>((e) => BabyLog.fromSleep(e)).toList();

    // Apply time filter in memory if specified
    if (time != null) {
      return _filterByTime(logs, time);
    }

    return logs;
  }

  Future<List<BabyLog>> _fetchMedicationLogs(
    String childId, {
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? time,
  }) async {
    var query = client.from('medicines').select().eq('baby_id', childId);

    // Apply date filters
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());
    } else if (startDate != null && endDate != null) {
      query = query
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());
    }

    final data = await query.order('created_at', ascending: false).limit(100);
    final logs = data.map<BabyLog>((e) => BabyLog.fromMedication(e)).toList();

    // Apply time filter in memory if specified
    if (time != null) {
      return _filterByTime(logs, time);
    }

    return logs;
  }

  Future<List<BabyLog>> _fetchGrowthLogs(
    String childId, {
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = client.from('growth').select().eq('child_id', childId);

    // Apply date filters
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .gte('date', startOfDay.toIso8601String())
          .lt('date', endOfDay.toIso8601String());
    } else if (startDate != null && endDate != null) {
      query = query
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
    }

    final data = await query.order('date', ascending: false).limit(50);
    return data.map<BabyLog>((e) => BabyLog.fromGrowth(e)).toList();
  }

  /// Filter logs by time of day (HH:mm format)
  List<BabyLog> _filterByTime(List<BabyLog> logs, String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return logs;

      final targetHour = int.parse(parts[0]);
      final targetMinute = int.parse(parts[1]);

      return logs.where((log) {
        final hour = log.timestamp.hour;
        final minute = log.timestamp.minute;
        // Match within 30 minutes window
        final minuteDiff =
            (hour * 60 + minute) - (targetHour * 60 + targetMinute);
        return minuteDiff.abs() <= 30;
      }).toList();
    } catch (e) {
      return logs;
    }
  }

  Future<List<BabyLog>> getLogsByType(String childId, LogType type) async {
    return getFilteredLogs(childId: childId, type: type);
  }
}