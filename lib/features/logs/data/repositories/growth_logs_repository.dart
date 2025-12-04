import 'package:tifli/features/logs/data/data_sources/growth_logs_data_source.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';

class GrowthLogRepository {
  final GrowthLogDataSource dataSource;

  GrowthLogRepository({required this.dataSource});

  Future<List<GrowthLog>> getLogs(String childId) =>
      dataSource.getLogs(childId);

  Future<GrowthLog> addLog(GrowthLog log) => dataSource.addLog(log);

  Future<GrowthLog> updateLog(String id, GrowthLog log) =>
      dataSource.updateLog(id, log);

  Future<void> deleteLog(String id) => dataSource.deleteLog(id);
}
