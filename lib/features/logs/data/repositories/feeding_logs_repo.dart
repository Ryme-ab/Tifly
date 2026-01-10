import 'package:tifli/features/logs/data/data_sources/feeding_logs_data.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';

class FeedingLogRepository {
  final FeedingLogDataSource dataSource;

  FeedingLogRepository({required this.dataSource});

  Future<List<FeedingLog>> getLogs(String userId, String childId) =>
      dataSource.getLogs(userId, childId);

  Future<FeedingLog> addLog(FeedingLog log) => dataSource.addLog(log);

  Future<FeedingLog> updateLog(String id, String userId, FeedingLog log) =>
      dataSource.updateLog(id, userId, log);

  Future<void> deleteLog(String id, String userId) =>
      dataSource.deleteLog(id, userId);

  Future<List<FeedingLog>> filterLogs({
    required String userId,
    required String childId,
    DateTime? date,
    String? time,
    String? category,
  }) async {
    final logs = await dataSource.getLogs(userId, childId);
    return logs.where((log) {
      final matchesDate =
          date == null ||
          (log.mealTime.year == date.year &&
              log.mealTime.month == date.month &&
              log.mealTime.day == date.day);
      final matchesTime =
          time == null ||
          log.mealTime.toIso8601String().substring(11, 16) == time;
      final matchesCategory = category == null || log.mealType == category;
      return matchesDate && matchesTime && matchesCategory;
    }).toList();
  }
}
