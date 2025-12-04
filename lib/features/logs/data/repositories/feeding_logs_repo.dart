import 'package:tifli/features/logs/data/data_sources/feeding_logs_data.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';

class FeedingLogRepository {
  final FeedingLogDataSource dataSource;

  FeedingLogRepository({required this.dataSource});

  Future<List<FeedingLog>> getLogs(String childId) => dataSource.getLogs(childId);

  Future<FeedingLog> addLog(FeedingLog log) => dataSource.addLog(log);

  Future<FeedingLog> updateLog(String id, FeedingLog log) =>
      dataSource.updateLog(id, log);

  Future<void> deleteLog(String id) => dataSource.deleteLog(id);
}
