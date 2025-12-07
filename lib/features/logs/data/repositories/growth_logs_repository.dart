import 'package:tifli/features/logs/data/data_sources/growth_logs_data_source.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';

class GrowthLogRepository {
  final GrowthLogDataSource dataSource;

  GrowthLogRepository({required this.dataSource});

  Future<List<GrowthLog>> getLogs(String userId, String childId) =>
      dataSource.getLogs(userId, childId);

  Future<GrowthLog> addLog(GrowthLog log) => dataSource.addLog(log);

  Future<GrowthLog> updateLog(String id, String userId, GrowthLog log) =>
      dataSource.updateLog(id, userId, log);

  Future<void> deleteLog(String id, String userId) =>
      dataSource.deleteLog(id, userId);
}
