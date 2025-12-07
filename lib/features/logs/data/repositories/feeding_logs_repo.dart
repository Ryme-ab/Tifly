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
}
