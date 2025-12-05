import 'package:tifli/features/logs/data/data_sources/sleep_log_data_source.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';

class SleepLogRepository {
  final SleepLogDataSource dataSource;

  SleepLogRepository({required this.dataSource});

  Future<List<SleepLog>> getLogs(String userId, String childId) => dataSource.getLogs(userId, childId);

  Future<SleepLog> addLog(SleepLog log) => dataSource.addLog(log);

  Future<SleepLog> updateLog(String id, String userId, SleepLog log) =>
      dataSource.updateLog(id, userId, log);

  Future<void> deleteLog(String id, String userId) => dataSource.deleteLog(id, userId);
}
